
years1 = seq(2010, 2050, 10)
years2 = seq(2060, 2100, 10)
ssp = paste0('SSP', seq(1,5), '_', '1km_NetCDF')
typelist = c("rural", "total", "urban")

ssp2 = paste0('ssp', seq(1,5))
for (s in ssp){
  for (ty in typelist){
    setwd(paste0("/Users/james/Documents/Delaware/urban_climate/datasets/1km_urban_population_projections/",
                 "UrbanPopulationProjections_SSPs1-5_2010-2100_v1_NETCDF_1km/", s))
    system(paste0("/usr/bin/zip -r ",paste0(substr(s,10,16),'_',substr(s, 1,5),ty, '_', years2[[1]], '-', years2[[5]] ,'.zip '), 
                  '*',ssp2[which(ssp == s)],'_', ty, "_", years2[[1]], "* ",
                  '*',ssp2[which(ssp == s)],'_', ty, "_", years2[[2]], "* ",
                  '*',ssp2[which(ssp == s)],'_', ty, "_", years2[[3]], "* ",
                  '*',ssp2[which(ssp == s)],'_', ty, "_", years2[[4]], "* ",
                  '*',ssp2[which(ssp == s)],'_', ty, "_", years2[[5]], "* -x '*.DS_Store'"))
    system(paste0("/usr/bin/zip -r ",paste0(substr(s,10,16),'_',substr(s, 1,5),ty, '_', years2[[1]], '-', years2[[5]],'.zip.zip '),
                  paste0(substr(s,10,16),'_',substr(s, 1,5),ty, '_', years2[[1]], '-', years2[[5]] ,'.zip',
                         " -x '*.DS_Store'")))
  }
}


for (s in ssp){
  for (ty in typelist){
    setwd(paste0("/Users/james/Documents/Delaware/urban_climate/datasets/1km_urban_population_projections/",
                 "UrbanPopulationProjections_SSPs1-5_2010-2100_v1_NETCDF_1km/", s))
    system(paste0("/usr/bin/zip -r ",paste0(substr(s,10,16),'_',substr(s, 1,5),ty, '_', years1[[1]], '-', years1[[5]] ,'.zip '), 
                  '*',ssp2[which(ssp == s)],'_', ty, "_", years1[[1]], "* ",
                  '*',ssp2[which(ssp == s)],'_', ty, "_", years1[[2]], "* ",
                  '*',ssp2[which(ssp == s)],'_', ty, "_", years1[[3]], "* ",
                  '*',ssp2[which(ssp == s)],'_', ty, "_", years1[[4]], "* ",
                  '*',ssp2[which(ssp == s)],'_', ty, "_", years1[[5]], "* -x '*.DS_Store'"))
    system(paste0("/usr/bin/zip -r ",paste0(substr(s,10,16),'_',substr(s, 1,5),ty, '_', years1[[1]], '-', years1[[5]],'.zip.zip '),
                  paste0(substr(s,10,16),'_',substr(s, 1,5),ty, '_', years1[[1]], '-', years1[[5]] ,'.zip',
                         " -x '*.DS_Store'")))
  }
}


zip -r GeoTIFF_Base_year_urban.zip *urban* -x "*.DS_Store"

ssp1_rural_2010