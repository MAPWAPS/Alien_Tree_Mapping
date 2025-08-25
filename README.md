# AlienTreeMapping for the MapWAPS project
This repository contains Google Earth Engine Code for the MapWAPS (Mapping woody invasive alien plants) project in five catchments in South Africa.

The classification process was as follows:
1. Call S2 image collection from imports and filter to get least cloudy image
2. Import ALOS landform and elevation datasets
3. Generate S2 indices and add them as bands to the image
4. Create a training data subset
5. Run RF classification with the training subset
6. Stipulate colour palette and express the classification
7. Add the Legend
8. Specify split panels for the S2 image and classification
9. Display the split panels

Sentinel-2 and ALOS datasets required for the classifation can be loaded from Google Earth Engine archives. The training and validation datasets can be uploaded as assets. 

The MapWAPS results and traning dataset have been archived on SunScholar repository. 
1) uMzimvubu Catchment: https://scholardata.sun.ac.za/articles/dataset/MapWAPS_Invasive_Alien_Plant_Map_for_the_uMzimvubu_Catchment/25050401
3) Luvhuvu Catchment: https://scholardata.sun.ac.za/articles/dataset/MapWAPS_Invasive_Alien_Plant_Map_for_the_Luvuvhu_Catchment/25050314
5) Tugela Catchment: https://scholardata.sun.ac.za/articles/dataset/MapWAPS_Invasive_Alien_Plant_map_for_the_Tugela_Catchment/25066151
7) Sabie-Crocodile Catchments: https://scholardata.sun.ac.za/articles/dataset/Invasive_Alien_Plant_map_for_the_Sabie-Crocodile_Catchments/25050368
9) Olifants-Doring Catchments: https://scholardata.sun.ac.za/articles/dataset/MapWAPS_Invasive_Alien_Plant_map_for_the_Olifants-Doring_Catchments/29958053
