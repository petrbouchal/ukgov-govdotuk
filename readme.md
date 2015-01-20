GOV.UK content and traffic data analysis
=============
Analysis of gov.uk content and traffic data.

Currently (January 2015) only contains script for downloading, analysing and visualising the publication feed of GOV.UK.

# Data sources

* The source for this script is [GOV.UK publication page JSON](https://gov.uk/government/publications.json)
* Most addresses in the `/government` part of GOV.UK can be accessed in JSON format by adding `.json` to the address.

# Other data sources

* There are also JSON API access points into the [Performance Platform](http://gov.uk/performance) accessible through the JSON link on each performance page.
  * For services, it looks like this: https://www.gov.uk/performance/tax-disc/api/realtime?sort_by=_timestamp%3Adescending&limit=1
  * For activity (pages) it looks like this:  https://www.performance.service.gov.uk/data/govuk/visitors?duration=104&collect=visitors%3Asum&group_by=website&period=week

Untangling the nested JSON - or indeed collecting more data at one go - might require some looping and data processing in Python or R, or some playing around with PowerQuery in Excel.


