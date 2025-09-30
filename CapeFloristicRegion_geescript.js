// // // // Classification of Sentinel 2:
 
// Define the start and end dates for your image collection
var start_date = '2023-09-01';
var end_date = '2023-11-27';

// Filter by date range and region
var criteria = ee.Filter.and(
  ee.Filter.bounds(AOI),
  ee.Filter.date(start_date, end_date)
);

// Load the Sentinel 2 imagery collection
var s2_collection = ee.ImageCollection('COPERNICUS/S2_HARMONIZED').filter(criteria);

// Function to mask clouds based on cloud probability
var MAX_CLOUD_PROBABILITY = 20;
var maskClouds = function(img) {
  var clouds = ee.Image(img.get('cloud_mask')).select('probability');
  var isNotCloud = clouds.lt(MAX_CLOUD_PROBABILITY);
  return img.updateMask(isNotCloud);
};

// Import Cloud Probability datasets & filter
var s2Clouds = ee.ImageCollection('COPERNICUS/S2_CLOUD_PROBABILITY');
var s2Cloudsfiltered = s2Clouds.filter(criteria);

// Join the two collections to add cloud mask to each image
var s2WithCloudMask = ee.Join.saveFirst('cloud_mask').apply({
  primary: s2_collection,
  secondary: s2Cloudsfiltered,
  condition: ee.Filter.equals({
    leftField: 'system:index',
    rightField: 'system:index'
  })
});

// Apply cloud masking
var s2CloudMasked = ee.ImageCollection(s2WithCloudMask)
  .map(maskClouds);

// Calculate median and clip to AOI
var medianImage = s2CloudMasked.median().clip(AOI);

// Convert image to float (if needed)
var cloudfreeImage = medianImage.toFloat();

// Define the band of interest
var BANDS =  ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B11', 'B12'];

// Select the bands (i.e. unselect B1, B9, B10)
var image = cloudfreeImage.select(BANDS).divide(10000);

// Set visualization parameters
var visParams = {
  bands: ['B2', 'B3', 'B4'],
  min: 0,
  max: 0.3,
  gamma: 1.4  // Adjust gamma to enhance contrast
};

// Display the cloud-free RGB image
//Map.addLayer(image, visParams, 'Sentinel 2 Image Collection Mosaic');

Map.centerObject(AOI, 8)

// Print the CRS of the image
var crs = image.projection().crs();
print('Image CRS:', crs);

///////////////////////////////////////////////////////////
/////               Generating Indices               /////
//////////////////////////////////////////////////////////

// 1 NDVI 
    var NDVI = image.expression(
        "(NIR - RED) / (NIR + RED)",
        {
          RED: image.select("B4"),    //  RED
          NIR: image.select("B8"),    // NIR
        });
// 2 Chlogreen (Chlorophyll Green Index)
    var Chlogreen = image.expression(
        "(NIRnarrow) / (GREEN + REDedge1)",
        {
          NIRnarrow: image.select("B8A"),    
          GREEN: image.select("B3"),    
          REDedge1: image.select("B5")    
        });
// 3 LAnthoC (Leaf Anthocynanid Content)
    var LAnthoC = image.expression(
        "(REDedge3) / (GREEN + REDedge1)",
        {
          REDedge3: image.select("B7"),    
          GREEN: image.select("B3"),    
          REDedge1: image.select("B5")    
        });
// 4 LCaroC
var LCaroC = image.expression(
        "(Rededge3) / (Blue - Rededge1)",
        { Rededge3: image.select("B7"),    // Rededge3
          Blue: image.select("B2"),    // Blue
          Rededge1: image.select("B5"),    // Rededge1
          });
// 5 LChloC
var LChloC = image.expression(
        "(Rededge3) / (Rededge1)",
        { Rededge3: image.select("B7"),    // Rededge3
          Rededge1: image.select("B5"),    // Rededge1
          });

// 6 BAI
var BAI = image.expression(
        "(Blue - NIR)/(Blue + NIR)",
        { Blue: image.select("B2"),   
          NIR: image.select("B8"),    
          });
// 7 GI
var GI = image.expression(
        "Green/Red",
        { Green: image.select("B3"),   
          Red: image.select("B4"),
          });
// 8 gNDVI
var gNDVI = image.expression(
        "(NIR - Green)/(NIR + Green)",
        { NIR: image.select("B8"),   
          Green: image.select("B3"),
          });

// 9 MSI
var MSI = image.expression(
        "SWIR1/NIR",
        { SWIR1: image.select("B11"),   
          NIR: image.select("B8"),
          });
// 10 NDrededgeSWIR
var NDrededgeSWIR = image.expression(
        "(Rededge2 - SWIR2) / (Rededge2 + SWIR2)",
        { Rededge2: image.select("B6"),   
          SWIR2: image.select("B12"),
          });
// 11 NDTI (also referred to as NBR2)
var NDTI = image.expression(
        "(SWIR1 - SWIR2) / (SWIR1 + SWIR2)",
        { SWIR1: image.select("B11"),   
          SWIR2: image.select("B12"),
          });
// 12 NDVIre
var NDVIre = image.expression(
        "(NIR - Rededge1) / (NIR + Rededge1)",
        { NIR: image.select("B8"),   
          Rededge1: image.select("B5"),
          });  
// 13 NDVI1
var NDVI1 = image.expression(
        "(NIR - SWIR1) / (NIR + SWIR1)",
        { NIR: image.select("B8"),   
          SWIR1: image.select("B11"),
          });           
// 14 NDVI2
var NDVI2 = image.expression(
        "(Green - NIR) / (Green + NIR)",
        { NIR: image.select("B8"),   
          Green: image.select("B3"),
          }); 
