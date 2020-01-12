---
title: "物件的語法糖"
date: 2020-01-12T20:09:37+08:00
categories: [es6]
draft: true
---

<!--more-->

## 簡化物件的返回值

```javascript
const request = () => {
    const code = 200;
    const body = "ok";
    return { code, body };
}

console.log(request());// { code: 200, body: "ok"}
```

## 定義物件的時候其key值也可以加入邏輯判斷、運算

```javascript
const flag = true;
const name = 'john';
const n = 1

const obj = {
    [name + n]: 18, // { john1: 18 }
}
```