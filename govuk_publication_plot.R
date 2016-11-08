## This script reshapes the publication data and creates plots

# library(pbtools) #source at github.com/petrbouchal/pbtools

# Load data - this is created by govuk_publications_scrape.R

load('./data-output/500GovUKpublications.rda')
library(tidyr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)
library(feather)

## Reshape and create aggregate/proportions, and filter

dfs <- select(df[1:20000,], dayname, hour, dayhour, display_type, weekid) %>%
  mutate(count_all=n()) %>% # count of everything in the dataset
  group_by(dayhour) %>%
  mutate(count_dayhour=n(),share_dayhour=n()/count_all) %>% # rate of all per hour
  ungroup() %>%  
  group_by(display_type) %>%
  mutate(counttype=n()) %>% # count by type
  group_by(dayname, hour, dayhour, display_type, weekid) %>% 
  mutate(sharedayhourtype=n()/counttype) %>% # rate by type per hour
  summarise(share_type=mean(sharedayhourtype),count_type=n(), # means
            count_all=mean(count_all),share_all=mean(share_dayhour)) %>%
  filter(display_type=='Transparency data') %>%
  gather(variable, value, 6:9) %>%
  #   filter(variable=='share_type' | variable=='share_all') %>%
  filter(variable=='share_type') %>%
  ungroup() %>% 
  mutate(display_type=as.character(display_type), # reformulate labels
         latestweek=ifelse(as.numeric(weekid)==as.numeric(paste0(year(now()),week(now()))),TRUE,FALSE),
         display_type=ifelse(variable=='share_all','All publications',display_type))

## Plots

# loadcustomthemes(mycols=ifgbasecolours[,1],fontfamily = 'Calibri',tints = c(0.75,0.5,0.25))

plot1 <- ggplot(dfs, aes(x=hour, y=value, fill=dayname)) +
  geom_bar(stat="identity",position = 'dodge') +
  # scale_fill_manual(values=rev(ifgbasecolours[,1]), guide='none') +
  scale_y_continuous(label=percent) +
  scale_x_discrete(breaks=c('00','03','06','09','12','15','18','21')) +
  facet_wrap(~ dayname, nrow=1) +
  theme(strip.text=element_text(size=14, face='bold'))
plot1

# plot1a <- ggplot(dfs, aes(x=hour, y=value, fill=dayname, group=display_type)) +
#   geom_bar(stat="identity",position = 'stack') +
#   scale_fill_manual(values=rev(ifgbasecolours[,1]), guide='none') +
#   scale_y_continuous(label=percent) +
#   scale_x_discrete(breaks=c('00','03','06','09','12','15','18','21')) +
#   facet_grid(latestweek ~ dayname,drop = FALSE) +
#   theme(strip.text=element_text(size=14, face='bold'))
# plot1a

plot2 <- ggplot(dfs, aes(x=hour, y=value, fill=display_type, group=display_type)) +
  geom_bar(stat="identity",position='dodge') +
  # scale_fill_manual(values=ifgbasecolours) +
  scale_y_continuous(label=percent) +
  facet_wrap(~dayname, nrow=1)
plot2

plot3 <- ggplot(dfs, aes(x=dayname, y=value, fill=dayname)) +
  geom_bar(stat="identity",position = 'stack') +
  # scale_fill_manual(values=ifgbasecolours) +
  scale_y_continuous(label=percent)
plot3

## Stats

sum(dfs$value[as.numeric(dfs$hour)<15 & dfs$dayname!='Fri'])
mean(dfs$value[as.numeric(dfs$hour)<15 & dfs$dayname!='Fri'])
mean(dfs$value)
sum(dfs$value[as.numeric(dfs$hour)>14 & dfs$dayname=='Fri'])
mean(dfs$value[as.numeric(dfs$hour)>14 & dfs$dayname=='Fri'])