// 15 NHI
var NHI = image.expression(
        "(SWIR1 - Green) / (SWIR1 + Green)",
        { SWIR1: image.select("B11"),   
          Green: image.select("B3"),
          }); 
// 16 EVI
var EVI = image.expression(
        "2.5 * ((NIR - Red) / (NIR + 6*Red-7.5*Blue)+1)",
        { NIR: image.select("B8"),   
          Red: image.select("B4"),
          Blue: image.select("B2"),
          });  
// 17 EVI2
var EVI2 = image.expression(
        "2.4 * ((NIR - Red) / (NIR + Red +1))",
        { NIR: image.select("B8"),   
          Red: image.select("B4"),
          }); 
          
// 18 EVI2_2          
var EVI2_2 = image.expression(
        "2.5 * ((NIR - Red) / (NIR + 2.4 * Red +1))",
        { NIR: image.select("B8"),   
          Red: image.select("B4"),
          }); 
          
// 19 MSAVI
var MSAVI = image.expression(
        "(2 * NIR + 1 - sqrt(pow((2 * NIR + 1), 2) - 8 * (NIR - Red)) ) / 2",
        { NIR: image.select("B8"),   
          Red: image.select("B4"),
          });   
          

// 20 Norm-G (Normalised Green)
 var NormG = image.expression(
        "(GREEN) / (NIRwide + RED + GREEN)",
        {
          GREEN: image.select("B3"),    
          NIRwide: image.select("B8"),    
          RED: image.select("B4")    
        });
// 21 Norm-NIR (Normalised NIR)
 var NormNIR = image.expression(
       "(NIRwide) / (NIRwide + RED + GREEN)",
        {
          GREEN: image.select("B3"),    
          NIRwide: image.select("B8"),    
          RED: image.select("B4")    
        });
// 22 Norm-R (Normalised Red)
 var NormR = image.expression(
       "(RED) / (NIRwide + RED + GREEN)",
        {
          GREEN: image.select("B3"),    
          NIRwide: image.select("B8"),    
          RED: image.select("B4")    
        });
// 23 RededgePeakArea (Red-edge peak area)
 var RededgePeakArea = image.expression(
        "(RED + Rededge1 + Rededge2 + Rededge3 + NIRnarrow)",
        {
          Rededge1: image.select("B5"), 
          Rededge2: image.select("B6"), 
          Rededge3: image.select("B7"), 
          NIRnarrow: image.select("B8A"),    
          RED: image.select("B4")    
        });
// 24 RedSWIR1 (Bands difference)
 var RedSWIR1 = image.expression(
        "(RED - SWIR)",
        {
          RED: image.select("B4"),    
          SWIR: image.select("B11")    
        });
// 25 RTVIcore (Red-edge Triangular Vegetation Index)
 var RTVIcore = image.expression(
        "(100 * (NIRnarrow - Rededge1) - 10 * (NIRnarrow - Green))",
        {
          NIRnarrow: image.select("B8A"),    
          Rededge1: image.select("B5"),    
          Green: image.select("B3")    
        });
// 26 SAVI (Soil Adjusted Vegetation Index)
 var SAVI = image.expression(
        "((NIRnarrow - RED) / (NIRnarrow + RED + 0.5) * 1.5)",
        {
          NIRnarrow: image.select("B8A"),    
          RED: image.select("B4")    
          });
// 27 SR-BlueRededge1 (Simple Blue and Red-edge 1 Ratio)
 var SRBlueRededge1 = image.expression(
        "(BLUE / REDedge1)",
        {
          BLUE: image.select("B2"),    
          REDedge1: image.select("B5")    
        });
// 28 SR-BlueRededge2 (Simple Blue and Red-edge 2 Ratio)
 var SRBlueRededge2 = image.expression(
        "(BLUE / REDedge2)",
        {
          BLUE: image.select("B2"),    
          REDedge2: image.select("B6")    
        });
// 29 SR-BlueRededge3 (Simple Blue and Red-edge 3 Ratio)
 var SRBlueRededge3 = image.expression(
        "(BLUE / REDedge3)",
        {
          BLUE: image.select("B2"),    
          REDedge3: image.select("B7")    
        });
// 30 SR-NIRnarrowBlue (Simple ratio NIR narrow and Blue)
 var SRNIRnarrowBlue = image.expression(
        "(NIRnarrow / BLUE)",
        {
          NIRnarrow: image.select("B8A"),    
          BLUE: image.select("B2")    
        });
// 31 SR-NIRnarrowGreen (Simple ratio NIR narrow and Green)
 var SRNIRnarrowGreen = image.expression(
        "(NIRnarrow / GREEN)",
        {
          NIRnarrow: image.select("B8A"),    
          GREEN: image.select("B3")    
        });
// 32 SR-NIRnarrowRed (Simple ratio NIR narrow and Red)
 var SRNIRnarrowRed = image.expression(
        "(NIRnarrow / RED)",
        {
          NIRnarrow: image.select("B8A"),    
          RED: image.select("B4")    
        });
// 33 SR-NIRnarrowRededge1 (Simple NIR and Red-edge 1 Ratio)
 var SRNIRnarrowRededge1 = image.expression(
        "(NIRnarrow / REDedge1)",
        {
          NIRnarrow: image.select("B8A"),    
          REDedge1: image.select("B5")    
        });
// 34 SR-NIRnarrowRededge2 (Simple NIR and Red-edge 2 Ratio)
 var SRNIRnarrowRededge2 = image.expression(
        "(NIRnarrow / REDedge2)",
        {
          NIRnarrow: image.select("B8A"),    
          REDedge2: image.select("B6")    
        });
