# script to reformat size composition data as SS model input for the crab and lobster observer data - Northumberland IFCA 

# check if required packages are installed
required <- c("readr", "dplyr", "lubridate", "tidyr", "RColorBrewer", "rgdal", "sp", 
              "rnaturalearth", "ggplot2", "ggridges")
installed <- rownames(installed.packages())
(not_installed <- required[!required %in% installed])
install.packages(not_installed, dependencies=TRUE)

# run input data processing script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source( file = "1b_observer_dataprocessing_nifca.R" )

# read in data
observer_data_fleet <- readr::read_csv("processed_data/nifca/observer_data_fleet_nifca_clean.csv") |> 
  dplyr::glimpse()
observer_data_offshore <- readr::read_csv("processed_data/nifca/observer_data_offshore_nifca_clean.csv") |> 
  dplyr::glimpse()
observer_data_fleet <- readr::read_csv("processed_data/nifca/observer_data_fleet_nifca_clean_env.csv") |>
  dplyr::mutate(date = as.Date(date, format = "%d/%m/%Y")) |>
  dplyr::glimpse() 
observer_data_fleet$ices.rect <- mapplots::ices.rect2(observer_data_fleet$start_lon, observer_data_fleet$start_lat)

observer_data_offshore <- readr::read_csv("processed_data/nifca/observer_data_offshore_nifca_clean_env.csv") |> 
  dplyr::mutate(date = as.Date(date, format = "%d/%m/%Y")) |> # format as date 
  dplyr::mutate(temperature = Temperature,
                temperature_interpolation_dist = Temp_dist,
                Distance_to_shore = distance_to_shore,
                Depth = depth,
                Depth_interpolation_distance = depth_interpolation_distance,
                Distance_to_shore = distance_to_shore) |>
  dplyr::glimpse()
observer_data_offshore$ices.rect <- mapplots::ices.rect2(observer_data_offshore$start_lon, observer_data_offshore$start_lat)

# subset by species
observer_data_fleet_lobster <- observer_data_fleet |> 
  dplyr::filter(species=="Lobster") |> 
  dplyr::glimpse()
observer_data_fleet_crab <- observer_data_fleet |> 
  dplyr::filter(species=="Crab") |> 
  dplyr::glimpse()
observer_data_offshore_lobster <- observer_data_offshore |> 
  dplyr::filter(species=="Lobster") |> 
  dplyr::glimpse()
observer_data_offshore_crab <- observer_data_offshore |> 
  dplyr::filter(species=="Crab") |> 
  dplyr::glimpse()

# read in cpue data
observer_cpue_fleet_lobster <- readr::read_csv("processed_data/nifca/observer_data_fleet_lobster_nominal.cpue_potset.csv", 
                                         col_types = readr::cols(lat = readr::col_double())) |> 
  dplyr::mutate(ices.rect = mapplots::ices.rect2(lon, lat)) |>
  dplyr::glimpse()
observer_cpue_fleet_crab <- readr::read_csv("processed_data/nifca/observer_data_fleet_crab_nominal.cpue_potset.csv", 
                                      col_types = readr::cols(lat = readr::col_double())) |> 
  dplyr::mutate(ices.rect = mapplots::ices.rect2(lon, lat)) |>
  dplyr::glimpse()
observer_cpue_offshore_lobster <- readr::read_csv("processed_data/nifca/observer_data_offshore_lobster_nominal.cpue_potset.csv", 
                                         col_types = readr::cols(lat = readr::col_double())) |> 
  dplyr::mutate(ices.rect = mapplots::ices.rect2(lon, lat)) |>
  dplyr::glimpse()
observer_cpue_offshore_crab <- readr::read_csv("processed_data/nifca/observer_data_offshore_crab_nominal.cpue_potset.csv", 
                                      col_types = readr::cols(lat = readr::col_double())) |> 
  dplyr::mutate(ices.rect = mapplots::ices.rect2(lon, lat)) |>
  dplyr::glimpse()

# merge datasets
observer_cpue_fleet_lobster <- observer_cpue_fleet_lobster |> 
  dplyr::group_by(year, month, ices.rect) |>
  dplyr::mutate(nominal.cpue_potset = sum(nominal.cpue_potset, na.rm = TRUE)) 
observer_data_fleet_lobster <- observer_data_fleet_lobster |> 
  tidyr::unite(month.yr.rect, c(year, month, ices.rect), sep = "-", remove = FALSE) |> 
  dplyr::left_join(observer_cpue_fleet_lobster) |>
  dplyr::select(month.yr, qrt.yr, month.yr.rect, year, month, survey_type, port, vesselID, species, 
                fleet_num, carapace_width, sex, abdomen_wdth, mass_g, nominal.cpue_potset)           
