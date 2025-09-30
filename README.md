# AlienTreeMapping for the MapWAPS project
This repository contains Google Earth Engine Code for the MapWAPS (Mapping woody invasive alien plants) project in five catchments in South Africa.

The classification process was as follows:
1. Call Sentinel-2 image collection from imports and filter to get least cloudy image
2. Import ALOS landform and elevation datasets
3. Generate Sentinel-2 indices and add them as bands to the image
4. Create a training data subset
5. Run RF classification with the training subset
6. Stipulate colour palette and express the classification
7. Add the Legend
8. Specify split panels for the Sentinel-2 image and classification
9. Display the split panels

Sentinel-2 and ALOS datasets required for the classifation can be loaded from Google Earth Engine archives. The training and validation datasets can be uploaded as assets. 

The repository also includes R code for accuracy assessment, stratified sampling to split the dataset into 70% training and 30% validation, as well as scripts for generating jitter plots and wavelength plots.

The MapWAPS results and traning dataset have been archived on SunScholar repository. 
1) uMzimvubu Catchment: https://scholardata.sun.ac.za/articles/dataset/MapWAPS_Invasive_Alien_Plant_Map_for_the_uMzimvubu_Catchment/25050401
3) Luvhuvu Catchment: https://scholardata.sun.ac.za/articles/dataset/MapWAPS_Invasive_Alien_Plant_Map_for_the_Luvuvhu_Catchment/25050314
5) Tugela Catchment: https://scholardata.sun.ac.za/articles/dataset/MapWAPS_Invasive_Alien_Plant_map_for_the_Tugela_Catchment/25066151
7) Sabie-Crocodile Catchments: https://scholardata.sun.ac.za/articles/dataset/Invasive_Alien_Plant_map_for_the_Sabie-Crocodile_Catchments/25050368
9) Olifants-Doring Catchments: https://scholardata.sun.ac.za/articles/dataset/MapWAPS_Invasive_Alien_Plant_map_for_the_Olifants-Doring_Catchments/29958053
10) Cape Floristic Region: https://scholardata.sun.ac.za/articles/dataset/BioSCape_Invasive_Alien_Plant_map_for_the_Cape_Floristic_Region/27377211

MapWAPS Water Research Commison report can be downloaded from this link: https://www.wrc.org.za/wp-content/uploads/mdocs/3193%20final.pdf

The citation for this code is on this link: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.16964232.svg)](https://doi.org/10.5281/zenodo.16964232)

# Acknowledgements
The code used in this study was adapted from Petra B. Holden, Alanna J. Rebelo, Mark G. New, 2021, Mapping invasive alien trees in water towers: A combined approach using satellite data fusion, drone technology and expert engagement,Remote Sensing Applications: Society and Environment, Volume 21, https://doi.org/10.1016/j.rsase.2020.100448.

Mr Nicholas Coertze is acknowleged for his contribution with the Cape Floristic Region Alien Map.
