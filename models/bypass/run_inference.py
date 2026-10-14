import sys
from pathlib import Path

import numpy as np
import torch

_HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(_HERE.parent / "common"))
import inference_engine as E
import train as TC   # import Bypass model class and MP_ROUNDS

class BypassSource:
    name = "bypass"

    def setup(self, seg, meta):
        ck = meta["ckpt"]
        TC.MP_ROUNDS = int(ck.get("mp_rounds", TC.MP_ROUNDS))
        self.model = TC.Bypass(ck["node_dim"], ck["edge_dim"], len(meta["metal_cols"]), len(meta["via_cols"]),
                               ck["cell_vocab_size"])
        missing, unexpected = self.model.load_state_dict(ck["model_state"], strict=False)
        unused = lambda k: k in {"c_L", "ctx_gate", "r_L_warm", "r_via_warm"} or k.startswith(("net_ctx.", "node_global_attn."))
        if missing:
            raise RuntimeError(f"checkpoint lacks weights of the model: {missing}")
        hard = [k for k in unexpected if not unused(k)]
        if hard:
            print(f"WARN: checkpoint weights not used by the model: {hard}")
        self.model.eval()

    def edge_rc(self, batch):
        with torch.no_grad():
            o = self.model(batch["node_feats"].float(), batch["edge_feats"].float(),
                           batch["edge_index"].long(), batch["metal_lens"].float(),
                           batch["via_counts"].float(), batch["cell_type_idx"].long(),
                           batch["graph_ids_node"].long(), batch["graph_ids_edge"].long())
        return o[3].numpy().astype(np.float64), o[4].numpy().astype(np.float64)   # R_eff, C_edge_eff


if __name__ == "__main__":
    E.main(BypassSource(), _HERE / "predictions")
