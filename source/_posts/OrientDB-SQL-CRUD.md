---
categories: orientdb
title: OrientDB-SQL-CRUD
date: 2017-05-22 16:53:11
tags:
---

這裡紀錄一些重要的CRUD語法

## 查詢
針對某些rid查詢
```sql
select from [#13:0,#14:0]
```

使用`count`函數
```sql
select count(*) from Person
```

搭配過濾條件
```sql
select from Model where name like "C%"
```

排序
```sql
select distinct(firstName) as name from Person order by name asc
```

eval表達式運算
```sql
select eval("highwayMPG - cityMPG") as variance from Model
```

## 新增
新增多筆紀錄
```sql
insert into Model (name, cityMPG, highwayMPG, modelYear) values ("car1", 10, 20, 2013),("car2", 11, 21, 2014)
```

新增記錄藉由json
```sql
insert into Person content {"firstName": "A", "lastName": "B", "info": {"hair": "black", "eyes": "blue"}}
```

藉由建立vertex方式
```sql
create vertex Person content{firstName: "wang", lastName: "pine"}
```

## 更新
upsert: 當查詢條件存在時則更新，否則新增
```sql
update Person set firstName = "Alberto" upsert where first="wrongname"
```

update and return
```sql
update #13:6890 set firstName="Alberto2" return after
```


