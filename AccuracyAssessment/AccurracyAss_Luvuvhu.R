#install.packages("installr")
#library(installr)
#updateR()install.packages("dplyr")

install.packages("dplyr")
install.packages("broom")
install.packages("ggplot2")
install.packages("tidyr")
install.packages("caret")
install.packages("e1071")
install.packages("lattice")
install.packages("Rtools")

rm(list=ls())
library(lattice)
library(dplyr)
library(broom)
library(tidyr)
library(ggplot2)
library(caret)
library(e1071)

# update.packages()

# Set your WD
setwd("C:/Users/Liam/OneDrive - Stellenbosch University/Coding/MAPWAPS_Outputs/SelectedConfigs/Luvuvhu5")

###----------------------------------------------5A--------------------------------------
# Prepare validation and training sets for the accuracy assessments
# ---------- ------

obspreds_valLuvuvhu = read.csv("Class5_validation_30_Luv.csv") %>% mutate(classification = as.factor(classification))

levs = levels(obspreds_valLuvuvhu$classification)
labs = c("Bare Ground", "Dryland Agriculture", "Gum", "Indigenous Bush_Mopane", "Indigenous Bush_Other", "Indigenous Forest", "Irrigated Agriculture", 
         "Orchards_Banana","Orchards_Nuts", "Orchards_Other", "Pine", "Tea", "Urban", "Water", "Wetland", "Lantana", "Bugweed", "Other Invasive Alien Plants")

obspreds_valLuvuvhu = obspreds_valLuvuvhu %>% mutate(LC = factor(classification, levels = levs, labels = labs)) %>% 
  select(LC, Id, classification) %>% mutate(Id = as.factor(as.character (Id)))

confusionMatrix(obspreds_valLuvuvhu$Id, obspreds_valLuvuvhu$classification, positive = NULL, dnn = c("Predicted", "Observed"))

# Get the confusion matrix results exported to excel 
results <- confusionMatrix(obspreds_valLuvuvhu$Id, obspreds_valLuvuvhu$classification, positive = NULL, dnn = c("Predicted", "Observed"))

as.table(results)
as.matrix(results,what="overall")
as.matrix(results, what = "classes")

broom::tidy(results) %>% list(as.data.frame(results$table)) %>% writexl::write_xlsx("AccResults_5A.xlsx")

#-----
#0''ffffff', // Bare Ground
#1'ffff00', // Dryland Agriculture
#2'ff7f00', // Gum
#3'a8a800', // Indigenous Bush_Mopane
#4'6aa84f', // Indigenous Bush_Other
#5' 14870e', // Indigenous Forest
#6'00ff00', // Irrigated Agriculture
#7'ffc125', // Orchards_Banana
#8'ffcc99', // Orchards_Nuts
#9'd5df33', // Orchards_Other
#10'fd0618', // Pine
#11'ccffb3', // Tea
#12'000000', // Urban
#13'0a14f9', // Water
#14'08f3e4', // Wetland
#15'cd6090', // Bugweed and Lantana
#16'4d9592', // Mauritius Thorn
#17'eea2ad', // Triffid Weed

###----------------------------------------------5B--------------------------------------
### accuracy assessment - aliens versus other validation set
IAP_obspreds_valLuvuvhu = obspreds_valLuvuvhu %>% 
  mutate(predicted = case_when(
    ! Id %in% c("2","10", "15", "16", "17") ~ "Other",
    Id %in% c("2","10", "15", "16", "17") ~ "Aliens")) %>%
  mutate(trained = case_when(! classification %in% c("2","10", "15", "16", "17") ~ "Other",
                             classification %in% c("2","10", "15", "16", "17") ~ "Aliens")) %>% mutate(predicted = as.factor(as.character (predicted))) %>%  
  mutate(trained = as.factor(as.character (trained)))

confusionMatrix(IAP_obspreds_valLuvuvhu$predicted, IAP_obspreds_valLuvuvhu$trained, positive = NULL, dnn = c("Predicted", "Observed"))

# Get the confusion matrix results exported to excel 
results <- confusionMatrix(IAP_obspreds_valLuvuvhu$predicted, IAP_obspreds_valLuvuvhu$trained, positive = NULL, dnn = c("Predicted", "Observed"))

as.table(results)
as.matrix(results,what="overall")
as.matrix(results, what = "classes")

broom::tidy(results) %>% list(as.data.frame(results$table)) %>% writexl::write_xlsx("AccResults_5B.xlsx")

###----------------------------------------------5C--------------------------------------
### accuracy assessment - between alien species in the validation set

#2'ff7f00', // Gum
#10'#'fd0618', // Pine
#15'b7b7b7', // Bugweed and Lantana
#16'4d9592', // Mauritius Thorn
#17'eea2ad', // Triffid Weed

IAPspp_only_obspreds_valLuvuvhu = obspreds_valLuvuvhu %>% 
  mutate(predicted = case_when(
    ! Id %in% c("2","10", "15", "16", "17") ~ "Other",
    Id %in% c("2") ~ "Gum",
    Id %in% c("10") ~ "Pine",
    Id %in% c("15") ~ "Lantana",
    Id %in% c("16") ~ "Bugweed",
          Id %in% c("17") ~ "Other Invasive Alien Plants")) %>%
  mutate(trained = case_when(
    ! classification %in% c("2","10", "15", "16", "17") ~ "Other",
    classification %in% c("2") ~ "Gum",
    classification %in% c("10") ~ "Pine",
    classification %in% c("15") ~ "Lantana",
    classification %in% c("16") ~ "Bugweed",
    classification %in% c("17") ~ "Other Invasive Alien Plants")) %>% mutate(predicted = as.factor(as.character (predicted))) %>%  
  mutate(trained = as.factor(as.character (trained)))

