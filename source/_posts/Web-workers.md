---
categories: web
title: Web workers
date: 2017-04-26 21:00:31
---

Web Workers主要提供簡單的API讓網頁在背景執行緒中執行程式而不干擾使用者的操作

## 為什麼javascript要設計為單執行緒?
javascript主要功能是與user操作頁面互動及操作dom，試想若使用多執行緒的概念，那麼一個動作是新增至某個dom節點，另一個動作則是修改該dom節點，此時瀏覽器應該使用哪個動作為準?
所以為了避免複雜性才設計為單執行緒

## 理解javascript非同步的概念
單執行緒就表示說所有任務都需要排隊處理，相對的效率較低落，IO或Network request通常需要等待較長的時間，如果前端頁面常常因為這些動作發生堵塞則user看到的畫面就是整個鎖死的，因此javascript使用了一些機制來避免這個問題，主要將任務分為兩種：

- 同步任務： 主執行緒上排隊執行的任務
- 異步任務： 不進入主執行緒，而是進入任務佇列等待執行

{% asset_img event_loop.png Event loop %}

上圖的執行機制
>1. 主程序會先從stack中執行function
>2. 執行過程中遇到setTimeout這類的非同步API呼叫，會透過事件委託的機制掛一個callback到setTimeout之類的Web API，執行完畢後會將該callback傳入上圖的callback queue等待。
>3. 執行堆棧空閒時才從callback queue中取出任務執行
>4. 因此我們才會使用setTimeout的技巧讓一些需要長時間計算的任務排到任務佇列中等待，然而主執行緒就不會因為這個任務發生阻塞現象，可以先執行觸發loading動畫的事件後才處理這些耗時的任務，讓user感覺到畫面並非被鎖死

上面的技巧雖然解決了畫面被鎖死的問題，但實際上執行的時間並沒有減少，因此發展出了Web Worker的機制，讓我們在web上也能有多執行緒的功能，最大化的利用系統資源，但是仍有部分功能受限

## Web Workers的類型
Web Workers依照用途又分為Dedicated workers與Shared workers

- Dedicated workers: 只能與產生它的頁面相互溝通
- Shared workers: 只要是相同來源(分頁、iframe)上執行的程序都能夠相互溝通 

## 應用的情境
一般狀況下或許我們不需要Web Workers來處理程式執行過久的情境，但是若能運用Web Workers或許能將部分Server的運算工作轉移至前端執行，以下是一些大量運算的使用情境：

- 解密等複雜的數學運算
- 排序大量的array
- 緩存資料
- 語法高亮標記、拼音檢查
- 影像、視訊、音頻的解析處理
- polling web services

## Work中常用的方法

- `postMessage(data)` 

    > 子線程與主線程之間相互溝通的方法，傳遞的data為任意值
- `onmessage` 
    > 監聽線程之間message的傳遞，當線程之間觸發postMessage時，能夠藉由onmessage順利接收傳遞的資料。
- `onerror`
    > 常用於debug
- `terminate()` 
    > 主線程中終止worker任務的API，一旦終止後不能再次啟用，只能重新創建

## 使用上的限制
Web Workers因為安全性問題所以使用上需要有一些使用上的限制:

- 無法訪問主頁面的dom結構
- 無法使用全域變數或者全域函數
- 無法使用window或document
- 不能傳遞functions

{% asset_img use_limit.png Use limit %}

## 可以使用的API
上面提到那麼多的限制，那麼Web Workers到底能夠做什麼?

以下列出幾個較常且可以使用的function

- `setTimeout、clearTimeoput、setInterval` 等定時器相關的方法
- `navigator` 識別瀏覽器的相關資訊
- `importScripts()` 允許worker載入依賴套件到自己的作用域內
- `XMLHttpRequest、Websocket` 與後端之間的通訊
- `location` read only
- [Functions and classes available to Web Workers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Functions_and_classes_available_to_workers)有詳細列出更多可以使用的function

## 開始使用Web Workers
這裡主要針對`Dedicated workers`示範使用方式，而`Shared workers`操作方式大致上相同於`Dedicated workers`因此僅需要了解概念即可
### 首先需要檢查瀏覽器是否支援Web Workers

```javascript
function isWebWorkerSupport() {
   return typeof Worker !== "undefined";
}

if (isWebWorkerSupport()) {
   ....
} else {
   alert("Ops, your browser doesn't support Web Worker");
}
```

### 簡單的創建一個Worker

```javascript
var worker = new Worker("worker.js");
```

### 與Worker之間的溝通方式

main.js

```javascript
//傳遞消息給worker這裡可以是array、string、number等型態
worker.postMessage("Send to worker");
//監聽message事件，接收worker回報的訊息
worker.onmessage = function(e) {
   console.log(e.data);
}
```

worker.js

```javascript
self.onmessage = function(e) {
   //處理複雜運算完成後回報運算結果或者通知
   self.postMessage("finished");
}
```

### 終止worker工作
當每個worker thread完成工作時記得終止，讓瀏覽器能夠釋放資源

```javascript
worker.terminate();
```

## [實際範例](https://embed.plnkr.co/OTK0kx/)

## [各家瀏覽器支援狀況](http://caniuse.com/#feat=webworkers)

## References

- [https://www.w3.org/TR/workers/](https://www.w3.org/TR/workers/)
- [https://developer.mozilla.org/zh-TW/docs/Web/API/Web_Workers_API/Using_web_workers](https://developer.mozilla.org/zh-TW/docs/Web/API/Web_Workers_API/Using_web_workers)
- [Background JavaScript Makes Web Apps Faster](https://blogs.msdn.microsoft.com/ie/2011/07/01/web-workers-in-ie10-background-javascript-makes-web-apps-faster/)
- [event loop](https://www.youtube.com/watch?v=6MXRNXXgP_0)