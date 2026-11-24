// ============================================================
// TuGraph 实验1 作业1 —— Cypher 查询脚本
// 子图：elliptic    点：Transaction(id, category)    边：TRANSFER
// 以下语句均已在 tuGraph 4.3.1 上实际执行验证
// ============================================================

// ---------- 1. 数据完整性校验 ----------

// 点总数
MATCH (n:Transaction) RETURN count(n) AS c;
// => 203769

// 边总数
MATCH ()-[r:TRANSFER]->() RETURN count(r) AS c;
// => 234355

// 类别分布
MATCH (n:Transaction)
RETURN n.category AS category, count(n) AS total
ORDER BY total DESC;
// => unknown 157205 / licit 42019 / illicit 4545


// ---------- 2. 基础查询 ----------

// 2.1 按标签 + 属性匹配：找出非法交易
MATCH (n:Transaction {category:'illicit'})
RETURN n.id AS txId, n.category AS category
LIMIT 10;

// 2.2 等价的 WHERE 写法
MATCH (n:Transaction)
WHERE n.category = 'illicit'
RETURN n.id, n.category
LIMIT 10;

// 2.3 按 ID 精确查找（走主键索引）
MATCH (n:Transaction {id:2984918})
RETURN n;


// ---------- 3. 复杂查询 ----------

// 3.1 出度 TOP10：找出资金转出最频繁的中枢交易
MATCH (n:Transaction)-[:TRANSFER]->(m:Transaction)
RETURN n.id AS txId, count(m) AS outDegree
ORDER BY outDegree DESC
LIMIT 10;
// => 2984918 472 / 89273 288 / 102570 122 / 3181 112 / 7952 99 ...

// 3.2 资金流向矩阵：来源类别 -> 去向类别
MATCH (a:Transaction)-[r:TRANSFER]->(b:Transaction)
RETURN a.category AS src, b.category AS dst, count(r) AS cnt
ORDER BY cnt DESC;
// => unknown->unknown 131778, unknown->licit 45386, licit->licit 33930 ...
//    合计 234355，与边总数一致

// 3.3 两跳路径：非法 -> 中转 -> 非法
MATCH p=(a:Transaction {category:'illicit'})-[:TRANSFER*2]->(c:Transaction {category:'illicit'})
RETURN a.id AS fromId, c.id AS toId
LIMIT 5;

// 3.4 非法资金流向合法主体（反洗钱重点）
MATCH (n:Transaction {category:'illicit'})-[r:TRANSFER]->(m:Transaction {category:'licit'})
RETURN n.id AS srcId, m.id AS dstId
LIMIT 5;

// 3.5 只统计非法节点的出度 TOP5
MATCH (n:Transaction {category:'illicit'})-[r:TRANSFER]->(m:Transaction)
RETURN n.id AS txId, count(m) AS outDegree
ORDER BY outDegree DESC
LIMIT 5;


// ---------- 4. 增删改 ----------

// 4.1 创建
CREATE (n:Transaction {id:999999999, category:'test'})
RETURN n.id, n.category;

// 4.2 更新属性
MATCH (n:Transaction {id:999999999})
SET n.category = 'licit'
RETURN n.id, n.category;

// 4.3 删除属性（保留节点）
MATCH (n:Transaction {id:999999999})
REMOVE n.category
RETURN n.id;

// 4.4 删除节点（若存在关联边需一并删除）
MATCH (n:Transaction {id:999999999}) DELETE n;
// MATCH (n:Transaction {id:xxx})-[r]-() DELETE n, r;

// 4.5 删除后校验（应回到 203769）
MATCH (n:Transaction) RETURN count(n) AS c;
