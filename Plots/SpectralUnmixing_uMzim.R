### Wavelength plots
rm(list=ls())
library(dplyr)
library(ggplot2)
library(tidyr)

#Bands
#'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B11', 'B12'
#Central Wavelengths
#490, 560,   665,   705,  740, 786,   842,  865,  1610,   2190

setwd("C:/Users/Thand/OneDrive - Stellenbosch University/MAPWAPS/Fieldwork/uMzimvubuFieldTrip/FinalOutputs/SpectralUnmixing")

#######################################################################
##################              ALL BANDS           ##################
######################################################################

#Options
#alltraining_bands_S1_Longtimeperiod.csv
#alltraining_bands_s1.csv

### mean, max and min values for BANDS
bands_all = read.csv("Training_BandsIndices.csv") %>% 
  select(LULC, B11:B8A) %>%
  mutate(LULC = as.factor(as.character(LULC)))

#scale <- function(x) (x/10000) do this in GEE

bands_all_grp = bands_all %>% group_by(LULC) %>%  
  summarise_if(is.numeric, (list(~mean(.), ~min(.), ~max(.)))) %>% gather(band, value, B11_mean:B8A_max) %>%
  extract(col = band, into = c("band", "stat"), "(.*)_([^_]+)$") %>% 
  spread(stat,value) %>% mutate(band = as.factor(band)) 

bandlevs = levels(bands_all_grp$band)
labs = c("1610", "2190", "490",  "560", "665",  "705",  "740",  "786",  "842",  "865")

 bands_all_grp = bands_all_grp %>% mutate(wavelength = factor(band, levels = bandlevs, 
                              labels = labs)) %>%
   mutate(wavelength = as.numeric(as.character(wavelength)))  %>%
   ungroup()

# Setting levels for LULC class colours 
levels(bands_all_grp$LULC)
bands_all_grp$Landclass <- as.character(bands_all_grp$LULC)
bands_all_grp$Landclass <- factor(bands_all_grp$Landclass, levels=unique(bands_all_grp$Landclass))
bands_all_grp <- bands_all_grp %>% mutate(Landclass = factor(Landclass, levels = c("Alien_Black Wattle", "Alien_Gum", "Alien_Other","Alien_Pine", "Alien_Poplar", "Alien_Silver Wattle", "Bare Ground", "Dryland Agriculture", "Grassland",  "Indigenous Bush","Irrigated Agriculture", 
           "Maize","Urban", "Water", "Wetland")))
levels(bands_all_grp$Landclass)

## add colour for alien tree other into here below "#7811F7",
cols = c("#cd6090", "#F91DF9","#741b47", "#fd0618", "#674EA7","#eea2ad", "#FFFFFF", "#FEE238", "#a8a800", "#6aa84f", "#ffff00",
         "#783f04","#000000", "#0a14f9", "#08f3e4")

#'ffffff', // Bare Ground// White
#'cd6090', //B.wattle//dark purple
#'FEE238', // Dryland AG// Yellow
#'a8a800', // Grassland // citrus green
#'F91DF9', //Gum/purple
#'6aa84f', // Indigenous Bush // moderate dark green
#'ffff00', // Irrigated AG // Lime green
#'783f04', // Maize/ brown
#'741b47', //Other invasive alien trees
#'fd0618',//Pine, red
#'674EA7', // Poplar,
#'eea2ad', //S.Wattle// light purple
#'000000', //Urban//black
#'0a14f9', // Water// Royal blue
#'08f3e4', // Wetland//Baby blue


#### plotting wavelength plot
windows()  
 ggplot(bands_all_grp) +
   geom_line(aes(wavelength, mean, colour = Landclass), group = 1) +
   geom_ribbon(aes(x = wavelength, ymax = max, ymin = min, fill = Landclass), alpha = 0.3) + 
   facet_wrap(.~Landclass, ncol = 6) +
   scale_colour_manual(values=cols) +
   scale_fill_manual(values=cols)+
   theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ 
   theme (panel.background = element_rect(fill = "lightgrey", colour = "lightgrey",
                                 size = 2, linetype = "solid")) + 
   theme(legend.position = "none") +ylab("Reflectance")+xlab("Wavelength (nanometers)")
#setting scale - scale_x_continuous(breaks = c(490, 560,   665,   705,  740, 786,   842,  865,  1610,   2190))

### overlaying onto one plot & subsetting certain classes (adjust as needed)
## New colours

## add colour for alien tree other into here below "#7811F7",
#cols_IAP = c("#FD0618", "#F442D1", "#FF7F00", "#6A0DAD")

