library(RCurl)
library(jsonlite)
library(httr)
library(dplyr)

# get open events
# events url: https://api.meetup.com/2/open_events?and_text=False&country=us&offset=0&city=Hartford&format=json&limited_events=False&state=ct&photo-host=public&page=20&radius=25.0&desc=False&status=upcoming&sig_id=189051097&sig=5bb34ce8155ab2a301d04e586139da434613ff56
cities <- c('Hartford', 'Boston', 'Charlotte')
states <- c('CT', 'MA', 'NC')

i <- 1


for(i in i:length(cities)){

  city <- cities[i]
  state <- states[i]
# pull event data
events_url <- sprintf('https://api.meetup.com/2/open_events?key="insertkeyhere"&country=us&offset=0&city=%s&state=%s&radius=10.0&sign=true', 
                      city, state)
x <- GET(events_url)
y <- fromJSON(as.character(x))

#get events
events_df <- y$results %>%
  select(name,yes_rsvp_count,id)
events_df_wvenue <- y$results$venue %>%
  select(lat,lon) %>%
  mutate(id = y$results$id)

#Events with latitude and longitude
events_df <- events_df %>%
  full_join(events_df_wvenue,by="id")

#Events by group affiliation
events_df_by_group <- y$results$group
colnames(events_df_by_group)[5] <- "gid"

#create an events data fram with group_id to join to groups
events_df <-  events_df_by_group %>%
  mutate(id = y$results$id) %>% 
  select(gid, id) %>% 
  full_join(events_df, by="id")

# pull group data

# group_url <- 'https://api.meetup.com/2/groups?country=us&offset=0&city=Hartford&format=json&lon=-72.6699981689&photo-host=public&state=ct&page=20&radius=10.0&fields=&lat=41.7900009155&order=id&desc=false&sig_id=189051097&sig=a352c27062e37a18215697e5a612194d7de67dba'


groups_url <- sprintf('https://api.meetup.com/2/groups?key="insertkeyhere"&country=us&offset=0&city=%s&state=%s&radius=10.0&sign=true', 
                      city, state)


a <- GET(groups_url)
z <- fromJSON(as.character(a))

# clean up

#create data fram
fields <- c('name','created', 'city', 'state', 'members','who', 'id')
groups_df <- z$results[,fields] %>% 
  mutate(gid= z$results$id)

#ad the column with category and change the column name to category
groups_df2 <- z$results$category %>% 
  select(name) %>% 
  mutate(gid=z$results$id)
colnames(groups_df2)[1] <- "category"

#join groups so each group has gid and category
groups_df3 <- groups_df %>% 
  full_join(groups_df2, by='gid')

#join events, groups
finalCity<-groups_df3 %>% 
  full_join(events_df, by='gid')

# join

events_hart<-finalCity%>% 
  group_by(category) %>% 
  summarise(rsvp=sum(yes_rsvp_count, na.rm=TRUE)) %>% 
  arrange(desc(rsvp))
#dim(final)
#View(final)
#View(events_hart)

# write result to disk
filepath <- sprintf('data/%s_%s.csv', city, state)
write.csv(finalCity, filepath)
#View(finalCity)
  
}




