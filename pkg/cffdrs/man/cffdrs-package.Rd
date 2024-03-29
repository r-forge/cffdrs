\name{cffdrs-package}
\alias{cffdrs-package}
\alias{cffdrs}
\docType{package}
\title{
Canadian Forest Fire Danger Rating System
}
\description{
The cffdrs package allows R users to calculate the outputs of the two main components of the Canadian Forest Fire Danger Rating System (CFFDRS; \url{http://cwfis.cfs.nrcan.gc.ca/background/summary/fdr}): the Fire Weather Index (FWI) System (\url{http://cwfis.cfs.nrcan.gc.ca/background/summary/fwi}) and the Fire Behaviour Prediction (FBP) System (\url{http://cwfis.cfs.nrcan.gc.ca/background/summary/fbp}) along with additional methods created and used Canadian fire modelling. These systems are widely used internationally to assess fire danger (FWI System) and quantify fire behavior (FBP System).

The FWI System (Van Wagner 1987) is based on the moisture content and the effect of wind of three classes of forest fuels on fire behavior. It consists of six components: three fuel moisture codes (Fire Fuel Moisture Code, Duff Moisture Code, Drought Code), and three fire behavior indexes representing rate of spread (Initial Spread Index), fuel consumption (Buildup Index), and fire intensity (Fire Weather Index). The FWI System outputs are determined from daily noon weather observations: temperature, relative humidity, wind speed, and 24-hour rainfall.

The FBP System (Forestry Canada Fire Danger Group 1992; Hirsch 1996) provides a set of primary and secondary measures of fire behavior. The primary outputs consist of estimates of fire spread rate, fuel consumption, fire intensity, and fire description (i.e., surface, intermittent, or crown fire). The secondary outputs, which are not used nearly as often, give estimates of fire area, perimeter, perimeter growth rate, and flank and back fire behavior based on a simple elliptical fire growth model. Unlike the FWI System, which is weather based, the FBP System also requires information on vegetation (hereafter, fuel types) and slope (if any) to calculate its outputs. Sixteen fuel types are included in the FBP System, covering mainly major vegetation types in Canada.

}
\details{
\tabular{ll}{
Package: \tab cffdrs\cr
Type: \tab Package\cr
Version: \tab 1.8.19\cr
Date: \tab 2022-07-08\cr
License: \tab GPL-2\cr
}
This package includes eleven functions. Seven functions, \code{\link{fwi}}, \code{\link{fwiRaster}}, \code{\link{hffmc}}, \code{\link{hffmcRaster}}, \code{\link{sdmc}}, \code{\link{gfmc}}, and \code{\link{wDC}} are used for FWI System calculation, whereas two functions, \code{\link{fbp}} and \code{\link{fbpRaster}} are used for FBP System calculation. One function, \code{\link{fireSeason}} determines fire season start and end dates based on weather. Two functions \code{\link{pros}} and \code{\link{lros}} are rate of spread and direction calculations across tiangles. These functions are not fully independent: their inputs overlap greatly and the users will have to provide FWI System outputs to calculate FBP System outputs. The fwi, fwiRaster, and sdmc functions calculate the outputs based on daily noon local standard time (LST) weather observations of temperature, relative humidity, wind speed, and 24-hour rainfall, as well as the previous day's moisture content. The hffmc, gfmc, and hffmcRaster functions calculate the outputs based on hourly weather observations of temperature, relative humidity, wind speed, and hourly rainfall, as well as the previous hour's weather conditions. The fbp and fbpRaster functions calculate the outputs of the FBP System based on given set of information about fire weather conditions (weather observations and their associated FWI System components), fuel type, and slope (optional).
}
\author{
Xianli Wang, Alan Cantin, Marc-André Parisien, Mike Wotton, Kerry Anderson, Brett Moore, Tom Schiks, Jordan Evens, and Mike Flannigan

Maintainer: Alan Cantin \email{Alan.Cantin@NRCan-RNCan.gc.ca}
}
\references{
1. Van Wagner, C.E. and T.L. Pickett. 1985. Equations and FORTRAN program for the Canadian Forest Fire Weather Index System. Can. For. Serv., Ottawa, Ont. For. Tech. Rep. 33. 18 p.

2. Van Wagner, C.E. 1987. Development and structure of the Canadian forest fire weather index system. Forest Technology Report 35. (Canadian Forestry Service: Ottawa).

3. Lawson, B.D. and O.B. Armitage. 2008. Weather guide for the Canadian Forest Fire Danger Rating System. Nat. Resour. Can., Can. For. Serv., North. For. Cent., Edmonton, AB.

4. Hirsch K.G. 1996. Canadian Forest Fire Behavior Prediction (FBP) System: user's guide. Nat. Resour. Can., Can. For. Serv., Northwest Reg., North. For. Cent., Edmonton, Alberta. Spec. Rep. 7. 122p.

5. Forestry Canada Fire Danger Group. 1992. Development and structure of the Canadian Forest Fire Behavior Prediction System. Forestry Canada, Ottawa, Ontario Information Report ST-X-3. 63 p. \url{http://cfs.nrcan.gc.ca/pubwarehouse/pdfs/10068.pdf}

6. Wotton, B.M., Alexander, M.E., Taylor, S.W. 2009. Updates and revisions to the 1992 Canadian forest fire behavior prediction system. Nat. Resour. Can., Can. For. Serv., Great Lakes For. Cent., Sault Ste. Marie, Ontario, Canada. Information Report GLC-X-10, 45p. \url{http://publications.gc.ca/collections/collection_2010/nrcan/Fo123-2-10-2009-eng.pdf}

7. Tymstra, C., Bryce, R.W., Wotton, B.M., Armitage, O.B. 2009. Development and structure of Prometheus: the Canadian wildland fire growth simulation Model. Nat. Resour. Can., Can. For. Serv., North. For. Cent., Edmonton, AB. Inf. Rep. NOR-X-417.
}

\keyword{ package }
\seealso{
   \code{\link{fbp}},
   \code{\link{fireSeason}},
   \code{\link{fwi}},
   \code{\link{fwiRaster}},
   \code{\link{gfmc}},
   \code{\link{hffmc}},
   \code{\link{hffmcRaster}},
   \code{\link{lros}},
   \code{\link{pros}},
   \code{\link{sdmc}},
   \code{\link{wDC}}
}
\examples{
#Calculating daily FWI with wintering DC 

# This exercise demonstrates how to calculate daily FWI System variables given a chronical two years
# daily fire weather observations from one weather station. In the example, we showed first how to 
# decide fire season start and end dates with fireSeason, we then made overwintering DC adjustment
# with wDC for the second fire season, and eventually calculated the daily FWI System variables over
# two fire seasons with fwi.  All these steps were packed up into an example user's function, which 
# could be modified by various user groups. Note: the data used in this example is also the test
# data for wDC.
library(cffdrs)

#Example of a customised function to calculate fwi and 
#overwinter DC. This could be further modified by 
#users with various needs.
fwi_fs_wDC <- function(input){
  all.fwi <- NULL
  curYr.fwi <- NULL
  #Create date variable
  input$date <- as.Date(as.POSIXlt(paste(input$yr, "-", input$mon, "-", input$day,sep="")))
  
  #use default fire season start and end temperature thresholds
  fs <- fireSeason(input)
  #Fire season dates, ordered chronologically
  fs <- with(fs,fs[order(yr,mon,day),])
  #Create same Date format as weather dataset for comparison
  fs$date <- as.Date(as.POSIXlt(paste(fs$yr,"-",fs$mon,"-",fs$day,sep="")))

  theyears <- unique(fs$yr)
  
  for(curYr.row in 1:length(theyears)){
    curYr <- theyears[curYr.row]
    curYr.d <- fs[fs$yr==curYr,]
    curYr.init <- data.frame(ffmc=80,dmc=10,dc=16) #set an initial startup values
    
    #if there is more than one year of data, accumulate precipitation, then calculate overwinterDC
    #and continue
    if(curYr.row > 1){
      #calculate the overwinter period
      #end of last year's fire season
      curYr.owd <- curYr.fsd[nrow(curYr.fsd),]
      #rbind with beginning of current year's fire season
      curYr.owd <- rbind(curYr.owd, curYr.d[1,])
      
      #accumulate precipitation for the period between end of last and start of current
      curYr.owdata <- sum(input[(input$date>curYr.owd[1,"date"] & 
                          input$date < curYr.owd[2,"date"]),]$prec)
      owDC <- wDC(DCf=tail(curYr.fwi$DC,n=1),rw=curYr.owdata) #calculate overwinter DC value
      curYr.init <- data.frame(ffmc=80,dmc=10,dc=owDC) #Initialize moisture codes
    }    
    
    curYr.fsd <- curYr.d[c(1,nrow(curYr.d)),]#get first and last dates of this year
    #match input data to those dates for fire season data
    curYr.fsdata <- input[input$yr == curYr & input$date >= curYr.fsd[1,"date"] & 
                          input$date <= curYr.fsd[2,"date"],]
    
    #run fwi on fireseason data
    curYr.fwi <- fwi(curYr.fsdata,init=curYr.init)
    #force column names to be uppercase for consistency
    names(curYr.fwi) <- toupper(names(curYr.fwi))
    all.fwi <- rbind(all.fwi,curYr.fwi)
  }
  all.fwi
}

##Usage of the custom function
# Load the test dataset, which is also the test data for wDC:
data("test_wDC")
#select 1 weather station
localWX_1 <- test_wDC[test_wDC$id==1,]
#run function with the data and fire season values
fwi_withFSwDC <- fwi_fs_wDC(localWX_1)
#Check the resulting fwi indices, calculated with a fire season start and end date, and using 
#overwintered DC
fwi_withFSwDC
}