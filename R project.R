### wine quality classification project


����ġ 4898���� 12�� ������ ���� �Ǿ��ִ� ������
11���� ȭ�� ���е��� ���������� ����Ͽ� ������ ǰ��(quality)�� �����ϴ� ���� ����
������ ���� �ڼ��� ������ �Ʒ��� �����ϴ�.

11�� ������ �� ������ ǰ��(quality)�� ���� ������ ���� ���� ���ڿ� (alcohol)���� �� �� �ִ�.

������ ǰ��(quality)�� 0�� 10 ������ ���� �����ϴ� ȸ�ͺм��� �ƴ�,
ǰ���� ���� ������ �����ϴ� ���� �з��м�
���� ǰ���� ���� integer �������� 7 �̻��̸� ����(Good), �� �ܿ��� ����(Bad)�� factor ������ ��ȯ


rw<- read.csv("winequality-red.csv", header = T, sep=";")
names(rw)
rw.scale<-scale(rw[1:11])
rw<- cbind(rw.scale, wine[12])

rw.pc<-princomp(rw.scale,cor=T)
summary(rw.pc)
rw.pc$loadings
rw.pc.pd<-predict(rw.pc,rw)[,1:5]


#################3
rw.fa<-factanal(rw.scale,factors=5,rotation="varimax",scores="regression")
rw.fa
#summary(rw.fa)

rw.fa.data<- data.fa$scores
class(rw.fa.data)
class(rw$quality)
rw.fa.data<-as.data.frame(rw.fa.data)
rw.fa.data$quality<-rw$quality

head(rw.fa.data)
class(rw.fa.data)
class(rw$quality)
rw$quality<-as.numeric(rw$quality)
rw$quality
rw.fa.data<-as.matrix(rw.fa.data)
rw.fa.data$quality<-rw$quality 
rw.fa.data


  
````{r}
EDA
1. ������ ��ó��
2. ������ ��ó�� �� Ž���� ������ �м�

���� Ȯ��
1. PCA
2. FA

classification 
1. logistic
2. LDA
3. K means

````
#####
#��Ű�� ��ġ
install.packages("fpc")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("gridExtra")
install.packages("GGally")
install.packages("MASS")
install.packages("cluster")
install.packages("ROCR")
install.packages("nnet")
library(fpc)
library(cluster)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(GGally)
library(MASS)
library(ROCR)
library(nnet)
#####
#��� ����
setwd("C:/Users/HS/Documents/GitHub/Analyzing-Wine-Quality-Data")
#������ �б�
wine<- read.csv("winequality-red.csv", header = T, sep=";")
head(wine)
names(wine)

#####
#EDA
p1 <- wine %>%
  ggplot(aes(quality)) +
  geom_bar() +
  ggtitle("���� ǰ�� ���� �׷���")

p2 <- wine %>%
  ggplot(aes(alcohol, factor(quality))) +
  geom_jitter(col = "gray") +
  geom_boxplot(alpha = .5) +
  ggtitle("ǰ���� ���ڿ� ���� �׷���")

p3 <- wine %>%
  ggplot(aes(alcohol, density)) +
  geom_point(alpha=.1) +
  geom_smooth() +
  ggtitle("���ڿ�, �е� ������ & �߼���")

p4 <- wine %>%
  ggplot(aes(factor(quality), density)) +
  geom_jitter(color = "gray") +
  geom_boxplot(alpha = .5) +
  ggtitle("ǰ���� �е� ���� �׷���")
p4
grid.arrange(p1, p2, p3, p4, ncol=2)


ǰ���� 5���� 6�� ���� ����, 1����4,  7���� 10������ ���� ������ �� �� �ִ�.
table(wine$quality)
������ �������� ���� ���� ���� ���ڿð� ǰ���� ��� ���� �������� ������, �� ������ ���� �������� �� �� �ִ�.
�������� �߼����� ���� �� ���ڿð� �е��� ���� ������谡 �ִ�.
ǰ���� �е� ���ڱ׸��� ���� ������ ǰ���� �������� ��� �е��� ������ �� �� �ִ�.

#####
#������ ��ó�� �� �Ф�
wine <- wine %>%
  mutate(quality1 = factor(ifelse(quality >= 6, "Good", "Bad"))) %>%
  #quality1 �� 2�� ���ַ� ����
  mutate(quality2 = factor(ifelse(quality >= 7, "Good", 
                                 ifelse(quality <=4, "Bad", "Medium" ))))
  #quality2 �� 3�� ���ַ� ����

