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





rep = raster("/Users/james/Documents/Delaware/urban_climate/datasets/TestData_2000_GLOBE_38m/output.tif")


# reproject Jing's grid to mercator and use that resolution for the aggregation in the next step
# gdalwarp -t_srs '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs' -s_srs '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0' baseYr_rural_2000.tif test.tif

# aggregate from 38m to 1km using average approach
# gdalwarp -t_srs '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs' -tr 1030.559469528862564 1030.585972279782709 -r average GHS_BUILT_LDS2000_GLOBE_R2016A_3857_38_v1_0_p1.tif agg_p1.tif
# gdalwarp -t_srs '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs' -tr 1030.559469528862564 1030.585972279782709 -r average GHS_BUILT_LDS2000_GLOBE_R2016A_3857_38_v1_0_p2.tif agg_p2.tif

# combine the aggregated geotiffs together
# gdal_merge.py agg_p1.tif agg_p2.tif combined.tif
# 

# reproject the combined tif and specify the exact resolution and extent
# note that if we didn't specify this would be the resolution/extent 0.008333165638817 0.008333165638817 / -180 -55.7721945 179.9927556 83.6416667
# we also must specify the extents here because Jing's grid extent is slightly larger than GHS grid extent
# gdalwarp combined.tif combined_reprojected_GHS.tif -of GTIFF -tr 0.008333333333300 0.008333333333300 -te -180 -55.7750000 180 83.6416667 -s_srs '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs' -t_srs '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'

# change the scale to 0 to 1 - 32 bit floats
# gdal_translate -of GTIFF PROFILE=GeoTIFF -co COMPRESS=LZW -ot Float32 -scale 1 101 0 1 combined_reprojected_GHS.tif GHS_1km_agg.tif 










# attempting to place no data values to -3.40282306073709653e+38
# gdal_merge.py agg_p1.tif agg_p2.tif combined.tif
# gdalwarp combined.tif combined_reprojected_GHS.tif -of GTIFF -tr 0.008333333333300 0.008333333333300 -te -180 -55.7750000 180 83.6416667 -s_srs '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs' -t_srs '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'
# gdal_calc.py --type Float32 -A combined_reprojected_GHS.tif --outfile=resultcalc.tif --calc="A*(A>0)" --NoDataValue=0
# gdal_translate resultcalc.tif result.tif -a_nodata -3.40282306073709653e+38 -ot Float32 -f GTIFF
# gdal_translate -of GTIFF -co COMPRESS=LZW -ot Float32 -scale 1 101 0 1 result.tif GHS_1km_agg.tif

# gdal_translate -of GTIFF -co COMPRESS=LZW -ot Float32 -scale 1 101 0 1 -a_nodata "value [-3.40282306073709653e+38]" combined_reprojected_GHS.tif GHS_1km_agg.tif 




# gdalbuildvrt -srcnodata -0.010 myVrt.vrt GHS_1km_agg.tif 
# gdal_translate -of GTIFF -co COMPRESS=LZW -ot Float32 -a_nodata -3.40282306073709653e+38 myVrt.vrt output.tif


# this is the latest version that I need to check. It may work
gdalwarp combined.tif rep_test.tif -of GTIFF -tr 0.008333333333300 0.008333333333300 -te -180 -55.7750000 180 83.6416667 -s_srs '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs' -t_srs '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'
gdal_calc.py -A rep_test.tif --outfile=resultcalc.tif --calc="A*(A>0)" --NoDataValue=0
gdalbuildvrt -srcnodata 0 myVrt.vrt resultcalc.tif 
gdal_translate -of GTIFF -co COMPRESS=LZW -ot Float32 -scale 1 101 0 1 -a_nodata -3.40282306073709653e+38 myVrt.vrt output.tif


