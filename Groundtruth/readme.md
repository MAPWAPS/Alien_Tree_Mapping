# Accuracy per Ground Truth Polygon

This folder contains a Python script that calculates the classification accuracy per ground truth (GT) polygon using output data exported from ArcGIS Pro's Summarize Statistics tool.

### For this workflow you must have:

1. A RasterToPoint_SpatialJoin layer (classification results joined to GT polygons).

2. A summary statistics table generated from ArcGIS Pro.

These inputs should be exported to Excel before running the script.

### Workflow

- Reads an Excel sheet containing the number of predicted LULC points/pixels inside each GT polygon.

- Calculates:

  1. Total number of pixels per GT polygon.

  2. Percentage of correctly and incorrectly classified pixels.

  3. Accuracy (%) for each GT polygon.

- Joins GT LULC class names and IDs with the calculated accuracy.

- Exports the final results to a new Excel file.
