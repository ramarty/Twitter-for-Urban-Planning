# Download GADM

setwd(file.path(data_gadm_dir, "gadm"))
ken_adm_1 <- getData('GADM', country='KEN', level=1)

