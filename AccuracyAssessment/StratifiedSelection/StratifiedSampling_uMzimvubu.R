#install packages, sf and terra are used for spatial analysis  
library(sf)
library(terra)
library(caret)
library(rgdal)

#set a working directory
setwd("C:/Users/User/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/TrainingData_Updated/uMzim_v2/Training")

# Load the shapefile
# Add path of your shapefile
shapefile_data <- readOGR(dsn = "C:/Users/User/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/TrainingData_Updated/uMzim_v2", layer = "TrainingData_umzim_v2")

# Convert the shapefile to a data frame 
data_df <- as.data.frame(shapefile_data) 

# Set the seed for reproducibility 
set.seed(123) 

# Create a stratified sample with a 70-30 split for training and testing 
train_indices <- createDataPartition(data_df$LULC, p = 0.7, list = FALSE)

# Create training and testing datasets based on the indices 
trainingSet <- data_df[train_indices, ] 
validationSet <- data_df[-train_indices, ]

str(validationSet)
summary(validationSet)

#export validation set as excel sheet
#write.xlsx(validation_set, file = "C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/uMzimvubuFieldTrip/Configurations/Configuration_2/validation_set.xlsx")
#write.xlsx(training_set, file = "C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/uMzimvubuFieldTrip/Configurations/Configuration_2/training_set.xlsx")

# set datasets to a Spatial data frame
coordinates(validationSet) <- c("X", "Y")
proj4string(validationSet) <- CRS("+proj=utm +zone=35 +south +datum=WGS84")

coordinates(trainingSet) <- c("X", "Y")
proj4string(trainingSet) <- CRS("+proj=utm +zone=35 +south +datum=WGS84")


#export as shapefile
writeOGR(validationSet, dsn = "C:/Users/User/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/TrainingData_Updated/uMzim_v2/Training", layer = "validationSet", driver = "ESRI Shapefile")
writeOGR(trainingSet, dsn = "C:/Users/User/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/TrainingData_Updated/uMzim_v2/Validation", layer = "trainingSet", driver = "ESRI Shapefile")
