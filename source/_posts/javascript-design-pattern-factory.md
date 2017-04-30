---
categories: javascript
title: javascript-design-pattern-factory
date: 2017-04-01 23:59:54
tags:
---

工廠模式就是負責來生產東西的，裡面當然包含著生產流程及各產品的生產方法，而該工廠則根據訂單生產不同類型的產品

#### 以下範例以生產巧克力為例，假設該工廠根據訂單生產出不同類型的巧克力棒、巧克力磚...等
- 客人是接洽工廠的人
- 客人只想看到成品不管生產過程
- 工廠接單後內部決定如何生產

#### 定義一個工廠類包含生產巧克力的方法，接收參數來決定生產種類

```javascript
function Factory(){
     this.productChoco = function(type){
          ....
     }
}
```

#### 在productChoco內部便可以定義生產流程

```javascript
var choco;
//產品標籤製作方法
this.chocoBar = function(){
    this.price = '$30';
    this.name = 'chocoBar'
}
this.chocoBrick = function(){
    this.price = '$50';
    this.name = 'chocoBrick';
}
//決定生產種類
if (type === 'bar') choco = new chocoBar();
else if (type === 'brick') choco = new this.chocoBrick();
//生產後貼上產品品標籤
choco.getProductInfo = function(){
    return 'name : ' + this.name + ',price : ' + this.price;
}
return choco;
```

#### 客人訂單
```javascript
function run(){
    var factory = new Factory();
    var barChoco = factory.productChoco('bar');
    var brickChoco = factory.productChoco('brick');
    console.log(barChoco.getProductInfo());
    console.log(brickChoco.getProductInfo());
}
```

#### 工廠模式的好處
- 增加程式碼彈性，降低耦合度，如上例子將生產產品的過程封裝後，到不同的地方都能進行生產，而且決定生產的入口只有一個，這對管理來說是一大便利
- 確保生產過程的一致性，不會因為不同客戶而所不同導致產品有落差
- 減少重複生產(重複程式碼)的問題，假若未使用工廠模式，在各個客戶端生產時會發生如下問題，客戶A與B生產相同東西，卻要將原料、機器各派一份至客戶端進行生產，造成成本的浪費