# data conversion validation
# this r script is going to convert the arcgrid data to geotiff to netcdf to ascii
# James Simkins
############################################################################################
# Begin Script
############################################################################################

# load required libraries
library(raster)
# put together a list of all directories
years = seq(2010, 2100, 10)
ssp = paste0('ssp', seq(1,5), '_')
dirnames = list()
for (y in years){
  for (s in ssp){
    dirnames = append(dirnames, paste0(s, y))
  }
}

# Begin Loop that opens each file and compares it against the various formats
for (i in seq_along(dirnames)){
  # separate into it's own character for ease of use
  SSP = dirnames[[i]]
  
  # read geotiff data in the data as raster and convert to matrix for checking
  temrast1 = raster(paste0("/Users/james/Downloads/UrbanExtentProjections_SSPs1-5_2010-2100_v1_GEOTIFF_1_8_dgr/SSP", substr(SSP[[1]], 4, 4), "_GeoTIFF/",SSP[[1]], ".tif"))
  ccrs = crs(temrast1)
  cextent = extent(temrast1)
  r1=as.matrix(temrast1)
  
  # read netcdf data in the data as raster, add in projection, and convert to matrix for checking
  x = ncdf4::nc_open(paste0("/Users/james/Downloads/UrbanExtentProjections_SSPs1-5_2010-2100_v1_NETCDF_1_8_dgr/SSP", substr(SSP[[1]], 4, 4), "_NETCDF/",SSP[[1]], ".nc"))
  b1 = ncdf4::ncvar_get(x, "Band1")
  temrast2 = raster(b1)
  temrast2 = t(temrast2)
  crs(temrast2) = as.character(ccrs)
  extent(temrast2) = cextent
  r2 = as.matrix(temrast2)
  
  # read ascii data in the data as rasterand convert to matrix for checking
  temrast3 = raster(paste0("/Users/james/Downloads/UrbanExtentProjections_SSPs1-5_2010-2100_v1_ASCII_1_8_dgr/SSP", substr(SSP[[1]], 4, 4), "_ASCII/",SSP[[1]], ".asc"))
  r3 = as.matrix(temrast3)

  # perform all equal check to make sure that the raw values are identical
  if (all.equal(r1,r2) == TRUE){
    if (all.equal(r1,r3) == TRUE){
      print("Equal Data!")
    } else {
      print("DATA NOT EQUAL!!!!!")
    }
  }
  
  # verify that the lat/lon extents and values are equal for each grid cell
  # this doesnt need the == TRUE like above, it is native to the as() function already
  if (as(temrast1, 'BasicRaster') == as(temrast2, 'BasicRaster')){
    if (as(temrast1, 'BasicRaster') == as(temrast3, 'BasicRaster')){
      print("Equal Lat/Lons")
    } else {
      print("DATA NOT EQUAL!!!!!")
    }
  }
}

# All data is equal to each other, both raw data and grids
# Now we just need to verify that the GIS to geotiff worked properly
