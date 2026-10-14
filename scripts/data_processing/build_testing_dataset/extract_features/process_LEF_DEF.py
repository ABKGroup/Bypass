import os
import csv
import math
import time
import json
import argparse
from collections import defaultdict, deque
from multiprocessing import Pool, cpu_count

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", ".."))
INVS_IN = os.environ.get("INVS_INPUTS", REPO + "/scripts/invs_scripts/tech")

CFG = {
    "dbu": 2000,
    "lef_json": REPO + "/data/configs/ng45_lef_geometry.json",
    "lefs": [INVS_IN + "/ng45/lef/NangateOpenCellLibrary.macro.mod.lef"]
            + sorted(__import__("glob").glob(INVS_IN + "/ng45/lef/fakeram45_*.lef")),
}

# Sort key of a DEF point, so that the order of the points is the same in every run. #
def _point_sort_key(pt):
    if isinstance(pt, tuple) and len(pt) >= 2 and isinstance(pt[0], str):
        if pt[0] == 'split':
            return (pt[1][0], pt[1][1], 2)
        return (pt[1][0], pt[1][1], 1)   # ('virtual', (x,y))
    return (pt[0], pt[1], 0)

def _get_coords(pt):
    if isinstance(pt, tuple) and len(pt) >= 2 and isinstance(pt[0], str):
        return pt[1]   # ('virtual',(x,y)) or ('split',(x,y),frozenset)
    return pt

# Metal layer of the wire between two points, or None if the pair is unknown. #
def _lookup_layer(point_pair_layer, a, b):
    for key in [(a, b), (b, a),
                (_get_coords(a), _get_coords(b)),
                (_get_coords(b), _get_coords(a))]:
        layer = point_pair_layer.get(key)
        if layer is not None:
            return layer
    return None

# Read the LEF geometry from the JSON file. Returns cells, tech_vias and viarules. #
def load_lef_json(json_path):
    with open(json_path, "r") as f:
        raw = json.load(f)

    cells = {}
    for cell_name, pin_map in raw.get("cells", {}).items():
        rebuilt = {}
        for key, value in pin_map.items():
            if key == "_size":
                rebuilt["_size"] = tuple(value)
            else:
                rebuilt[key] = [(layer, tuple(rect)) for layer, rect in value]
        cells[cell_name] = rebuilt

    tech_vias = {}
    for via_name, layer_list in raw.get("vias", {}).items():
        tech_vias[via_name] = [(layer, tuple(rect)) for layer, rect in layer_list]

    # A rule with rectangles and no via of the same name is also registered as a via #
    viarules = {}
    for rule_name, rule_data in raw.get("viarules", {}).items():
        layers = []
        via_layers = []
        for lyr in rule_data.get("layers", []):
            entry = {"name": lyr["name"]}
            if "enclosure" in lyr:
                entry["enclosure"] = tuple(lyr["enclosure"])
            if "rect" in lyr:
                entry["rect"] = tuple(lyr["rect"])
                via_layers.append((lyr["name"], tuple(lyr["rect"])))
            if "spacing" in lyr:
                entry["spacing"] = tuple(lyr["spacing"])
            layers.append(entry)
        viarules[rule_name] = {"name": rule_data.get("name", rule_name), "layers": layers}
        if rule_name not in tech_vias and via_layers:
            tech_vias[rule_name] = via_layers

    return cells, tech_vias, viarules

# Replace each "*" of a DEF wire path by the coordinate of the previous point. #
def expand_star_points(points):
    last_x = last_y = None
    new_points = []
    for x, y in points:
        if x is None:
            x = last_x
        if y is None:
            y = last_y
        new_points.append((x, y))
        last_x, last_y = x, y
    return new_points