observer_cpue_offshore_lobster <- observer_cpue_offshore_lobster |> 
  dplyr::group_by(year, month, ices.rect) |>
  dplyr::mutate(nominal.cpue_potset = sum(nominal.cpue_potset, na.rm = TRUE)) 
observer_data_offshore_lobster <- observer_data_offshore_lobster |> 
  tidyr::unite(month.yr.rect, c(year, month, ices.rect), sep = "-", remove = FALSE) |> 
  dplyr::left_join(observer_cpue_offshore_lobster) |>
  dplyr::select(month.yr, qrt.yr, month.yr.rect, year, month, survey_type, port, vesselID, species, 
                fleet_num, carapace_width, sex, abdomen_wdth, mass_g, nominal.cpue_potset)  
observer_data_lobster <- observer_data_fleet_lobster |>
  dplyr::bind_rows(observer_data_offshore_lobster)

observer_cpue_fleet_crab <- observer_cpue_fleet_crab |> 
  dplyr::group_by(year, month, ices.rect) |>
  dplyr::mutate(nominal.cpue_potset = sum(nominal.cpue_potset, na.rm = TRUE)) 
observer_data_fleet_crab <- observer_data_fleet_crab |> 
  tidyr::unite(month.yr.rect, c(year, month, ices.rect), sep = "-", remove = FALSE) |> 
  dplyr::left_join(observer_cpue_fleet_crab) |>
  dplyr::select(month.yr, qrt.yr, month.yr.rect, year, month, survey_type, port, vesselID, species, 
                fleet_num, carapace_width, sex, abdomen_wdth, mass_g, nominal.cpue_potset)   
observer_cpue_offshore_crab <- observer_cpue_offshore_crab |> 
  dplyr::group_by(year, month, ices.rect) |>
  dplyr::mutate(nominal.cpue_potset = sum(nominal.cpue_potset, na.rm = TRUE)) 
observer_data_offshore_crab <- observer_data_offshore_crab |> 
  tidyr::unite(month.yr.rect, c(year, month, ices.rect), sep = "-", remove = FALSE) |> 
  dplyr::left_join(observer_cpue_offshore_crab) |>
  dplyr::select(month.yr, qrt.yr, month.yr.rect, year, month, survey_type, port, vesselID, species, 
                fleet_num, carapace_width, sex, abdomen_wdth, mass_g, nominal.cpue_potset)   
observer_data_crab <- observer_data_fleet_crab |>
  dplyr::bind_rows(observer_data_offshore_crab)


# reformat length composition input data (for SS)
# fleet & offshore data
# lobster - weighted by cpue
data <- observer_data_lobster |>
  dplyr::filter(!is.na(sex)) |>
  dplyr::mutate(carapace_width = carapace_width/10)
colnames(data)[11] <- "length" 
size.min <- 1
size.max <- 23
width <- 0.2
n.size <- length(table(cut(data$length, 
                           breaks = c(size.min, 
                                      seq(size.min+width, size.max-width, by = width), size.max))))
size.dist_m <- matrix(NA, 1, n.size+7)
size.dist_f <- matrix(NA, 1, n.size+7)
size.dist_lobster <- NULL 
for (i in c(unique(data$month.yr))) {
  print(i)
  subdata <- data[data$month.yr==i,]
  subdata_m <- subdata[subdata$sex==0,]
  subdata_f <- subdata[subdata$sex==1,]
  if (nrow(subdata_m) > 0) {
    size.dist_m[1] <- unique(subdata_m$year)
    size.dist_m[2] <- unique(subdata_m$month)
    size.dist_m[3] <- 1 # fleet
    size.dist_m[4] <- unique(subdata_m$sex)
    size.dist_m[5] <- 0 #part
    size.dist_m[6] <- nrow(subdata_m) * sum(unique(subdata_m$nominal.cpue_potset), na.rm = TRUE)
    size.dist_m[7:(n.size+6)] <- table(cut(subdata_m$length, 
                                           breaks = c(size.min, 
                                                      seq(size.min+width, size.max-width, by = width), 
                                                      size.max))) * 
      sum(unique(subdata_m$nominal.cpue_potset), na.rm = TRUE)
    size.dist_m[(n.size+6)+1] <- unique(subdata_m$month.yr)
  }
  if (nrow(subdata_f) > 0) {
    size.dist_f[1] <- unique(subdata_f$year)
    size.dist_f[2] <- unique(subdata_f$month)
    size.dist_f[3] <- 1 # fleet
    size.dist_f[4] <- unique(subdata_f$sex)
    size.dist_f[5] <- 0 #part
    size.dist_f[6] <- nrow(subdata_f) * sum(unique(subdata_f$nominal.cpue_potset), na.rm = TRUE)
    size.dist_f[7:(n.size+6)] <- table(cut(subdata_f$length, 
                                           breaks = c(size.min, 
                                                      seq(size.min+width, size.max-width, by = width), 
                                                      size.max)))  * 
      sum(unique(subdata_f$nominal.cpue_potset), na.rm = TRUE)
    size.dist_f[(n.size+6)+1] <- unique(subdata_f$month.yr)
  }
  size.dist <- dplyr::bind_rows(as.data.frame(size.dist_m), as.data.frame(size.dist_f))
  size.dist_lobster <- dplyr::bind_rows(as.data.frame(size.dist_lobster), as.data.frame(size.dist))
}

