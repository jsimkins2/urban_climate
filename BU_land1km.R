# BU_land 1km creation
# 
# James Simkins
############################################################################################
# as of right now, I'm upscaling the globe p1 file using this string
# gdalwarp -t_srs '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs' 
#          -tr 1000 1000 -r average GHS_BUILT_LDS2000_GLOBE_R2016A_3857_38_v1_0_p1.tif upscaled_globep1.tif
# from this website  
#https://www.geos.ed.ac.uk/~smudd/TopoTutorials/html/tutorial_raster_conversion.html
############################################################################################



############################################################################################
# Begin Script
############################################################################################

# load required libraries
library(raster)
library(rgdal)

# read in the upscaled via averaging data & then reproject to longlat projection
gp1c = raster("/Users/james/Documents/Delaware/urban_climate/datasets/TestData_2000_GLOBE_38m/upscaled_globep1.tif")
newproj = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
gp1.reproj = projectRaster(gp1,crs = newproj)

# perform the same thing for the second half
gp2 = raster("/Users/james/Documents/Delaware/urban_climate/datasets/TestData_2000_GLOBE_38m/upscaled_globep2.tif")
gp2.reproj = projectRaster(gp2,crs = newproj)
res(gp2.reproj) = res(gp1.reproj)
# merge both halves
gp = merge(gp1,gp2)
gp.reproj = projectRaster(gp,crs = newproj)
# load the desired geotiff resolution & extents and resample the BU data to this resolution/projection
landmask1km = raster("/Users/james/Documents/Delaware/urban_climate/datasets/1km_urban_population_projections/UrbanPopulationProjections_SSPs1-5_2010-2100_v1_GEOTIFF_1km/BaseYear_1km_GeoTIFF/baseYr_rural_2000.tif")
gp.resampled = resample(gp, landmask1km, method = 'ngb') 
writeRaster(gp.resampled, filename = "/Users/james/Documents/Delaware/urban_climate/datasets/TestData_2000_GLOBE_38m/BU_1km.tif", format = "GTiff")



gp1 = projectRaster(landmask1km,crs = '+proj=merc +lon_0=0 +lat_ts=0 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +units=m +no_defs')

p1 = raster("/Users/james/Documents/Delaware/urban_climate/datasets/TestData_2000_GLOBE_38m/GHS_BUILT_LDS2000_GLOBE_R2016A_3857_38_v1_0_p1.tif")
p2 = raster("/Users/james/Documents/Delaware/urban_climate/datasets/TestData_2000_GLOBE_38m/GHS_BUILT_LDS2000_GLOBE_R2016A_3857_38_v1_0_p2.tif")





rep = raster("/Users/james/Documents/Delaware/urban_climate/datasets/TestData_2000_GLOBE_38m/landmask.tif")













#-scale 0 1


#gdalwarp -t_srs '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs' -tr 928 956 -r average GHS_BUILT_LDS2000_GLOBE_R2016A_3857_38_v1_0_p1.tif jing_p1.tif

#gdalwarp -t_srs '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs' -tr 928 956 -r average GHS_BUILT_LDS2000_GLOBE_R2016A_3857_38_v1_0_p2.tif jing_p2.tif


#gdaltranslate -scale 0 1 