# Read the DEF. Returns components, top_pins and nets (pins, USE and the routed wire segments). #
def parse_def(def_path):
    components = {}
    top_pins = {}
    nets = {}

    section = None
    comp_buf = ""

    cur_pin = None
    cur_pin_layer = None
    cur_pin_rects = []
    cur_pin_x = 0
    cur_pin_y = 0
    cur_pin_orient = "N"
    cur_pin_dir = None

    cur_net = None

    with open(def_path, "r") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue

            if line.startswith("COMPONENTS") and section is None:
                section = "COMPONENTS"
                continue
            if line.startswith("END COMPONENTS"):
                section = None
                comp_buf = ""
                continue

            if line.startswith("PINS") and section is None:
                section = "PINS"
                continue
            if line.startswith("END PINS"):
                if cur_pin is not None:
                    top_pins[cur_pin] = {
                        "rects": cur_pin_rects,
                        "x": cur_pin_x,
                        "y": cur_pin_y,
                        "orient": cur_pin_orient,
                        "direction": cur_pin_dir,
                    }
                    cur_pin = None
                section = None
                continue

            if line.startswith("NETS") and section is None:
                section = "NETS"
                continue
            if line.startswith("END NETS"):
                cur_net = None
                section = None
                continue

            if section == "COMPONENTS":
                if line.startswith("-") or comp_buf:
                    comp_buf += " " + line
                    if ";" in line:
                        tokens = comp_buf.replace(";", " ").split()
                        if len(tokens) >= 3 and tokens[0] == "-":
                            inst_name = tokens[1]
                            inst_name = inst_name.replace("$", r"\$")
                            inst_name = inst_name.replace(".", r"\.")
                            macro_name = tokens[2]
                            x = y = orient = None
                            for i, tok in enumerate(tokens):
                                if tok == "(" and i + 3 < len(tokens):
                                    try:
                                        x = int(tokens[i + 1])
                                        y = int(tokens[i + 2])
                                        if i + 4 < len(tokens):
                                            orient = tokens[i + 4]
                                    except ValueError:
                                        pass
                            if x is not None and y is not None and orient is not None:
                                components[inst_name] = {
                                    "macro": macro_name,
                                    "x": x,
                                    "y": y,
                                    "orient": orient,
                                }
                        comp_buf = ""
                continue

            if section == "PINS":
                if line.startswith("-") and cur_pin is None:
                    tokens = line.split()
                    if len(tokens) >= 2:
                        cur_pin = tokens[1]
                        cur_pin = cur_pin.replace(".", r"\.")
                        cur_pin_rects = []
                        cur_pin_layer = None
                        cur_pin_x = 0
                        cur_pin_y = 0
                        cur_pin_orient = "N"
                        cur_pin_dir = None
                    continue

                if cur_pin is None:
                    continue

                tokens = line.split()
                i = 0
                while i < len(tokens):
                    tok = tokens[i]
                    if tok == "LAYER" and i + 1 < len(tokens):
                        cur_pin_layer = tokens[i + 1]
                        i += 2
                    elif tok == "(" and cur_pin_layer is not None:
                        if (i + 7 < len(tokens) and tokens[i + 3] == ")" and
                                tokens[i + 4] == "(" and tokens[i + 7] == ")"):
                            try:
                                x1 = int(tokens[i + 1])
                                y1 = int(tokens[i + 2])
                                x2 = int(tokens[i + 5])
                                y2 = int(tokens[i + 6])
                                cur_pin_rects.append(
                                    (cur_pin_layer, (x1, y1, x2, y2))
                                )
                                i += 8
                                continue
                            except ValueError:
                                pass
                        i += 1
                    elif tok == "DIRECTION" and i + 1 < len(tokens):
                        cur_pin_dir = tokens[i + 1]
                        i += 2
                    elif tok in ("PLACED", "FIXED", "COVER") and i + 3 < len(tokens) and tokens[i + 1] == "(":   # swerv writes its ports as FIXED
                        try:
                            cur_pin_x = int(tokens[i + 2])
                            cur_pin_y = int(tokens[i + 3])
                            if i + 5 < len(tokens) and tokens[i + 4] == ")":
                                cur_pin_orient = tokens[i + 5]
                                i += 6
                                continue
                        except (ValueError, IndexError):
                            pass
                        i += 1
                    else:
                        i += 1

                if line.endswith(";"):
                    top_pins[cur_pin] = {
                        "rects": cur_pin_rects,
                        "x": cur_pin_x,
                        "y": cur_pin_y,
                        "orient": cur_pin_orient,
                        "direction": cur_pin_dir,
                    }
                    cur_pin = None
                    cur_pin_layer = None
                continue

            if section == "NETS":
                if line.startswith("- "):
                    tokens = line.split()
                    if len(tokens) >= 2:
                        cur_net = tokens[1]
                        cur_net = cur_net.replace("$", r"\$")
                        cur_net = cur_net.replace(".", r"\.")
                        nets[cur_net] = {"pins": [], "segments": []}
                    continue

                if line.startswith(";"):
                    cur_net = None
                    continue

                if cur_net is None:
                    continue

                if line.startswith("("):
                    tmp = line.replace("(", " ").replace(")", " ")
                    tokens = tmp.split()
                    for i in range(0, len(tokens), 2):
                        if i + 1 < len(tokens):
                            tokens[i] = tokens[i].replace(".", r"\.")
                            tokens[i+1] = tokens[i+1].replace(".", r"\.")
                            nets[cur_net]["pins"].append((tokens[i], tokens[i + 1]))
                    continue

                tokens = line.replace(";", " ").split()
                if not tokens:
                    continue

                if tokens[0] == "+" and len(tokens) >= 3 and tokens[1] == "USE":
                    nets[cur_net]["use"] = tokens[2]
                    continue

                if tokens[0] == "+" and len(tokens) >= 3 and tokens[1] == "ROUTED":
                    layer = tokens[2]
                    rest = tokens[3:]
                elif tokens[0] == "NEW" and len(tokens) >= 2:
                    layer = tokens[1]
                    rest = tokens[2:]
                else:
                    continue

                points = []
                via_name = None
                has_patch = False
                i = 0
                while i < len(rest):
                    tok = rest[i]
                    # A RECT patch after a point is a metal patch, neither a via nor a wire, so its tokens are skipped #
                    if tok == "RECT":
                        has_patch = True
                        i += 7
                    elif tok == "(" and i + 3 < len(rest):
                        x = None if rest[i + 1] == "*" else int(rest[i + 1])
                        y = None if rest[i + 2] == "*" else int(rest[i + 2])
                        points.append((x, y))
                        i += 4
                    else:
                        if tok not in (")", "(") and via_name is None:
                            via_name = tok
                        i += 1

                if has_patch and via_name is None and len(points) <= 1:
                    continue   # pure patch: no routed length, no via

                if points:
                    points = expand_star_points(points)
                    seg_id = len(nets[cur_net]["segments"])
                    nets[cur_net]["segments"].append({
                        "id": seg_id,
                        "layer": layer,
                        "points": points,
                        "via": via_name,
                    })

    return components, top_pins, nets

