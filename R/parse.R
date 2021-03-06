#install.packages("rvest")
#install.packages("RSelenium")
#install.packages("rJava")

# Libraries!

# library(RSelenium)
# library(rJava)
library(rvest)
library(tidyverse)
library(readxl)
library(writexl)

# Simple scrap from the one-paged web site ----

link1 <- read_html("http://rabota.kitabi.ru/otzyvy-sotrudnikov/grinatom-zao")

dates_link1 <- link1 %>% 
  html_nodes(".reviews-list-item-date") %>% 
  html_text() %>% 
  as.data.frame() %>% 
  rename(date = ".")

comments_link1 <- link1 %>%
  html_nodes(".reviews-list2-item-text") %>%
  html_text() %>% 
  str_trim(side = "both") %>% 
  as.data.frame() %>% 
  rename(comment1 = ".") %>% 
  as.data.frame() %>% 
  mutate(comment2 = "")

link1_final <- cbind(dates_link1, comments_link1)

# Trying to scrap comments from the web site with multiple pages ----

#rsDriver()

# rs <- rsDriver(browser = "firefox", check = FALSE)
# 
# rd <- rsDriver(browser="chrome",
#                extraCapabilities=list("C://Users//Кирилл//Desktop//RRR//driver//chromedriver.exe"),
#                chromever="92.0.4515.107",
#                check = FALSE)

python_excel <- read_xlsx("./output/О-Работе-комментарии-Гринатом.xlsx") %>% 
  rename(comment1 = positive,
         comment2 = negative) %>% 
  select(-1) %>% 
  rbind(comments_link1) %>% 
  writexl::write_xlsx("./output/comments_all_greenatom.xlsx")

