#install.packages("RSelenium")
#install.packages("rJava")
#library(rJava)

library(RSelenium)
library(tidyverse)

#rsDriver()

rs <- rsDriver(browser="firefox", check=F)
browser <- rs$client
browser$navigate("https://twitter.com/explore")

input <- browser$findElement(using = 'xpath', "//input[@enterkeyhint='search']") # ссылка на коробку с запросом
input$sendKeysToElement(list("$python", key = "enter")) #ввел запрос «пайтон» и нажал на энтер для поиска

keyword <- "$python"
since <- "2020-05-20"
until <- "2020-05-25"

query <- sprintf("%s since:%s until:%s", keyword, since, until)

input$clearElement() # очистит окно для запроса

input$sendKeysToElement(list(query, key = "enter"))

tws <- browser$findElements(using = 'xpath', "//div[@data-testid='tweet']")
tw1 <- tws[[1]]
tw1$getElementText()
html <- tw1$getElementAttribute("innerHTML")# получили доступ к хтмл коду твиттов

library(rvest)

date <- read_html(html[[1]]) %>%
  html_nodes("time") %>%
  html_attr("datetime")

reply <- read_html(html[[1]]) %>%
  html_nodes(xpath = "//div[@data-testid='reply']") %>%
  html_text()

like <- read_html(html[[1]]) %>%
  html_nodes(xpath = "//div[@data-testid='like']") %>%
  html_text()

retweet <- read_html(html[[1]]) %>%
  html_nodes(xpath = "//div[@data-testid='retweet']") %>%
  html_text()

text <- tw1$getElementText()

get_tweet <- function(tw0){
  html <- tw0$getElementAttribute('innerHTML')
  date <- read_html(html[[1]]) %>% html_nodes("time") %>% html_attr("datetime")
  reply <- read_html(html[[1]]) %>% html_nodes(xpath="//div[@data-testid = 'reply']") %>% 
    html_text()
  retweet <- read_html(html[[1]]) %>% html_nodes(xpath="//div[@data-testid = 'retweet']") %>% 
    html_text()
  like <- read_html(html[[1]]) %>% html_nodes(xpath="//div[@data-testid = 'like']") %>% 
    html_text()
  text <- tw0$getElementText()[[1]]
  L <- c(date = date, reply = reply, retweet = retweet, like = like, 
         text = text)
  return(L)
}

twee <- lapply(tws, get_tweet) %>%
  as.data.frame %>%
  t %>%
  as.data.frame
rownames(twee) <- 1:nrow(twee)


browser$executeScript("window.scrollTo(0, 3200)")

browser$executeScript("return document.body.scrollHeight")
last_height <- browser$executeScript("return document.body.scrollHeight")[[1]]
all_tweets <- c()

while (TRUE){
  browser$executeScript("window.scrollTo(0, document.body.scrollHeight)")
  Sys.sleep(4)
  new_height <- browser$executeScript("return document.body.scrollHeight")[[1]]
  tweets <- browser$findElements(using = "xpath", "//div[@data-testid = 'tweet']")
  twee <- lapply(tweets, get_tweet) 
  all_tweets <- c(all_tweets, twee)
  
  if (new_height == last_height){break}
  last_height <- new_height
}

all_tweets