# aggregate by month
colnames(size.dist_lobster) <- c("year", "month", "fleet", "sex", "part", "nsample", paste0("s", 1:n.size), "month.yr")
size.dist_m2 <- matrix(0, 1, n.size+6)
size.dist_f2 <- matrix(0, 1, n.size+6)
size.dist_lobster2 <- NULL 
size.dist_lobster <- size.dist_lobster |> 
  dplyr::filter(is.finite(as.numeric(nsample)))
for (i in c(unique(data$month.yr))) {
  subdata <- size.dist_lobster[size.dist_lobster$month.yr==i,]
  subdata_m <- subdata[subdata$sex==0,1:ncol(subdata)-1]
  subdata_f <- subdata[subdata$sex==1,1:ncol(subdata)-1]
  if (nrow(subdata_m) > 0) {
    size.dist_m2[1] <- unique(subdata_m$year)
    size.dist_m2[2] <- unique(subdata_m$month)
    size.dist_m2[3] <- unique(subdata_m$fleet)
    size.dist_m2[4] <- unique(subdata_m$sex)
    size.dist_m2[5] <- unique(subdata_m$part)
    size.dist_m2[6] <- round(sum(as.numeric(subdata_m$nsample), na.rm = TRUE))
    if (nrow(subdata_m) > 1) {
      size.dist_m2[7:(n.size+6)] <- round(colSums(as.data.frame(apply(subdata_m[7:ncol(subdata_m)], 2, as.numeric)), na.rm = TRUE), digits=1)
    } else size.dist_m2[7:(n.size+6)] <- round(as.numeric(subdata_m[7:ncol(subdata_m)]), digits = 1)
  }
  if (nrow(subdata_f) > 0) {
    size.dist_f2[1] <- unique(subdata_f$year)
    size.dist_f2[2] <- unique(subdata_f$month)
    size.dist_f2[3] <- unique(subdata_f$fleet)
    size.dist_f2[4] <- unique(subdata_f$sex)
    size.dist_f2[5] <- unique(subdata_f$part)
    size.dist_f2[6] <- round(sum(as.numeric(subdata_f$nsample), na.rm = TRUE))
    if (nrow(subdata_f) > 1) {
      size.dist_f2[7:(n.size+6)] <- round(colSums(as.data.frame(apply(subdata_f[7:ncol(subdata_f)], 2, as.numeric)), na.rm = TRUE), digits=1)
    } else size.dist_f2[7:(n.size+6)] <- round(as.numeric(subdata_f[7:ncol(subdata_f)]), digits = 1)
  }
  size.dist <- dplyr::bind_rows(as.data.frame(size.dist_m2), as.data.frame(size.dist_f2))
  size.dist_lobster2 <- dplyr::bind_rows(as.data.frame(size.dist_lobster2), as.data.frame(size.dist))
}

# reformat for ss
colnames(size.dist_lobster2) <- c("year", "month", "fleet", "sex", "part", "nsample", paste0("s", 1:n.size))
size.dist_lobster_m <- size.dist_lobster2 |> 
  dplyr::filter(sex == 0) |> 
  dplyr::mutate(sex = 3) |>
  dplyr::rename(nsample.m = nsample) |>
  dplyr::select(-year, -month, -fleet, -sex, -part)
size.dist_lobster_f <- size.dist_lobster2 |> 
  dplyr::filter(sex == 1) |> 
  dplyr::mutate(sex = 3) 
size.dist_lobster_fleet <- size.dist_lobster_f |> 
  dplyr::bind_cols(size.dist_lobster_m) |>
  dplyr::mutate(nsample = as.numeric(nsample)+as.numeric(nsample.m)) |>
  dplyr::select(-nsample.m)
