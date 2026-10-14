import argparse
import json

import numpy as np

from fit_calibration import design_matrix
from net_features import clean, net_features


def factors(segments_csv, case, calibration):
    cal = json.load(open(calibration))
    f = net_features(segments_csv, keep_runs={case})
    if f.empty:
        raise SystemExit("no nets of %s in %s" % (case, segments_csv))
    f["key"] = f.key.map(lambda k: clean(k[len(case) + 1:]))
    k = np.exp(np.clip(design_matrix(f) @ np.array(cal["beta"]), np.log(cal["clip"][0]), np.log(cal["clip"][1])))
    return dict(zip(f.key, k))


def write_calibrated(spef_in, spef_out, kmap):
    names, sec, sub, f, nets, hit = {}, None, None, 1.0, 0, 0
    with open(spef_in) as fi, open(spef_out, "w") as fo:
        for ln in fi:
            if ln.startswith("*NAME_MAP"):
                sec = "map"
            elif ln.startswith("*D_NET"):
                t = ln.split()
                net = clean(names.get(t[1], t[1]))
                f = kmap.get(net, 1.0)
                sec, sub = "net", None
                nets += 1
                hit += net in kmap
                if f != 1.0:
                    ln = "%s %s %.6g\n" % (t[0], t[1], float(t[2]) * f)
            elif sec == "map" and ln.startswith("*") and len(ln.split()) == 2:
                key, val = ln.split()
                names[key] = val
            elif sec == "net":
                if ln.startswith("*CAP"):
                    sub = "cap"
                elif ln.startswith("*RES") or ln.startswith("*CONN"):
                    sub = "other"
                elif ln.startswith("*END"):
                    sec = None
                elif sub == "cap" and f != 1.0:
                    t = ln.split()
                    if len(t) >= 3:
                        t[-1] = "%.6g" % (float(t[-1]) * f)
                        ln = " ".join(t) + "\n"
            fo.write(ln)
    return nets, hit


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--spef", required=True)
    ap.add_argument("--segments", required=True, help="processed_segments.csv of the feature extraction")
    ap.add_argument("--case", required=True)
    ap.add_argument("--calibration", required=True, help="json written by fit_calibration.py")
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    kmap = factors(a.segments, a.case, a.calibration)
    nets, hit = write_calibrated(a.spef, a.out, kmap)
    k = np.array(list(kmap.values()))
    print("INFO: nets %d  with a factor %d (%.1f %%)  k median %.3f  min %.2f  max %.2f" % (nets, hit, 100.0 * hit / max(nets, 1), np.median(k), k.min(), k.max()))
    print("INFO: wrote %s" % a.out)


if __name__ == "__main__":
    main()
