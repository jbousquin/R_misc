#script to read raw brfss csv data in, process it and write it out
#library(plyr)

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

count <- function(x) {length(na.omit(x))} 

#set where files are saved
setwd("L:/Public/jbousqui/GED/GIS/HWBI/BRFSS/Tabular")

#set range of years
rngYears = (2006:2010) #2006

for(year in rngYears){
  current_csv = paste("BRFSS_", year, ".csv", sep="")
  tbl = read.csv(current_csv)

  #fix FIPS
  #county 999= reduced, 777 = Don't know/Not sure
  tbl$FIPS = (tbl$x.state *1000) + tbl$ctycode
  
  #fix gpwelpr
  #How well prepared do you feel your household is to handle a large-scale disaster or emergency?
  #figure out which code exists
  codes = c("gpwelpr3", "gpwelpr2", "gpwelprd")
  for(code in codes){
    tbl$gpwelpr <- add_exist_col(tbl, code)
  }
  #convert responses to yes/no
  #1 = Well prepared
  tbl$gpwelpr[tbl$gpwelpr == 2] = 1  #2 = Somewhat prepared
  tbl$gpwelpr[tbl$gpwelpr == 3] = 0  #3 = Not prepared at all
  tbl$gpwelpr[tbl$gpwelpr == 7] = NA #7 = Don't know/Not Sure
  tbl$gpwelpr[tbl$gpwelpr == 9] = NA #9 = Refused
  
  #fix meds, 'gp3dyprs"
  #Does your household have a 3-day supply of prescription medication for each person who takes prescribed medicines?
  #1 = Yes
  tbl$gp3dyprs[tbl$gp3dyprs == 2] = 0  #2 = No
  tbl$gp3dyprs[tbl$gp3dyprs == 3] = NA #3 = No one in household requires prescribed medicine
  tbl$gp3dyprs[tbl$gp3dyprs == 7] = NA #7 = Don't know/Not Sure
  tbl$gp3dyprs[tbl$gp3dyprs == 9] = NA #9 = Refused
  
  #fix evacuation, "gpmndevc"
  #If public authorities announced a mandatory evacuation from your community due to a  large-scale disaster or emergency, would you evacuate?
  #1 = Yes
  tbl$gpmndevc[tbl$gpmndevc == 2] = 0  #2 = No
  tbl$gpmndevc[tbl$gpmndevc == 7] = NA #7 = Don't know/Not Sure
  tbl$gpmndevc[tbl$gpmndevc == 9] = NA #9 = Refused
  
  temp_table <- aggregate(tbl, list(tbl$x.state), FUN = mean, na.rm=TRUE)
  cnt_table <- aggregate(tbl, list(tbl$x.state), FUN = count)
  temp_subTable <- temp_table[,c(1,3)]
  for (col in c("gpwelpr", "gp3dyprs", "gpmndevc")){
    col_year = paste(col, year, sep="_")
    col_year_cnt = paste(col_year, "cnt", sep = "_")
    temp_subTable[[col_year]] <- temp_table[[col]]
    temp_subTable[[col_year_cnt]] <- cnt_table[[col]]
  }
  
  if(!exists("state_table")){
    #remove "Group.1"
    temp_subTable<-subset(temp_subTable, select= -Group.1)
    state_table<-temp_subTable
  } else {
    #remove "Group.1"
    temp_subTable<-subset(temp_subTable, select= -Group.1)
    state_table <- merge(state_table, temp_subTable, by = "x.state", all = T)
  }
}
write.csv(state_table, "BRFSS_metrics.csv")
