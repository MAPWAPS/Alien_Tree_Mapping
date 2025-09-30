Accuracy per Ground Truth Polygon

This repository contains a Python script that calculates the classification accuracy per ground truth (GT) polygon using output data exported from ArcGIS Pro's Summarize Statistics tool.

The workflow assumes you have:

A RasterToPoint_SpatialJoin layer (classification results joined to GT polygons).

A summary statistics table generated from ArcGIS Pro.

These inputs should be exported to Excel before running the script.

Features

Reads an Excel sheet containing the number of predicted LULC points/pixels inside each GT polygon.

Calculates:

Total number of pixels per GT polygon.

Percentage of correctly and incorrectly classified pixels.

Accuracy (%) for each GT polygon.

Joins GT LULC class names and IDs with the calculated accuracy.

Exports the final results to a new Excel file.