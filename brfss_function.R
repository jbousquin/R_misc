#script to read is BRFSS data (SAS export .xpt)

install.packages("Hmisc")
library(Hmisc)

###FUNCTIONS###
download_BRFSS <- function(year){
  temp = tempfile()
  zipF = paste("CDBRFS", substr(year, 3, 4), "XPT.ZIP", sep = "")
  #https://www.cdc.gov/brfss/annual_data/2009/files/CDBRFS09XPT.ZIP
  url = paste("https://www.cdc.gov/brfss/annual_data/", year, "/files/", zipF, sep = "")
  download.file(url, zipF, mode = "wb")
  dataset = unzip(zipF)
  #download.file(url, temp, mode = "wb")
  #dataset = unzip(temp)
  return(dataset)
}

add_exist_col <- function(dataset, code){
  #look for columns, if exists return
  if(code%in% colnames(dataset)){
    print(paste("Adding", toString(code), sep=" "))
    return(dataset[[eval(code)]])
  } else {
    print(paste(toString(code),"not found in dataset", sep=" "))
    return(NULL)
    }
}

###EXECUTE###
#set range of years
rngYears = (2006:2010) #2006

#set where files are saved
setwd("L:/Public/jbousqui/GED/GIS/HWBI/BRFSS/Tabular")

#set columns of interest
#county 999= reduced, 777 = Don't know/Not sure
city = "ctycode"
#How well prepared do you feel your household is to handle a large-scale disaster or emergency?
#1 = Well prepared
#2 = Somewhat prepared
#3 = Not prepared at all
#7 = Don't know/Not Sure
#9 = Refused
#code used in 2008-2010
prep = "gpwelpr3"
#code used in 2007
prep1 = "gpwelpr2"
#code used in 2006
prep2 = "gpwelprd"
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

#list of columns
codes = c(city, prep, prep1, prep2, meds, evac)

#cycle through survey years (all = 1984:2015)
for(year in rngYears){
  fileName = paste("BRFSS_", year, ".csv", sep="")
  print(paste("Creating", fileName, sep = " "))
  temp_BRFSS <- sasxport.get(download_BRFSS(year))
  temp_matrix = temp_BRFSS[1:2]
  for(code in codes){
    temp_matrix[[code]] <- add_exist_col(temp_BRFSS, code)
  }
  write.csv(temp_matrix, fileName)
}