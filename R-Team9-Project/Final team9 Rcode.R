############################################################
## Program: MsBA4 Hult International Business School
## Script purpose: Air France Case Analysis
## Date: 12/12/2020
## Author: Team 9
############################################################

############################################################
#Creating UDF Functions for later use

####
# udf normalization
###
team9_normalize <- function(x) {
  my_min <- min(x, na.rm = T)
  my_max <- max(x, na.rm = T)
  min_max <- (x- my_min)/(my_max -my_min)
  return(min_max)
}# closing udf


####
# Descriptive analysis function
####

team9_desc_stats <- function(x)  {
  team9_min <- min(x, na.rm = TRUE)
  team9_mean <- mean(x, na.rm = TRUE)
  team9_max <- max(x, na.rm = TRUE)
  team9_sigma <- sd(x,na.rm=T)
  return(c(team9_min, team9_mean, team9_max, team9_sigma))
}# closing

####
# UDF to have z score
####
team9_zscore <- function(x) {
  my_mu <- mean(x, na.rm = T)
  my_sigma <- sd(x, na.rm = T)
  z_score <- (x - my_mu)/my_sigma
  return(z_score)
  
}# closing function

#####
# t-score function
#####

team9_tscore <- function (x) {
  t_score <- team9_zscore(x=x)*10+50
  return(t_score)
}# closing function
############################################################
# Cleaning Dataset- DoubleClick_Original contains raw data
# Messaged data called DoubleClick
############################################################
library(readxl)
DoubleClick_Original <- read_excel("Air France Case Spreadsheet Supplement.xls", 2)

#Copy to DoubleClick to message
DoubleClick <- as.data.frame(DoubleClick_Original)

#Remove publisher ID.
DoubleClick$`Publisher ID` <- NULL
#Change Pulisher Name to name
DoubleClick$name <- as.character(DoubleClick$`Publisher Name`)
DoubleClick$`Publisher Name`<- NULL
#Create a new column "name_numeric"
DoubleClick$name_numeric<- as.numeric(factor(DoubleClick$name))
#Remove keyword id. 
DoubleClick$`Keyword ID`<- NULL
#Checking patterns in keywords
DoubleClick$Keyword <- gsub(" ","",DoubleClick$Keyword)
# create a new column "pattern_airfrance"
DoubleClick$pattern_airfrance <- grepl("airfrance", DoubleClick$Keyword, ignore.case = FALSE, perl = FALSE,
                           fixed = FALSE, useBytes = FALSE)
DoubleClick$pattern_airfrance <- as.numeric(factor(DoubleClick$pattern_airfrance))-1
# Change N/A to Unknown for Match type
DoubleClick$match_type <- gsub("N/A","Unknown",DoubleClick$`Match Type`)
DoubleClick$`Match Type`<- NULL
# Create a new column according to match type: Broad to 1 and the rest to 0
DoubleClick$match_type_numeric <- ifelse(DoubleClick$match_type=="Broad","1","0")
# Remove campaign, remove keyword group, remove catogory, remove bid stretagy, remove keyword type, remove status
DoubleClick <- DoubleClick[,-c(2:7)]
# Change search engine bid to bid
DoubleClick$bid <- DoubleClick$`Search Engine Bid`
DoubleClick$`Search Engine Bid`<- NULL
# rename the rest columns
DoubleClick$click_charges <- DoubleClick$`Click Charges`
DoubleClick$`Click Charges`<- NULL
DoubleClick$avg_cost_click <- DoubleClick$`Avg. Cost per Click`
DoubleClick$`Avg. Cost per Click`<- NULL
DoubleClick$click_thru_percentage <-DoubleClick$`Engine Click Thru %`
DoubleClick$`Engine Click Thru %`<-NULL
DoubleClick$avg_pos <-DoubleClick$`Avg. Pos.`
DoubleClick$`Avg. Pos.`<- NULL
DoubleClick$trans_conv_percentage <-  DoubleClick$`Trans. Conv. %`
DoubleClick$`Trans. Conv. %` <- NULL
DoubleClick$cost_per_trans <- DoubleClick$`Total Cost/ Trans.`
DoubleClick$`Total Cost/ Trans.`<- NULL
DoubleClick$total_cost <- DoubleClick$`Total Cost`
DoubleClick$`Total Cost`<- NULL
DoubleClick$bookings <- DoubleClick$`Total Volume of Bookings`
DoubleClick$`Total Volume of Bookings`<- NULL

#create a new column "net profit"
DoubleClick$net_profit <- DoubleClick$Amount-DoubleClick$total_cost
#create a new column binary. 1 for net profit greater than 0.
DoubleClick$binary <- ifelse(DoubleClick$net_profit> 0,"1","0")
DoubleClick$binary <- as.numeric(factor(Data3$binary))-1
# check to see if there are any missing values.
sum(is.na(DoubleClick))

###############################################################

###############################################################
# message DoubleClick
###############################################################
# call team9_normalize function to create columns to contain normalized data
DoubleClick$Clicks_norm <- team9_normalize(DoubleClick$Clicks)
DoubleClick$Impressions_norm <- team9_normalize(DoubleClick$Impressions)
DoubleClick$Amount_norm <- team9_normalize(DoubleClick$Amount)

DoubleClick$bid_norm <- team9_normalize(DoubleClick$bid)
DoubleClick$click_charges_norm <- team9_normalize(DoubleClick$click_charges)
DoubleClick$avg_cost_click_norm <- team9_normalize(DoubleClick$avg_cost_click)