# Vias that only the DEF defines (NR_VIA*, VIAGEN_*), not in the LEF. Returns {via: [(layer, rect)]}, from explicit #
# RECTs or rebuilt from the VIARULE cut array.                                                                      #
def parse_def_vias(def_path):
    vias = {}
    in_vias = False
    buf = []
    stmts = []
    with open(def_path, 'r') as f:
        for raw in f:
            line = raw.strip()
            if not in_vias:
                if line.startswith('VIAS') and line.endswith(';'):
                    in_vias = True
                continue
            if line.startswith('END VIAS'):
                break
            buf.append(line)
            if line.endswith(';'):
                stmts.append(' '.join(buf))
                buf = []
    for st in stmts:
        t = st.replace(';', ' ').split()
        if not t or t[0] != '-':
            continue
        name = t[1]
        rects = []
        info = {'cut': None, 'layers': None, 'space': (0, 0), 'enc': (0, 0, 0, 0), 'rc': (1, 1)}
        i = 2
        while i < len(t):
            k = t[i]
            if k == 'RECT' and i + 8 < len(t) and t[i + 2] == '(':
                try:
                    rects.append((t[i + 1],
                                  (float(t[i + 3]), float(t[i + 4]), float(t[i + 7]), float(t[i + 8]))))
                except ValueError:
                    pass
                i += 9
            elif k == 'CUTSIZE' and i + 2 < len(t):
                info['cut'] = (float(t[i + 1]), float(t[i + 2])); i += 3
            elif k == 'LAYERS' and i + 3 < len(t):
                info['layers'] = tuple(t[i + 1:i + 4]); i += 4
            elif k == 'CUTSPACING' and i + 2 < len(t):
                info['space'] = (float(t[i + 1]), float(t[i + 2])); i += 3
            elif k == 'ENCLOSURE' and i + 4 < len(t):
                info['enc'] = tuple(float(x) for x in t[i + 1:i + 5]); i += 5
            elif k == 'ROWCOL' and i + 2 < len(t):
                info['rc'] = (int(t[i + 1]), int(t[i + 2])); i += 3
            else:
                i += 1
        if not rects and info['layers'] and info['cut']:
            cx, cy = info['cut']
            rows, cols = info['rc']
            w = cols * cx + (cols - 1) * info['space'][0]
            h = rows * cy + (rows - 1) * info['space'][1]
            bot, cutl, top = info['layers']
            bx, by, tx, ty = info['enc']
            rects = [
                (bot,  (-w / 2 - bx, -h / 2 - by, w / 2 + bx, h / 2 + by)),
                (cutl, (-w / 2, -h / 2, w / 2, h / 2)),
                (top,  (-w / 2 - tx, -h / 2 - ty, w / 2 + tx, h / 2 + ty)),
            ]
        if rects:
            vias[name] = rects
    return vias

# Add the via location as a corner to every wire of another layer that the via connects and that passes through it. #
def split_wires_at_vias(def_nets, tech_vias):
    for net_name, net_info in def_nets.items():
        via_points = {}
        for seg in net_info['segments']:
            if seg.get('via'):
                via_name = seg['via']
                layer = seg['layer']
                point = seg['points'][-1]
                via_points[point] = (layer, via_name)

        for (vx, vy), (via_layer, via_name) in via_points.items():
            if via_name not in tech_vias:
                continue
            via_def = tech_vias[via_name]
            connected_layers = {l for l, _ in via_def}

            for seg in net_info['segments']:
                if seg['layer'] == via_layer:
                    continue
                if seg['layer'] not in connected_layers:
                    continue

                pts = seg['points']
                for i in range(len(pts) - 1):
                    x1, y1 = pts[i]
                    x2, y2 = pts[i + 1]
                    if x1 == x2 == vx and min(y1, y2) <= vy <= max(y1, y2):
                        if vy == y1 or vy == y2:
                            continue
                        seg['points'] = pts[:i + 1] + [(vx, vy)] + pts[i + 1:]
                        break
                    elif y1 == y2 == vy and min(x1, x2) <= vx <= max(x1, x2):
                        if vx == x1 or vx == x2:
                            continue
                        seg['points'] = pts[:i + 1] + [(vx, vy)] + pts[i + 1:]
                        break

# Absolute pin rectangles [(layer, rect)] of a pin at its placement. Empty if the pin is unknown. #
def get_pin_abs_rects(inst_name, pin_name, components, cells, top_pins):
    # Top-level pin, "PIN" is the instance name that DEF uses for these #
    if inst_name == "PIN":
        pin_data = top_pins.get(pin_name)
        if not pin_data:
            return []
        rects = pin_data['rects']
        px, py = pin_data['x'], pin_data['y']
        orient = pin_data['orient']

        min_x = min_y = float('inf')
        max_x = max_y = float('-inf')
        for layer, (xl, yl, xh, yh) in rects:
            min_x = min(min_x, xl, xh)
            max_x = max(max_x, xl, xh)
            min_y = min(min_y, yl, yh)
            max_y = max(max_y, yl, yh)
        if min_x == float('inf'):
            return []

        width = max_x - min_x
        height = max_y - min_y

        abs_rects = []
        for layer, (xl, yl, xh, yh) in rects:
            oxl, oyl, oxh, oyh = orient_rect(xl, yl, xh, yh, orient, width, height)
            abs_rects.append((layer, (px + oxl, py + oyl, px + oxh, py + oyh)))
        return abs_rects

    comp = components.get(inst_name)
    if comp is None:
        return []
    macro_pins = cells.get(comp["macro"])
    if not macro_pins:
        return []
    pin_rects = macro_pins.get(pin_name)
    if not pin_rects:
        return []

    cell_w, cell_h = macro_pins.get('_size', (0, 0))
    abs_rects = []
    for layer, (xl, yl, xh, yh) in pin_rects:
        oxl, oyl, oxh, oyh = orient_rect(xl, yl, xh, yh, comp["orient"], cell_w, cell_h)
        abs_rects.append((
            layer,
            (comp["x"] + oxl, comp["y"] + oyl,
             comp["x"] + oxh, comp["y"] + oyh),
        ))
    return abs_rects

