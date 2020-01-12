---
title: "樣板字串 String Template"
date: 2020-01-12T19:09:37+08:00
categories: [es6]
draft: true
---

<!--more-->

樣板文字用反引號表示: ``, 如下:

```javascript
const html = '<div>' 
    + template.link
    + '</div>';
```

等同於
```javascript
const html = `<div>
                ${template.link}
              </div>`
```



