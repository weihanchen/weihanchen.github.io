---
categories: orientdb
title: 初探OrientDB
date: 2017-05-25 11:43:35
tags: 
---

初學OrientDB的一些心得記錄，並以實例來理解基礎操作

## OrientDB支援模式
OrientDB主要支援以下兩種模式

### Document Model
文檔型模式，這種類型主要以key/value來存儲資料，非常適合非結構化的資料結構，以下說明關聯式模型與文檔型模型之間的對應關係。

|關聯式模型|文檔式模型|
|:---------:|:---------:|
|Tabel|Class or Cluster|
|Row|Document|
|Column|Key/value pair|
|Relationship|Link

### Graph Model
圖形模式主要以節點(Node)與邊(Edge)來進行連結，定義如下：
- vertex - 頂點，一個實體可以連接到其他的頂點，並且具有以下的屬性：
   - 唯一識別性
   - 其他頂點連至本身的Edge集合(incoming)
   - 本身連至其他頂點的Edge集合(outgoing)
- edge - 邊，用來連結頂點的實體
   - 唯一識別性
   - 連入的頂點(head)
   - 連出的頂點(tail)
   - 標示頂點間的關係
以下說明關聯式模型與圖形模型之間的對應關係

|關聯式模型|圖形模型|
|:--------|------:|
|Table|Class or Cluster
|Row|Vertex|
|Column|Key/value pair|
|Relationship|Edge|

## 基礎概念

### Record
讀取與儲存的最小單元，主要有以下四種類型：
- 文件
- 紀錄的文字
- 頂點
- 邊

### Record ID
OrientDB內表示為`@rid`，每當產生一筆紀錄時將自動分配一個唯一的標示由Cluster與位置組成`#<cluster>:<position>`

### Class
類的概念來自物件導向，可以繼承自其他類形成樹狀體系，每個類又擁有自己的Cluster，一個類至少在一個Cluster底下，也可以隸屬於多個Cluster

## 名詞解釋
- Properties
   - 具有資料型態(Boolean、Integer)
   - 可以被indexed
- Vertex
   - 具備連結關係: `incoming edges`、`outgoing edges`
   - 也被稱為`Nodes`
   - 可以想像為圖的圓圈
   
```json
{
   @rid: 20:23
   name: "wendy",
   in: [#13:2, #13:45],
   out: [#12:10, #14:33]
}
```

- Edge
   - 紀錄`Vertex`之間的關係
   - 雙向
- Class
   - 資料的類型
   - 例如`Person`、`SuperHero`

```json
{
   superclass: "Person",
   clusters: [15],
   defaultCluster: 15,
   properties: [
      {
         name: "steven",
         type: "LONG",
         readyonly: false
      }
   ]
}
```

- Cluster
   - 多個`Person`類別歸在某個`Cluster`
   - 儲存、擴展、封存
   - 查詢最佳化(Map/Reduce Query)

## 開始進入OrientDB，並實作人與公司之間的案例
假設已經將[OrientDB](https://orientdb.com/docs/2.1/Tutorial-Installation.html)安裝完成後進入下面步驟,分別示範`Person`、`Company`、`WorksAt`之間的關係。

### 網頁UI編輯模式
進入`localhost:2480`，依據主機ip與啟動port號不同自行修改。

### 創建db 
![Create db](create_db.gif)

### 創建class 
其中`WorkAt`繼承自`edge`用來連結`Company`及`Person`
Command
```sql
create class Person extends V
create class Company extends V
create class WorkAt extends E
```

### 創建property
Command
```sql
create property Person.firstName string
create property Person.lastName string
create property Company.name string
```

### 新增sample data
Command
```sql
insert into Person (firstName, lastName) values ("Gary", "White"), ("Join", "Steven"), ("Lin", "Tom")
insert into Company set name = "ABC"
insert into Company set name = "XYZ"
```

### 查詢class
```sql
select from V
```

### Match查詢語法
語法結構，類似於neo4j中的[Cypher](https://neo4j.com/developer/cypher-query-language/)語法
```
MATCH 
  {
    [class: <class>], 
    [as: <alias>], 
    [where: (<whereCondition>)]
  }
  .<functionName>(){
    [class: <className>], 
    [as: <alias>], 
    [where: (<whereCondition>)], 
    [while: (<whileCondition>)],
    [maxDepth: <number>],
    [optional: (true | false)]
  }*
RETURN <expression> [ AS <alias> ] [, <expression> [ AS <alias> ]]*
LIMIT <number>
```
查詢範例
```
MATCH {class: Person, as: Person} RETURN $elements
```

### 創建edge
```sql
create edge WorkAt from #12:0 to #13:0
```

### 進到graph頁面查看關係圖
```sql
select from V
```
![Graph Relation](graph_relation.png)

### 直接藉由UI建立關聯
![Create Relation](create_relation.gif)

### 由UI產生新的vertex
![Create Node](create_node.gif)

## Console模式

### 啟動
```sh
cd orientdb/bin
./server.sh
# open new tab
./console.sh
```

### 建立db
```sh
create database remote:localhost/Demo root hello plocal
# plocal is storage type
```

### 停止連接
```sh
disconnect
```

### 連接
```sh
connect remote:localhost/databases/Demo root hello
```

### 其餘commands類似於Web UI操作

## 注意重點
### edge、linklist、linkmap
- `edge`: 代表兩個頂點間的關係，`Person`與`Car`這兩個頂點間連接著`Drives`這個`Edge`，例如Jane Drives Ford
- `link`: 代表與其他classes之間共同property的關聯與edge最大的差別在於沒有一個實體來記錄兩個class之間的關係。
- `linkist`： 代表多個class關聯到某個class，例如`Car`這個class可能由`Part`中多個部分組成
- `linkmap`： 
差異圖

## 進階操作
- [Transactions](http://orientdb.com/docs/last/OrientJS-Transactions.html)
- [Server Side Functions](https://orientdb.com/docs/2.2/Functions-Server.html)

## 參考資料
- [udemy-orientdb](https://www.udemy.com/orientdb-getting-started)