# Transform a point inside a cell for the DEF orientation (N, S, FN, FS, E, W, FE, FW). #
def orient_point(x, y, orient, cell_w, cell_h):
    if orient == "N":
        return x, y
    elif orient == "S":
        return cell_w - x, cell_h - y
    elif orient == "FN":
        return cell_w - x, y
    elif orient == "FS":
        return x, cell_h - y
    elif orient == "E":
        return y, cell_w - x
    elif orient == "W":
        return cell_h - y, x
    elif orient == "FE":
        return y, x
    elif orient == "FW":
        return cell_h - y, cell_w - x
    else:
        return x, y

def orient_rect(xl, yl, xh, yh, orient, cell_w, cell_h):
    corners = [(xl, yl), (xl, yh), (xh, yl), (xh, yh)]
    oriented = [orient_point(x, y, orient, cell_w, cell_h) for x, y in corners]
    xs = [p[0] for p in oriented]
    ys = [p[1] for p in oriented]
    return min(xs), min(ys), max(xs), max(ys)

# Add the centre of a pin shape as a corner to every wire of the net that passes through it on the pin layer. #
def split_wires_at_pins(def_nets, components, cells, tech_vias, top_pins, verbose):
    for net_name, net_info in def_nets.items():
        for (inst, pin) in net_info['pins']:
            rects_with_layer = get_pin_abs_rects(inst, pin, components, cells, top_pins)
            if not rects_with_layer:
                continue

            pin_layers = {layer for layer, _ in rects_with_layer}

            for seg in net_info['segments']:
                if seg['layer'] not in pin_layers:
                    continue

                for (layer, (xl, yl, xh, yh)) in rects_with_layer:
                    if layer != seg['layer']:
                        continue

                    pin_cx = int((xl + xh) / 2.0)
                    pin_cy = int((yl + yh) / 2.0)

                    pts = seg['points']
                    for i in range(len(pts) - 1):
                        x1, y1 = pts[i]
                        x2, y2 = pts[i + 1]

                        split_pt = None
                        if x1 == x2 and x1 == pin_cx:
                            if min(y1, y2) < pin_cy < max(y1, y2):
                                split_pt = (pin_cx, pin_cy)
                        elif y1 == y2 and y1 == pin_cy:
                            if min(x1, x2) < pin_cx < max(x1, x2):
                                split_pt = (pin_cx, pin_cy)

                        if split_pt is not None:
                            seg['points'] = pts[:i+1] + [split_pt] + pts[i+1:]
                            break

# (net, pin) -> (layer, other points that touch the same pin shape) #
PIN_TOUCH = {}


# Find the wire point where each pin connects, in this order: end of a via that overlaps a pin shape, a wire point #
# inside a pin shape, the closest wire point. Other contacts on the pin shape go to PIN_TOUCH.                     #
def build_def_pin_points(def_nets, components, cells, tech_vias, top_pins,
                         tolerance=20000, verbose=False):
    def_pin_points = {}
    def_point_to_pin_name = {}

    for net_name, net_info in def_nets.items():
        net_pin_points = {}
        all_points = set()
        via_points = []
        points_by_layer = defaultdict(set)

        for seg in net_info['segments']:
            all_points.update(seg['points'])
            points_by_layer[seg['layer']].update(seg['points'])
            if seg.get('via'):
                via_points.append((seg['points'][-1], seg['via']))

        pin_rects_cache = {}

        for (inst, pin) in net_info['pins']:
            cache_key = (inst, pin)
            if cache_key not in pin_rects_cache:
                pin_rects_cache[cache_key] = get_pin_abs_rects(
                    inst, pin, components, cells, top_pins)
            rects_with_layer = pin_rects_cache[cache_key]

            if not rects_with_layer:
                continue

            # 1. via end point whose via shape overlaps a pin shape on the same layer #
            best_point = None
            best_dist = float('inf')

            for (vpoint, via_name) in via_points:
                if best_point is not None and best_dist == 0:
                    break
                vx, vy = vpoint
                if via_name not in tech_vias:
                    continue
                via_def = tech_vias[via_name]

                for (pin_layer, (xl_pin, yl_pin, xh_pin, yh_pin)) in rects_with_layer:
                    for (via_layer, (vxl_rel, vyl_rel, vxh_rel, vyh_rel)) in via_def:
                        if via_layer != pin_layer:
                            continue
                        abs_vxl = vx + vxl_rel
                        abs_vyl = vy + vyl_rel
                        abs_vxh = vx + vxh_rel
                        abs_vyh = vy + vyh_rel
                        if (abs_vxl < xh_pin and abs_vxh > xl_pin and
                                abs_vyl < yh_pin and abs_vyh > yl_pin):
                            best_point = vpoint
                            best_dist = 0
                            break
                    if best_point is not None:
                        break
                if best_point is not None:
                    break

            # 2. wire point inside a pin shape #
            if best_point is None:
                for (layer, (xl, yl, xh, yh)) in rects_with_layer:
                    for (px, py) in all_points:
                        if xl <= px <= xh and yl <= py <= yh:
                            best_point = (px, py)
                            best_dist = 0
                            break
                    if best_point is not None:
                        break

            # 3. wire point closest to the centre of a pin shape #
            if best_point is None:
                for (layer, (xl, yl, xh, yh)) in rects_with_layer:
                    pin_cx = (xl + xh) / 2.0
                    pin_cy = (yl + yh) / 2.0
                    for (px, py) in all_points:
                        dist = math.hypot(px - pin_cx, py - pin_cy)
                        if dist < best_dist:
                            best_dist = dist
                            best_point = (px, py)

            pin_full_name = f"{inst}/{pin}" if inst != "PIN" else pin

            if best_point is not None:
                if best_dist <= tolerance:
                    net_pin_points[pin_full_name] = best_point
                    def_point_to_pin_name[best_point] = pin_full_name

                    # Other contacts on the same pin shape are joined by the pin metal, not by the DEF routing #
                    touch, tlayer = set(), None
                    for (pin_layer, (xl_pin, yl_pin, xh_pin, yh_pin)) in rects_with_layer:
                        for (vpoint, via_name) in via_points:
                            if via_name not in tech_vias:
                                continue
                            vx, vy = vpoint
                            for (via_layer, (a_, b_, c_, d_)) in tech_vias[via_name]:
                                if via_layer == pin_layer and (vx + a_ < xh_pin and vx + c_ > xl_pin
                                                               and vy + b_ < yh_pin and vy + d_ > yl_pin):
                                    touch.add(vpoint); tlayer = tlayer or pin_layer
                        for (px, py) in points_by_layer.get(pin_layer, ()):
                            if xl_pin <= px <= xh_pin and yl_pin <= py <= yh_pin:
                                touch.add((px, py)); tlayer = tlayer or pin_layer
                    touch.discard(best_point)
                    if touch:
                        PIN_TOUCH[(net_name, pin_full_name)] = (tlayer, sorted(touch))


        if net_pin_points:
            def_pin_points[net_name] = net_pin_points

    return def_pin_points, def_point_to_pin_name

