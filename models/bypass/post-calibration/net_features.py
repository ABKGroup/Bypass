import pandas as pd

LEN_COLS = ["len_metal%d" % i for i in range(1, 11)]
READ_COLS = ["net_key", "net_n_segments", "net_total_vias"] + LEN_COLS


def clean(name):
    return str(name).replace("\\", "")

def net_features(segments_csv, keep_runs=None):
    parts = []
    for ch in pd.read_csv(segments_csv, usecols=READ_COLS, low_memory=False, chunksize=1000000):
        ch["run"] = ch.net_key.str.split("/").str[0]
        if keep_runs is not None:
            ch = ch[ch.run.isin(keep_runs)]
        if ch.empty:
            continue
        ch["wl"] = ch[LEN_COLS].fillna(0).sum(axis=1)
        ch["up"] = ch[LEN_COLS[6:]].fillna(0).sum(axis=1)
        ch["mid"] = ch[LEN_COLS[3:6]].fillna(0).sum(axis=1)
        # One row per per net: run, key, wl, up_share, mid_share, number of segments and number of vias #
        parts.append(ch.groupby(["run", "net_key"]).agg(wl=("wl", "sum"), up=("up", "sum"), mid=("mid", "sum"),
                                                        nseg=("net_n_segments", "first"), nvia=("net_total_vias", "first")).reset_index())
    n = pd.concat(parts).groupby(["run", "net_key"]).agg(dict(wl="sum", up="sum", mid="sum", nseg="first", nvia="first")).reset_index()
    n["up_share"] = n.up / n.wl.clip(lower=1e-9)
    n["mid_share"] = n.mid / n.wl.clip(lower=1e-9)
    n["key"] = n.net_key.map(clean)
    return n[["run", "key", "wl", "up_share", "mid_share", "nseg", "nvia"]]
