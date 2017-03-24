#script to read is BRFSS data (SAS export .xpt)

install.packages("Hmisc")
library(Hmisc)

#functions
download_BRFSS <- function(year){
  temp = tempfile()
  zipF = paste("CDBRFS", year, "XPT.ZIP", sep = "")
  #https://www.cdc.gov/brfss/annual_data/2009/files/CDBRFS09XPT.ZIP
  url = paste("https://www.cdc.gov/brfss/annual_data/20", year, "/files/", zipF, sep = "")
  download.file(url, zipF, mode = "wb")
  dataset = unzip(zipF)
  #download.file(url, temp, mode = "wb")
  #dataset = unzip(temp)
  return(dataset)
}

add_exist_col <- function(dataset, code){
  #look for columns, if exists return
  if(code%in% colnames(dataset)){
    print(c("Adding ", toString(code)))
    return(dataset[[eval(code)]])
  } else {
    print(c(toString(code)," not found in ", toString(dataset)))
    }
}

#set where files are saved
setwd("L:/Public/jbousqui/GED/GIS/HWBI/BRFSS/Tabular")

#cycle through survey years (all = 1984:2015)
for(year in 2006:2010){
  print(year)
}

#read from .xpt
BRFSS_09 <- sasxport.get(download_BRFSS("09"))
#county 999= reduced, 777 = Don't know/Not sure
city = "ctycode"
#How well prepared do you feel your household is to handle a large-scale disaster or emergency?
#1 = Well prepared
#2 = Somewhat prepared
#3 = Not prepared at all
#7 = Don't know/Not Sure
#9 = Refused
prep = "gpwelpr3"
#Does your household have a 3-day supply of prescription medication for each person who takes prescribed medicines?
#1 = Yes
#2 = No
#3 = No one in household requires prescribed medicine 
#7 = Don't know/Not Sure
#9 = Refused
meds = "gp3dyprs"
#If public authorities announced a mandatory evacuation from your community due to a  large-scale disaster or emergency, would you evacuate?
#1 = Yes
#2 = No
#7 = Don't know/Not Sure
#9 = Refused
evac = "gpmndevc"

#fields
codes = c(city, prep, meds, evac)

#pull out datatable state & geo
temp_matrix = BRFSS_09[1:2]

#add columns to matrix for codes
for(code in codes){
  temp_matrix[[code]] <- add_exist_col(BRFSS_09, code)
}
#NOT WORKING
write.csv(temp_matrix, "BRFSS_09.csv")

#NOTES
setwd("L:/Public/jbousqui/GED/GIS/HWBI/BRFSS/Tabular")
fileName <- "CDBRFS09.XPT"
mydata <-sasxport.get(fileName)
mydata <-sasxport.get(unz(zipF, "xptF"))
https://www.cdc.gov/brfss/annual_data/2009/files/CDBRFS09XPT.ZIP
