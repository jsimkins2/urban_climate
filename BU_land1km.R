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
gp1 = raster("/Users/james/Documents/Delaware/urban_climate/datasets/TestData_2000_GLOBE_38m/upscaled_globep1.tif")
newproj = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
gp1.reproj = projectRaster(gp1,crs = newproj)

# perform the same thing for the second half
gp2 = raster("/Users/james/Documents/Delaware/urban_climate/datasets/TestData_2000_GLOBE_38m/upscaled_globep2.tif")
gp2.reproj = projectRaster(gp2,crs = newproj)

# merge both halves
gp = merge(gp1.reproj,gp2.reproj)
# load the desired geotiff resolution & extents and resample the BU data to this resolution/projection
landmask1km = raster("/Users/james/Documents/Delaware/urban_climate/datasets/1km_urban_population_projections/UrbanPopulationProjections_SSPs1-5_2010-2100_v1_GEOTIFF_1km/BaseYear_1km_GeoTIFF/baseYr_rural_2000.tif")
gp.resampled = resample(gp, landmask1km, method = 'ngb') 




















# load in 38m Built Up data we're going to use to create this file - note, trying to plot this broke it
globep1 = raster("/Users/james/Documents/Delaware/urban_climate/datasets/TestData_2000_GLOBE_38m/GHS_BUILT_LDS2000_GLOBE_R2016A_3857_38_v1_0_p1.tif")

# crop the top left 1/16th of this

gp1ext = extent(globep1)
x.16 = (1/16)*(xmin(gp1ext) - xmax(gp1ext))
y.16 = (1/16)*(ymax(gp1ext) - ymin(gp1ext))
new.ext = extent(c(xmin(gp1ext), xmin(gp1ext) - x.16, ymax(gp1ext) - y.16, ymax(gp1ext)))
tlcrn = crop(x = globep1, y = new.ext)

blcrn.agg = aggregate(tlcrn, fact=4, fun=sum)



r <- raster(nrow=45, ncol=90)
r[] <- 1:ncell(r)
e <- extent(-160, 10, 30, 60)
rc <- crop(r, e)	
rc2 <- crop(globep1, extent(globep1, 323584, 323584+40, 253952, 253952+40))
rc2.agg = aggregate(rc2, fact=4, fun=sum)
globep2 = raster("/Users/james/Documents/Delaware/urban_climate/datasets/TestData_2000_GLOBE_38m/GHS_BUILT_LDS2000_GLOBE_R2016A_3857_38_v1_0_p2.tif")

# 1km land mask
landmask1km = raster("/Users/james/Documents/Delaware/urban_climate/datasets/1km_urban_population_projections/UrbanPopulationProjections_SSPs1-5_2010-2100_v1_GEOTIFF_1km/BaseYear_1km_GeoTIFF/baseYr_rural_2000.tif")
landmask18dgr = raster("/Users/james/Documents/Delaware/urban_climate/datasets/1_8_degree_urban_extent_projections/UrbanExtentProjections_SSPs1-5_2010-2100_v1_GEOTIFF_1_8_dgr/AncillaryLayers_GeoTIFF/landavailmask.tif")

newproj = '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs '
landmask1km = projectRaster(landmask1km, crs = newproj)

# need to reproject landmask1km to globep1 projection because globep1 is too large for this
# once we reproject it should be better




