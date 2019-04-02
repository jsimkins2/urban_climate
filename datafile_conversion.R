# this r script is going to convert the arcgrid data to geotiff to netcdf to ascii
# first, use gdal translate to convert all of the arcgrid to geotiff
years = seq(2010, 2100, 10)
ssp = paste0('ssp', seq(1,5), '_')

dirnames = list()
for (y in years){
  for (s in ssp){
    dirnames = append(dirnames, paste0(s, y))
  }
}

for (d in seq_along(dirnames)){
  print(d)
  system(command = paste0("/Library/Frameworks/GDAL.framework/Programs/gdal_translate -of GTIFF /Users/james/Documents/Delaware/urban_climate/datasets/UrbanExtentProjections_SSPs1-5_2010-2100_v1_GRID_1_8_dgr/", 
                          dirnames[[d]], "/ ", "/Users/james/Documents/Delaware/urban_climate/datasets/UrbanExtentProjections_SSPs1-5_2010-2100_v1_GRID_1_8_dgr/",dirnames[[d]], "/", dirnames[[d]], ".tif"))
}
# finished processing the geotiffs

# now it's time to convert the geotiffs to netcdf and ascii format
library(raster)
for (d in seq_along(dirnames)){
  print(dirnames[[d]])
  temrast = raster(paste0("/Users/james/Documents/Delaware/urban_climate/datasets/UrbanExtentProjections_SSPs1-5_2010-2100_v1_GRID_1_8_dgr/",dirnames[[d]], "/", dirnames[[d]], ".tif"))
  
  nc_outfile = paste0("/Users/james/Documents/Delaware/urban_climate/datasets/UrbanExtentProjections_SSPs1-5_2010-2100_v1_GRID_1_8_dgr/",dirnames[[d]], "/", dirnames[[d]], ".nc")
  writeRaster(temrast, filename = nc_outfile,
              format="CDF", overwrite=TRUE,varname="Band1", longname="GDAL Band Number 1",
              xname="lon", yname="lat")
  
  ascii_outfile = paste0("/Users/james/Documents/Delaware/urban_climate/datasets/UrbanExtentProjections_SSPs1-5_2010-2100_v1_GRID_1_8_dgr/",dirnames[[d]], "/", dirnames[[d]], ".asc")
  writeRaster(temrast, filename = ascii_outfile,format="ascii", datatype="INT4S",overwrite=TRUE, prj=TRUE)
  
  # add to that netcdf file the crs definitions
  loc = nc_open(nc_outfile, write = TRUE)
  crs_ = ncvar_def(name = "crs", units = "", dim = list(),longname = "CRS definition")
  ncvar_add(nc=loc,v = crs_)
  nc_close(loc)
  loc = nc_open(nc_outfile, write = TRUE)
  ncatt_put(nc=loc,"crs",attname="GeoTransform", attval=c(extent(temrast)[1], extent(temrast)[2], extent(temrast)[3], extent(temrast)[4]))
  ncatt_put(nc=loc,"crs",attname="spatial_ref", attval="EPSG:4326")
  ncatt_put(nc=loc,"crs",attname="grid_mapping_name", attval="latitude_longitude")
  ncatt_put(nc=loc,"crs",attname="proj_string", attval=as.character(crs(temrast)))
  ncatt_put(nc=loc,"Band1",attname="grid_mapping", attval="crs")
  ncatt_put(nc=loc,"lat",attname="long_name", attval="latitude")
  ncatt_put(nc=loc,"lat",attname="standard_name", attval="latitude")
  ncatt_put(nc=loc,"lon",attname="long_name", attval="longitude")
  ncatt_put(nc=loc,"lon",attname="standard_name", attval="longitude")
  ncatt_put(nc=loc, 0, "Conventions", "CF=1.5")
  nc_close(loc)
}






# Now perform similar conversions for ancillary layers and base year
setwd("Documents/Delaware/urban_climate/datasets/")
dirnames = list("UrbanExtent_BaseYear_2000_v1_GRID_1_8_dgr/bu_frac_2000", "UrbanExtentProjections_AncillaryLayers_v1_GRID_1_8_dgr/land_area_km",
                "UrbanExtentProjections_AncillaryLayers_v1_GRID_1_8_dgr/landavailmask")

gtiffnames = list("bu_frac_2000", "land_area_km", "landavailmask")
for (d in seq_along(dirnames)){
  print(d)
  system(command = paste0("/Library/Frameworks/GDAL.framework/Programs/gdal_translate -of GTIFF /Users/james/Documents/Delaware/urban_climate/datasets/",
                          dirnames[[d]], "/ ", "/Users/james/Documents/Delaware/urban_climate/datasets/",dirnames[[d]], "/", gtiffnames[[d]], ".tif"))
}
# finished processing the geotiffs

# now it's time to convert the geotiffs to netcdf and ascii format
library(raster)
for (d in seq_along(dirnames)){
  print(dirnames[[d]])
  temrast = raster(paste0("/Users/james/Documents/Delaware/urban_climate/datasets/",dirnames[[d]], "/", gtiffnames[[d]], ".tif"))
  
  nc_outfile = paste0("/Users/james/Documents/Delaware/urban_climate/datasets/",dirnames[[d]], "/", gtiffnames[[d]], ".nc")
  writeRaster(temrast, filename = nc_outfile,
              format="CDF", overwrite=TRUE,varname="Band1", longname="GDAL Band Number 1",
              xname="lon", yname="lat")
  
  ascii_outfile = paste0("/Users/james/Documents/Delaware/urban_climate/datasets/",dirnames[[d]], "/", gtiffnames[[d]], ".asc")
  writeRaster(temrast, filename = ascii_outfile,format="ascii", datatype="INT4S",overwrite=TRUE, prj=TRUE)
  
  # add to that netcdf file the crs definitions
  loc = nc_open(nc_outfile, write = TRUE)
  crs_ = ncvar_def(name = "crs", units = "", dim = list(),longname = "CRS definition")
  ncvar_add(nc=loc,v = crs_)
  nc_close(loc)
  loc = nc_open(nc_outfile, write = TRUE)
  ncatt_put(nc=loc,"crs",attname="GeoTransform", attval=c(extent(temrast)[1], extent(temrast)[2], extent(temrast)[3], extent(temrast)[4]))
  ncatt_put(nc=loc,"crs",attname="spatial_ref", attval="EPSG:4326")
  ncatt_put(nc=loc,"crs",attname="grid_mapping_name", attval="latitude_longitude")
  ncatt_put(nc=loc,"crs",attname="proj_string", attval=as.character(crs(temrast)))
  ncatt_put(nc=loc,"Band1",attname="grid_mapping", attval="crs")
  ncatt_put(nc=loc,"lat",attname="long_name", attval="latitude")
  ncatt_put(nc=loc,"lat",attname="standard_name", attval="latitude")
  ncatt_put(nc=loc,"lon",attname="long_name", attval="longitude")
  ncatt_put(nc=loc,"lon",attname="standard_name", attval="longitude")
  ncatt_put(nc=loc, 0, "Conventions", "CF=1.5")
  nc_close(loc)
}
