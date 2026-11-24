# -*- coding: utf-8 -*-
"""生成 TuGraph 导入用 CSV（字段用 category，避免 class 在 Cypher 中歧义）。"""
import os
import pandas as pd

os.makedirs("import", exist_ok=True)

cls = pd.read_csv("elliptic_txs_classes.csv")
edge = pd.read_csv("elliptic_txs_edgelist.csv")

MAP = {"1": "illicit", "2": "licit", "unknown": "unknown"}

tx = pd.DataFrame({
    "id": cls["txId"].astype("int64"),
    "category": cls["class"].map(MAP).fillna("unknown"),
})
tx.to_csv("import/Transaction.csv", index=False, encoding="utf-8")

tr = pd.DataFrame({
    "src": edge["txId1"].astype("int64"),
    "dst": edge["txId2"].astype("int64"),
})
tr.to_csv("import/Transfer.csv", index=False, encoding="utf-8")

print("Transaction:", len(tx), dict(tx["category"].value_counts()))
print("Transfer:", len(tr))
print(tx.head(3).to_string(index=False))
print(tr.head(3).to_string(index=False))