# Add a pin-metal segment from the pin point to each other contact on the same pin shape (see PIN_TOUCH). #
def add_pin_shape_connections(def_nets, def_pin_points):
    n_added = 0
    for net_name, pins in def_pin_points.items():
        segs = def_nets[net_name]['segments']
        pin_pts = set(pins.values())
        for pin_full, primary in pins.items():
            t = PIN_TOUCH.get((net_name, pin_full))
            if not t:
                continue
            layer, pts = t
            for p in pts:
                if p == primary or p in pin_pts:
                    continue
                segs.append({'id': len(segs), 'layer': layer, 'points': [primary, p], 'via': None, 'pin_shape': True})
                n_added += 1
    return n_added


# Steiner points of a net, the non-pin points where three or more wire pieces meet. #
def find_steiner_points_for_net(net_info, pin_points=None):
    edge_set = set()
    point_segs = defaultdict(set)

    for seg in net_info["segments"]:
        pts = seg["points"]
        seg_id = seg["id"]
        if len(pts) == 1 or pts[0] == pts[-1]:
            continue
        for i in range(len(pts) - 1):
            a, b = pts[i], pts[i + 1]
            if a == b:
                continue
            pair = (min(a, b, key=_point_sort_key), max(a, b, key=_point_sort_key))
            if pair not in edge_set:
                edge_set.add(pair)
            point_segs[a].add(seg_id)
            point_segs[b].add(seg_id)

    degree = defaultdict(int)
    for a, b in edge_set:
        degree[a] += 1
        degree[b] += 1

    return {
        p: {"degree": deg, "segments": sorted(point_segs.get(p, set()))}
        for p, deg in degree.items()
        if deg >= 3 and (pin_points is None or p not in pin_points)
    }

def add_def_steiner_points(def_nets, def_pin_points):
    for net_name, net_info in def_nets.items():
        pin_points = set(def_pin_points.get(net_name, {}).values())
        net_info['steiner_points'] = find_steiner_points_for_net(net_info, pin_points)

# Undirected adjacency of the wire points of a net. #
def build_def_net_graph(net_info):
    graph = defaultdict(set)
    for seg in net_info['segments']:
        pts = seg['points']
        for i in range(len(pts) - 1):
            p1, p2 = pts[i], pts[i + 1]
            if p1 != p2:
                graph[p1].add(p2)
                graph[p2].add(p1)
    return {p: list(nbrs) for p, nbrs in graph.items()}

# Compress the wire graph to edges between pins and Steiner points. Returns [{p1, p2, intermediate}]. #
def extract_def_edges_between_interest(graph, interest_points):
    edges = []
    visited_edges = set()

    for start in interest_points:
        if start not in graph:
            continue
        for nb in graph[start]:
            canonical = (min(_point_sort_key(start), _point_sort_key(nb)),
                         max(_point_sort_key(start), _point_sort_key(nb)))
            if canonical in visited_edges:
                continue

            path = [start, nb]
            current = nb
            prev = start
            loop_guard = 0

            while (len(graph.get(current, [])) == 2
                   and current not in interest_points
                   and loop_guard < 100000):
                nxt = next((n for n in graph[current] if n != prev), None)
                if nxt is None or nxt == start:
                    break
                path.append(nxt)
                prev, current = current, nxt
                loop_guard += 1

            end = current
            for i in range(len(path) - 1):
                a, b = path[i], path[i + 1]
                c = (min(_point_sort_key(a), _point_sort_key(b)),
                     max(_point_sort_key(a), _point_sort_key(b)))
                visited_edges.add(c)

            edges.append({'p1': start, 'p2': end, 'intermediate': path[1:-1]})

    return edges

_G = {}          # per-process globals (inherited by Pool workers via fork)