// 35 SR-NIRnarrowRededge3 (Simple NIR and Red-edge 3 Ratio)
 var SRNIRnarrowRededge3 = image.expression(
        "(NIRnarrow / REDedge3)",
        {
          NIRnarrow: image.select("B8A"),    
          REDedge3: image.select("B7")    
        });
// 36 STI (Soil Tillage Index)
 var STI = image.expression(
        "(SWIR1 / SWIR2)",
        {
          SWIR1: image.select("B11"),    
          SWIR2: image.select("B12")
        });
// 37 WBI (Water Body Index)
 var WBI = image.expression(
        "(BLUE - RED) / (BLUE + RED)",
        {
          BLUE: image.select("B2"),    
          RED: image.select("B4")
        });
// 38 NDMI (Normalized Difference Moisture Index)
 var NDMI = image.expression(
        "(NIR-SWIR)/(NIR+SWIR)",
        {
          NIR: image.select("B8"),    
          SWIR: image.select("B11"),    
          });
// 39 NDBR (Normalized Difference Burning Ratio) (also referred to as NBR)
 var NDBR = image.expression(
        "(NIR-MIR)/(NIR+MIR)",
        {
          NIR: image.select("B8"),    
          MIR: image.select("B12"),    
          });

// // adding all the indices into the image as new bands
var image = image.addBands(NDVI); 
var image = image.addBands(Chlogreen);
var image = image.addBands(LAnthoC);
var image = image.addBands(LCaroC);
var image = image.addBands(LChloC);

var image = image.addBands(BAI);
var image = image.addBands(GI);
var image = image.addBands(gNDVI);
var image = image.addBands(MSI);

var image = image.addBands(NDrededgeSWIR);
var image = image.addBands(NDTI);
var image = image.addBands(NDVIre);
var image = image.addBands(NDVI1);
var image = image.addBands(NDVI2);

var image = image.addBands(NHI);
var image = image.addBands(EVI);
var image = image.addBands(EVI2);
var image = image.addBands(EVI2_2);
var image = image.addBands(MSAVI);

var image = image.addBands(NormG);
var image = image.addBands(NormNIR);
var image = image.addBands(NormR);
var image = image.addBands(RededgePeakArea);
var image = image.addBands(RedSWIR1);

var image = image.addBands(RTVIcore);
var image = image.addBands(SAVI);
var image = image.addBands(SRBlueRededge1);
var image = image.addBands(SRBlueRededge2);
var image = image.addBands(SRBlueRededge3);

var image = image.addBands(SRNIRnarrowBlue);
var image = image.addBands(SRNIRnarrowGreen);
var image = image.addBands(SRNIRnarrowRed);
var image = image.addBands(SRNIRnarrowRededge1);
var image = image.addBands(SRNIRnarrowRededge2);

var image = image.addBands(SRNIRnarrowRededge3);
var image = image.addBands(STI);
var image = image.addBands(WBI);
var image = image.addBands(NDMI);
var image = image.addBands(NDBR);

//print (image, "allindices added");

// Training data
var bands = ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B11', 'B12',
               'B8_1', 'B8A_1',
               'B7_1', 
               //'B7_2',
               'B7_3', "B2_1", "B3_1", "B8_2", "B11_1", 
                "B6_1", "B11_2", "B8_3", "B8_4", "B3_2", "B11_3", "constant", "constant_1", "constant_2", "constant_3",
                "B3_3", "B8_5", "B4_1", "B4_2", "B4_3", "constant_4", "B8A_2", "B2_2", "B2_3", "B2_4", 
                "B8A_3", "B8A_4", "B8A_5", "B8A_6", "B8A_7", "B8A_8", "B11_4", "B2_5", "B8_6", "B8_7"];

//print('Training Feature Collection:', Train_FC);

///////////////////////////////////////////////////////////
/////             Generate Training Data             /////
//////////////////////////////////////////////////////////

// Train the classifier with 70% of our data.
// Split the training dataset into three parts: first 5000,second 5000 and remaining 640 sample points
var training_list = training.toList(training.size());

// Get the first 5000 features
var training_part1 = ee.FeatureCollection(training_list.slice(0, 5000));

// Get the next 5000 features
var training_part2 = ee.FeatureCollection(training_list.slice(5000, 9000));

// Get the next 640 features

var training_part3 = ee.FeatureCollection(training_list.slice(10000, 10640));

// Sample the image bands for each subset
var training_subset1 = image.select(bands).sampleRegions({
  collection: training_part1, 
  properties: ['code', 'LULC'], 
  geometries: true,
  scale: 10
});
//print(training_subset1)

var training_subset2 = image.select(bands).sampleRegions({
  collection: training_part2, 
  properties: ['code', 'LULC'], 
  geometries: true,
  scale: 10
});

//print(training_subset2)

var training_subset3 = image.select(bands).sampleRegions({
  collection: training_part3, 
  properties: ['code', 'LULC'],  
  geometries: true,
  scale: 10
});

//print(training_subset3)


// Merge the two training subsets back into a single collection
var combined_training_subset = training_subset1.merge(training_subset2).merge(training_subset3);

//print(combined_training_subset, 'combined_training_subset');


/////////////////////////////////////////////////////////////////////////////////////////////////
// Export the combined training subset to Google Drive
Export.table.toDrive({
  collection: combined_training_subset,
  description: 'CFR_training_data_with_bands_and_indices_for_jitterplots',
  fileFormat: 'CSV'  // You can also use 'GeoJSON', 'KML', or other formats supported by GEE
});

/////////////////////////////////////////////////////////////////////////////////////////////////

