# VaxMap - Ontario Vaccine Clinic Map

@VaxHuntersCan and volunteers have put together the VaxFinder API (https://vax-availability-api.azurewebsites.net/swagger) which is an excellent source of information for app developers and end-users. 

This code in this repo can be used to pull data from the VaxFinder API and a build an interactive map of vaccine clinic locations in Ontario.  

Files in this repo: 
- getData.R connects to the VaxFinder API using `httr` and `jsonlite` 
- app.R builds an interactive `Shiny` app using `Leaflet` and a few other libraries 
- ClinicAddresses.rds retrieves a data frame of previously geocoded clinic addresses from getData.R

For Further Development:
- Incorporating more VaxFinderAPI endpoints as map search parameters
- Improve search features (case-insensitivity, etc.) 
- Fix data anomalies (incorrectly geocoded coordinates, etc.) 
- UI/UX improvement 
- ...

[![](https://github.com/mgd1984/vaxmap/blob/main/vaxmap2.png)](https://overviewanalytics.shinyapps.io/VaxMap/)