# windows()  
# bands_all_grp %>% filter(Landclass %in% c("Pine", "Wattle", "Gum", "Bugweed")) %>%
# ggplot() +
#   geom_line(aes(wavelength, mean, colour = Landclass)) +
#   geom_ribbon(aes(x = wavelength, ymax = max, ymin = min, fill = Landclass), alpha = 0.1)  +
#   scale_colour_manual(values=cols_IAP) +
#   scale_fill_manual(values=cols_IAP)+theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ 
#   theme (panel.background = element_rect(fill = "white", colour = "grey",
#                                          size = 2, linetype = "solid")) + theme(legend.position = "top") +
#   ylab("Reflectance")+
#   xlab("Wavelength (nanometers)")
# setting scale - scale_x_continuous(breaks = c(490, 560,   665,   705,  740, 786,   842,  865,  1610,   2190))


##### jitter dot plots for bands
#bands_full = bands_all %>% select(LULC, everything()) %>% 
  #gather(band, value, VH_Filtered: VV_Filtered)  %>% mutate(band = as.factor(band)) %>% mutate(reflectance = value)


bands_full = bands_all %>% select(LULC, everything()) %>% 
  gather(band, value, B11: B8A)  %>% mutate(band = as.factor(band)) %>% mutate(reflectance = value)

# add on if would like to change names of bands to wavelengths 
# mutate(wavelength = factor(band, levels = c(), labels = c())) 

levels(bands_full$band)
# setting levels for colours
levels(bands_full$LULC)
bands_full$Landclass <- as.character(bands_full$LULC)
bands_full$Landclass <- factor(bands_full$Landclass, levels=unique(bands_full$Landclass))
bands_full <- bands_full %>% 
  mutate(Landclass = factor(Landclass, 
                            levels = c("Alien_Black Wattle", "Alien_Gum", "Alien_Other","Alien_Pine", "Alien_Poplar", "Alien_Silver Wattle", "Bare Ground", "Dryland Agriculture", "Grassland",  "Indigenous Bush","Irrigated Agriculture", 
                                       "Maize","Urban", "Water", "Wetland")))

# plot
windows() 
bands_full %>% 
  ggplot(aes(x = Landclass, y = reflectance, colour = Landclass)) +
  geom_boxplot(fill = "grey", colour = "black", outlier.colour="grey") +
  geom_jitter(position = position_jitter(width = 0.1, height = 0), alpha = 1/4) +
  stat_summary(fun.y = min, geom = "point", size = 1) +
  stat_summary(fun.y = max, geom = "point", size = 1) +
  scale_colour_manual(values=cols)+ 
  facet_wrap(.~band, scales = "free_y", ncol = 5) +
  theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ 
  theme (panel.background = element_rect(fill = "grey", colour = "grey",
                                         size = 2, linetype = "solid")) + theme(legend.position = "none")  + 
  theme(axis.text.x = element_text(angle = 90))


#######################################################################
##################             ALL INDICES           ##################
######################################################################


##### jitter dot plots for indices
#### refer to code to get band names and related index name: https://code.earthengine.google.com/cbebf2b28d05d0cb94a4cdb0f5345404

indices_all = read.csv("alltraining_indices.csv") %>% select(-system.index, -latitude_209564535, -longitude_209564535, -.geo) %>%
  select(LULC, code, B11_1:constant_4) %>%
  mutate(code = as.factor(as.character(code))) %>% 
  gather(index, value, B11_1:constant_4)  %>% mutate(index = as.factor(index))

indices_all$index <- factor(indices_all$index, levels=unique(indices_all$index))
indices_all <- indices_all %>% mutate(index = factor(index, levels = c('B8_1', 'B8A_1', 'B7_1', 'B7_2', 'B7_3', "B2_1", "B3_1", "B8_2", "B11_1", 
                                                                       "B6_1", "B11_2", "B8_3", "B8_4", "B3_2", "B11_3", "constant", "constant_1", "constant_2", "constant_3",
                                                                       "B3_3", "B8_5", "B4_1", "B4_2", "B4_3", "constant_4", "B8A_2", "B2_2", "B2_3", "B2_4", 
                                                                       "B8A_3", "B8A_4", "B8A_5", "B8A_6", "B8A_7", "B8A_8", "B11_4", "B2_5", "B8_6", "B8_7")))

indlevs = levels(indices_all$index)
indlabs = c("NDVI", "Chlogreen", "LAnthoC", "LCaroC", "LChloC", "BAI", "GI", "gNDVI", "MSI",
            "NDrededgeSWIR", "NDTI", "NDVIre", "NDVI1", "NDVI2", "NHI", "EVI", "EVI2", "EVI2_2", "MSAVI",
            "NormG", "NormNIR", "NormR", "RededgePeakArea", "RedSWIR1", "RTVIcore", "SAVI", "SRBlueRededge1", "SRBlueRededge2", "SRBlueRededge3",
            "SRNIRnarrowBlue", "SRNIRnarrowGreen", "SRNIRnarrowRed", "SRNIRnarrowRededge1", "SRNIRnarrowRededge2", "SRNIRnarrowRededge3", "STI", "WBI", "NDMI", "NDBR")

