---
title: "擴展運算子 Spread Operator"
date: 2020-01-12T19:09:37+08:00
categories: [es6]
draft: true
---

<!--more-->

常常我們可以看到es6語法出現了`...`這樣子的符號, 而`...`本身就具有無限想像的意思, 因此被設計為擴展的用途。

## 情境一: 擴展元素到函數的參數

```javascript
const add = (a, b) => {
    return a + b;
};

const nums = [1 , 2];
add(...nums);

// 又等同於
add(1, 2);
```

## 情境二: 串接陣列

```javascript
const a = [1,2,3];
const b = [4,5,6];

const c = [...a, ...b];

console.log(c); // [1,2,3,4,5,6]
// 又等同於
const d = a.concat(b);
```