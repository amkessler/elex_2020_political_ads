library(tidyverse)
library(DBI)
library(RMariaDB)

##add user name and pw in your .Renvrion file
con <- dbConnect(MariaDB(), 
                 user=Sys.getenv("ADANALYTICS_USER"), 
                 password=Sys.getenv("ADANALYTICS_PW"), 
                 host="products.r53.advertisinganalyticsllc.com",
                 port="3306", 
                 dbname="products")

#list tables in database
dbplyr::src_dbi(con)

#pull main table into db object
admo_main_db <- tbl(con, "vw_bloomberg_political_airings")

glimpse(admo_main_db)

#set time for timestamp columns below
current_time <- Sys.time()

### PRESIDENTIAL ####

#pulling down presidential ad data into dataframe - from March 1 onwards
prez_ads_all <- admo_main_db %>% 
  filter(str_detect(election, "Presidential 2020"),
         airdate >= "2020-03-01") %>% 
  collect()

#add timestamp
prez_ads_all$bb_data_date <- current_time

#save as rds
saveRDS(prez_ads_all, "raw_data/prez_ads_all.rds")


#### HOUSE AND SENATE ####

# pulling down senate races
senate_ads_all <- admo_main_db %>% 
  filter(str_detect(election, "Senate 2020"),
         airdate >= "2020-03-01") %>% 
  collect()

#add timestamp
senate_ads_all$bb_data_date <- current_time


# pulling down house races
house_ads_all <- admo_main_db %>% 
  filter(str_detect(election, "CD-"),
         airdate >= "2020-03-01") %>% 
  collect()

#add timestamp
house_ads_all$bb_data_date <- current_time


#save as rds
saveRDS(senate_ads_all, "raw_data/senate_ads_all.rds")
#save as rds
saveRDS(house_ads_all, "raw_data/house_ads_all.rds")




#### DELTA DATABASE ####

#pull main table into db object

# admo_delta_db <- tbl(con, "vw_bloomberg_delta_spending")
# 
# glimpse(admo_delta_db)
# 
# temp_delta <- admo_delta_db %>% 
#   head() %>% 
#   collect()
# 
# temp_delta

  

#disconnect
dbDisconnect(con)


