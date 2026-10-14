import sys
from pathlib import Path

import numpy as np

_HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(_HERE.parent / "common"))
import inference_engine as E 

# Constants for the NG45 technology file, including resistance per unit length (Ohm/um) # 
# and capacitance per unit length (fF/um) for different metal layers. These values are  #
# used in the physics-based calculations of R and C_edge.                               #
R_OHM_PER_UM = {                   
    "len_metal1": 5.4286, "len_metal2": 3.70635, "len_metal3": 3.57728,
    "len_metal4": 1.47397, "len_metal5": 1.49065, "len_metal6": 1.50265,
    "len_metal7": 0.264082, "len_metal8": 0.189296, "len_metal9": 0.034286,
    "len_metal10": 0.038654,
}
C_FF_PER_UM = { 
    "len_metal2": 0.0833611, "len_metal3": 0.103981, "len_metal4": 0.11915,
    "len_metal5": 0.109256, "len_metal6": 0.114168, "len_metal7": 0.117491,
    "len_metal8": 0.0945346, "len_metal9": 0.106091, "len_metal10": 0.737095,
}
R_PER_VIA = 3.0 # uniform via resistance, Ohm

# TechSource: Uses the NG45 technology file to compute R and C_edge for each net in a batch. #
class TechSource:
    name = "tech"

    def setup(self, seg, meta):
        mc = meta["metal_cols"]
        self.r_l = np.array([R_OHM_PER_UM.get(c, 0.0) for c in mc], np.float64)
        self.c_l = np.array([C_FF_PER_UM.get(c, 0.0) for c in mc], np.float64) / 1000.0   # pF/um

    def edge_rc(self, batch):
        ml = batch["metal_lens"].numpy().astype(np.float64)  # (E, n_metals) um
        vc = batch["via_counts"].numpy().astype(np.float64)  # (E, n_vias)
        R = np.clip((ml * self.r_l).sum(1) + vc.sum(1) * R_PER_VIA, 1e-6, None)
        Ce = (ml * self.c_l).sum(1)
        return R, Ce

if __name__ == "__main__":
    E.main(TechSource(), _HERE / "predictions")
