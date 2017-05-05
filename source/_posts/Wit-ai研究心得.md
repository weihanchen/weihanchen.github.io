---
categories: chatbot
title: Wit.ai研究心得
date: 2017-05-05 12:12:30
tags:
---

以下紀錄了實際操作[Wit.ai](https://wit.ai/)相關心得及操作，並延伸至nodejs api應用面，註冊及基本使用方式可以參考至[https://wit.ai/docs/quickstart](https://wit.ai/docs/quickstart)，以下針對重點紀錄：

## 實體(Entity)
所謂Entity指的是實體物件中組成的類別，也就是會將相同類型的物件歸屬於相同類別，例如說User是一個實體而User中的username、password則為該實體之下的相關屬性(attribute)，wit.ai中對話意圖也可以當成一個實體來使用。

#### Wit.ai中將實體(Entity)分為三大類，也就是說我們希望Wit.ai利用這三大類怎麼從句子中找出Entity：
- 特性(Trait)： 以整個句子來獲得實體，例如： [今天是禮拜一嗎?], 這個句子我們可能定義一個`intent`為`yes_or_no`其中集合只有`['yes', 'no']`這兩種特定集合, 也就是根據這個句子來獲得`yes_or_no`這個實體中的`yes`、`no`。
- 關鍵詞(Keywords)： 需完全符合預先設定的關鍵字才會觸發，如下圖中從`禮拜一我要去爬山`中擷取`爬山`並歸類為`spot`。
![Keywords](keywords.gif)
- 自由本文(Free Text): 擷取句子中某段文字，只要符合就能夠被觸發，如下圖中從`禮拜一我要去爬山`中擷取`要去爬山`並歸類為`schedule`，而wit.ai中Free Text需搭配Keywords一起使用。
![Free Text](free_text.gif)

特性(Trait)與其他兩種是不相容的，而關鍵詞與自由本文則可相容，也就是說一個實體可以為關鍵詞與自由本文兩種類別。

## 故事(Stories)
一個故事模擬使用者發問後的某個情境流程，我們可以看到頁面中有四個功能分別為：
- User says: 這裡表示User可能會說的話並設定Entity來標示使用者有哪些關鍵字、哪段文字代表什麼意義。
- Bot sends: bot回應的訊息內容，其中可以User輸入的關鍵字回應，或者透過呼叫外部API的方式來完成User的需求。
- Bot executes: 讓我們定義Bot要執行的function，這裡僅定義名稱，實作則透過API，以下會使用Nodejs當範例。
- Jump: 當滿足了某些條件下，可以跳至某個Bot executes或Bot sends

#### 實際定義一個簡單回覆訊息的User story
![Story1](story1.gif)

#### 使用Bot executes
假如一個Bot只是單純回應User的輸入無法處理事情的話，那麼就失去了設計Bot的意義了，所以我們可以使用`Bot executes`來讓Bot幫我們執行一些事情，
這裡我們設定一個function `setSchedult`以及輸出的參數在這邊我們並不實作它。

![Executes](executes1.gif)

設定完成後記得訓練一次，讓機器人知道要以剛剛設定的`scheduleResult`當作回覆，讓機器人記住這個context

![Context key](context_key.gif)

## 使用Nodejs API來實作executes function
流程中我們會記錄使用者輸入的日期、地點、運動種類，因此我們需要針對這些操作分別設計`Bot executes`
![Executes full](executes_full.gif)

首先我們先從`Settings` > `API Details` > `Server Access Token` 取得token

Pending...