// Train the classifier with the combined dataset
var classifier = ee.Classifier.smileRandomForest(500).train({
  features: combined_training_subset, 
  classProperty: 'code', 
  inputProperties: bands
});
// Define a palette for visualization

var palette = [
  '#FF0000',  // Pine (Bright Red)
  '#FF7F00',  // Gum (Bright Orange)
  '#FF69B4',  // Wattle (Bright Pink)
  '#800080',  // Hakea (Purple)
  '#FFEBBE',  // Other IAP (Saharah Sand)
  '#006400',  // Afromontane Forest (Dark Green)
  '#6D974E',  // LD Fynbos (Mid Green)
  '#4C7300',  // HD Fynbos (Olive Green)
  '#898944',  // Renosterveld (Grayish Olive)
  '#E9FFBE',  // Succulent Karoo (Light Green)
  '#73DFFF',  // Wetland (Sky Blue)
  '#0000FF',  // Water (Blue)
  '#875B39',  // Bare Ground (Brown)
  '#FFFFFF',  // Urban (White)
  '#E1E1E1',  // Rock (Light Gray)
  '#4CE600',  // Irrigated Agri (Lime Green)
  '#C7D79E',  // Dryland Agri (Pale Olive)
  '#000000',  // Shade (Dark Gray)
  '#FFFF00'   // Poplar (Bright Yellow)
];



// Define visualization parameters for classified images
var classified_vis_params = {
  min: 1,
  max: 19,
  palette: palette
};


// Select bands for classification and classify the image
var classified_image = image.clip(AOI).select(bands).classify(classifier);


// Add the classified image to the map
Map.addLayer(classified_image, classified_vis_params, 'classification');

///////////////////////////////////////////////////////////
/////                   Export                        /////
//////////////////////////////////////////////////////////
var wktAEA = 'PROJCS["AEA_RSA_WGS84",' +
    'GEOGCS["GCS_WGS_1984",' +
        'DATUM["D_WGS_1984",' +
            'SPHEROID["WGS_1984",6378137.0,298.257223563]],' +
        'PRIMEM["Greenwich",0.0],' +
        'UNIT["Degree",0.0174532925199433]],' +
    'PROJECTION["Albers"],' +
    'PARAMETER["False_Easting",0.0],' +
    'PARAMETER["False_Northing",0.0],' +
    'PARAMETER["Central_Meridian",25.0],' +
    'PARAMETER["Standard_Parallel_1",-24.0],' +
    'PARAMETER["Standard_Parallel_2",-33.0],' +
    'PARAMETER["Latitude_Of_Origin",0.0],' +
    'UNIT["Meter",1.0]]';

Export.image.toDrive({
  image: classified_image,
  description: 'CFR_LULC_Classification_2023',
  scale: 10,
  region: AOI,
  fileFormat: 'GeoTIFF',
  crs: wktAEA,
  maxPixels: 1e10  // Increase this to handle larger exports
});


///////////////////////////////////////////////////////////
/////             Generate Validation Data             /////
//////////////////////////////////////////////////////////
// Train the classifier with 30% of our data.

// Sample the image bands 
var validation_subset = image.select(bands).sampleRegions({
  collection: validation, 
  properties: ['code','LULC'], 
  geometries: true,
  scale: 10
});

///////////////////////////////////////////////////////////
/////     Accuracy Assessment Export                 /////
//////////////////////////////////////////////////////////

// // exporting data for accuracy assessment in R
// adding predicted LULC to training and validation datasets

// // // validation 30% not used in training
var validation_30 = classified_image.select('classification').sampleRegions({        ///
  collection: validation_subset, 
  properties: ['code'],
  //tileScale: 4,
  //geometries: false, //true,
  scale: 10
});
// // print(validation_30, 'validation_30');

Export.table.toDrive({
  collection: validation_30,
  description:'CFR_classification_1_validation_30',
  fileFormat: 'CSV'
});

// // training 70% used in training
var training_70 = classified_image.select('classification').sampleRegions({      //.select('classification')
  collection: combined_training_subset, 
  properties: ['code'],
  //tileScale: 4,
  //geometries: false,//true,
  scale: 10
});
// // print(training_70, "training_70");

Export.table.toDrive({
  collection: training_70,
  description:'CFR_classification_1_training_70',
  fileFormat: 'CSV'
});


 ////////////////////////////////////////////////////////////////////////////////////////////////////
// setting for APP

// add legend and set position of panel
var legend = ui.Panel({
  style: {
    position: 'bottom-right',
    padding: '8px 15px'
  }
});
 // Create legend title
var legendTitle = ui.Label({
  value: 'Legend',
  style: {
    fontWeight: 'bold',
    fontSize: '18px',
    margin: '0 0 4px 0',
    padding: '0'
    }
});
 // Add the title to the panel
legend.add(legendTitle);
 // Creates and styles 1 row of the legend.
var makeRow = function(color, name) {
       // Create the label that is actually the colored box.
      var colorBox = ui.Label({
        style: {
          backgroundColor: color,
          // Use padding to give the box height and width.
          padding: '8px',
          margin: '0 0 4px 0'
        }
      });
       // Create the label filled with the description text.
      var description = ui.Label({
        value: name,
        style: {margin: '0 0 4px 6px'}
      });
       // return the panel
      return ui.Panel({
        widgets: [colorBox, description],
        layout: ui.Panel.Layout.Flow('horizontal')
      });
};
 // name of the legend
var names = ['Pine','Gum','Wattle','Hakea','Other IAP','Afromontane Forest','LD Fynbos','HD Fynbos','Renosterveld','Succulent Karoo','Wetland','Water','Bare Ground','Urban','Rock','Irrigated Agriculture','Dryland Agriculture','Shade','Poplar'];
 // Add color and and names
