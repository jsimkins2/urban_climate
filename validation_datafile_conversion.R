# data conversion validation
# this r script is going to convert the arcgrid data to geotiff to netcdf to ascii

# load required libraries
library(raster)

# going to pull together a list of dirnames and randomly select ones to check
years = seq(2010, 2100, 10)
ssp = paste0('ssp', seq(1,5), '_')

dirnames = list()
for (y in years){
  for (s in ssp){
    dirnames = append(dirnames, paste0(s, y))
  }
}
rowLen = seq(1,1117)
colLen = seq(1,2880)
for (i in seq_len(50)){
  #randomly select a file, a row, and a column
  randSSP = sample(dirnames, 1)
  randRow = sample(rowLen, 1)
  randCol = sample(colLen, 1)
  
  # read in the data as raster
  temrast = raster(paste0("/Users/james/Documents/Delaware/urban_climate/datasets/1_8_degree_urban_extent_projections/UrbanExtentProjections_SSPs1-5_2010-2100_v1_GEOTIFF_1_8_dgr/SSP", substr(temfile[[1]], 4, 4), "_GeoTIFF/",temfile[[1]], ".tif"))
  tifVal = getValues(temrast, randRow)[randCol]
  ccrs = crs(temrast)
  cextent = extent(temrast)
  
  x = ncdf4::nc_open(paste0("/Users/james/Documents/Delaware/urban_climate/datasets/1_8_degree_urban_extent_projections/UrbanExtentProjections_SSPs1-5_2010-2100_v1_NETCDF_1_8_dgr/SSP", substr(temfile[[1]], 4, 4), "_NETCDF/",temfile[[1]], ".nc"))
  b1 = ncdf4::ncvar_get(x, "Band1")
  temrast = raster(b1)
  temrast = t(temrast)
  crs(temrast) = as.character(ccrs)
  extent(temrast) = cextent
  ncVal = getValues(temrast, randRow)[randCol]
  
  temrast = raster(paste0("/Users/james/Documents/Delaware/urban_climate/datasets/1_8_degree_urban_extent_projections/UrbanExtentProjections_SSPs1-5_2010-2100_v1_ASCII_1_8_dgr/SSP", substr(temfile[[1]], 4, 4), "_ASCII/",temfile[[1]], ".asc"))
  crs(temrast) = as.character(ccrs)
  extent(temrast) = cextent
  asciiVal = getValues(temrast, randRow)[randCol]
  
  # print a flag if the geotiff values and nc values aren't equal
  # note that the ascii files are all wrong here
  if (is.na(ncVal) == FALSE){
    if (ncVal != tifVal | ncVal != asciiVal){
      print(paste0("BAD DATA ", "ncVal=",ncVal, " tifVal=",tifVal, " asciiVal=", asciiVal," row", randRow, " col", randCol, " file",temfile[[1]]))
    } else {
      print(paste0("GOOD DATA ", ncVal, " ",tifVal))
    }
  }
}

