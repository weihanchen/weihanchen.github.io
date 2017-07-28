---
categories: elasticsearch
title: elasticsearch-span-queries
date: 2017-06-27 12:17:39
tags:
---

Elasticsearch Span Queries
===
Elasticsearch Span Query跨度查詢,首先建立幾筆樣本資料進行測試。
```javascript
PUT test/span/1
{
    "dialogs": "Span queries are low-level positional queries which provide expert control over the order and proximity of the specified terms. These are typically used to implement very specific queries on legal documents or patents.Span queries cannot be mixed with non-span queries (with the exception of the span_multi query)"
}

PUT test/span/2
{
    "dialogs": "Matches spans containing a term. The span term query maps to Lucene SpanTermQuery. Here is an example"
}

PUT test/span/3
{
    "dialogs": "Matches spans near the beginning of a field. The span first query maps to Lucene SpanFirstQuery. Here is an example"
}

PUT test/span/4
{
    "dialogs": "Matches the union of its span clauses. The span or query maps to Lucene SpanOrQuery. Here is an example"
}

PUT test/span/5
{
    "dialogs": "Returns matches which enclose another span query. The span containing query maps to Lucene SpanContainingQuery. Here is an example"
}
```
## 常用的`span queries`
### span_term

類似於 `term` query，
```javascript
GET test/_search
{
   "query": {
      "span_term": {
         "dialogs": "containing"
      }
   }
}
```

另外也可以指定查詢權重
```javascript
    {
       "query": {
          "span_term": {
             "dialogs": {
                 "value": "containing",
                 "boost": 2.0
             }

          }
       }
    }
```

### span_multi
`span_multi`允許包裝`multi term query`(wildcard、fuzzy、prefix、range、regexp query)成`span_query`並嵌套於其中

```javascript
    {
        "query": {
            "span_multi":{
                "match":{
                    "prefix" : { "dialogs" :  { "value" : "containing" } }
                }
            }
        }
    }
```

### span_first
查詢某個單詞並設定起始偏移位置的最大範圍

```javascript
GET test/_search
{
   "_source": "none",
   "size": 1000,
   "query": {
      "span_first": {
         "match": {
            "span_term": {
               "dialogs": {
                  "value": "containing"
               }
            }
         },
         "end": 5
      }
   },
   "highlight": {
      "fields": {
         "dialogs": {}
      }
   }
}
```

### span_near
這個查詢主要用來確定幾個`span_term`之間的距離，並設定`slop`來限制詞之間的跨距限制,下面的例子中四個`span_term`,跨距限制至少要大於等於13, 且跨距的計算並不包過中間被包覆的`span_tern`，如下面的例子可以對照結果後計算出跨詞距離

```javascript
GET test/_search
{
   "_source": "none",
   "size": 1000,
   "query": {
      "span_near": {
         "clauses": [
            { "span_term": {"dialogs": "matches" }},
            { "span_term": {"dialogs": "containing" }},
            { "span_term": {"dialogs": "spantermquery" }},
            { "span_term": {"dialogs": "example" }}
        ],
        "slop": 13
      }
   },
   "highlight": {
      "fields": {
         "dialogs": {}
      }
   }
}
```

Results:

```javascript
 {
            "_index": "test",
            "_type": "span",
            "_id": "2",
            "_score": 0.16442803,
            "_source": {},
            "highlight": {
               "dialogs": [
                  "<em>Matches</em> spans <em>containing</em> a term. The span term query maps to Lucene <em>SpanTermQuery</em>. Here is an <em>example</em>"
               ]
            }
}
```

### span_or
多個詞之間的查詢條件,以`or`做為邏輯關係，也就是說下面的條件只要其中一組被命中到就算成立

```javascript
GET test/_search
{
   "_source": "none",
   "size": 1000,
   "query": {
      "span_or": {
         "clauses": [
            { "span_term": {"dialogs": "matches" }},
            { "span_term": {"dialogs": "containing" }},
            { "span_term": {"dialogs": "spantermquery" }},
            { "span_term": {"dialogs": "example" }}
        ]
      }
   },
   "highlight": {
      "fields": {
         "dialogs": {}
      }
   }
}

```

### span_not
`include`代表句子中需包含的條件，而`exclude`則是需排除的條件

```javascript
GET test/_search
{
   "_source": "none",
   "size": 1000,
   "query": {
      "span_not": {
         "include": {
            "span_term": {
               "dialogs": "example"
            }
         },
         "exclude": {
            "span_term": {
               "dialogs": "containing"
            }
         }
      }
   },
   "highlight": {
      "fields": {
         "dialogs": {}
      }
   }
}
```



### span_containing
查詢結構需包含`little`及`big`,代表`big`為最外層的查詢條件,而`little`則可以當作是`big`條件下的子查詢

```javascript
 GET test/_search
{
   "_source": "none",
   "size": 1000,
   "highlight": {
      "fields": {
         "dialogs": {}
      }
   },
   "query": {
      "bool": {
         "should": [
            {
               "span_containing": {
                  "little": {
                    "span_term": {
                        "dialogs": "which"
                    }
                  },
                  "big": {
                     "span_near": {
                        "clauses": [
                           {
                              "span_term": {
                                 "dialogs": "matches"
                              }
                           },
                           {
                              "span_term": {
                                 "dialogs": "another"
                              }
                           },
                           {
                               "span_term": {
                                   "dialogs": "query"
                               }
                           }
                        ],
                        "slop": 7,
                        "in_order": true,
                        "collect_payloads": false
                     }
                  }
               }
            }
         ]
      }
   }
}
```

### span_within
與`span_containing`相似,差別在於搜尋結果不包含big

```javascript
GET test/_search
{
   "_source": "none",
   "size": 1000,
   "highlight": {
      "fields": {
         "dialogs": {}
      }
   },
   "query": {
      "bool": {
         "should": [
            {
               "span_within": {
                  "little": {
                    "span_term": {
                        "dialogs": "which"
                    }
                  },
                  "big": {
                     "span_near": {
                        "clauses": [
                           {
                              "span_term": {
                                 "dialogs": "matches"
                              }
                           },
                           {
                              "span_term": {
                                 "dialogs": "another"
                              }
                           },
                           {
                               "span_term": {
                                   "dialogs": "query"
                               }
                           }
                        ],
                        "slop": 7,
                        "in_order": true,
                        "collect_payloads": false
                     }
                  }
               }
            }
         ]
      }
   }
}
```

# boost說明
主要用於調整查詢權重

```javascript
    GET /_search
    {
      "query": {
        "bool": {
          "should": [
            { "match": { 
                "title":  {
                  "query": "War and Peace",
                  "boost": 2
            }}},
            { "match": { 
                "author":  {
                  "query": "Leo Tolstoy",
                  "boost": 2
            }}},
            { "bool":  { 
                "should": [
                  { "match": { "translator": "Constance Garnett" }},
                  { "match": { "translator": "Louise Maude"      }}
                ]
            }}
          ]
        }
      }
    }
```

`title`和`author`的`boost`為`2`,嵌套語句預設的`boost`為`1`