colnames(size.dist_lobster_fleet) <- c("year", "month", "fleet", "sex", "part", "nsample", 
                                 paste0("f", 1:n.size), paste0("m", 1:n.size))

# aggregate by year
size.dist_lobster_yr_fleet <- size.dist_lobster_fleet |> 
  tidyr::gather(sizebin, value, f1:colnames(size.dist_lobster_fleet)[length(colnames(size.dist_lobster_fleet))], 
                factor_key = TRUE) |>
  dplyr::filter(is.finite(nsample)) |>
  dplyr::group_by(year, sizebin) |>
  dplyr::reframe(year = unique(year),
                 month = max(month),
                 fleet = 1,
                 sex = 3,
                 part = 0,
                 nsample = sum(nsample, na.rm = TRUE),
                 sizebin = unique(sizebin),
                 value = sum(as.numeric(value), na.rm = TRUE)/nsample) |>
  tidyr::spread(sizebin, value) |>
  dplyr::glimpse()


# crab - weighted by cpue
data <- observer_data_crab |>
  dplyr::filter(!is.na(sex)) |>
  dplyr::mutate(carapace_width = carapace_width/10)
colnames(data)[11] <- "length" 
size.min <- 1
size.max <- 24
width <- 0.2
n.size <- length(table(cut(data$length, 
                           breaks = c(size.min, 
                                      seq(size.min+width, size.max+width*2-width, by = width), 
                                      size.max+width*2))))
size.dist_m <- matrix(NA, 1, n.size+7)
size.dist_f <- matrix(NA, 1, n.size+7)
size.dist_crab <- NULL 
for (i in c(unique(data$month.yr))) {
  print(i)
  subdata <- data[data$month.yr==i,]
  subdata_m <- subdata[subdata$sex==0,]
  subdata_f <- subdata[subdata$sex==1,]
  if (nrow(subdata_m) > 0) {
    size.dist_m[1] <- unique(subdata_m$year)
    size.dist_m[2] <- unique(subdata_m$month)
    size.dist_m[3] <- 1 # fleet
    size.dist_m[4] <- unique(subdata_m$sex)
    size.dist_m[5] <- 0 #part    
    size.dist_m[6] <- nrow(subdata_m) * sum(unique(subdata_m$nominal.cpue_potset), na.rm = TRUE)
    size.dist_m[7:(n.size+6)] <- table(cut(subdata_m$length, 
                                           breaks = c(size.min, 
                                                      seq(size.min+width, size.max-width, by = width), 
                                                      size.max))) * 
      sum(unique(subdata_m$nominal.cpue_potset), na.rm = TRUE)
    size.dist_m[(n.size+6)+1] <- unique(subdata_m$month.yr)
    print(size.dist_m[7:(n.size+6)])
  }
  if (nrow(subdata_f) > 0) {
    size.dist_f[1] <- unique(subdata_f$year)
    size.dist_f[2] <- unique(subdata_f$month)
    size.dist_f[3] <- 1 # fleet
    size.dist_f[4] <- unique(subdata_f$sex)
    size.dist_f[5] <- 0 #part    
    size.dist_f[6] <- nrow(subdata_f) * sum(unique(subdata_f$nominal.cpue_potset), na.rm = TRUE)
    size.dist_f[7:(n.size+6)] <- table(cut(subdata_f$length, 
                                           breaks = c(size.min, 
                                                      seq(size.min+width, size.max+width*2-width, by = width), 
                                                      size.max+width*2))) * 
      sum(unique(subdata_f$nominal.cpue_potset), na.rm = TRUE)
    size.dist_f[(n.size+6)+1] <- unique(subdata_f$month.yr)
  }
  size.dist <- dplyr::bind_rows(as.data.frame(size.dist_m), as.data.frame(size.dist_f))
  size.dist_crab <- dplyr::bind_rows(as.data.frame(size.dist_crab), as.data.frame(size.dist))
}

# aggregate by month
colnames(size.dist_crab) <- c("year", "month", "fleet", "sex", "part", "nsample", paste0("s", 1:n.size), "month.yr")
size.dist_m2 <- matrix(0, 1, n.size+6)
size.dist_f2 <- matrix(0, 1, n.size+6)
size.dist_crab2 <- NULL 
size.dist_crab <- size.dist_crab |> 
  dplyr::filter(is.finite(as.numeric(nsample)))
