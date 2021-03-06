#' @export
#' @title Function which converts category option combos from identifier to another 
#' 
#' @description remapCategoryOptionCombos should be supplied a vector of category option combos (names,codes,uids or shortnames)
#' It will return a vector of another class as specified with the mode_out paramater
#' 
#'
#' @param cocs_in A vector of category option combinations
#' @param mode_in Should be one of code, name,shortName or id. This is the class we are mapping from.
#' @param mode_out Should be one of code,name,shortName or id. This is the class we are mapping to..
#' @return Returns a vector of category option combos of the mode_out type.
#' @note
#' remapCategoryOptionCombos(foo,"https://www.datim.org","admin","district","code","name")
#' will remap categoryOptionCombos specified as codes to their corresponding names.

remapCategoryOptionCombos<-function(cocs_in,mode_in,mode_out) {
  
  valid_modes <- c("code","name","id","shortName") 
  is_valid_mode_in <- mode_in %in% valid_modes
  is_valid_mode_out <- mode_out %in% valid_modes
  is_ambiguous_mode <- ( mode_in %in%  c("name","shortName") ) &  ( mode_out %in% c("code","id")) 
  
  is_valid_mode <- is_valid_mode_in & is_valid_mode_out
  if ( !is_valid_mode  )  { stop("Not a valid mode. Must be one of code,name,shortName or id") }
  
  if (is_ambiguous_mode) { stop("Ambiguous mapping mode detected. Names cannot be reliably mapped to unique codes/ids.")}
  
  cocs<-getCategoryOptionCombosMap()
  cmd<-paste("plyr::mapvalues(cocs_in,cocs$",mode_in,",cocs$",mode_out,",warn_missing = FALSE)")
  as.character(eval(parse(text=cmd))) }
