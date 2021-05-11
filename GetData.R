library(jsonlite)
library(dplyr)

base <- "https://vax-availability-api.azurewebsites.net/"

endpoints <- data.frame(
  "api/v1/vaccine-availability",
  "api/v1/vaccine-availability/{vaccine-availability_id}",
  "api/v1/vaccine-availability/{vaccine-availability_id}/timeslots",
  "api/v1/vaccine-availability/{vaccine-availability_id}/requirements",
  "api/v1/locations",
  "api/v1/locations/{location_id}",
  "api/v1/addresses",
  "api/v1/addresses/{address_id}",
  "api/v1/organizations",
  "api/v1/organizations/{organization_id}",
  "api/v1/requirements",
  "api/v1/requirements/{requirement_id}")

endpoints.df <- sapply(base, paste, endpoints, sep="")

endpoints.df[1:4]

# Pull from the VaxFinder addresses endpoint and store in data.frame with fromJSON()
ClinicAddresses.df <- fromJSON(endpoints.df[7]) 

# Drop unneeded columns 
ClinicAddresses.df <- ClinicAddresses.df[, -c(2,6,7)] 

# Create full_address field using apply() and paste()
ClinicAddresses.df$full_address <- apply(ClinicAddresses.df,1,paste,collapse=" ") 

# Send batch geocoding request to Mapbox (** API fees may apply **)
# ClinicCoordinates <- lapply(ClinicAddresses.df$full_address, mb_geocode) 

saveRDS(ClinicAddresses.df,"ClinicAddresses.rds")