for (var i = 0; i < 19; i++) {
  legend.add(makeRow(palette[i], names[i]));
  }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
 
// 8 // Specify split panels for the S2 image and classification ///////////////////////////////////////////////////////
// Display the original image and classified map in a split panel
var leftMap = ui.Map();
var rightMap = ui.Map();
// // Center the maps on the ROI
leftMap.centerObject(AOI, 7);
rightMap.centerObject(AOI, 7);
// // Add layers to the left map (S2 image)
leftMap.addLayer(image, {bands: ['B4', 'B3', 'B2'], max: 0.3}, 'S2 Image');
// // Add layers to the right map (classified map)
rightMap.addLayer(classified_image, {min: 1, max: 19, palette: palette}, 'Land Cover Classification_2023');
rightMap.add(legend);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 9 // Display the split panels ///////////////////////////////////////////////////////////////////////////////////////////
// // Create a split panel and add the maps
var splitPanel = ui.SplitPanel({
  firstPanel: leftMap,
  secondPanel: rightMap,
  orientation: 'horizontal',
  wipe: true,
  style: {stretch: 'both'}
});
// // Add the split panel to the Code Editor
ui.root.widgets().reset([splitPanel]);
// // Link the maps for synchronization
var linker = ui.Map.Linker([leftMap, rightMap]);











////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Define the start and end dates for your image collection
var start_date_2017 = '2018-09-01';
var end_date_2017 = '2018-11-27';

// Filter by date range and region
var criteria = ee.Filter.and(
  ee.Filter.bounds(AOI),
  ee.Filter.date(start_date_2017, end_date_2017)
);

// Load the Sentinel 2 imagery collection
var s2_collection = ee.ImageCollection('COPERNICUS/S2_HARMONIZED').filter(criteria);

// Function to mask clouds based on cloud probability
var MAX_CLOUD_PROBABILITY = 20;
var maskClouds = function(img) {
  var clouds = ee.Image(img.get('cloud_mask')).select('probability');
  var isNotCloud = clouds.lt(MAX_CLOUD_PROBABILITY);
  return img.updateMask(isNotCloud);
};

// Import Cloud Probability datasets & filter
var s2Clouds = ee.ImageCollection('COPERNICUS/S2_CLOUD_PROBABILITY');
var s2Cloudsfiltered = s2Clouds.filter(criteria);

// Join the two collections to add cloud mask to each image
var s2WithCloudMask = ee.Join.saveFirst('cloud_mask').apply({
  primary: s2_collection,
  secondary: s2Cloudsfiltered,
  condition: ee.Filter.equals({
    leftField: 'system:index',
    rightField: 'system:index'
  })
});

// Apply cloud masking
var s2CloudMasked = ee.ImageCollection(s2WithCloudMask)
  .map(maskClouds);

// Calculate median and clip to AOI
var medianImage = s2CloudMasked.median().clip(AOI);

// Convert image to float (if needed)
var cloudfreeImage = medianImage.toFloat();

// Define the band of interest
var BANDS =  ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B11', 'B12'];

// Select the bands (i.e. unselect B1, B9, B10)
var image = cloudfreeImage.select(BANDS).divide(10000);

// Set visualization parameters
var visParams = {
  bands: ['B2', 'B3', 'B4'],
  min: 0,
  max: 0.3,
  gamma: 1.4  // Adjust gamma to enhance contrast
};

// Display the cloud-free RGB image
//Map.addLayer(image, visParams, 'Sentinel 2 Image Collection Mosaic');

Map.centerObject(AOI, 8)

// Print the CRS of the image
var crs = image.projection().crs();
print('Image CRS:', crs);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////               Generating Indices               /////
//////////////////////////////////////////////////////////

// 1 NDVI 
    var NDVI = image.expression(
        "(NIR - RED) / (NIR + RED)",
        {
          RED: image.select("B4"),    //  RED
          NIR: image.select("B8"),    // NIR
        });
// 2 Chlogreen (Chlorophyll Green Index)
    var Chlogreen = image.expression(
        "(NIRnarrow) / (GREEN + REDedge1)",
        {
          NIRnarrow: image.select("B8A"),    
          GREEN: image.select("B3"),    
          REDedge1: image.select("B5")    
        });
// 3 LAnthoC (Leaf Anthocynanid Content)
    var LAnthoC = image.expression(
        "(REDedge3) / (GREEN + REDedge1)",
        {
          REDedge3: image.select("B7"),    
          GREEN: image.select("B3"),    
          REDedge1: image.select("B5")    
        });
// 4 LCaroC
var LCaroC = image.expression(
        "(Rededge3) / (Blue - Rededge1)",
        { Rededge3: image.select("B7"),    // Rededge3
          Blue: image.select("B2"),    // Blue
          Rededge1: image.select("B5"),    // Rededge1
          });
// 5 LChloC
var LChloC = image.expression(
        "(Rededge3) / (Rededge1)",
        { Rededge3: image.select("B7"),    // Rededge3
          Rededge1: image.select("B5"),    // Rededge1
          });

// 6 BAI
var BAI = image.expression(
        "(Blue - NIR)/(Blue + NIR)",
        { Blue: image.select("B2"),   
          NIR: image.select("B8"),    
          });
// 7 GI
var GI = image.expression(
        "Green/Red",
        { Green: image.select("B3"),   
          Red: image.select("B4"),
          });
// 8 gNDVI
var gNDVI = image.expression(
        "(NIR - Green)/(NIR + Green)",
        { NIR: image.select("B8"),   
          Green: image.select("B3"),
          });

