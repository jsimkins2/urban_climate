
# This script will downscale 1/8th degree data to 1km
import os
import multiprocessing as mp
import itertools
from osgeo import osr, gdal
import numpy as np
from scipy import spatial
##### Variable Definition
# spatialWeight = 1km GHS dataset that is the spatial weight for this downscaling procedure. Year 2000
# landArea = how much land there is per 1/8th degree cell considering latitude and non-land entities
# landMask = how much a grid cell can possibly be developed - this is our primary boundary control (consider indian reservations for example)
# ds2dwnsc = dataset 2 downscale - urban extent projections 

# Let's time it
from datetime import datetime
startTime = datetime.now()
##### Define Useful Functions
def x2lon(x, y):
    xp = a * x + b * y + xoff
    return(xp)

def y2lat(x, y):
    yp = d * x + e * y + yoff
    return(yp)

def find_nearest(array, value):
    array = np.asarray(array)
    idx = (np.abs(array - value)).argmin()
    return idx

''' Use this for each ssp - run 5 cores
velocity_cartopy_dark.py
with mp.Pool(processes=4) as pool:
pool.map(plot_velocity_gif, dataset)
'''

# Read in our new 1km grid 
file = "/Users/james/Documents/Delaware/urban_climate/datasets/TestData_2000_GLOBE_38m/GHS_1km_agg.tif"
sWds = gdal.Open(file)
sWrows = sWds.RasterXSize
sWcolms = sWds.RasterYSize
xoff, a, b, yoff, d, e = sWds.GetGeoTransform()

ghsLon=[]
ghsLat=[]
for row in range(0,sWrows):
    col=0
    ghsLon.append(x2lon(row,col))

for col in range(0,sWcolms):
    row=0
    ghsLat.append(y2lat(row,col))

band = sWds.GetRasterBand(1)
spatialWeight = band.ReadAsArray()

# Read in our land Area 
file = "/Users/james/Documents/Delaware/urban_climate/datasets/land_area_km1.tif"
ds = gdal.Open(file)
band = ds.GetRasterBand(1)
kmlandArea = band.ReadAsArray()

file = "/Users/james/Documents/Delaware/urban_climate/datasets/1_8_degree_urban_extent_projections/UrbanExtentProjections_SSPs1-5_2010-2100_v1_GEOTIFF_1_8_dgr/AncillaryLayers_GeoTIFF/land_area_km.tif"
ds = gdal.Open(file)
band = ds.GetRasterBand(1)
landArea = band.ReadAsArray()

# Read in our Land Avail Mask
file = "/Users/james/Documents/Delaware/urban_climate/datasets/1_8_degree_urban_extent_projections/UrbanExtentProjections_SSPs1-5_2010-2100_v1_GEOTIFF_1_8_dgr/AncillaryLayers_GeoTIFF/landavailmask.tif"
ds = gdal.Open(file)
band = ds.GetRasterBand(1)
landMask = band.ReadAsArray()


SSPloc = "/Users/james/Documents/Delaware/urban_climate/datasets/1_8_degree_urban_extent_projections/UrbanExtentProjections_SSPs1-5_2010-2100_v1_GEOTIFF_1_8_dgr/SSP5_GeoTIFF/"
SSPfile = "ssp5_2100.tif"
ds = gdal.Open(SSPloc + SSPfile)
rows = ds.RasterXSize
colms = ds.RasterYSize
xoff, a, b, yoff, d, e = ds.GetGeoTransform()

band = ds.GetRasterBand(1)
ds2dwnsc = band.ReadAsArray()

sspLon=[]
sspLat=[]
for row in range(0,rows):
    col=0
    sspLon.append(x2lon(row,col))

for col in range(0,colms):
    row=0
    sspLat.append(y2lat(row,col))

# Now that we have the lats & lons we need to find the nearest grid cell locations
# we need to normalize the lat/lons 
ghsLon = np.asarray(ghsLon) + 180
ghsLat = sorted((np.asarray(ghsLat)) + 90, reverse=True)

sspLon = np.asarray(sspLon) + 180
sspLat = sorted((np.asarray(sspLat)) + 90, reverse=True)

