## This script reshapes the publication data and creates plots

library(pbtools) #source at github.com/petrbouchal/pbtools

# Load data - this is created by govuk_publications_scrape.R

load('./data-output/500GovUKpublications.rda')

## Reshape and create aggregate/proportions, and filter

dfs <- select(df, dayname, hour, dayhour, display_type, weekid) %>%
mutate(count_all=n()) %>% # count of everything in the dataset
group_by(dayhour) %>%
mutate(count_dayhour=n(),share_dayhour=n()/count_all) %>% # rate of all per hour
ungroup() %>%  
group_by(display_type) %>%
mutate(counttype=n()) %>% # count by type
group_by(dayname, hour, dayhour, display_type) %>% 
mutate(sharedayhourtype=n()/counttype) %>% # rate by type per hour
summarise(share_type=mean(sharedayhourtype),count_type=n(), # means
          count_all=mean(count_all),share_all=mean(share_dayhour)) %>%
filter(display_type=='Transparency data') %>%
melt() %>% # reshape
#   filter(variable=='share_type' | variable=='share_all') %>%
filter(variable=='share_type') %>%
mutate(display_type=as.character(display_type), # reformulate labels
       display_type=ifelse(variable=='share_all','All publications',display_type))

## Plots

plot <- ggplot(dfs, aes(x=hour, y=value, fill=dayname)) +
  geom_bar(stat="identity",position = 'stack') +
  scale_fill_manual(values=ifgbasecolours) +
  scale_y_continuous(label=percent) +
  scale_x_discrete(breaks=c('00','03','06','09','12','15','18','21')) +
  facet_wrap(~dayname, nrow=1)
plot

plot <- ggplot(dfs, aes(x=hour, y=value, fill=display_type, group=display_type)) +
  geom_bar(stat="identity",position='dodge') +
  scale_fill_manual(values=ifgbasecolours) +
  scale_y_continuous(label=percent) +
  facet_wrap(~dayname, nrow=1) 
plot

plot <- ggplot(dfs, aes(x=dayname, y=value, fill=dayname)) +
  geom_bar(stat="identity",position = 'stack') +
  scale_y_continuous(label=percent) +
  scale_fill_manual(values=ifgbasecolours)
plot

## Stats

sum(dfs$value[as.numeric(dfs$hour)<15 & dfs$dayname!='Fri'])
mean(dfs$value[as.numeric(dfs$hour)<15 & dfs$dayname!='Fri'])
sum(dfs$value[as.numeric(dfs$hour)>14 & dfs$dayname=='Fri'])
mean(dfs$value[as.numeric(dfs$hour)>14 & dfs$dayname=='Fri'])