indices_all = indices_all %>% mutate(vegindex = factor(index, levels = indlevs, 
                                                       labels = indlabs))
# setting levels for colours
levels(indices_all$LULC)
indices_all$Landclass <- as.character(indices_all$LULC)
indices_all$Landclass <- factor(indices_all$Landclass, levels=unique(indices_all$Landclass))
indices_all <- indices_all %>% 
  mutate(Landclass = factor(Landclass, 
                            levels = c("Wetland", "Bare Ground", "Water", "Dryland Crops", "Irrigated Grazing", 
                                       "Sugarcane", "Burnt Area", "Urban/Settlements","Grassland", "Indigenous Forest", 
                                       "Pine", "Wattle", "Gum", "Bugweed")))




# plot in stages 
windows() 
indices_all %>% filter(vegindex %in% c("NDVI", "Chlogreen", "LAnthoC", "LCaroC", "LChloC", "BAI", "GI", "gNDVI", "MSI"))%>%
  ggplot(aes(x = Landclass, y = value, colour = Landclass)) +
  geom_boxplot(fill = "grey", colour = "black", outlier.colour="grey") +
  geom_jitter(position = position_jitter(width = 0.1, height = 0), alpha = 1/4) +
  stat_summary(fun.y = min, geom = "point", size = 1) +
  stat_summary(fun.y = max, geom = "point", size = 1) +
  scale_colour_manual(values=cols)+ 
  facet_wrap(.~vegindex, scales = "free_y", ncol = 5) +
  theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ 
  theme (panel.background = element_rect(fill = "grey", colour = "grey",
                                         size = 2, linetype = "solid")) + theme(legend.position = "none")  + 
  theme(axis.text.x = element_text(angle = 90))

indices_all %>% filter(vegindex %in% c("NDrededgeSWIR", "NDTI", "NDVIre", "NDVI1", "NDVI2", "NHI", "EVI", "EVI2", "EVI2_2", "MSAVI"))%>%
  ggplot(aes(x = Landclass, y = value, colour = Landclass)) +
  geom_boxplot(fill = "grey", colour = "black", outlier.colour="grey") +
  geom_jitter(position = position_jitter(width = 0.1, height = 0), alpha = 1/4) +
  stat_summary(fun.y = min, geom = "point", size = 1) +
  stat_summary(fun.y = max, geom = "point", size = 1) +
  scale_colour_manual(values=cols)+ 
  facet_wrap(.~vegindex, scales = "free_y", ncol = 5) +
  theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ 
  theme (panel.background = element_rect(fill = "grey", colour = "grey",
                                         size = 2, linetype = "solid")) + theme(legend.position = "none")  + 
  theme(axis.text.x = element_text(angle = 90))

indices_all %>% filter(vegindex %in% c("NormG", "NormNIR", "NormR", "RededgePeakArea", "RedSWIR1", "RTVIcore", "SAVI", "SRBlueRededge1", "SRBlueRededge2", "SRBlueRededge3"))%>%
  ggplot(aes(x = Landclass, y = value, colour = Landclass)) +
  geom_boxplot(fill = "grey", colour = "black", outlier.colour="grey") +
  geom_jitter(position = position_jitter(width = 0.1, height = 0), alpha = 1/4) +
  stat_summary(fun.y = min, geom = "point", size = 1) +
  stat_summary(fun.y = max, geom = "point", size = 1) +
  scale_colour_manual(values=cols)+ 
  facet_wrap(.~vegindex, scales = "free_y", ncol = 5) +
  theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ 
  theme (panel.background = element_rect(fill = "grey", colour = "grey",
                                         size = 2, linetype = "solid")) + theme(legend.position = "none")  + 
  theme(axis.text.x = element_text(angle = 90))


indices_all %>% filter(vegindex %in% c("SRNIRnarrowBlue", "SRNIRnarrowGreen", "SRNIRnarrowRed", "SRNIRnarrowRededge1", "SRNIRnarrowRededge2", "SRNIRnarrowRededge3", "STI", "WBI", "NDMI", "NDBR")) %>%
  ggplot(aes(x = Landclass, y = value, colour = Landclass)) +
  geom_boxplot(fill = "grey", colour = "black", outlier.colour="grey") +
  geom_jitter(position = position_jitter(width = 0.1, height = 0), alpha = 1/4) +
  stat_summary(fun.y = min, geom = "point", size = 1) +
  stat_summary(fun.y = max, geom = "point", size = 1) +
  scale_colour_manual(values=cols)+ 
  facet_wrap(.~vegindex, scales = "free_y", ncol = 5) +
  theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ 
  theme (panel.background = element_rect(fill = "grey", colour = "grey",
                                         size = 2, linetype = "solid")) + theme(legend.position = "none")  + 
  theme(axis.text.x = element_text(angle = 90))