confusionMatrix(IAPspp_only_obspreds_valLuvuvhu$predicted, IAPspp_only_obspreds_valLuvuvhu$trained, positive = NULL, dnn = c("Predicted Land Class", "Trained Land Class"))

# Get the confusion matrix results exported to excel 
results <- confusionMatrix(IAPspp_only_obspreds_valLuvuvhu$predicted, IAPspp_only_obspreds_valLuvuvhu$trained, positive = NULL, dnn = c("Predicted", "Observed"))

as.table(results)
as.matrix(results,what="overall")
as.matrix(results, what = "classes")

broom::tidy(results) %>% list(as.data.frame(results$table)) %>% writexl::write_xlsx("AccResults_5C.xlsx")

#####################

###----------------------------------------------1.3D--------------------------------------
#Training 70 dataset
###_____________All LULCs - overall
obspreds_trainLuvuvhu = read.csv("Class1.3_training_70.csv") %>% mutate(classification = as.factor(classification)) 
levs = levels(obspreds_trainLuvuvhu$classification)

labs = c("Bare Ground", "Dryland Agriculture", "Gum", "Indigenous Bush_Mopane", "Indigenous Bush_Other", "Indigenous Forest", "Irrigated Agriculture", 
         "Orchards_Banana","Orchards_Nuts", "Orchards_Other", "Pine", "Tea", "Urban", "Water", "Wetland", "Bugweed and Lantana", "Mauritius Thorn", "Triffid Weed")

obspreds_trainLuvuvhu = obspreds_trainLuvuvhu %>% mutate(LC = factor(classification, levels = levs, labels = labs)) %>% 
  select(LC, Id, classification) %>% mutate(Id = as.factor(as.character (Id)))

confusionMatrix(obspreds_trainLuvuvhu$Id, obspreds_trainLuvuvhu$classification, positive = NULL, dnn = c("Predicted", "Observed"))

# Get the confusion matrix results exported to excel 
results <- confusionMatrix(obspreds_trainLuvuvhu$Id, obspreds_trainLuvuvhu$classification, positive = NULL, dnn = c("Predicted", "Observed"))

as.table(results)
as.matrix(results,what="overall")
as.matrix(results, what = "classes")

broom::tidy(results) %>% list(as.data.frame(results$table)) %>% writexl::write_xlsx("AccResults_1.3D.xlsx")

###----------------------------------------------1.3E--------------------------------------
###______________IAPs vs Other

IAP_obspreds_trainLuvuvhu = obspreds_trainLuvuvhu %>% 
  mutate(predicted = case_when(
    ! Id %in% c("2","10", "15", "16", "17") ~ "Other",
    Id %in% c("2","10", "15", "16", "17") ~ "Aliens")) %>%
  mutate(trained = case_when(! classification %in% c("2","10", "15", "16", "17") ~ "Other",
                             classification %in% c("2","10", "15", "16", "17") ~ "Aliens")) %>% mutate(predicted = as.factor(as.character (predicted))) %>%  
  mutate(trained = as.factor(as.character (trained)))

confusionMatrix(IAP_obspreds_trainLuvuvhu$predicted, IAP_obspreds_trainLuvuvhu$trained, positive = NULL, dnn = c("Predicted", "Observed"))

# Get the confusion matrix results exported to excel 
results <- confusionMatrix(IAP_obspreds_trainLuvuvhu$predicted, IAP_obspreds_trainLuvuvhu$trained, positive = NULL, dnn = c("Predicted", "Observed"))

as.table(results)
as.matrix(results,what="overall")
as.matrix(results, what = "classes")

broom::tidy(results) %>% list(as.data.frame(results$table)) %>% writexl::write_xlsx("AccResults_1.3E.xlsx")

###----------------------------------------------1.3F--------------------------------------
###______________Between IAPs 

IAPspp_only_obspreds_trainLuvuvhu = obspreds_trainLuvuvhu %>% 
  mutate(predicted = case_when(
    ! Id %in% c("2","10", "15", "16", "17") ~ "Other",
    Id %in% c("2") ~ "Gum",
    Id %in% c("10") ~ "Pine",
    Id %in% c("15") ~ "Bugweed and Lantana",
    Id %in% c("16") ~ "Mauritius Thorn",
    Id %in% c("17") ~ "Triffid Weed")) %>%
  mutate(trained = case_when(
    ! classification %in% c("2","10", "15", "16", "17") ~ "Other",
    classification %in% c("2") ~ "Gum",
    classification %in% c("10") ~ "Pine",
    classification %in% c("15") ~ "Bugweed and Lantana",
    classification %in% c("16") ~ "Mauritius Thorn",
    classification %in% c("17") ~ "Triffid Weed")) %>% mutate(predicted = as.factor(as.character (predicted))) %>%  
  mutate(trained = as.factor(as.character (trained)))

confusionMatrix(IAPspp_only_obspreds_trainLuvuvhu$predicted, IAPspp_only_obspreds_trainLuvuvhu$trained, positive = NULL, dnn = c("Predicted Land Class", "Trained Land Class"))

# Get the confusion matrix results exported to excel 
results <- confusionMatrix(IAPspp_only_obspreds_valLuvuvhu$predicted, IAPspp_only_obspreds_valLuvuvhu$trained, positive = NULL, dnn = c("Predicted", "Observed"))

as.table(results)
as.matrix(results,what="overall")
as.matrix(results, what = "classes")

broom::tidy(results) %>% list(as.data.frame(results$table)) %>% writexl::write_xlsx("AccResults_1.3F.xlsx")

