# data conversion validation
# this r script is going to convert the arcgrid data to geotiff to netcdf to ascii
# James Simkins

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

# Begin Loop
for (i in seq_len(150)){
  #randomly select a file, a row, and a column
  randSSP = sample(dirnames, 1)
  
  # read geotiff data in the data as raster and convert to matrix for checking
  temrast1 = raster(paste0("/Users/james/Documents/Delaware/urban_climate/datasets/1_8_degree_urban_extent_projections/UrbanExtentProjections_SSPs1-5_2010-2100_v1_GEOTIFF_1_8_dgr/SSP", substr(randSSP[[1]], 4, 4), "_GeoTIFF/",randSSP[[1]], ".tif"))
  ccrs = crs(temrast1)
  cextent = extent(temrast1)
  r1=as.matrix(temrast1)
  
  # read netcdf data in the data as raster, add in projection, and convert to matrix for checking
  x = ncdf4::nc_open(paste0("/Users/james/Documents/Delaware/urban_climate/datasets/1_8_degree_urban_extent_projections/UrbanExtentProjections_SSPs1-5_2010-2100_v1_NETCDF_1_8_dgr/SSP", substr(randSSP[[1]], 4, 4), "_NETCDF/",randSSP[[1]], ".nc"))
  b1 = ncdf4::ncvar_get(x, "Band1")
  temrast2 = raster(b1)
  temrast2 = t(temrast2)
  crs(temrast2) = as.character(ccrs)
  extent(temrast2) = cextent
  r2 = as.matrix(temrast2)
  
  # read ascii data in the data as rasterand convert to matrix for checking
  temrast3 = raster(paste0("/Users/james/Documents/Delaware/urban_climate/datasets/1_8_degree_urban_extent_projections/UrbanExtentProjections_SSPs1-5_2010-2100_v1_ASCII_1_8_dgr/SSP", substr(randSSP[[1]], 4, 4), "_ASCII/",randSSP[[1]], ".asc"))
  r3 = as.matrix(temrast3)

  # perform all equal check to make sure that matrices are identical
  if (all.equal(r1,r2) == TRUE){
    if (all.equal(r1,r3) == TRUE){
      print("All Equal!")
    } else {
      print("OH NO THEY AREN'T EQUAL")
    }
  }
}