# Undo the escaping of '.' and '$' that parse_def does. #
def raw_name(s):
    return s.replace('\\.', '.').replace('\\$', '$')


# {macro: {pin: direction}} from the cell LEFs. The output pin is the driver of the net. #
def parse_lef_pin_directions(lef_paths):
    dirs = {}
    for path in lef_paths:
        if not os.path.exists(path):
            print("WARNING: LEF not found: %s" % path)
            continue
        macro = pin = None
        with open(path) as f:
            for line in f:
                t = line.split()
                if not t:
                    continue
                if t[0] == 'MACRO' and len(t) >= 2:
                    macro, pin = t[1], None
                    dirs.setdefault(macro, {})
                elif t[0] == 'PIN' and len(t) >= 2 and macro:
                    pin = t[1]
                elif t[0] == 'DIRECTION' and len(t) >= 2 and macro and pin:
                    dirs[macro][pin] = t[1].rstrip(';')
                elif t[0] == 'END' and len(t) >= 2:
                    if t[1] == pin:
                        pin = None
                    elif t[1] == macro:
                        macro = pin = None
    return dirs


LAYER_ORDER = ['metal1', 'metal2', 'metal3', 'metal4', 'metal5',
               'metal6', 'metal7', 'metal8', 'metal9', 'metal10']
LAYER_IDX = {l: i for i, l in enumerate(LAYER_ORDER)}


# Direction of a pin (top-level pin from the DEF, cell pin from the LEF), or None if unknown. #
def pin_direction(inst, pin):
    if inst == "PIN":
        d = _G['top_pins'].get(pin, {}).get('direction')
    else:
        comp = _G['components'].get(inst)
        d = _G['pin_dirs'].get(comp['macro'], {}).get(pin) if comp else None
    return d