quality1<-ifelse(wine$quality1=="Good", 2, 1 )
quality2<-ifelse(wine$quality2=="Good", 3, 
                 ifelse(wine$quality2=="Bad", 1, 2))

head(wine)
names(wine)
table(wine$quality) ; table(wine$quality1) ; table(wine$quality2)
class(wine$quality) ; class(wine$quality1) ; class(wine$quality2)



sp1 <- wine %>%
  ggplot(aes(quality1)) + 
  geom_bar() +
  ggtitle("ǰ�� ���� ���� �׷���")

sp2 <- wine %>%
  ggplot(aes(alcohol, fill = quality1)) +
  geom_density(alpha = .5) +
  ggtitle("���ڿ�, ǰ�� �е� �׷���")

sp3 <- wine %>%
  ggplot(aes(alcohol, density, col = quality1)) +
  geom_point() +
  ggtitle("���ڿ�, �е� ������")

sp4 <- wine %>%
  ggplot(aes(residual.sugar, fill = quality1)) +
  geom_density(alpha = .5) +
  xlim(0, 25) +
  ggtitle("�ܴ�, �е��� ���� �е� �׷���")

grid.arrange(sp1, sp2, sp3, sp4, ncol = 2)


sp1 <- wine %>%
  ggplot(aes(quality2)) + 
  geom_bar() +
  ggtitle("ǰ�� ���� ���� �׷���")
sp1
sp2 <- wine %>%
  ggplot(aes(alcohol, fill = quality2)) +
  geom_density(alpha = .5) +
  ggtitle("���ڿ�, ǰ�� �е� �׷���")
sp2
sp3 <- wine %>%
  ggplot(aes(alcohol, density, col = quality2)) +
  geom_point() +
  ggtitle("���ڿ�, �е� ������")
sp3
sp4 <- wine %>%
  ggplot(aes(residual.sugar, fill = quality2)) +
  geom_density(alpha = .5) +
  xlim(0, 25) +
  ggtitle("�ܴ�, �е��� ���� �е� �׷���")
sp4
grid.arrange(sp1, sp2, sp3, sp4, ncol = 2)


�ð�ȭ�� ���� ���� ��ǵ��� �� �� �ִ�.
ǰ���� ���� �� ���� �ͺ��� ������ �� �� �ִ�.
ǰ���� �� ���� ������ ���� ǰ���� ���κ��� ���� �󵵰� ���� �Ͱ� 
�� ������ ���� �������� �� �� �ִ�.
ǰ���� ��� ���� ���ڿð� �е��� ���� ������� �̴�.
ǰ���� ���� �ܴ��� ū ���̰� ����. ��, �ܴ��� ǰ���� ū ������� ������ �� �Ѵ�.


#####
#logistic regression 

#good, bad
set.seed(1802)
names(wine)
wine.glm <- glm(quality1 ~  fixed.acidity + volatile.acidity + citric.acid +
                  residual.sugar + chlorides + free.sulfur.dioxide + 
                  total.sulfur.dioxide + density + pH+
                  sulphates +alcohol, 
                data   = wine,
                family = "binomial")

#������ �����Կ� �־ ������ �����鿡�� � �͵��� �ִ����� Ư�� ������ �������� ������ �ִ��� Ȯ�� �غ��� �����Դϴ�.
summary(wine.glm)

#total.sulfur.dioxide, volatile.acidity , sulphates, alcohol 

y_obs<- ifelse(wine$quality1 =="Good", 1, 0)
yhat_glm <- predict(wine.glm)
binomial_deviance(y_obs, yhat_glm)

# ROC Curve
pred_glm <- prediction(yhat_glm, y_obs)
perf_glm <- performance(pred_glm,
                        measure   = "tpr",
                        x.measure = "fpr") 

plot(perf_glm,
     col='black',
     main="ROC Curve of glm")

abline(0,1)
table(wine$quality1)
#bad 744, good 855
performance(pred_glm, "auc")@y.values[[1]]
#0.82219

##good, bad, middle  

set.seed(1802)
#names(wine)
wine.glm <- multinom(quality2 ~  fixed.acidity + volatile.acidity +
                       citric.acid +
                  residual.sugar + chlorides + free.sulfur.dioxide + 
                  total.sulfur.dioxide + density + pH+
                  sulphates +alcohol, 
                data   = wine)
wine.glm

#������ �����Կ� �־ ������ �����鿡�� � �͵��� �ִ����� Ư�� ������ �������� ������ �ִ��� Ȯ�� �غ��� �����Դϴ�.
summary(wine.glm)

#volatile.acidity , alcohol , pH, residual.sugar

