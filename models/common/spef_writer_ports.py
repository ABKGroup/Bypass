import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
import graph_builder as GB
import datetime
from collections import defaultdict
get_liberty_pin_cap = GB.get_liberty_pin_cap

# Writes a SPEF file with port support. The def_ports # 
# argument is a dict mapping port  names to metadata  #
# dicts with keys:                                    #
#   - direction: 'I' or 'O'                           #
#   - x_um: x-coordinate in micrometers               #
#   - y_um: y-coordinate in micrometers               #
def write_spef_ports(node_df_out, edge_df_out, path, design_name, def_ports=None):
    nets_nodes = defaultdict(list)
    nets_edges = defaultdict(list)
    for _, row in node_df_out.iterrows():
        nets_nodes[row['net_name']].append(row)
    for _, row in edge_df_out.iterrows():
        nets_edges[row['net_name']].append(row)

    all_nets = sorted(set(nets_nodes) | set(nets_edges))
    net_alias = {net: idx + 1 for idx, net in enumerate(all_nets)}

    inst_alias = {}
    alias_counter = [len(all_nets) + 1]

    def _get_inst_alias(inst: str) -> int:
        if inst not in inst_alias:
            inst_alias[inst] = alias_counter[0]
            alias_counter[0] += 1
        return inst_alias[inst]

    def _split_pin(nid: str):
        if '/' in nid:
            return nid.rsplit('/', 1)
        if ':' in nid:
            return nid.rsplit(':', 1)
        return nid, ''

    _port_meta = {}
    if def_ports:
        for _k, _v in def_ports.items():
            _port_meta[_k.replace('\\', '')] = (_k, _v)

    def _port_lookup(nid):
        if '/' in nid or ':' in nid:
            return None
        return _port_meta.get(nid.replace('\\', ''))

    with open(path, 'w') as f:

        now = datetime.datetime.now().strftime("%a %b %d %H:%M:%S %Y")
        f.write('*SPEF "IEEE 1481-1998"\n')
        f.write(f'*DESIGN "{design_name}"\n')
        f.write(f'*DATE "{now}"\n')
        f.write('*VENDOR "Bypass GNN"\n')
        f.write('*PROGRAM "infer_new_design.py"\n')
        f.write('*VERSION "1.0"\n')
        f.write('*DESIGN_FLOW "PIN_CAP NONE" "NAME_SCOPE LOCAL"\n')
        f.write('*DIVIDER /\n')
        f.write('*DELIMITER :\n')
        f.write('*BUS_DELIMITER []\n')
        f.write('*T_UNIT 1 NS\n')
        f.write('*C_UNIT 1 PF\n')
        f.write('*R_UNIT 1 OHM\n')
        f.write('*L_UNIT 1 HENRY\n\n')

        for net_name, node_rows in nets_nodes.items():
            for row in node_rows:
                nid = str(row['node_id'])
                is_drv = int(row.get('is_driver_pin', 0))
                ctype = str(row.get('cell_type', 'UNKNOWN'))
                if ctype not in ('UNKNOWN', 'INTERNAL') or is_drv:
                    inst, _ = _split_pin(nid)
                    _get_inst_alias(inst)

        short_to_alias = {}
        for net, idx in net_alias.items():
            short_name = net.split('/', 1)[-1]
            short_to_alias[short_name] = idx

        if def_ports:
            for pin_name in def_ports:
                if pin_name not in short_to_alias:
                    _get_inst_alias(pin_name)

        f.write('*NAME_MAP\n\n')
        for net, idx in net_alias.items():
            short_name = net.split('/', 1)[-1]
            f.write(f'*{idx} {short_name}\n')
        for inst, idx in inst_alias.items():
            f.write(f'*{idx} {inst}\n')
        f.write('\n')

        if def_ports:
            f.write('*PORTS\n')
            for pin_name, pmeta in def_ports.items():
                alias = short_to_alias.get(pin_name, inst_alias.get(pin_name))
                if alias is None:
                    continue
                dirn = pmeta['direction']
                x = pmeta['x_um']
                y = pmeta['y_um']
                f.write(f'*{alias} {dirn} *C {x} {y}\n')
            f.write('\n')

        def _port_alias(pin_name):
            return short_to_alias.get(pin_name, inst_alias.get(pin_name))

        for net_name in all_nets:
            alias = net_alias[net_name]
            node_rows = nets_nodes.get(net_name, [])
            edge_rows = nets_edges.get(net_name, [])

            total_cap = (sum(r['C_node_eff_pf'] for r in node_rows) + sum(r['C_edge_eff_pf']  for r in edge_rows))

            f.write(f'*D_NET *{alias} {total_cap:.6g}\n')

            STEINER_TYPES = {'UNKNOWN', 'INTERNAL', 'INTERNAL_X1'}
            port_rows = []
            for r in node_rows:
                pm = _port_lookup(str(r['node_id']))
                if pm is not None and _port_alias(pm[0]) is not None:
                    port_rows.append((r, pm))
            port_ids = {id(r) for r, _ in port_rows}
            pin_rows = [r for r in node_rows
                        if id(r) not in port_ids and (int(r.get('is_driver_pin', 0)) == 1
                        or str(r.get('cell_type', 'UNKNOWN')) not in STEINER_TYPES)]
            pin_ids = {id(r) for r in pin_rows}
            steiner_rows = [r for r in node_rows if id(r) not in pin_ids and id(r) not in port_ids]

            f.write('*CONN\n')
            for row, (pname, pmeta) in port_rows:
                f.write(f'*P *{_port_alias(pname)} {pmeta["direction"]} *C {pmeta["x_um"]} {pmeta["y_um"]} *L 0\n')
            for row in pin_rows:
                nid = str(row['node_id'])
                inst, pin = _split_pin(nid)
                inst_id = _get_inst_alias(inst)
                is_drv = int(row.get('is_driver_pin', 0))
                dirn = 'O' if is_drv else 'I'
                ctype = str(row.get('cell_type', 'UNKNOWN'))
                x = float(row.get('x_um', 0.0))
                y = float(row.get('y_um', 0.0))
                if is_drv:
                    pin_load = 0.0
                else:
                    lib_cap = get_liberty_pin_cap(ctype, pin)
                    pin_load = lib_cap / 1000.00
                f.write(f'*I *{inst_id}:{pin} {dirn} *C {x:.3f} {y:.3f} '
                        f'*L {pin_load:.6g} *D {ctype}\n')
            f.write('\n')

            # Distribute C_edge/2 onto each endpoint's grounded cap (pi-model) #
            edge_cap_by_node = defaultdict(float)
            for row in edge_rows:
                ep1 = str(row['endpoint_1'])
                ep2 = str(row['endpoint_2'])
                half = row['C_edge_eff_pf'] / 2.0
                edge_cap_by_node[ep1] += half
                edge_cap_by_node[ep2] += half

            f.write('*CAP\n')
            cap_idx = 1
            node_id_to_label = {}
            steiner_idx = 1

            for row, (pname, pmeta) in port_rows:
                nid = str(row['node_id'])
                label = f'*{_port_alias(pname)}'
                node_id_to_label[nid] = label
                total_c = row['C_node_eff_pf'] + edge_cap_by_node.get(nid, 0.0)
                f.write(f'{cap_idx} {label} {total_c:.6g}\n')
                cap_idx += 1

            for row in pin_rows:
                nid = str(row['node_id'])
                inst, pin = _split_pin(nid)
                inst_id = _get_inst_alias(inst)
                label = f'*{inst_id}:{pin}'
                node_id_to_label[nid] = label
                total_c = row['C_node_eff_pf'] + edge_cap_by_node.get(nid, 0.0)
                f.write(f'{cap_idx} {label} {total_c:.6g}\n')
                cap_idx += 1

            for row in steiner_rows:
                nid = str(row['node_id'])
                label = f'*{alias}:{steiner_idx}'
                node_id_to_label[nid] = label
                steiner_idx += 1
                total_c = row['C_node_eff_pf'] + edge_cap_by_node.get(nid, 0.0)
                f.write(f'{cap_idx} {label} {total_c:.6g}\n')
                cap_idx += 1

            f.write('\n')

            f.write('*RES\n')
            for res_idx, row in enumerate(edge_rows, 1):
                ep1 = str(row['endpoint_1'])
                ep2 = str(row['endpoint_2'])
                label1 = node_id_to_label.get(ep1, f'*{alias}:?')
                label2 = node_id_to_label.get(ep2, f'*{alias}:?')
                f.write(f'{res_idx} {label1} {label2} {row["R_eff_ohm"]:.6g}\n')

            f.write('*END\n\n')

    print(f"INFO: SPEF written: {path}  ({len(all_nets):,} nets)")