# Edge rows and node rows of one net, or None. #
def process_net(args):
    net_name, net_info, pin_pts = args
    dbu = float(_G['dbu'])
    tech_vias = _G['tech_vias']

    def_edges = net_info.get('def_edges', [])
    if not def_edges:
        return None

    point_pair_layer = net_info['point_pair_layer']
    point_to_pin = {pt: nm for nm, pt in pin_pts.items()}

    # driver / sinks (LEF + DEF-PINS directions) #
    driver_pt = None
    top_in_pt = None
    for (inst, pin) in net_info['pins']:
        key = pin if inst == "PIN" else "%s/%s" % (inst, pin)
        pt = pin_pts.get(key)
        if pt is None:
            continue
        d = pin_direction(inst, pin)
        if inst != "PIN" and d == 'OUTPUT' and driver_pt is None:
            driver_pt = pt
        elif inst == "PIN" and d == 'INPUT' and top_in_pt is None:
            top_in_pt = pt
    if driver_pt is None:
        driver_pt = top_in_pt
    if driver_pt is None:                    
        driver_pt = next(iter(pin_pts.values()), None)

    is_sink_set = {pt for pt in pin_pts.values() if pt != driver_pt}
    n_sink_pins = len(pin_pts) - (1 if driver_pt is not None else 0)

    adj = defaultdict(list)
    for e in def_edges:
        adj[e['p1']].append(e['p2'])
        adj[e['p2']].append(e['p1'])

    edge_len = {}
    for e in def_edges:
        pts = [e['p1']] + e.get('intermediate', []) + [e['p2']]
        tot = 0.0
        for i in range(len(pts) - 1):
            ax, ay = _get_coords(pts[i]); bx, by = _get_coords(pts[i + 1])
            tot += abs(bx - ax) + abs(by - ay)
        tot /= dbu
        edge_len[(e['p1'], e['p2'])] = tot
        edge_len[(e['p2'], e['p1'])] = tot

    # BFS from the driver, then from the largest-degree node of each leftover component #
    tree_depth, bfs_order = {}, []
    if driver_pt is not None and driver_pt in adj:
        q = deque([(driver_pt, None, 0)])
        seen = {driver_pt}
        while q:
            node, parent, depth = q.popleft()
            tree_depth[node] = depth
            bfs_order.append((node, parent))
            for nb in adj.get(node, []):
                if nb not in seen:
                    seen.add(nb)
                    q.append((nb, node, depth + 1))
    all_nodes = set(adj.keys())
    unvisited = all_nodes - set(tree_depth.keys())
    comp_off = (max(tree_depth.values()) + 100) if tree_depth else 100
    while unvisited:
        root = max(unvisited, key=lambda n: len(adj.get(n, [])))
        q = deque([(root, None, comp_off)])
        local = {root}
        while q:
            node, parent, depth = q.popleft()
            tree_depth[node] = depth
            bfs_order.append((node, parent))
            for nb in adj.get(node, []):
                if nb not in local and nb not in tree_depth:
                    local.add(nb)
                    q.append((nb, node, depth + 1))
        unvisited -= local
        comp_off += 100

    parent_of = {}
    for node, parent in bfs_order:
        parent_of.setdefault(node, parent)
    sub_sinks, sub_len = {}, {}
    for node, parent in reversed(bfs_order):
        kids = [nb for nb in adj.get(node, [])
                if tree_depth.get(nb, -1) == tree_depth.get(node, 0) + 1
                and parent_of.get(nb) == node]
        sub_sinks[node] = (1 if node in is_sink_set else 0) + sum(sub_sinks.get(c, 0) for c in kids)
        sub_len[node] = sum(edge_len.get((node, c), 0.0) + sub_len.get(c, 0.0) for c in kids)

    all_layers, all_via_types = set(), set()
    point_to_via = {}
    for seg in net_info['segments']:
        all_layers.add(seg['layer'])
        if seg.get('via'):
            all_via_types.add(seg['via'])
            point_to_via[seg['points'][-1]] = seg['via']

    edge_rows = []
    inc_len = defaultdict(lambda: defaultdict(float))     # node -> layer -> um
    inc_tot = defaultdict(float)
    inc_vias = defaultdict(int)
    via_max = defaultdict(int)
    via_min = defaultdict(lambda: 99)

    # Name of a point for the edge table: the pin name for a pin, else "Steiner(x, y)". #
    def lbl(p):
        return point_to_pin.get(p, "Steiner%s" % (p,))

    for e in def_edges:
        p1, p2 = e['p1'], e['p2']
        pts = [p1] + e.get('intermediate', []) + [p2]
        by_layer = defaultdict(float)
        tot_dbu = 0
        for i in range(len(pts) - 1):
            a, b = pts[i], pts[i + 1]
            ax, ay = _get_coords(a); bx, by = _get_coords(b)
            if (ax, ay) == (bx, by):
                continue
            L = abs(bx - ax) + abs(by - ay)
            by_layer[_lookup_layer(point_pair_layer, a, b) or "unknown"] += L
            tot_dbu += L
        if tot_dbu == 0 and p1 == p2:
            continue
        by_layer = {k: v / dbu for k, v in by_layer.items()}
        tot_um = tot_dbu / dbu

        via_counts = defaultdict(int)
        for pt in pts:
            if pt in point_to_via:
                via_counts[point_to_via[pt]] += 1

        # incident (node) features: half of each incident edge goes to each endpoint #
        for pt in (p1, p2):
            for lyr, L in by_layer.items():
                inc_len[pt][lyr] += L / 2.0
            inc_tot[pt] += tot_um / 2.0
            vn = point_to_via.get(pt)
            if vn is not None:
                inc_vias[pt] += 1
                lv = [LAYER_IDX[l] for l, _ in tech_vias.get(vn, [])
                      if l in LAYER_IDX and not l.startswith('via')]
                if lv:
                    via_max[pt] = max(via_max[pt], max(lv))
                    via_min[pt] = min(via_min[pt], min(lv))

        row = {
            'net_name': raw_name(net_name),
            'edge_idx': len(edge_rows),
            'endpoint_1': raw_name(lbl(p1)), 'endpoint_2': raw_name(lbl(p2)),
            'coord_x1': p1[0], 'coord_y1': p1[1], 'coord_x2': p2[0], 'coord_y2': p2[1],
            'R_ohms': '', 'C_edge_pf': '',          # no SPEF -> no labels
            'path_edges': 1, 'direct_match': 1, 'stub_relumped': 0,
            'total_vias': sum(via_counts.values()),
            'total_len_um': tot_um,
            'is_virtual_steiner': 0,
        }
        for lyr in sorted(all_layers):
            row['len_%s' % lyr] = by_layer.get(lyr, 0.0)
        for vt in sorted(all_via_types):
            row['n_via_%s' % vt] = via_counts.get(vt, 0)
        edge_rows.append(row)

    if not edge_rows:
        return None

    node_pts = set(pin_pts.values())
    for r in edge_rows:
        node_pts.add((r['coord_x1'], r['coord_y1']))
        node_pts.add((r['coord_x2'], r['coord_y2']))
    node_rows = []
    steiner_idx = 0
    for pt in sorted(node_pts):
        is_pin = pt in point_to_pin
        if is_pin:
            nid = raw_name(point_to_pin[pt])
        else:
            steiner_idx += 1
            nid = "%s/%d" % (raw_name(net_name), steiner_idx)   # numeric suffix => INTERNAL in add_cell_types
        act = [LAYER_IDX[l] for l, v in inc_len[pt].items() if v > 0 and l in LAYER_IDX]
        mx = max(act) if act else 0
        mn = min(act) if act else 0
        vmin = via_min[pt] if via_min[pt] != 99 else 0
        row = {
            'net_name': raw_name(net_name),
            'node_id': nid, 'node_id_def': nid,
            'coord_x': pt[0], 'coord_y': pt[1],
            'is_pin': int(is_pin),
            'is_driver_pin': int(pt == driver_pt),
            'is_sink_pin': int(is_pin and pt != driver_pt),
            'node_degree': len(adj.get(pt, [])),
            'tree_depth': tree_depth.get(pt, -1),
            'n_sink_pins': n_sink_pins,
            'subtree_n_sinks': sub_sinks.get(pt, 0),
            'subtree_total_len': sub_len.get(pt, 0.0),
            'n_active_layers': len(act),
            'max_layer_idx': mx,
            'layer_span': mx - mn,
            'incident_vias': inc_vias[pt],
            'max_via_level': via_max[pt],
            'via_stack_height': via_max[pt] - vmin,
            'total_incident_len_um': inc_tot[pt],
            'C_node_pf': '',
        }
        for lyr in sorted(all_layers):
            row['len_%s' % lyr] = inc_len[pt].get(lyr, 0.0)
        node_rows.append(row)
    return edge_rows, node_rows


EDGE_PREFIX = ['net_name', 'edge_idx', 'endpoint_1', 'endpoint_2',
               'coord_x1', 'coord_y1', 'coord_x2', 'coord_y2',
               'R_ohms', 'C_edge_pf', 'path_edges', 'direct_match']
NODE_PREFIX = ['net_name', 'node_id', 'node_id_def', 'coord_x', 'coord_y',
               'is_pin', 'is_driver_pin', 'is_sink_pin',
               'node_degree', 'tree_depth', 'n_sink_pins',
               'subtree_n_sinks', 'subtree_total_len',
               'n_active_layers', 'max_layer_idx', 'layer_span',
               'incident_vias', 'max_via_level', 'via_stack_height']


