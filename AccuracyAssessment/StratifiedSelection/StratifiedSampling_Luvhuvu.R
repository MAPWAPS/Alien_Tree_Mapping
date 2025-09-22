#install packages, sf and terra are used for spatial analysis  
library(terra)
library(sf)
library(caret)
library(rgdal)

#set a working directory
setwd("C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/SS_Luvhuvu")

# Load the shapefile
# Add path of your shapefile
shapefile_data <- readOGR(dsn = "C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/SS_Luvhuvu", layer = "Luvuvhu_2811")

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
#write.xlsx(validation_set, file = "C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/SS_Tugela/Config_1/validation_set.xlsx")
#write.xlsx(training_set, file = "C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/SS_Tugela/Config_1/training_set.xlsx")

# set datasets to a Spatial data frame
coordinates(validationSet) <- c("X", "Y")
proj4string(validationSet) <- CRS("+proj=utm +zone=36 +south +datum=WGS84")

coordinates(trainingSet) <- c("X", "Y")
proj4string(trainingSet) <- CRS("+proj=utm +zone=36 +south +datum=WGS84")


#export as shapefile
writeOGR(validationSet, dsn = "C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/SS_Luvhuvu", layer = "validationSet", driver = "ESRI Shapefile")
writeOGR(trainingSet, dsn = "C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/SS_Luvhuvu", layer = "trainingSet", driver = "ESRI Shapefile")
