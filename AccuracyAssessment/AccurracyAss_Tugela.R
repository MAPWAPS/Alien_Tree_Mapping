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
setwd("C:/Users/Liam/OneDrive - Stellenbosch University/Coding/MAPWAPS_Outputs/SelectedConfigs/Tugela5")

###----------------------------------------------5A--------------------------------------

# Prepare validation and training sets for the accuracy assessments

obspreds_valTugela = read.csv("Class5_validation_30_Tug.csv") %>% mutate(classification = as.factor(classification))

levs = levels(obspreds_valTugela$classification)
labs = c("Poplar", "Wattle", "Gum", "Indigenous Bush_Other", "Irrigated Agriculture", "Indigenous Bush_Pteridium", "Indigenous Bush_Vachellia", 
         "Pine","Water", "Wetland", "Bare Ground", "Dryland Agriculture", "Grassland", "Indigenous Forest", "Urban", "Other Invasive Alien Plants")

obspreds_valTugela = obspreds_valTugela %>% mutate(LC = factor(classification, levels = levs, labels = labs)) %>% 
  select(LC, ID, classification) %>% mutate(ID = as.factor(as.character (ID)))

confusionMatrix(obspreds_valTugela$ID, obspreds_valTugela$classification, positive = NULL, dnn = c("Predicted", "Observed"))

# Get the confusion matrix results exported to excel 
results <- confusionMatrix(obspreds_valTugela$ID, obspreds_valTugela$classification, positive = NULL, dnn = c("Predicted", "Observed"))

as.table(results)
as.matrix(results,what="overall")
as.matrix(results, what = "classes")

broom::tidy(results) %>% list(as.data.frame(results$table)) %>% writexl::write_xlsx("AccResults_5A.xlsx")


#-----
#'e2c5ff', // Poplar
#'9900ff', // Wattle
#'f91df9', // Gum
#'6aa84f', // Indigenous Bush_Other
#'00ff00', // Irrigated Agriculture
#'// Indg Bush_Pteridium
#'00ff00', // Indigenous Bush_Vachellia
#'fd0618', // Pine
#'0a14f9', // Water
#'08f3e4', // Wetland
#'ffffff', // Bare Ground
#'fee238', // Dryland Agriculture
#'a8a800', // Grassland
#'14870e', // Indigenous Forest
#'000000', // Urban
#'// LAntana
#'741b47', // Other Invasive Alien Plants

###----------------------------------------------5B--------------------------------------

### accuracy assessment - aliens versus other validation set
IAP_obspreds_valTugela = obspreds_valTugela %>% 
  mutate(predicted = case_when(
    ! ID %in% c("0","1", "2", "7", "15") ~ "Other",
    ID %in% c("0","1", "2", "7", "15") ~ "Aliens")) %>%
  mutate(trained = case_when(! classification %in% c("0","1", "2", "7", "15") ~ "Other",
                             classification %in% c("0","1", "2", "7", "15") ~ "Aliens")) %>% mutate(predicted = as.factor(as.character (predicted))) %>%  
  mutate(trained = as.factor(as.character (trained)))

confusionMatrix(IAP_obspreds_valTugela$predicted, IAP_obspreds_valTugela$trained, positive = NULL, dnn = c("Predicted", "Observed"))

# Get the confusion matrix results exported to excel 
results <- confusionMatrix(IAP_obspreds_valTugela$predicted, IAP_obspreds_valTugela$trained, positive = NULL, dnn = c("Predicted", "Observed"))

as.table(results)
as.matrix(results,what="overall")
as.matrix(results, what = "classes")

broom::tidy(results) %>% list(as.data.frame(results$table)) %>% writexl::write_xlsx("AccResults_5B.xlsx")

###----------------------------------------------5C--------------------------------------

### accuracy assessment - between alien species in the validation set

#'e2c5ff', // Poplar
#'9900ff', // Wattle
#'f91df9', // Gum

#'fd0618', // Pine
# // Lantana
#'741b47', // Other Invasive Alien Plants
#'
IAPspp_only_obspreds_valTugela = obspreds_valTugela %>% 
  mutate(predicted = case_when(
    ! ID %in% c("0","1", "2", "7", "15") ~ "Other",
    ID %in% c("0") ~ "Poplar",
    ID %in% c("1") ~ "Wattle",
    ID %in% c("2") ~ "Gum",
    ID %in% c("7") ~ "Pine",
    ID %in% c("15") ~ "Other Invasive Alien Plants")) %>%
  mutate(trained = case_when(
    ! classification %in% c("0","1", "2", "7", "15") ~ "Other",
    classification %in% c("0") ~ "Poplar",
    classification %in% c("1") ~ "Wattle",
    classification %in% c("2") ~ "Gum",
    classification %in% c("7") ~ "Pine",
    classification %in% c("15") ~ "Other Invasive Alien Plants")) %>% mutate(predicted = as.factor(as.character (predicted))) %>%  
  mutate(trained = as.factor(as.character (trained)))

confusionMatrix(IAPspp_only_obspreds_valTugela$predicted, IAPspp_only_obspreds_valTugela$trained, positive = NULL, dnn = c("Predicted Land Class", "Trained Land Class"))

# Get the confusion matrix results exported to excel 
results <- confusionMatrix(IAPspp_only_obspreds_valTugela$predicted, IAPspp_only_obspreds_valTugela$trained, positive = NULL, dnn = c("Predicted", "Observed"))