# initialize blank dataset
alloDF = np.zeros((spatialWeight.shape))
#lat=334
#lon=735
for lon in range(0,len(sspLon)-1):
    for lat in range(0,len(sspLat)-1):
        if lon==720:
            print('25% done')
        if lon==1440:
            print('50% done')
        if lon==1440+720:
            print('75% done')
        
        # define 1/8th degree variables
        sspVal = ds2dwnsc[lat,lon]
        maskVal = landMask[lat,lon]
        areaVal = landArea[lat,lon]
        
        # may need to make a lat3 which is the new bottomLat so we don't skip any cells
        # in other words, if it's not the first value then bottomLat on the next run == topLat
        if lat==0:
            bottomLat=0
            topLat=find_nearest(array=ghsLat,value=sspLat[1])
            #topLat=find_nearest(array=ghsLat,value=sspLat[lat])
        else:
            bottomLat=topLat
            topLat=find_nearest(array=ghsLat,value=sspLat[lat+1])
        
        lon1=lon*15
        lon2=lon1+15
        
        if sspVal != -3.4028235e+38:
            # grab 1km variables and place nanmask in there
            gridGHS = spatialWeight[bottomLat:topLat,lon1:lon2]
            kmAreaVal = kmlandArea[bottomLat:topLat,lon1:lon2]
            nanmask = kmAreaVal < 0
            gridGHS = np.ma.array(gridGHS, mask=nanmask)
            kmAreaVal = np.ma.array(kmAreaVal, mask=nanmask)
            kmAreaVal.fill_value=-3.4028235e+38
            gridGHS.fill_value=-3.4028235e+38
            # define weight variables
            amtToAloc = areaVal * sspVal
            rawWgt = areaVal * gridGHS
            sumWgt = np.sum(rawWgt)
            amtAvailLnd = kmAreaVal * maskVal # resampling to 1-km via 'disaggregation'
            
            if sumWgt >= amtToAloc:
                outputAmt = rawWgt * amtToAloc / sumWgt
            else:
                
                outputAmt = rawWgt * amtToAloc / sumWgt
                diff1km = outputAmt - amtAvailLnd
                overflowCells =  np.ma.masked_less_equal(diff1km, 0)
                amtOverflow = np.sum(overflowCells)
                if amtOverflow is np.ma.masked:
                    amtOverflow = 0
                                
                # need to find a way to mask individual cells here once they are full
                # and then recalculate the sumWgt
                while amtOverflow > 0:
                    notfullmask = (outputAmt < amtAvailLnd)
                    fullmask = (outputAmt >=amtAvailLnd)
                    outputAmt[fullmask] = amtAvailLnd[fullmask]
                    sumWgt = np.sum(rawWgt[notfullmask])
                    if sumWgt is np.ma.masked:
                        sumWgt = 0
                    if np.sum(sumWgt) > 0:
                        rawWgt[notfullmask] = rawWgt[notfullmask]
                        overflowReceiveAmt = rawWgt * amtOverflow / sumWgt
                        outputAmt[notfullmask] += overflowReceiveAmt[notfullmask]
                        diff1km = outputAmt - amtAvailLnd
                        overflowCells =  np.ma.masked_less_equal(diff1km, 0)
                        amtOverflow = np.sum(overflowCells)
                        if amtOverflow is np.ma.masked:
                            amtOverflow = 0
                    else: # sumWgt=0, you've run out of cells that were at least a little urban in 2000
                        rawWgt[:,:]= amtAvailLnd
                        sumWgt = np.sum(rawWgt)
                        overflowReceiveAmt = rawWgt * amtOverflow / sumWgt
                        outputAmt[notfullmask] += overflowReceiveAmt[notfullmask]
                        diff1km = outputAmt - amtAvailLnd
                        overflowCells =  np.ma.masked_less_equal(diff1km, 0)
                        amtOverflow = np.sum(overflowCells)
                        if amtOverflow is np.ma.masked:
                            amtOverflow = 0
                                

            outputAmt = outputAmt / kmAreaVal
            outputAmt[outputAmt < 0] = 0
            outputAmt.fill_value=-3.4028235e+38
            alloDF[bottomLat:topLat,lon1:lon2] = outputAmt
        else:
            alloDF[bottomLat:topLat,lon1:lon2] = -3.4028235e+38


[finalcols, finalrows] = spatialWeight.shape

outFileName = "/Users/james/Downloads/downscaled_" + SSPfile
driver = gdal.GetDriverByName("GTiff")
outdata = driver.Create(outFileName, finalrows, finalcols, 1, gdal.GDT_Float32)
outdata.SetGeoTransform(sWds.GetGeoTransform())##sets same geotransform as input
outdata.SetProjection(sWds.GetProjection())##sets same projection as input
outdata.GetRasterBand(1).WriteArray(alloDF) 
outdata.FlushCache() ##saves to disk!!
outdata = None
band=None
ds=None

print(datetime.now() - startTime)