y_obs<- ifelse(wine$quality2 =="Good", 3, 
               ifelse(wine$quality2=="Bad", 1, 0))
yhat_glm <- predict(wine.glm)
yhat_glm<-ifelse(yhat_glm =="Good", 3, 
       ifelse(yhat_glm=="Bad", 1, 0))
binomial_deviance(y_obs, yhat_glm)

# ROC Curve
pred_glm <- prediction(yhat_glm, y_obs)
perf_glm <- performance(pred_glm,
                        measure   = "tpr",
                        x.measure = "fpr") 

plot(perf_glm,
     col='black',
     main="ROC Curve of glm")

abline(0,1)
table(wine$quality2)
#bad 63, good 217, medium 1319
(1319)/(1319+63+217) #0.824
performance(pred_glm, "auc")@y.values[[1]]
#0.7108545

#########
#LDA
# good, bad -> 1���� ���
wine.lda <- lda(quality1 ~ total.sulfur.dioxide + volatile.acidity +
                  sulphates+ alcohol , data=wine)
wine.lda
predict(wine.lda)
wine.lda.values <- predict(wine.lda)
ldahist(data = wine.lda.values$x[,1], g=quality2)
ldahist(data = wine.lda.values$x[,2], g=quality2)  #������ ����
plot(wine.lda.values$x[,1]) # make a scatterplot
text(wine.lda.values$x[,1],
     quality1,cex=0.7,pos=4,col="red") # add labels


# good, bad, middle -> 2���� ���
wine.lda <- lda(quality2 ~ volatile.acidity + alcohol + pH+ residual.sugar , data=wine)
wine.lda
predict(wine.lda)
wine.lda.values <- predict(wine.lda)
ldahist(data = wine.lda.values$x[,1], g=quality2)
ldahist(data = wine.lda.values$x[,2], g=quality2)
plot(wine.lda.values$x[,1],wine.lda.values$x[,2]) # make a scatterplot
text(wine.lda.values$x[,1],wine.lda.values$x[,2],
     quality2,cex=0.7,pos=4,col="red") # add labels




```
########
#k means cluster

ǰ�� ������ �ƴϰ� �׳� �з� 

Step1: Scale the data
As the measurement of free sulfur dioxide is from 1 to 72 while citric acidity is scaled from 0 to 1. We need to scale the data in order to perform accuracy of distance of each clusters. 
Step2: Find the ideal number of clusters
Step3: Plot the clusters
Step 4: Validate if number of cluster equal to 6 is more accurate than 8.
Step 5: Get the mean of the each attribute of each group
```


summary(wine)
wine.scale<-scale(wine[1:11])
wine<- cbind(wine.scale, wine[12])

wine<-rw.fa
wss<-(nrow(wine)-1)*sum(apply(wine,2,var))
for(i in 1:15) wss[i]<-sum(kmeans(wine,centers=i)$withinss)
plot(1:15,wss,type='b',xlab="Number of Clusters",ylab='Within groups sum of squares')

#I choose 6 and 8 to see which one is going to be more appropriate for our analysis.

fit1 <- kmeans(wine,2)
fit2 <- kmeans(wine,3)
fit3 <- kmeans(wine,4)
fit4 <- kmeans(wine,5)
fit4 <- kmeans(wine,6)


table(fit1$cluster)
plotcluster(wine, fit1$cluster)
aggregate(wine,by=list(fit1$cluster),FUN=mean)
mydata <- data.frame(wine, fit1$cluster)

table(fit2$cluster)
plotcluster(wine, fit2$cluster)
aggregate(wine,by=list(fit2$cluster),FUN=mean)
mydata <- data.frame(wine, fit2$cluster)

table(fit3$cluster)
plotcluster(wine, fit3$cluster)
aggregate(wine,by=list(fit3$cluster),FUN=mean)
mydata <- data.frame(wine, fit3$cluster)

table(fit4$cluster)
plotcluster(wine, fit4$cluster)
aggregate(wine,by=list(fit4$cluster),FUN=mean)
mydata <- data.frame(wine, fit4$cluster)


clusplot(wine, fit1$cluster, color=TRUE, shade=TRUE,labels=2, lines=0)
clusplot(wine, fit2$cluster, color=TRUE, shade=TRUE,labels=2, lines=0)
clusplot(wine, fit3$cluster, color=TRUE, shade=TRUE,labels=2, lines=0)
clusplot(wine, fit4$cluster, color=TRUE, shade=TRUE,labels=2, lines=0)

cluster.stats(?, fit1$cluster, fit2$cluster)
?cluster.stats


