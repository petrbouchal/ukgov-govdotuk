## This script loads JSON data on publicaions from gov.uk, turns it into a 
## dataset, and creates a chart of publication by time in the week

library(rjson)
library(pbtools)
library(RCurl)

LoadCustomThemes(mycols=ifgbasecolours[,1],fontfamily = 'Calibri',tints = c(0.75,0.5,0.25))

## Load pages and create a long list of all results rows (list of lists)
results <- list()
temporaryFile <- tempfile()
for (i in 1:500) {
  url <- paste0('https://www.gov.uk/government/publications.json?page=',i)
  pubsfile <- download.file(url,destfile = temporaryFile, method='curl',quiet = T)
  pubs <- readLines(temporaryFile)
  pubsj <- fromJSON(pubs)
  results <- append(results, pubsj$results)
  if (i%%10==0) {print(i)} # print progress every 10 iterations
}

## Turn the list of lists into a data frame
# First fix NULL values
json_file <- lapply(results, function(x) {
  x[sapply(x, is.null)] <- NA
  unlist(x)
})

# Turn into dataframe
df <- as.data.frame(do.call("rbind", json_file))

# fix dates & create additional time/date vars
df$date <- strptime(df$public_timestamp, format='%Y-%m-%dT%H:%M:%S')
df$dayname <- wday(df$date,label = T)
df$daynum <- wday(df$date,label = F)
df$hour <- sprintf('%02s',hour(df$date))
df$weekid <- paste0(week(df$date),'_',year(df$date))
df$dayhour <- paste0(df$daynum, '_', df$hour)

## Save data if needed

# save(df,'./data-output/500GovUKpublications.rda')

# Dig out organisation from HTML - TODO
# df$orgname <- str_extract(df$organisations,)
