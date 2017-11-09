library(RCurl)
library(jsonlite)

# get groups
# group_url <- 'https://api.meetup.com/2/groups?country=us&offset=0&city=Hartford&format=json&lon=-72.6699981689&photo-host=public&state=ct&page=20&radius=10.0&fields=&lat=41.7900009155&order=id&desc=false&sig_id=189051097&sig=a352c27062e37a18215697e5a612194d7de67dba'

cities <- c('Hartford', 'Boston')
states <- c('CT', 'MA')
group_url <- sprintf('https://api.meetup.com/2/groups?key=62c15445c44f4e5473e7e3e164d7f&country=us&offset=0&city=%s&state=%s&radius=10.0&sign=true', 
                     cities[1], states[1])
x <- GET(group_url)
y <- fromJSON(as.character(x))
fields <- c('id', 'name', 'created', 'city', 'state', 'members', 'who','visibility')
groups_df <- y$results[,fields]
head(groups_df)
groups_df<-filter(groups_df, visibility=='public')
head(groups_df)


#get events
events_url<-'https://api.meetup.com/2/events?offset=0&format=json&limited_events=False&rsvp=yes&group_id=145906&photo-host=public&page=20&fields=&order=time&desc=false&status=upcoming&sig_id=189051097&sig=78e045a9dd044ab8484a1557874967e3239db6ab'
group_id <- '145906'
# events_url<-sprintf('https://api.meetup.com/2/events?offset=0&format=json&limited_events=False&rsvp=yes&group_id=%s&photo-host=public&page=20&fields=&order=time&desc=false&status=upcoming&sig_id=189051097&sig=78e045a9dd044ab8484a1557874967e3239db6ab', group_id)

get_events <- function(group_id){
  
  i <- 1
  group_id <- groups_df$id[i]
  group_id
  #https://api.meetup.com/2/events?key=62c15445c44f4e5473e7e3e164d7f&group_id=145906&rsvp=yes&sign=true
  events_url <- sprintf('https://api.meetup.com/2/events?key=62c15445c44f4e5473e7e3e164d7f&group_id=%s&rsvp=yes&sign=true', group_id)
  z <- GET(events_url)
  z1 <- fromJSON(as.character(z))
  events_df<-z1$meta
  return(events_df)
}

i <- 1
get_events(groups_df$id[i])
