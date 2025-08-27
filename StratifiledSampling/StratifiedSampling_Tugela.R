#install packages, sf and terra are used for spatial analysis  
library(sf)
library(terra)
library(caret)
library(rgdal)

#set a working directory
setwd("C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/SS_Tugela")

# Load the shapefile
# Add path of your shapefile
shapefile_data <- readOGR(dsn = "C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/SS_Tugela/Config_1", layer = "Tug_SHP_IA")

# Convert the shapefile to a data frame 
data_df <- as.data.frame(shapefile_data) 

# Set the seed for reproducibility 
set.seed(123) 

# Create a stratified sample with a 70-30 split for training and testing 
train_indices <- createDataPartition(data_df$LULC, p = 0.7, list = FALSE)

# Create training and testing datasets based on the indices 
training_set <- data_df[train_indices, ] 
validation_set <- data_df[-train_indices, ]

str(validation_set)
summary(validation_set)

#export validation set as excel sheet
write.xlsx(validation_set, file = "C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/SS_Tugela/Config_1/validation_setIA.xlsx")
write.xlsx(training_set, file = "C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/SS_Tugela/Config_1/training_setIA.xlsx")

# set datasets to a Spatial data frame
coordinates(validation_set) <- c("Longitude", "Latitude")
proj4string(validation_set) <- CRS("+proj=utm +zone=35 +south +datum=WGS84")

coordinates(training_set) <- c("Longitude", "Latitude")
proj4string(training_set) <- CRS("+proj=utm +zone=35 +south +datum=WGS84")


#export as shapefile
writeOGR(validation_set, dsn = "C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/SS_Tugela/Config_1", layer = "validation_setIA", driver = "ESRI Shapefile")
writeOGR(training_set, dsn = "C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/SS_Tugela/Config_1", layer = "training_setIA", driver = "ESRI Shapefile")