// 9 MSI
var MSI = image.expression(
        "SWIR1/NIR",
        { SWIR1: image.select("B11"),   
          NIR: image.select("B8"),
          });
// 10 NDrededgeSWIR
var NDrededgeSWIR = image.expression(
        "(Rededge2 - SWIR2) / (Rededge2 + SWIR2)",
        { Rededge2: image.select("B6"),   
          SWIR2: image.select("B12"),
          });
// 11 NDTI (also referred to as NBR2)
var NDTI = image.expression(
        "(SWIR1 - SWIR2) / (SWIR1 + SWIR2)",
        { SWIR1: image.select("B11"),   
          SWIR2: image.select("B12"),
          });
// 12 NDVIre
var NDVIre = image.expression(
        "(NIR - Rededge1) / (NIR + Rededge1)",
        { NIR: image.select("B8"),   
          Rededge1: image.select("B5"),
          });  
// 13 NDVI1
var NDVI1 = image.expression(
        "(NIR - SWIR1) / (NIR + SWIR1)",
        { NIR: image.select("B8"),   
          SWIR1: image.select("B11"),
          });           
// 14 NDVI2
var NDVI2 = image.expression(
        "(Green - NIR) / (Green + NIR)",
        { NIR: image.select("B8"),   
          Green: image.select("B3"),
          }); 
// 15 NHI
var NHI = image.expression(
        "(SWIR1 - Green) / (SWIR1 + Green)",
        { SWIR1: image.select("B11"),   
          Green: image.select("B3"),
          }); 
// 16 EVI
var EVI = image.expression(
        "2.5 * ((NIR - Red) / (NIR + 6*Red-7.5*Blue)+1)",
        { NIR: image.select("B8"),   
          Red: image.select("B4"),
          Blue: image.select("B2"),
          });  
// 17 EVI2
var EVI2 = image.expression(
        "2.4 * ((NIR - Red) / (NIR + Red +1))",
        { NIR: image.select("B8"),   
          Red: image.select("B4"),
          }); 
          
// 18 EVI2_2          
var EVI2_2 = image.expression(
        "2.5 * ((NIR - Red) / (NIR + 2.4 * Red +1))",
        { NIR: image.select("B8"),   
          Red: image.select("B4"),
          }); 
          
// 19 MSAVI
var MSAVI = image.expression(
        "(2 * NIR + 1 - sqrt(pow((2 * NIR + 1), 2) - 8 * (NIR - Red)) ) / 2",
        { NIR: image.select("B8"),   
          Red: image.select("B4"),
          });   
          

// 20 Norm-G (Normalised Green)
 var NormG = image.expression(
        "(GREEN) / (NIRwide + RED + GREEN)",
        {
          GREEN: image.select("B3"),    
          NIRwide: image.select("B8"),    
          RED: image.select("B4")    
        });
// 21 Norm-NIR (Normalised NIR)
 var NormNIR = image.expression(
       "(NIRwide) / (NIRwide + RED + GREEN)",
        {
          GREEN: image.select("B3"),    
          NIRwide: image.select("B8"),    
          RED: image.select("B4")    
        });
// 22 Norm-R (Normalised Red)
 var NormR = image.expression(
       "(RED) / (NIRwide + RED + GREEN)",
        {
          GREEN: image.select("B3"),    
          NIRwide: image.select("B8"),    
          RED: image.select("B4")    
        });
// 23 RededgePeakArea (Red-edge peak area)
 var RededgePeakArea = image.expression(
        "(RED + Rededge1 + Rededge2 + Rededge3 + NIRnarrow)",
        {
          Rededge1: image.select("B5"), 
          Rededge2: image.select("B6"), 
          Rededge3: image.select("B7"), 
          NIRnarrow: image.select("B8A"),    
          RED: image.select("B4")    
        });
// 24 RedSWIR1 (Bands difference)
 var RedSWIR1 = image.expression(
        "(RED - SWIR)",
        {
          RED: image.select("B4"),    
          SWIR: image.select("B11")    
        });
// 25 RTVIcore (Red-edge Triangular Vegetation Index)
 var RTVIcore = image.expression(
        "(100 * (NIRnarrow - Rededge1) - 10 * (NIRnarrow - Green))",
        {
          NIRnarrow: image.select("B8A"),    
          Rededge1: image.select("B5"),    
          Green: image.select("B3")    
        });
// 26 SAVI (Soil Adjusted Vegetation Index)
 var SAVI = image.expression(
        "((NIRnarrow - RED) / (NIRnarrow + RED + 0.5) * 1.5)",
        {
          NIRnarrow: image.select("B8A"),    
          RED: image.select("B4")    
          });
// 27 SR-BlueRededge1 (Simple Blue and Red-edge 1 Ratio)
 var SRBlueRededge1 = image.expression(
        "(BLUE / REDedge1)",
        {
          BLUE: image.select("B2"),    
          REDedge1: image.select("B5")    
        });
// 28 SR-BlueRededge2 (Simple Blue and Red-edge 2 Ratio)
 var SRBlueRededge2 = image.expression(
        "(BLUE / REDedge2)",
        {
          BLUE: image.select("B2"),    
          REDedge2: image.select("B6")    
        });
// 29 SR-BlueRededge3 (Simple Blue and Red-edge 3 Ratio)
 var SRBlueRededge3 = image.expression(
        "(BLUE / REDedge3)",
        {
          BLUE: image.select("B2"),    
          REDedge3: image.select("B7")    
        });
// 30 SR-NIRnarrowBlue (Simple ratio NIR narrow and Blue)
 var SRNIRnarrowBlue = image.expression(
        "(NIRnarrow / BLUE)",
        {
          NIRnarrow: image.select("B8A"),    
          BLUE: image.select("B2")    
        });
