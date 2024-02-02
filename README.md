Overview

Cyclistic is a bike sharing company based in Chicago. They have three type of bikes - docked, electric and classic. It has put over 5800 bikes in service with 600 docking stations all over Chicago city. Company has two types of customers including members and casual riders. The executives have realised the annual memberships are much more profitable for company and they believe that company future success lies in maximizing the annual memberships.

Lily Moreno is the director of marketing and my boss. I am working as a junior data analyst in marketing analyst team.

Company is looking forward to convert its casual riders, who already are aware about cyclistic bike sharing program, into members rather than targeting new customers. My team has been tasked with designing a new marketing strategy for this task. Lily has asked me to analyze the trip data from last 12 months and find out how do casual riders and members use the bike differently.

The main goal of this project is to determine how casual riders and members of Cyclistic shared bike program use the bikes differently.

Data structure

The data has been provided by Motivate International Inc. and can be downloaded from this link. The data is available in csv format with column names as:

cols(

ride_id = col_character(),

rideable_type = col_character(),

started_at = col_datetime,

ended_at = col_datetime,

start_station_name = col_character(),

start_station_id = col_character(),

end_station_name = col_character(),

end_station_id = col_character(),

start_lat = col_double(),

start_lng = col_double(),

end_lat = col_double(),

end_lng = col_double(),

member_casual = col_character()

)


We have combined the data from all the 12 files in 1 dataset and would use efficiency of R to clean and process the data.

