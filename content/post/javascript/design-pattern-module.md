---
title: "Javascript Design Pattern Module"
date: 2017-03-30T17:09:37+08:00
categories: [javascript]
draft: true
---

#### Module Pattern的特點
- 模組化
- 封裝性、鬆耦合
- 只暴露public方法，隱藏private方法
<!--more-->
#### 基本用法
```javascript
 var Calculator = (function() {
    var self = {};
    var msg = 'Please input current number.'; //私有成員
    function divide(a, b) { //內部定義除法
        if (b <= 0) console.log(msg);
        else return a / b;
    }
    self.divide = divide;
    return self
}());
console.log(Calculator.divide(6,3));
```

#### 擴展: 開發大型專案時，常常需要將不同功能的代碼拆分，讓多人可以分工開發，此時當基本模組建立後，各功能的負責成員便可基於此模組進行擴展開發各子功能。
```javascript
Calculator = (function(self) {
    self.add = function(a, b) {
        return a + b;
    }
    return self;
}(Calculator));
console.log(Calculator.add(6,3));
```

#### 子模組：假設計算器中定義了進階計算的子模組進行平方運算，便可以下列程式碼為例：
```javascript
Calculator.advanced = (function(){//進階計算
    var self = {};
    self.square = square;
    function square(a){//平方運算
         return a * a;
    }
    return self;
}())    
console.log(Calculator.advanced.square(3));
```