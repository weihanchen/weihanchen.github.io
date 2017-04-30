---
categories: web
title: Service workers
date: 2017-04-30 23:05:40
tags:
---

Service worker與Web workers相同，也都是一段運行在瀏覽器後台的腳本，提供一些不需要與頁面直接交互的功能(操作dom)，主要處理網路相關的問題，可以攔截網路請求進行相對應的優化動作，我們把它想像成與伺服器之間的代理服務器可能會比較容易理解，當網路環境不佳時便回應快取資源，待網路順暢後同步最新資料，因此能提高更好的離線體驗，我們可能會想說為什麼有了Web workers、AppCache這類的API還需要Service worker呢?因為這些既有的功能主要都由我們自己去handle一些細緻的操作，過程非常繁瑣，因此發展出Service worker，背後幫我們解決掉許多事情(error handler、http request  listener...)

## 功能
-   資源快取
-   離線應用
-   多頁面傳遞(Post Message)
-   推播通知
-   後台自動更新

## 生命週期
{% asset_img life_circle.png Life Circle %}

> 1.  註冊Service worker
> 2.  註冊之後瀏覽器會在背景啟動Service Worker的安裝
> 
> -   安裝過程中會將設定的靜態資源進行緩存，待所有靜態資源緩存成功後進入Activated狀態
> -   如果過程中任何一個資源不能成功緩存則代表安裝失敗，進入error，待重新安裝
> 
> 3.  進入Activated狀態後進行監聽，當request或post message發生時則觸發相對應動作
> 4.  Terminated狀態由瀏覽器決定是否銷毀，如果長期不使用或者記憶體不足時，則可能銷毀這個worker

## Worker中常使用的事件
{% asset_img events.png Events %}

## 簡單實作Service Worker

### 註冊Service Worker

```html
            <html>
               <body>
                  <script>
                     if ('serviceWorker' in navigator) {
                        navigator.serviceWorker.register('./sw.js')
                           .then(reg => console.log(reg))
                           .catch(err => console.log(err));
                     }
                  </script>
               </body></html>
```

### 撰寫sw.js腳本檔

```javascript
            const cacheUrl = [
               './index.html',
               './script.js',
               './car.svg'
            ];
            const cacheName = 'precache' + (self.registration ? self.registration.scope: '');
            self.addEventListener('install', (event) => {
               event.waitUntil(
                  caches.open(cacheName)
                     .then((cache) => {
                        console.log('open cache');
                        return cache.addAll(cacheUrl);
                     });
               );
            });
            //clean cached files
            self.addEventListener('activate', (event) => {
               event.waitUntil(
                  caches.keys().then(function(cacheNames) {
                                    var promiseArr = cacheNames.map(function(item) {
                                            if (item !== cacheName) {
                                                    return caches.delete(item);
                                            }
                                    })
                                    return Promise.all(promiseArr);
                            })
               )
            });
            self.addEventListener('fetch', (event) => {
                //cache first
                event.respondWith(caches.match(event.request).then(res => {
                  if (res) {
                     console.log('match');
                     return res;
                  }
                  return fetch(event.request);
               }));
            });
```

## cache的策略

### Cache only

這種方式下任何請求都會從Cache storage取得

![Cache only](https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/images/ss-cache-only.png)

```javascript
    self.addEventListener('fetch', function(event) {
      event.respondWith(caches.match(event.request));
    });
```

### Network only

這種方式下任何請求都不會跟Cache storage打交道，直接向後端發送

![Network only](https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/images/ss-network-only.png)

```javascript
    self.addEventListener('fetch', function(event) {
      event.respondWith(fetch(event.request));
      // or simply don't call event.respondWith, which
      // will result in default browser behaviour
    });
```
### Cache first

頁面發送request時會先從Cache storage中存取若發現該請求尚未被緩存到則會改為Network請求

![Cache first](https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/images/ss-falling-back-to-network.png)