// 31 SR-NIRnarrowGreen (Simple ratio NIR narrow and Green)
 var SRNIRnarrowGreen = image.expression(
        "(NIRnarrow / GREEN)",
        {
          NIRnarrow: image.select("B8A"),    
          GREEN: image.select("B3")    
        });
// 32 SR-NIRnarrowRed (Simple ratio NIR narrow and Red)
 var SRNIRnarrowRed = image.expression(
        "(NIRnarrow / RED)",
        {
          NIRnarrow: image.select("B8A"),    
          RED: image.select("B4")    
        });
// 33 SR-NIRnarrowRededge1 (Simple NIR and Red-edge 1 Ratio)
 var SRNIRnarrowRededge1 = image.expression(
        "(NIRnarrow / REDedge1)",
        {
          NIRnarrow: image.select("B8A"),    
          REDedge1: image.select("B5")    
        });
// 34 SR-NIRnarrowRededge2 (Simple NIR and Red-edge 2 Ratio)
 var SRNIRnarrowRededge2 = image.expression(
        "(NIRnarrow / REDedge2)",
        {
          NIRnarrow: image.select("B8A"),    
          REDedge2: image.select("B6")    
        });
// 35 SR-NIRnarrowRededge3 (Simple NIR and Red-edge 3 Ratio)
 var SRNIRnarrowRededge3 = image.expression(
        "(NIRnarrow / REDedge3)",
        {
          NIRnarrow: image.select("B8A"),    
          REDedge3: image.select("B7")    
        });
// 36 STI (Soil Tillage Index)
 var STI = image.expression(
        "(SWIR1 / SWIR2)",
        {
          SWIR1: image.select("B11"),    
          SWIR2: image.select("B12")
        });
// 37 WBI (Water Body Index)
 var WBI = image.expression(
        "(BLUE - RED) / (BLUE + RED)",
        {
          BLUE: image.select("B2"),    
          RED: image.select("B4")
        });
// 38 NDMI (Normalized Difference Moisture Index)
 var NDMI = image.expression(
        "(NIR-SWIR)/(NIR+SWIR)",
        {
          NIR: image.select("B8"),    
          SWIR: image.select("B11"),    
          });
// 39 NDBR (Normalized Difference Burning Ratio) (also referred to as NBR)
 var NDBR = image.expression(
        "(NIR-MIR)/(NIR+MIR)",
        {
          NIR: image.select("B8"),    
          MIR: image.select("B12"),    
          });

// // adding all the indices into the image as new bands
var image = image.addBands(NDVI); 
var image = image.addBands(Chlogreen);
var image = image.addBands(LAnthoC);
var image = image.addBands(LCaroC);
var image = image.addBands(LChloC);

var image = image.addBands(BAI);
var image = image.addBands(GI);
var image = image.addBands(gNDVI);
var image = image.addBands(MSI);

var image = image.addBands(NDrededgeSWIR);
var image = image.addBands(NDTI);
var image = image.addBands(NDVIre);
var image = image.addBands(NDVI1);
var image = image.addBands(NDVI2);

var image = image.addBands(NHI);
var image = image.addBands(EVI);
var image = image.addBands(EVI2);
var image = image.addBands(EVI2_2);
var image = image.addBands(MSAVI);

var image = image.addBands(NormG);
var image = image.addBands(NormNIR);
var image = image.addBands(NormR);
var image = image.addBands(RededgePeakArea);
var image = image.addBands(RedSWIR1);

var image = image.addBands(RTVIcore);
var image = image.addBands(SAVI);
var image = image.addBands(SRBlueRededge1);
var image = image.addBands(SRBlueRededge2);
var image = image.addBands(SRBlueRededge3);

var image = image.addBands(SRNIRnarrowBlue);
var image = image.addBands(SRNIRnarrowGreen);
var image = image.addBands(SRNIRnarrowRed);
var image = image.addBands(SRNIRnarrowRededge1);
var image = image.addBands(SRNIRnarrowRededge2);

var image = image.addBands(SRNIRnarrowRededge3);
var image = image.addBands(STI);
var image = image.addBands(WBI);
var image = image.addBands(NDMI);
var image = image.addBands(NDBR);

//print (image, "allindices added");

// Training data
var bands = ['B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B11', 'B12',
               'B8_1', 'B8A_1',
               'B7_1', 
               //'B7_2',
               'B7_3', "B2_1", "B3_1", "B8_2", "B11_1", 
                "B6_1", "B11_2", "B8_3", "B8_4", "B3_2", "B11_3", "constant", "constant_1", "constant_2", "constant_3",
                "B3_3", "B8_5", "B4_1", "B4_2", "B4_3", "constant_4", "B8A_2", "B2_2", "B2_3", "B2_4", 
                "B8A_3", "B8A_4", "B8A_5", "B8A_6", "B8A_7", "B8A_8", "B11_4", "B2_5", "B8_6", "B8_7"];

//print('Training Feature Collection:', Train_FC);



var palette = [
  '#FF0000',  // Pine (Bright Red)
  '#FF7F00',  // Gum (Bright Orange)
  '#FF69B4',  // Wattle (Bright Pink)
  '#800080',  // Hakea (Purple)
  '#FFEBBE',  // Other IAP (Saharah Sand)
  '#006400',  // Afromontane Forest (Dark Green)
  '#6D974E',  // LD Fynbos (Mid Green)
  '#4C7300',  // HD Fynbos (Olive Green)
  '#898944',  // Renosterveld (Grayish Olive)
  '#E9FFBE',  // Succulent Karoo (Light Green)
  '#73DFFF',  // Wetland (Sky Blue)
  '#0000FF',  // Water (Blue)
  '#875B39',  // Bare Ground (Brown)
  '#FFFFFF',  // Urban (White)
  '#E1E1E1',  // Rock (Light Gray)
  '#4CE600',  // Irrigated Agri (Lime Green)
  '#C7D79E',  // Dryland Agri (Pale Olive)
  '#000000',  // Shade (Dark Gray)
  '#FFFF00'   // Poplar (Bright Yellow)
];



