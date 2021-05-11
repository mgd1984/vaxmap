# VaxMap - Ontario Vaccine Clinic Map

@VaxHuntersCan and volunteers have put together the VaxFinder API (https://vax-availability-api.azurewebsites.net/swagger) which is an excellent source of information for app developers and end-users.  

This repo contains a couple files: 
- getData.R that connects to the VaxFinder API using `httr` and `jsonlite` 
- app.R builds an interactive `Shiny` app using `Leaflet` and a few other libraries 
- ClinicAddresses.rds for retrieiving data frame of previously geocoded clinic addresses from getData.R

Areas for Improvement:
- Incorporating more VaxFinderAPI endpoints as map search parameters 
- Fix data anomalies (incorrectly geocoded coordinates, etc.) 
- UI improvements 
- ...


[![](https://github.com/mgd1984/vaxmap/blob/main/vaxmap.png?raw=true)](https://overviewanalytics.shinyapps.io/VaxMapR/)

