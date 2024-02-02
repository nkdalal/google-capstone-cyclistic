library(tidyverse)
library(lubridate)
library(ggplot2)
library(dplyr)
options(scipen=999)

jan_df <- read_csv('Trip Data/202301-divvy-tripdata.csv')
feb_df <- read_csv('Trip Data/202302-divvy-tripdata.csv')
mar_df <- read_csv('Trip Data/202303-divvy-tripdata.csv')
apr_df <- read_csv('Trip Data/202304-divvy-tripdata.csv')
may_df <- read_csv('Trip Data/202305-divvy-tripdata.csv')
jun_df <- read_csv('Trip Data/202306-divvy-tripdata.csv')
jul_df <- read_csv('Trip Data/202307-divvy-tripdata.csv')
aug_df <- read_csv('Trip Data/202308-divvy-tripdata.csv')
sep_df <- read_csv('Trip Data/202309-divvy-tripdata.csv')
oct_df <- read_csv('Trip Data/202310-divvy-tripdata.csv')
nov_df <- read_csv('Trip Data/202311-divvy-tripdata.csv')
dec_df <- read_csv('Trip Data/202312-divvy-tripdata.csv')


trip_data <- rbind(jan_df,feb_df,mar_df,apr_df,may_df,jun_df,jul_df,aug_df,sep_df,oct_df,nov_df,dec_df)




remove(jan_df,feb_df,mar_df,apr_df,may_df,jun_df,jul_df,aug_df,sep_df,oct_df,nov_df,dec_df)

str(trip_data)

count_df <- trip_data %>% 
  summarise(raw_lines = n())

# Remove rows with NA values
trip_data_cleaned <- na.omit(trip_data)

# Remove column start_station_id and end_station_id as it doesn't make any contribution in our analysis
trip_data_cleaned <- trip_data_cleaned[,-6]
trip_data_cleaned <- trip_data_cleaned[,-7]

# Calculate ride duration

trip_data_cleaned$duration <- difftime(trip_data_cleaned$ended_at, trip_data_cleaned$started_at, units = "mins")

# identify and delete the rows with negative time duration due to incorrect starting and ending time 

trip_data_cleaned <- trip_data_cleaned[trip_data_cleaned$duration >= 0, ]

# delete rows with duration as 0 minutes

trip_data_cleaned <- trip_data_cleaned %>%
  filter(duration != 0)

# create new column for month and day of week

trip_data_cleaned$month <- format(trip_data_cleaned$started_at, "%B")
trip_data_cleaned$day <- wday(trip_data_cleaned$started_at, label=TRUE)
trip_data_cleaned$date <- format(trip_data_cleaned$started_at, "%D")

# Export a cleaned csv file for further analysis

write_csv(trip_data_cleaned, 'Trip Data/2023_combined_trip_data.csv')

# total number of trips made by casual riders vs members

trip_summary <- trip_data_cleaned %>% 
  group_by(member_casual) %>% 
  summarise(total_trips_taken = n())

# Visualize total number of rides per user type

ggplot(data = trip_data_cleaned) +
  geom_bar(mapping = aes(x = member_casual, fill = member_casual), width = 0.2, stat = 'count') +
  labs(title = "Total number of trips", subtitle = "casual riders vs members")
  
# Visualize the total number of rides per bike type per user type

ggplot(data = trip_data_cleaned) +
  geom_bar(mapping = aes(x = rideable_type, fill = member_casual), width = 0.2, position = "dodge") +
  labs(title = "Total number of rides", subtitle = "per bike type for casual vs members")

# Visualize the number of trips made by casual riders and members per month

ggplot(data = trip_data_cleaned) +
  geom_line(mapping = aes(x = fct_inorder(month), group = member_casual, colour = member_casual), stat = "count") +
  
  labs(title = "Total number of rides", subtitle = "per month by casual vs members")

# average duration of trip made by casual rider vs member

average_duration <- trip_data_cleaned %>% 
  group_by(member_casual) %>% 
  summarise(duration_in_minutes = mean(duration))

# Visualize the average duration for which members and casual riders use the bikes

