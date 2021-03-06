#' @export
#' @title getDataElementsOrgunits(data,organisationUnit,datasets)
#' 
#' @description Returns a map of lists consisting of data elements and orgunits for a dataset (or datasets) for a given organisationUnit
#' @param organisationUnit Organisation unit. Defaults to user organisation unit if not supplied explicitly.
#' @param datasets Should be a character vector of data set UIDs. Alternatively, if left missing, user will be promted.
#' @return Returns a data frame of "data" which was submitted along for a reason of why the data is considered to be invalid.

getDataElementsOrgunits <- function(organisationUnit = NA,
                                    datasets = NA) {
  if (is.na(organisationUnit)) {
    organisationUnit = getOption("organisationUnit")
  }
  
  allDataSets <- getDataSets()
  
  if ( length(datasets) == 0 | any(is.na(datasets)) ) {
    datasets <- selectDataset()
  }
  
  dataSetValid <- Reduce("&", datasets %in% allDataSets$id)
  
  if (!dataSetValid) {
    stop("Invalid dataset")
  }
  
    for (i in seq_along(datasets)) {
  
      if (i == 1)  { des_ous.all <- list() }
      
      url <-
        paste0(
          getOption("baseurl"),
          "api/",api_version(),"/organisationUnits?fields=id&paging=false&filter=path:like:",
          organisationUnit,
          "&filter=dataSets.id:eq:",
          datasets[i]
        )
      
      sig <- digest::digest(paste0(url), algo = 'md5', serialize = FALSE)
      des_ous <- getCachedObject(sig)
      
      if (is.null(des_ous)) {
        r <- httr::GET(url, httr::timeout(60))
        r <- httr::content(r, "text")
        ous <-
          unique(jsonlite::fromJSON(r, flatten = TRUE)$organisationUnits$id)
        #OUs
        des <-
          unique(getValidDataElements(datasets[i])$dataelementuid)
        des_ous <- list(dataset = datasets[i], list(ous = ous, des = des))
        saveCachedObject(des_ous, sig)
      }
      
      des_ous.all <- rlist::list.append(des_ous.all, des_ous)
    }

  return(des_ous.all) }



#' @export
#' @title checkDataElementOrgunitValidity(data,organisationUnit,datasets)
#' 
#' @description Returns a data frame invalid data elements which exist in the data 
#' but which do not have a valid organistion unit / dataset association. 
#'
#' @param data D2 compliant data frame
#' @param organisationUnit Should be the UID of the organisation unit ancestor, typically the operating unit. 
#' @param datasets Should be a character vector of data set UIDs. Alternatively, if left missing, user will be promted.
#' @param return_violations Return the invalid data if TRUE
#'  @return Returns subset of data which contains invalid data element / organisation unit associations.
#' 

checkDataElementOrgunitValidity<-function(data=NA,organisationUnit=NA,datasets=NA,return_violations=TRUE) {
  
  if (is.na(organisationUnit)) { organisationUnit = getOption("organisationUnit") }
  if ( NROW(data) == 0  ) {stop("Data cannot be missing!")}
  if ( length(datasets) == 0 | any(is.na(datasets)) ) { stop("Please specifiy a list of data sets!") }
  
  des_ous<-getDataElementsOrgunits(organisationUnit,datasets)
  des_ous_map<-plyr::ldply(des_ous,function(x) expand.grid(dataElement=x[[2]]$des,orgUnit=x[[2]]$ous,stringsAsFactors = FALSE))
  data_des_ous_map<-unique(data[,c("dataElement","orgUnit")])
  result_data<-dplyr::anti_join(data,des_ous_map,by=c("dataElement","orgUnit"))
  if (NROW(result_data > 0 )) {
    warning("Invalid data element/orgunit associations were detected!")
    if ( return_violations ) {return(result_data)}
    } else
    {
      return(TRUE)
    }
}