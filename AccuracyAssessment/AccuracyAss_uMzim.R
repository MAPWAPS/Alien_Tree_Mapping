rm(list=ls())
library(lattice)
library(dplyr)
library(broom)
library(tidyr)
library(ggplot2)
library(caret)
library(e1071)

setwd("C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/uMzimvubuFieldTrip/FinalOutputs/AccuracyAss")

#import validation csv file and muate the ID colounn to a factor (categorize)
obspred_val = read.csv("uMzimClassification5_validation.csv") %>% mutate (ID = as.factor(ID))

#Create levels from 1-16 and also create labels to match LULC Class
#1 Bare Ground
#2 Black Wattle
#3 Dryland Agriculture
#4 Grassland
#5 Gum
#6 Indigenous Bush
#7 Irrigated Agriculture
#8 Maize
# 9 Other Invasive Alien Trees
# 10 Pine
# 11 Poplar
# 12 Silver Wattle
# 13 Urban
# 14 Water
# 15 Wetland

levs = levels(obspred_val$ID)
labels = c("Bare Ground", "Black Wattle", "Dryland Agriculture", "Grassland", "Gum", "Indigenous Bush","Irrigated Agriculture", 
           "Maize","Other Invasive Alien Plants", "Pine","Poplar", "Silver Wattle", "Urban", "Water", "Wetland")

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

#2 Black Wattle
#5 Gum
# 9 Other Invasive Alien Trees
# 10 Pine
# 11 Poplar
# 12 Silver Wattle

### accuracy assessment - alien trees vs other classes
IAT_obspred_val = obspred_val %>%
  mutate(predicted = case_when(
    !classification %in% c("2", "5", "9", "10", "11", "12") ~ "Other",
    classification %in% c("2", "5", "9", "10", "11", "12") ~ "Aliens"
  )) %>%
  mutate(trained = case_when(
    !ID %in% c("2", "5", "9", "10", "11", "12") ~ "Other",
    ID %in% c("2", "5", "9", "10", "11", "12") ~ "Aliens"
  )) %>%
  mutate(predicted = as.factor(predicted)) %>%  
  mutate(trained = as.factor(trained))

results<-confusionMatrix(IAT_obspred_val$predicted, IAT_obspred_val$trained, positive = NULL, dnn = c("Predicted", "Observed"))
as.table(results) 
as.matrix(results,what="overall") 
as.matrix(results, what = "classes")  
broom::tidy(results) %>% list(as.data.frame(results$table)) %>% 
  writexl::write_xlsx("AccResults_aliensvsother.xlsx")

# accuracy assessment - between invasive alien species in the validation set
Aspp_only_obspred_val = obspred_val %>% 
  mutate(predicted = case_when(
    ! classification %in% c("2", "5", "9", "10", "11", "12") ~ "Other",
    classification %in% c("2") ~ "BlackWattle",
    classification %in% c("5") ~ "Gum",
    classification %in% c("9") ~ "Others",
    classification %in% c("10") ~ "Pine",
    classification %in% c("11") ~ "Poplar",
    classification %in% c("12") ~ "SilverWattle")) %>%
  mutate(trained = case_when(
    ! ID %in% c("2", "5", "9", "10", "11", "12") ~ "Other",
    ID %in% c("2") ~ "BlackWattle",
    ID %in% c("5") ~ "Gum",
    ID %in% c("9") ~ "Others",
    ID %in% c("10") ~ "Pine",
    ID %in% c("11") ~ "Poplar",
    ID %in% c("12") ~ "SilverWattle"))%>% mutate(predicted = as.factor(as.character (predicted))) %>%  
  mutate(trained = as.factor(as.character (trained)))

results<-confusionMatrix(Aspp_only_obspred_val$predicted, Aspp_only_obspred_val$trained, positive = NULL, dnn = c("Predicted Land Class", "Trained Land Class"))
as.table(results) 
as.matrix(results,what="overall") 
as.matrix(results, what = "classes")  
broom::tidy(results) %>% list(as.data.frame(results$table)) %>% 
  writexl::write_xlsx("AccResults_betweenaliens.xlsx")