```javascript
    self.addEventListener('fetch', function(event) {
      event.respondWith(
        caches.match(event.request).then(function(response) {
          return response || fetch(event.request);
        })
      );
    });
```

### Network first

頁面發送request時會先由Network向後端請求，若請求失敗則改由Cache storage請求

![Network first](https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/images/ss-network-falling-back-to-cache.png)

```javascript
    self.addEventListener('fetch', function(event) {
      event.respondWith(
        fetch(event.request).catch(function() {
          return caches.match(event.request);
        })
      );
    });
```

### Cache & network race

頁面發送request時同時向Cache及Network請求，哪一個請求先回來則使用該response

![Cache network race](https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/images/ss-cache-and-network-race.png)

```javascript
    // Promise.race is no good to us because it rejects if// a promise rejects before fulfilling. Let's make a proper// race function:function promiseAny(promises) {
      return new Promise((resolve, reject) => {
        // make sure promises are all promises
        promises = promises.map(p => Promise.resolve(p));
        // resolve this promise as soon as one resolves
        promises.forEach(p => p.then(resolve));
        // reject if all promises reject
        promises.reduce((a, b) => a.catch(() => b))
          .catch(() => reject(Error("All failed")));
      });
    };

    self.addEventListener('fetch', function(event) {
      event.respondWith(
        promiseAny([
          caches.match(event.request),
          fetch(event.request)
        ])
      );
    });
```

### Cache then network

頁面發送request時先由Cache storage取得顯示給user，然後再由Network取得後更新資料。

![Cache then network](https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/images/ss-cache-then-network.png)

Code in Page

```javascript
    var networkDataReceived = false;

    startSpinner();

    // fetch fresh data
    var networkUpdate = fetch('/data.json').then(function(response) {
      return response.json();
    }).then(function(data) {
      networkDataReceived = true;
      updatePage();
    });

    // fetch cached data
    caches.match('/data.json').then(function(response) {
      if (!response) throw Error("No data");
      return response.json();
    }).then(function(data) {
      // don't overwrite newer network data
      if (!networkDataReceived) {
        updatePage(data);
      }
    }).catch(function() {
      // we didn't get cached data, the network is our last hope:
      return networkUpdate;
    }).catch(showErrorMessage).then(stopSpinner);
```

Code in the ServiceWorker: 當網路請求資源成功時，更新緩存內容

```javascript
    self.addEventListener('fetch', function(event) {
      event.respondWith(
        caches.open('mysite-dynamic').then(function(cache) {
          return fetch(event.request).then(function(response) {
            cache.put(event.request, response.clone());
            return response;
          });
        })
      );
    });
```

## 相關概念

-   Service worker與Web worker一樣不能直接對dom結構進行操作，僅透過`postMessage`相互溝通
-   基於安全考量Service worker只能運行在`https`的環境之上，畢竟修改網路請求的能力是相對危險的
-   使用Service worker來進行cache優於一般worker的原因是Service worker能夠細緻的控制，例如發生error時直接於worker內部進行相對應處理，而一般worker僅能於產生worker的那個頁面進行，且API相對較少

## [實際操作](https://demopwa.in/)

## Service worker相關的library

`sw-precache`主要根據配置來產生service worker腳本檔的工具，而`sw-toolbox`則是`sw-precache`的加強工具，可以針對動態請求進行細部控制

-   [sw-precache](https://github.com/GoogleChrome/sw-precache): 主要專注在靜態檔案的cache
-   [sw-toolbox](https://github.com/GoogleChrome/sw-toolbox): 針對動態請求進行細部操作

## [各家瀏覽器支援狀況](http://caniuse.com/#search=service%20workers)

## 參考資源

- [Cache API](https://developer.mozilla.org/zh-TW/docs/Web/API/Cache)
- [Service Worker Introduction](https://developers.google.com/web/fundamentals/getting-started/primers/service-workers)
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)

