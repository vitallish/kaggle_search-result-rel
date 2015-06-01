# First go
require(readr);
og_train <- read_csv('raw-data/train.csv')

# some explortion
require(dplyr)
summary(og_train)
str(og_train)

sapply(og_train$product_description, function(x){
  strsplit(x,split =" ", fixed = T) %>% length
}, USE.NAMES = F) %>% hist

strsplit(og_train$product_description, split = " ", fixed =T) %>%  sapply(length)  %>% summary
require(ggplot2)
ggplot(aes(y =relevance_variance, x=as.factor(median_relevance)), data = og_train)+ geom_violin()

# explore specific entries
# where relevance = 4
og_train[1:1000,] %>% 
  glimpse()

require(stringr)
set.seed(11)
test <-og_train[sample(1:nrow(og_train),1000),]

q_t_perc <- sapply(1:1000, function(x){
  q = str_split(test$query[[x]]," ")[[1]] 
   sum(q %in% str_split(tolower(test$product_title[[x]]), " ")[[1]])/length(q)
}) %>% data.frame(perc =., rel = test$median_relevance) 

q_t_perc%>% 
  ggplot(aes(perc, rel), data = .)+ geom_jitter() + geom_smooth(method = "lm")

q_t_perc %>% 
  group_by(rel) %>% 
  summarise(mean(perc),sd(perc))

q_t_perc %>% 
  ggplot(aes(x=perc, fill = factor(rel)), data=.) + geom_density(alpha = 0.5)

q_t_count <- sapply(1:1000, function(x){
  q = unique(str_split(test$query[[x]]," ")[[1]] )
  sum(str_count(test$product_title[[x]], ignore.case(q)))/length(q)
}) %>% data.frame(count_perc =., rel = test$median_relevance)

q_t_count %>% 
  ggplot(aes(x=count_perc, fill = factor(rel)), data=.) + geom_density(alpha = 0.5)

q_t_count %>% 
  group_by(rel) %>% 
  summarise(mean(count_perc),sd(count_perc))

#shit there are hella 4s anyway
prop.table(table(q_t_count$rel))
require(rpart); require(rattle)
rpartmod <- rpart(as.factor(rel)~count_perc, data = q_t_count)
fancyRpartPlot(rpartmod)

set.seed(13)
test2 <- og_train[sample(1:nrow(og_train),1000),]
q_t_count2 <- sapply(1:1000, function(x){
  q = unique(str_split(test2$query[[x]]," ")[[1]] )
  sum(str_count(test2$product_title[[x]], ignore.case(q)))/length(q)
}) %>% data.frame(count_perc =., rel = test2$median_relevance)

out<-predict(rpartmod, q_t_count2, type = "class")
# not good, very unablanced data set
mean(out == q_t_count2$rel)

#caret
require(caret)
c_rpart <- train(as.factor(rel)~., data = q_t_count, method ='rpart', metric = "Kappa")
out <- predict(c_rpart, q_t_count2)