DoubleClick$click_thru_percentage_norm <- team9_normalize(DoubleClick$click_thru_percentage)
DoubleClick$avg_pos_norm <- team9_normalize(DoubleClick$avg_pos)
DoubleClick$trans_conv_percentage_norm <- team9_normalize(DoubleClick$trans_conv_percentage)

DoubleClick$cost_per_trans_norm <- team9_normalize(DoubleClick$cost_per_trans)
DoubleClick$total_cost_norm <- team9_normalize(DoubleClick$total_cost)
DoubleClick$bookings_norm <- team9_normalize(DoubleClick$bookings)
DoubleClick$net_profit_norm <- team9_normalize(DoubleClick$net_profit)
#################################################################

#################################################################
# compare the profit of different channels and see what Match Type works
#################################################################
library(ggplot2)
Data1 <- DoubleClick[which(DoubleClick$net_profit>-30000),]

try1 <- ggplot(Data1, aes(x=net_profit, y=name, fill=match_type)) +
  geom_bar(stat = "identity") 
try1


################################################################


#########
# click per bookings-  Average clicks per bookings for each channel. 
#########
Data3 <- DoubleClick[DoubleClick$bookings>0,]
#create a new column click per booking
Data3$click_per_booking <- Data3$Clicks/Data3$bookings

hist(Data3$click_per_booking, breaks = 50, xlim = c(0,600),ylim = c(0,140),
     col = "grey", main = "Distribution of Clicks per booking")
c1 <- rainbow(10)
c2 <- rainbow(10, alpha=0.5)
c3 <- rainbow(10, v=0.7)
boxplot(Data3$click_per_booking~ Data3$name_numeric, ylim=c(0,1000),
        col=c2, medcol=c3, whiskcol=c1, staplecol=c3, boxcol=c3, outcol=c3, pch=15, cex=1)
# on average, it takes about 100 clicks to complete a booking except for channel 6- Overture US.
# Overture US takes about 200 clicks to complete a booking on average. put assisted keywords amount as 100.

###
# then we looked into impressions
###


boxplot(Data3$Impressions~ Data3$name_numeric, ylim=c(200,150000), 
        col=c2, medcol=c3, whiskcol=c1, staplecol=c3, boxcol=c3, outcol=c3, pch=15, cex=1) 
## as we can see, overture US caused extremely high impressions.BUT...
boxplot(Data3$click_thru_percentage~Data3$name_numeric,ylim=c(0,30), 
        col=c2, medcol=c3, whiskcol=c1, staplecol=c3, boxcol=c3, outcol=c3, pch=15, cex=1) 
## But the engine click through% is very low.

######
# predictive model
######

############################################################################
#logit regression to interpret success of odds. create a unique formula  
#50%-net profit + 30% trans-conv % + 20% click thru%.
# the higher the score, the better performance of the keyword
############################################################################


####################################
##### team9_score
####################################
DoubleClick$team9_score <- c()
rowsnumber <- nrow(DoubleClick)
for (i in 1: rowsnumber) {
  DoubleClick$team9_score[i] <- 0.5*DoubleClick$net_profit[i] + 
    0.3*DoubleClick$trans_conv_percentage[i] +
    0.2*DoubleClick$click_thru_percentage[i] 
}# closing the i loop

team9_desc_stats(DoubleClick$team9_score)
# the mean score is 435. if it's greater than 435, we are saying the keyword is working fine.

DoubleClick$binary_keywordperf <- ifelse(DoubleClick$team9_score > 435,"1","0")
DoubleClick$binary_keywordperf <- as.factor(DoubleClick$binary_keywordperf)


# use normalized logit to check which variables matter the most and ATC is used to remove variables.

library(splitstackshape)

team9training_testing <- stratified(as.data.frame(DoubleClick), group = 35, size=0.8, bothSets = TRUE)
team9_training <- team9training_testing$SAMP1
team9_testing <- team9training_testing$SAMP2

team9_logit <- glm(binary_keywordperf ~   
                 click_charges_norm + avg_cost_click_norm +
                    + cost_per_trans_norm + bookings_norm,
                   data= team9_training,family="binomial" )
summary(team9_logit)
########

#business unit model
team9_logit1 <- glm(binary_keywordperf ~    
                     click_charges + avg_cost_click + cost_per_trans + bookings,
                   data= team9_training,family="binomial" )

summary(team9_logit1)
## 1 unit increase in click charges, the success of odds will decrease about 0.4%
exp(-0.0042260 )-1
# 1 unit increase in average cost per click, the success of odds will decrease about 43%
exp(-0.5612838)-1
# 1 unit increase in cost per transaction, the success of odds will increase about 0.5%
exp(0.0045537)-1
# 1 unit increase in bookings, success of odds will increase 113 times.
exp(4.7403987)-1

# testing resting data
team9_logit2 <- glm(binary_keywordperf ~    
                      click_charges + avg_cost_click + cost_per_trans
                    + bookings,
                    data= team9_testing,family="binomial" )

summary(team9_logit2)
#############################################################################
# gini tree
#############################################################################
library(rpart)
team9_tree <- rpart(binary_keywordperf ~ Clicks + Impressions + Amount + bid+
                    click_charges + avg_cost_click+click_thru_percentage +
                    avg_pos + trans_conv_percentage + cost_per_trans + total_cost+
                    bookings +name_numeric + match_type_numeric,
                    data = team9_training,
                    method="class",
                    cp=0.0005)
library(rpart.plot)
rpart.plot(team9_tree,extra=1,type=1)

# choose a proper cp value
plotcp(team9_tree)


