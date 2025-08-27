# Install and load necessary libraries
library(sf)
library(terra)
library(caret)
#library(openxlsx)

# Set the working directory
setwd("C:/Users/User/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/SabieCroc/FinalMapOutputs/Configuration1/Raw_TrainingData")

# Load the shapefile (using sf for spatial data handling)
shapefile_data <- st_read("Training_v2.shp")

# Convert the shapefile to a data frame
data_df <- as.data.frame(shapefile_data)

# Set seed for reproducibility
set.seed(123)

# Create a stratified sample with a 70-30 split for training and testing
train_indices <- createDataPartition(data_df$LULC_Class, p = 0.7, list = FALSE)

# Create training and testing datasets based on the indices
trainingSet <- data_df[train_indices, ]
validationSet <- data_df[-train_indices, ]

# Check structure and summary of validation set
str(validationSet)
summary(validationSet)

# Export validation and training sets as Excel files
#write.xlsx(validationSet, file = "C:/Users/User/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/SabieCroc/FinalMapOutputs/Configuration1/validation_set.xlsx")
#write.xlsx(trainingSet, file = "C:/Users/User/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/SabieCroc/FinalMapOutputs/Configuration1/training_set.xlsx")

# Convert data frames to spatial objects using sf
trainingSet_sf <- st_as_sf(trainingSet, coords = c("X", "Y"), crs = 32736)  # UTM Zone 36S, WGS84 datum
validationSet_sf <- st_as_sf(validationSet, coords = c("X", "Y"), crs = 32736)

# Export as shapefiles
st_write(validationSet_sf, dsn = "C:/Users/User/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/SabieCroc/FinalMapOutputs/Configuration1/validationSet.shp")
st_write(trainingSet_sf, dsn = "C:/Users/User/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/SabieCroc/FinalMapOutputs/Configuration1/trainingSet.shp")