ggplot(data = trip_data_cleaned) +
  geom_bar(mapping = aes(x = member_casual, y = as.numeric(duration), fill = member_casual), width = 0.2, stat = "summary", fun = "mean") +
  labs(title = "Average duration of trips", subtitle = "casual riders vs members")

# Maximum and minimum duration of ride by both type of users

duration_summary <- trip_data_cleaned %>% 
  group_by(member_casual) %>% 
  summarise(
    Max_value = max(duration),
    Min_value = min(duration)
  )

# Number of times bike was not returned for more than 1 day grouped by type of user

threshold_value <- as.difftime(1440, units = "mins")
bike_overuse_df <- trip_data_cleaned %>% 
  group_by(member_casual) %>% 
  summarize(Count = sum(duration > threshold_value))

# Visualize the trend of bike usage (number of trips) by both types of users on days of week

ggplot(data = trip_data_cleaned) +
  geom_line(mapping = aes(x = day, group = member_casual, colour = member_casual), stat = "count") +
  labs(title = "Number of rides on days of week", subtitle = "casual vs member")

# Visualize the average number of hours both type of users use bike on weekdays

ggplot(data = trip_data_cleaned) +
  geom_bar(mapping = aes(x = day, y = as.numeric(duration), fill = member_casual), width = 0.2, position = "dodge", stat = "summary", fun = "mean") +
  labs(title = "Average duration on weekdays", subtitle = "casual vs member")

# Visualize the average trend of bike usage in whole day per user type

trip_data_cleaned$time_ride_started <- format(trip_data_cleaned$started_at, "%H:%M")
ggplot(data = trip_data_cleaned) +
  geom_line(mapping = aes(x =time_ride_started, group = member_casual, colour = member_casual), stat = "count") +
  scale_x_discrete(breaks = c( "00:00","01:00", "02:00","03:00","04:00","05:00","06:00","07:00","08:00", 
                               "09:00","10:00","11:00","12:00","13:00","14:00" ,"15:00","16:00", 
                               "17:00","18:00","19:00","20:00","21:00","22:00","23:00"), expand = c(0,0)) +
  labs(title = "Average number of trips during an average day")

trip_data_cleaned$time_ride_started <- format(trip_data_cleaned$started_at, "%H")
summary_data <- trip_data_cleaned %>%
  group_by(time_ride_started, member_casual) %>%
  summarize(avg_trips = n()/(n_distinct(date)))


ggplot(summary_data, aes(x = time_ride_started, y = avg_trips, color = member_casual, group = member_casual)) +
  geom_line() +
  labs(title = "Average Rides per Day by Hour", x = "Hour of Day", y = "Average Rides per Day", color = "Member Type")

# Visualize the trend of bike usage per hour on an average on weekdays 

trip_data_cleaned$time_ride_started <- format(trip_data_cleaned$started_at, "%H:%M")
ggplot(data = trip_data_cleaned) +
  geom_line(mapping = aes(x =time_ride_started, group = day, colour = day), stat = "count") +
  scale_x_discrete(breaks = c( "00:00","01:00", "02:00","03:00","04:00","05:00","06:00","07:00","08:00", 
                               "09:00","10:00","11:00","12:00","13:00","14:00" ,"15:00","16:00", 
                               "17:00","18:00","19:00","20:00","21:00","22:00","23:00"), expand = c(0,0)) +
  labs(title = "Average number of trips during an average week")

# Visualize the type of bike used in hour of the day on average

trip_data_cleaned$time_ride_started <- format(trip_data_cleaned$started_at, "%H:%M")
ggplot(data = trip_data_cleaned) +
  geom_smooth(mapping = aes(x = time_ride_started, group = rideable_type, color = rideable_type), stat = "count")+
  scale_x_discrete(breaks = c( "00:00","01:00", "02:00","03:00","04:00","05:00","06:00","07:00","08:00", 
                               "09:00","10:00","11:00","12:00","13:00","14:00" ,"15:00","16:00", 
                               "17:00","18:00","19:00","20:00","21:00","22:00","23:00" ), expand = c(0,0)) +
  labs(title = "Type of bike used during an average day")






  

