#install.packages("installr")
#library(installr)
#updateR()

#install.packages("dplyr")
#install.packages("broom")
#install.packages("ggplot2")
#install.packages("tidyr")
#install.packages("caret")
#install.packages("e1071")
#install.packages("lattice")
#install.packages("Rtools")

rm(list=ls())
library(lattice)
library(dplyr)
library(broom)
library(tidyr)
library(ggplot2)
library(caret)
library(e1071)
library(writexl)

#update.packages()

setwd("C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/SabieCroc/FinalMapOutputs/AccuracyAss")

#import validation csv file and muate the ID colounn to a factor (categorize)
obspred_val = read.csv("SabieClass1_6_validation.csv") %>% mutate (ID = as.factor(ID))

#Create levels from 1-17 and also create labels to match LULC Class
# 1 Bananas
# 2 Bare Ground
# 3 Bugweed
# 4 Burnt
# 5 Grassland
# 6 Gum
# 7 Indigenous Bush
# 8 Indigenous Forest
# 9 Lantana
# 10 Macadamias
# 11 Orchards
# 12 Other IAPS
# 13 Pine
# 14 Urban
# 15 Water
# 16 Wetland
# 17 Yellow Bells

levs = levels(obspred_val$ID)
labels = c("Bananas", "Bare Ground", "Bugweed", "Burnt", "Grassland", "Gum", "Indigenous Bush","Indigenous Forest", 
           "Lantana","Macadamias", "Orchards", "Other Invasive Alien Tress", "Pine", "Urban", "Water", "Wetland", "Yellow Bells")

#Adding LC column
obspred_val = obspred_val %>% mutate(LC = factor(ID, levels = levs, labels = labels)) %>% 
  select(LC, classification, ID) %>% mutate(classification = as.factor(as.character (classification)))

#generate a confusion matrix
results<-confusionMatrix(obspred_val$classification, obspred_val$ID, positive = NULL, dnn = c("Predicted", "Observed"))
as.table(results) 
as.matrix(results,what="overall") 
as.matrix(results, what = "classes")  
broom::tidy(results) %>% list(as.data.frame(results$table)) %>% 
  writexl::write_xlsx("AccResults_overall.xlsx")

### accuracy assessment - alien trees vs other classes
# 3 Bugweed
#  6 Gum
# 9 Lantana
# 12 Other Invasive Alien Trees
# 13 Pine
# 17 Yellow Bells

IAT_obspred_val = obspred_val %>%
  mutate(predicted = case_when(
    !classification %in% c("3", "6", "9", "12", "13", "17") ~ "Other",
    classification %in% c("3", "6", "9", "12", "13", "17") ~ "Aliens"
  )) %>%
  mutate(trained = case_when(
    !ID %in% c("3", "6", "9", "12", "13", "17") ~ "Other",
    ID %in% c("3", "6", "9", "12", "13", "17") ~ "Aliens"
  )) %>%
  mutate(predicted = as.factor(predicted)) %>%  
  mutate(trained = as.factor(trained))

results<-confusionMatrix(IAT_obspred_val$predicted, IAT_obspred_val$trained, positive = NULL, dnn = c("Predicted", "Observed"))
as.table(results) 
as.matrix(results,what="overall") 
as.matrix(results, what = "classes")  
broom::tidy(results) %>% list(as.data.frame(results$table)) %>% 
  writexl::write_xlsx("AccResults_aliensvsother.xlsx")

#between invasive alien species in the data set
Aspp_only_obspred_val = obspred_val %>% 
  mutate(predicted = case_when(
    ! classification %in% c("3", "6", "9", "12", "13", "17") ~ "Other",
    classification %in% c("3") ~ "Bugweed",
    classification %in% c("6") ~ "Gum",
    classification %in% c("9") ~ "Lantana",
    classification %in% c("12") ~ "Others",
    classification %in% c("13") ~ "Pine",
    classification %in% c("17") ~ "YellowBells")) %>%
  mutate(trained = case_when(
    ! ID %in% c("3", "6", "9", "12", "13", "17") ~ "Other",
    ID %in% c("3") ~ "Bugweed",
    ID %in% c("6") ~ "Gum",
    ID %in% c("9") ~ "Lantana",
    ID %in% c("12") ~ "Others",
    ID %in% c("13") ~ "Pine",
    ID %in% c("17") ~ "YellowBells")) %>% mutate(predicted = as.factor(as.character (predicted))) %>%  
  mutate(trained = as.factor(as.character (trained)))

results<-confusionMatrix(Aspp_only_obspred_val$predicted, Aspp_only_obspred_val$trained, positive = NULL, dnn = c("Predicted Land Class", "Trained Land Class"))
as.table(results) 
as.matrix(results,what="overall") 
as.matrix(results, what = "classes")  
broom::tidy(results) %>% list(as.data.frame(results$table)) %>% 
  writexl::write_xlsx("AccResults_betweenaliens.xlsx")