for (i in c(unique(data$month.yr))) {
  subdata <- size.dist_crab[size.dist_crab$month.yr==i,]
  subdata_m <- subdata[subdata$sex==0,1:ncol(subdata)-1]
  subdata_f <- subdata[subdata$sex==1,1:ncol(subdata)-1]
  if (nrow(subdata_m) > 0) {
    size.dist_m2[1] <- unique(subdata_m$year)
    size.dist_m2[2] <- unique(subdata_m$month)
    size.dist_m2[3] <- unique(subdata_m$fleet)
    size.dist_m2[4] <- unique(subdata_m$sex)
    size.dist_m2[5] <- unique(subdata_m$part)
    size.dist_m2[6] <- round(sum(as.numeric(subdata_m$nsample), na.rm = TRUE))
    if (nrow(subdata_m) > 1) {
      size.dist_m2[7:(n.size+6)] <- round(colSums(as.data.frame(apply(subdata_m[7:ncol(subdata_m)], 2, as.numeric)), na.rm = TRUE), digits=1)
    } else size.dist_m2[7:(n.size+6)] <- round(as.numeric(subdata_m[7:ncol(subdata_m)]), digits = 1)
  }
  if (nrow(subdata_f) > 0) {
    size.dist_f2[1] <- unique(subdata_f$year)
    size.dist_f2[2] <- unique(subdata_f$month)
    size.dist_f2[3] <- unique(subdata_f$fleet)
    size.dist_f2[4] <- unique(subdata_f$sex)
    size.dist_f2[5] <- unique(subdata_f$part)
    size.dist_f2[6] <- round(sum(as.numeric(subdata_f$nsample), na.rm = TRUE))
    if (nrow(subdata_f) > 1) {
      size.dist_f2[7:(n.size+6)] <- round(colSums(as.data.frame(apply(subdata_f[7:ncol(subdata_f)], 2, as.numeric)), na.rm = TRUE), digits=1)
    } else size.dist_f2[7:(n.size+6)] <- round(as.numeric(subdata_f[7:ncol(subdata_f)]), digits = 1)
  }
  size.dist <- dplyr::bind_rows(as.data.frame(size.dist_m2), as.data.frame(size.dist_f2))
  size.dist_crab2 <- dplyr::bind_rows(as.data.frame(size.dist_crab2), as.data.frame(size.dist))
}

# reformat for ss
colnames(size.dist_crab2) <- c("year", "month", "fleet", "sex", "part", "nsample", paste0("s", 1:n.size))
size.dist_crab_m <- size.dist_crab2 |> 
  dplyr::filter(sex == 0) |> 
  dplyr::mutate(sex = 3) |>
  dplyr::rename(nsample.m = nsample) |>
  dplyr::select(-year, -month, -fleet, -sex, -part)
size.dist_crab_f <- size.dist_crab2 |> 
  dplyr::filter(sex == 1) |> 
  dplyr::mutate(sex = 3) 
size.dist_crab_fleet <- size.dist_crab_f |> 
  dplyr::bind_cols(size.dist_crab_m) |> 
  dplyr::mutate(nsample = as.numeric(nsample)+as.numeric(nsample.m)) |>
  dplyr::select(-nsample.m)
colnames(size.dist_crab_fleet) <- c("year", "month", "fleet", "sex", "part", "nsample", 
                              paste0("f", 1:n.size), paste0("m", 1:n.size))

# aggregate by year
size.dist_crab_yr_fleet <- size.dist_crab_fleet |> 
  tidyr::gather(sizebin, value, f1:colnames(size.dist_crab_fleet)[length(colnames(size.dist_crab_fleet))], 
                factor_key = TRUE) |>
  dplyr::group_by(year, sizebin) |>
  dplyr::reframe(year = unique(year),
                 month = max(month),
                 fleet = 1,
                 sex = 3,
                 part = 0,
                 nsample = sum(nsample, na.rm = TRUE),
                 sizebin = unique(sizebin),
                 value = sum(as.numeric(value), na.rm = TRUE)/nsample) |>
  tidyr::spread(sizebin, value) |>
  dplyr::glimpse()

# merge fleet and offshore
readr::write_csv(size.dist_lobster_fleet, file = "processed_data/nifca/observer.size.comp.data_lobster_all_nifca_ss.csv") 
readr::write_csv(size.dist_crab_fleet, file = "processed_data/nifca/observer.size.comp.data_crab_all_nifca_ss.csv") 
readr::write_csv(size.dist_lobster_yr_fleet, file = "processed_data/nifca/observer.size.comp.data_lobster_all_yr_nifca_ss.csv") 
readr::write_csv(size.dist_crab_yr_fleet, file = "processed_data/nifca/observer.size.comp.data_crab_all_yr_nifca_ss.csv") 
