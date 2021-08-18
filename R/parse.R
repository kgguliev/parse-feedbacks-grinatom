#install.packages("rvest")

library(rvest)
library(tidyverse)

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
  rename(comment = ".")

link1_final <- cbind(dates_link1, comments_link1)
