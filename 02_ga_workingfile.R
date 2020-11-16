library(tidyverse)
library(lubridate)
library(janitor)
library(scales)
library(gt)
library(kableExtra)
options(dplyr.summarise.inform = FALSE)

### LOAD AND PROCESSING #### 

#load saved files from db pulls done in step 00_B
senate_ads_all <- readRDS("raw_data/senate_ads_all_postelex.rds")
house_ads_all <- readRDS("raw_data/house_ads_all_postelex.rds")
prez_ads_all <- readRDS("raw_data/prez_ads_all_postelex.rds")

#add field to mark senate/house
senate_ads_all <- senate_ads_all %>% 
  mutate(
    office = "senate"
  )

house_ads_all <- house_ads_all %>% 
  mutate(
    office = "house"
  )

prez_ads_all <- prez_ads_all %>% 
  mutate(
    office = "prez"
  )


# combine into one (can also work with each separately if desired)
admo_main <- bind_rows(prez_ads_all, senate_ads_all, house_ads_all)

#add date-derived fields
admo_main <- admo_main %>% 
  mutate(
    airdate_year = year(airdate),
    airdate_month = month(airdate),
    airdate_isoweek = isoweek(airdate),
    airdate_day = day(airdate)
  )

#pull out GA runoff records only, tv ads
ga_runoff_tvads <- admo_main %>% 
  filter(election_state == "GA",
         election %in% c("GA Senate 2020 General Runoff", "GA Senate Special 2020 General Runoff"),
         !station %in% c("Facebook", "Google")) #take out social media ads so it's tv airings only




### ANALYSIS ####

ga_runoff_tvads %>% 
  group_by(election, advertiser_party, advertiser) %>% 
  summarise(ads_aired = n(), est_spent = sum(spent)) 


ga_runoff_tvads %>% 
  count(advertiser_party, tone, name = "ads_aired") 


ga_runoff_tvads %>% 
  group_by(advertiser_party, market) %>% 
  summarise(ads_aired = n())


ga_runoff_tvads %>% 
  count(advertiser_party, market) %>% 
  slice_max(order_by = n, n = 5)


ga_runoff_tvads %>% 
  count(advertiser_party, market) %>% 
  top_n(n = 5, wt = market)



### CHARTS ####

dailycount_byparty <- ga_runoff_tvads %>% 
  count(airdate, advertiser_party, name = "ad_count")

dailycount_byparty

# #sample area chart
# # http://www.sthda.com/english/articles/32-r-graphics-essentials/128-plot-time-series-data-using-ggplot/
# df <- economics %>%
#   select(date, psavert, uempmed) %>%
#   gather(key = "variable", value = "value", -date)
# 
# head(df, 3)
# 
# ggplot(df, aes(x = date, y = value)) + 
#   geom_area(aes(color = variable, fill = variable), 
#             alpha = 0.5, position = position_dodge(0.8)) +
#   scale_color_manual(values = c("#00AFBB", "#F2785D")) +
#   scale_fill_manual(values = c("#00AFBB", "#F2785D"))


#apply to ad dataframe
ggplot(dailycount_byparty, aes(x = airdate, y = ad_count)) + 
  geom_area(aes(color = advertiser_party, fill = advertiser_party), 
            alpha = 0.5, position = position_dodge(0.8)) +
  scale_color_manual(values = c("#00AFBB", "#F2785D")) +
  scale_fill_manual(values = c("#00AFBB", "#F2785D")) +
  labs(title = "GA Senate Runoffs - Ad Spots By Party", 
       subtitle = "",
       x = "",
       y = "") +
  theme_minimal() +
  scale_y_continuous(labels = comma)



#bar chart
ggplot(dailycount_byparty, aes(x = airdate, y = ad_count)) + 
  geom_col(aes(color = advertiser_party, fill = advertiser_party), 
            alpha = 0.5, position = position_dodge(preserve = "single")) +
  scale_color_manual(values = c("#00AFBB", "#F2785D")) +
  scale_fill_manual(values = c("#00AFBB", "#F2785D")) +
  labs(title = "GA Senate Runoffs - Ad Spots By Party", 
       subtitle = "",
       x = "",
       y = "") +
  theme_minimal() +
  scale_y_continuous(labels = comma)



#CANDIDATES

dailycount_bycand <- ga_runoff_tvads %>% 
  count(airdate, advertiser, name = "ad_count")

dailycount_bycand

#bar chart for CANDIDATES
ggplot(dailycount_bycand, aes(x = airdate, y = ad_count)) + 
  geom_col(aes(color = advertiser, fill = advertiser), 
           alpha = 0.5, position = position_dodge(preserve = "single")) +
  scale_color_manual(values = c("#DC3A3A", "#00AFBB", "#F2785D", "#2E90B8")) +
  scale_fill_manual(values = c("#DC3A3A", "#00AFBB", "#F2785D", "#2E90B8")) +
  labs(title = "GA Senate Runoffs - Ad Spots By Candidate", 
       subtitle = "",
       x = "",
       y = "") +
  theme_minimal() +
  scale_y_continuous(labels = comma)