# Write rows to a CSV: the fixed prefix columns, the columns that start with each group prefix, then the fixed suffix. #
def write_csv(path, rows, prefix, suffix, group_prefixes):
    keys = set()
    for r in rows:
        keys.update(r.keys())
    groups = [sorted(k for k in keys if k.startswith(p)) for p in group_prefixes]
    fields = prefix + [c for g in groups for c in g] + suffix
    with open(path, 'w', newline='') as f:
        w = csv.DictWriter(f, fieldnames=fields, extrasaction='ignore', restval=0.0)
        w.writeheader()
        for r in rows:
            w.writerow(r)
    print("INFO: Wrote %s rows to %s" % (format(len(rows), ",d"), path))


def parse_args():
    p = argparse.ArgumentParser(description="DEF/LEF-only feature extraction (no SPEF).")
    p.add_argument("--lef-json", dest="lef_json", help="LEF geometry as JSON (default: data/configs/ng45_lef_geometry.json)")
    p.add_argument("--dbu", type=float, help="override DBU (default: 2000)")
    p.add_argument("def_path", help="Path to DEF file")
    p.add_argument("--output_csv", required=True, help="edge CSV (node CSV = <name>_nodes.csv)")
    p.add_argument("--workers", type=int, default=8)
    p.add_argument("-v", "--verbose", action="store_true")
    return p.parse_args()


# Extract the features of every net of one DEF and write the edge and node CSVs. #
def main():
    args = parse_args()
    cfg = CFG
    dbu = args.dbu or cfg["dbu"]
    t0 = time.perf_counter()

    cells, tech_vias, _ = load_lef_json(args.lef_json or cfg["lef_json"])
    print("INFO: Loaded the LEF json with %d cells and %d vias" % (len(cells), len(tech_vias)))
    pin_dirs = parse_lef_pin_directions(cfg["lefs"])
    print("INFO: Read the pin directions of %d macros" % len(pin_dirs))

    components, top_pins, def_nets = parse_def(args.def_path)
    print("INFO: Parsed the DEF with %s components, %s top pins and %s nets" % (format(len(components), ",d"), format(len(top_pins), ",d"), format(len(def_nets), ",d")))
    tech_vias.update(parse_def_vias(args.def_path))

    split_wires_at_vias(def_nets, tech_vias)
    split_wires_at_pins(def_nets, components, cells, tech_vias, top_pins, args.verbose)
    def_pin_points, _ = build_def_pin_points(
        def_nets, components, cells, tech_vias, top_pins, tolerance=20000, verbose=args.verbose)
    if os.environ.get("PIN_SHAPE_CONNECT", "1") == "1":
        n_ps = add_pin_shape_connections(def_nets, def_pin_points)
        print("INFO: Added %d pin-shape connections" % n_ps)
    add_def_steiner_points(def_nets, def_pin_points)

    # Pins are plain nodes: a wire that runs through a pin is cut there. Power and ground nets are skipped. #
    n_no_pins = 0
    net_args = []
    n_pg = 0
    for net_name, net_info in def_nets.items():
        # VDD and VSS (USE POWER or GROUND) are not signal nets and would give an unreadable SPEF #
        if net_info.get("use") in ("POWER", "GROUND"):
            n_pg += 1
            continue
        pins = def_pin_points.get(net_name, {})
        if not pins:
            n_no_pins += 1
            continue
        g = build_def_net_graph(net_info)
        interest = set(pins.values()) | set(net_info.get('steiner_points', {}).keys())
        net_info['def_edges'] = extract_def_edges_between_interest(g, interest)
        ppl = {}
        for seg in net_info['segments']:
            pts = seg['points']
            for i in range(len(pts) - 1):
                ppl[(pts[i], pts[i + 1])] = seg['layer']
                ppl[(pts[i + 1], pts[i])] = seg['layer']
        net_info['point_pair_layer'] = ppl
        net_args.append((net_name, net_info, pins))

    _G.update(dict(dbu=dbu, tech_vias=tech_vias, top_pins=top_pins, components=components,
                   pin_dirs=pin_dirs))
    nw = min(args.workers, cpu_count() or args.workers)
    print("INFO: Processing %s nets with %d workers" % (format(len(net_args), ",d"), nw))
    all_edges, all_nodes, n_ok, n_none = [], [], 0, 0
    with Pool(processes=nw) as pool:
        for res in pool.imap_unordered(process_net, net_args, chunksize=64):
            if res is None:
                n_none += 1
            else:
                n_ok += 1
                all_edges.extend(res[0])
                all_nodes.extend(res[1])

    print("INFO: DEF nets %s: power/ground skipped %s, no pin points %s, no edges %s, with features %s"
          % (format(len(def_nets), ",d"), format(n_pg, ",d"), format(n_no_pins, ",d"), format(n_none, ",d"), format(n_ok, ",d")))
    write_csv(args.output_csv, all_edges, EDGE_PREFIX,
              ['total_vias', 'total_len_um', 'is_virtual_steiner', 'stub_relumped'],
              ['len_', 'n_via_'])
    node_csv = args.output_csv.replace('.csv', '_nodes.csv')
    write_csv(node_csv, all_nodes, NODE_PREFIX, ['total_incident_len_um', 'C_node_pf'], ['len_'])
    print("INFO: Total execution time %.1fs" % (time.perf_counter() - t0))


if __name__ == "__main__":
    main()
