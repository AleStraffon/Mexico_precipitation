# Mexico Precipitation: Data and Code

This repository contains the processed precipitation data and MATLAB/Python
code used for the analyses and figures presented in the manuscript.

## Repository structure

``` text
Mexico_precipitation/
├── Code/
├── Data/
└── Shape_HR/
```

### Data

The `Data` folder contains the processed information for the three
precipitation datasets used in this study:

-   **SMN**: Mexican National Meteorological Service gridded
    precipitation dataset
-   **CHIRPS3**: Climate Hazards Center InfraRed Precipitation with
    Station data
-   **ERA5**: ERA5 reanalysis precipitation data

For each dataset, the data are organized by the **37 Hydrological
Regions (HRs) of Mexico**.

Each dataset contains the spatially averaged precipitation time series
for each Hydrological Region for the period **1981--2024**. The data are
organized as follows:

-   **Rows 1--24:** mean precipitation for each fortnight of the year.
-   **Row 25:** annual accumulated precipitation.
-   **Columns 1--44:** the 44 years from **1981 to 2024**.
-   **Column 45:** linear trend of each time series.
-   **Column 46:** intercept (ordinate at the origin) of the
    corresponding linear regression.

The spatial averages were calculated using the grid points located
within each of the 37 Hydrological Regions.

### Shape_HR

The `Shape_HR` folder contains the shapefile defining the 37
Hydrological Regions used to calculate the spatial averages.

The Hydrological Region shapefile was obtained from the CONABIO
Geoportal:

http://geoportal.conabio.gob.mx/metadatos/doc/html/rha250kgw.html

The shapefile was used to identify the grid points falling within each
Hydrological Region and to calculate the corresponding spatially
averaged precipitation series.

### Code

The `Code` folder contains the MATLAB scripts used to process and
analyze the precipitation datasets and to generate the figures presented
in the study.

The scripts include analyses of:

-   precipitation trends;
-   comparison of the CHIRPS3 and ERA5 datasets with the SMN dataset;
-   ENSO--precipitation relationships;
-   statistical significance analyses; and
-   generation of the figures included in the manuscript.

The code is provided to document the processing and analysis procedures
used in the study and to facilitate reproducibility.

## Data sources

The original precipitation datasets used in this study are described in
the manuscript's **Open Research** section.

-   **CHIRPS3:** The Climate Hazards Center Data Repository (Climate
    Hazards Center, 2025). DOI: https://doi.org/10.15780/G2JQ0P
-   **ERA5:** Copernicus Climate Data Store (Copernicus Climate Change
    Service, 2019). DOI: https://doi.org/10.24381/cds.f17050d7
-   **SMN:** The gridded precipitation dataset used in this study is not
    publicly available. The underlying station observations are publicly
    available through the Mexican National Meteorological Service's
    *Información Estadística Climatológica* (Mexican National
    Meteorological Service, 2025):
    https://smn.conagua.gob.mx/es/climatologia/informacion-climatologica/informacion-estadistica-climatologica

The processed data provided in this repository correspond to the data
products used in the analyses described in the manuscript.

## Reproducibility

To reproduce the analyses and figures, use the MATLAB/Python scripts provided
in the `Code` folder together with the processed data in `Data` and the
Hydrological Region shapefile in `Shape_HR`.

## Contact

**Alejandra Straffon**  
Corresponding author / Data and code contact  
Email: alejandra.straffon@atmosfera.unam.mx