as.table(results)
as.matrix(results,what="overall")
as.matrix(results, what = "classes")

broom::tidy(results) %>% list(as.data.frame(results$table)) %>% writexl::write_xlsx("AccResults_5C.xlsx")


#####################

###----------------------------------------------1.1D--------------------------------------
#Training 70 dataset
###_____________All LULCs - overall
obspreds_trainLuvuvhu = read.csv("Class1.1_training_70.csv") %>% mutate(classification = as.factor(classification)) 
levs = levels(obspreds_trainLuvuvhu$classification)

labs = c("Bare Ground", "Dryland Agriculture", "Gum", "Indigenous Bush_Mopane", "Indigenous Bush_Other", "Indigenous Forest", "Irrigated Agriculture", 
         "Orchards_Banana","Orchards_Nuts", "Orchards_Other", "Pine", "Tea", "Urban", "Water", "Wetland", "Lantana", "Bugweed", "Mauritius Thorn","Triffid Weed", "Other Invasive Alien Plants")

obspreds_trainLuvuvhu = obspreds_trainLuvuvhu %>% mutate(LC = factor(classification, levels = levs, labels = labs)) %>% 
  select(LC, Id, classification) %>% mutate(Id = as.factor(as.character (Id)))

confusionMatrix(obspreds_trainLuvuvhu$Id, obspreds_trainLuvuvhu$classification, positive = NULL, dnn = c("Predicted", "Observed"))

results <- confusionMatrix(obspreds_trainLuvuvhu$Id, obspreds_trainLuvuvhu$classification, positive = NULL, dnn = c("Predicted", "Observed"))

# Get the confusion matrix results exported to excel as.table(results)
as.matrix(results,what="overall")
as.matrix(results, what = "classes")

broom::tidy(results) %>% list(as.data.frame(results$table)) %>% writexl::write_xlsx("AccResults_1.1D.xlsx")


###----------------------------------------------1.1E--------------------------------------
###______________IAPs vs Other

IAP_obspreds_trainLuvuvhu = obspreds_trainLuvuvhu %>% 
  mutate(predicted = case_when(
    ! Id %in% c("2","10", "15", "16", "17", "18", "19") ~ "Other",
    Id %in% c("2","10", "15", "16", "17", "18", "19") ~ "Aliens")) %>%
  mutate(trained = case_when(! classification %in% c("2","10", "15", "16", "17", "18", "19") ~ "Other",
                             classification %in% c("2","10", "15", "16", "17", "18", "19") ~ "Aliens")) %>% mutate(predicted = as.factor(as.character (predicted))) %>%  
  mutate(trained = as.factor(as.character (trained)))

confusionMatrix(IAP_obspreds_trainLuvuvhu$predicted, IAP_obspreds_trainLuvuvhu$trained, positive = NULL, dnn = c("Predicted", "Observed"))

# Get the confusion matrix results exported to excel 
results <- confusionMatrix(IAP_obspreds_trainLuvuvhu$predicted, IAP_obspreds_trainLuvuvhu$trained, positive = NULL, dnn = c("Predicted", "Observed"))

as.table(results)
as.matrix(results,what="overall")
as.matrix(results, what = "classes")

broom::tidy(results) %>% list(as.data.frame(results$table)) %>% writexl::write_xlsx("AccResults_1.1E.xlsx")


###----------------------------------------------1.1F--------------------------------------
###______________Between IAPs 

IAPspp_only_obspreds_trainLuvuvhu = obspreds_trainLuvuvhu %>% 
  mutate(predicted = case_when(
    ! Id %in% c("2","10", "15", "16", "17", "18", "19") ~ "Other",
    Id %in% c("2") ~ "Gum",
    Id %in% c("10") ~ "Pine",
    Id %in% c("15") ~ "Lantana",
    Id %in% c("16") ~ "Bugweed",
    Id %in% c("17") ~ "Mauritius Thorn",
    Id %in% c("18") ~ "Triffid Weed",
    Id %in% c("19") ~ "Other Invasive Alien Plants")) %>%
  mutate(trained = case_when(
    ! classification %in% c("2","10", "15", "16", "17", "18", "19") ~ "Other",
    classification %in% c("2") ~ "Gum",
    classification %in% c("10") ~ "Pine",
    classification %in% c("15") ~ "Lantana",
    classification %in% c("16") ~ "Bugweed",
    classification %in% c("17") ~ "Mauritius Thorn",
    classification %in% c("18") ~ "Triffid Weed",
    classification %in% c("19") ~ "Other Invasive Alien Plants")) %>% mutate(predicted = as.factor(as.character (predicted))) %>%  
  mutate(trained = as.factor(as.character (trained)))

confusionMatrix(IAPspp_only_obspreds_trainLuvuvhu$predicted, IAPspp_only_obspreds_trainLuvuvhu$trained, positive = NULL, dnn = c("Predicted Land Class", "Trained Land Class"))

# Get the confusion matrix results exported to excel 
results <- confusionMatrix(IAPspp_only_obspreds_valLuvuvhu$predicted, IAPspp_only_obspreds_valLuvuvhu$trained, positive = NULL, dnn = c("Predicted", "Observed"))

as.table(results)
as.matrix(results,what="overall")
as.matrix(results, what = "classes")

broom::tidy(results) %>% list(as.data.frame(results$table)) %>% writexl::write_xlsx("AccResults_1.1F.xlsx")