// Define visualization parameters for classified images
var classified_vis_params = {
  min: 1,
  max: 19,
  palette: palette
};


// Select bands for classification and classify the image
var classified_image = image.clip(AOI).select(bands).classify(classifier);


// Add the classified image to the map
Map.addLayer(classified_image, classified_vis_params, 'classification_2017');

///////////////////////////////////////////////////////////
/////                   Export                        /////
//////////////////////////////////////////////////////////
var wktAEA = 'PROJCS["AEA_RSA_WGS84",' +
    'GEOGCS["GCS_WGS_1984",' +
        'DATUM["D_WGS_1984",' +
            'SPHEROID["WGS_1984",6378137.0,298.257223563]],' +
        'PRIMEM["Greenwich",0.0],' +
        'UNIT["Degree",0.0174532925199433]],' +
    'PROJECTION["Albers"],' +
    'PARAMETER["False_Easting",0.0],' +
    'PARAMETER["False_Northing",0.0],' +
    'PARAMETER["Central_Meridian",25.0],' +
    'PARAMETER["Standard_Parallel_1",-24.0],' +
    'PARAMETER["Standard_Parallel_2",-33.0],' +
    'PARAMETER["Latitude_Of_Origin",0.0],' +
    'UNIT["Meter",1.0]]';

Export.image.toDrive({
  image: classified_image,
  description: 'CFR_LULC_Classification_2017',
  scale: 10,
  region: AOI,
  fileFormat: 'GeoTIFF',
  crs: wktAEA,
  maxPixels: 1e10  // Increase this to handle larger exports
});


///////////////////////////////////////////////////////////
/////             Generate Validation Data             /////
//////////////////////////////////////////////////////////
// Train the classifier with 30% of our data.

// Sample the image bands 
var validation_subset = image.select(bands).sampleRegions({
  collection: validation, 
  properties: ['code','LULC'], 
  geometries: true,
  scale: 10
});

///////////////////////////////////////////////////////////
/////     Accuracy Assessment Export                 /////
//////////////////////////////////////////////////////////

// // exporting data for accuracy assessment in R
// adding predicted LULC to training and validation datasets

// // // validation 30% not used in training
var validation_30 = classified_image.select('classification').sampleRegions({        ///
  collection: validation_subset, 
  properties: ['code'],
  //tileScale: 4,
  //geometries: false, //true,
  scale: 10
});
// // print(validation_30, 'validation_30');

Export.table.toDrive({
  collection: validation_30,
  description:'CFR_classification_1_validation_30',
  fileFormat: 'CSV'
});

// // training 70% used in training
var training_70 = classified_image.select('classification').sampleRegions({      //.select('classification')
  collection: combined_training_subset, 
  properties: ['code'],
  //tileScale: 4,
  //geometries: false,//true,
  scale: 10
});
// // print(training_70, "training_70");

Export.table.toDrive({
  collection: training_70,
  description:'CFR_classification_1_training_70',
  fileFormat: 'CSV'
});

 ////////////////////////////////////////////////////////////////////////////////////////////////////
// setting for APP

// add legend and set position of panel
var legend = ui.Panel({
  style: {
    position: 'bottom-right',
    padding: '8px 15px'
  }
});
 // Create legend title
var legendTitle = ui.Label({
  value: 'Legend',
  style: {
    fontWeight: 'bold',
    fontSize: '18px',
    margin: '0 0 4px 0',
    padding: '0'
    }
});
 // Add the title to the panel
legend.add(legendTitle);
 // Creates and styles 1 row of the legend.
var makeRow = function(color, name) {
       // Create the label that is actually the colored box.
      var colorBox = ui.Label({
        style: {
          backgroundColor: color,
          // Use padding to give the box height and width.
          padding: '8px',
          margin: '0 0 4px 0'
        }
      });
       // Create the label filled with the description text.
      var description = ui.Label({
        value: name,
        style: {margin: '0 0 4px 6px'}
      });
       // return the panel
      return ui.Panel({
        widgets: [colorBox, description],
        layout: ui.Panel.Layout.Flow('horizontal')
      });
};
 // name of the legend
var names = ['Pine','Gum','Wattle','Hakea','Other IAP','Afromontane Forest','LD Fynbos','HD Fynbos','Renosterveld','Succulent Karoo','Wetland','Water','Bare Ground','Urban','Rock','Irrigated Agriculture','Dryland Agriculture','Shade','Poplar'];
 // Add color and and names
for (var i = 0; i < 19; i++) {
  legend.add(makeRow(palette[i], names[i]));
  }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
 
// 8 // Specify split panels for the S2 image and classification ///////////////////////////////////////////////////////
// Display the original image and classified map in a split panel
var leftMap = ui.Map();
var rightMap = ui.Map();
// // Center the maps on the ROI
leftMap.centerObject(AOI, 7);
rightMap.centerObject(AOI, 7);
// // Add layers to the left map (S2 image)
leftMap.addLayer(image, {bands: ['B4', 'B3', 'B2'], max: 0.3}, 'S2 Image');
// // Add layers to the right map (classified map)
rightMap.addLayer(classified_image, {min: 1, max: 19, palette: palette}, 'Land Cover Classification_2017');
rightMap.add(legend);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
