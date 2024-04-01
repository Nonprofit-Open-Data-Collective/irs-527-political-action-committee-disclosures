## file.name: name of input text file
##   or a valid URL with raw POFD text.
##   Demo file URL: 
##   https://github.com/Nonprofit-Open-Data-Collective/irs-527-political-action-committee-disclosures/raw/main/HMDataFile.txt

## x: pre-loaded text vector
##
##     file.name="HMDataFile.txt"
##     con <- file(file.name,open="r")
##     x <- readLines(con)
##     close(con)

## form.type: A, B, D, R, E, 1, 2
## 
## | FORM   |   Freq|
## |:-------|------:|
## | A      | 214901|
## | B      | 121371|
## | D      |  26121|
## | 1      |  11075|
## | 2      |   8238|
## | R      |   3475|
## | E      |   2183|



## USAGE 

# d <- get_form_x( file.name="HMDataFile.txt", form.type="A" )

# con <- file( "HMDataFile.txt", open="r" )
# x <- readLines(con)
# close(con)
# 
# d <- get_form_x( x=line, form.type="A" )

# SAVES TO FILE - NO RETURN VALUES
# build_all( "FullDataFile.txt" )




library( dplyr )
library( knitr )
library( stringr )

read_textfile <- function(x)
{
  con <- file( x, open="r" )
  txt <- readLines(con)
  close(con)
  return( txt )
}

build_all <- function( file.name=NULL )
{

  x <- read_textfile( file.name )

  yyyy.mm   <- format( Sys.Date(), "%Y-%m" )
  
  df.2 <- get_form_x( x=x, form.type="2" )
  filename <- paste0( yyyy.mm, "-", "POL-ORGS-FM-8872.csv" )
  write.csv( df.2, filename, row.names=F )
  
  df.1 <- get_form_x( x=x, form.type="1" )
  filename <- paste0( yyyy.mm, "-", "POL-ORGS-FM-8871.csv" )
  write.csv( df.1, filename, row.names=F )
  
  df.h <- get_form_x( x=x, form.type="H" )
  filename <- paste0( yyyy.mm, "-", "POL-ORGS-HEADER.csv" )
  write.csv( df.h, filename, row.names=F )
  
  df.f <- get_form_x( x=x, form.type="F" )
  filename <- paste0( yyyy.mm, "-", "POL-ORGS-FOOTER.csv" )
  write.csv( df.f, filename, row.names=F )
  
  df.a <- get_form_x( x=x, form.type="A" )
  filename <- paste0( yyyy.mm, "-", "POL-ORGS-SCHED-A.csv" )
  write.csv( df.a, filename, row.names=F )
  
  df.b <- get_form_x( x=x, form.type="B" )
  filename <- paste0( yyyy.mm, "-", "POL-ORGS-SCHED-B.csv" )
  write.csv( df.b, filename, row.names=F )
  
  df.d <- get_form_x( x=x, form.type="D" )
  filename <- paste0( yyyy.mm, "-", "POL-ORGS-SCHED-D.csv" )
  write.csv( df.d, filename, row.names=F )
  
  df.e <- get_form_x( x=x, form.type="E" )
  filename <- paste0( yyyy.mm, "-", "POL-ORGS-SCHED-E.csv" )
  write.csv( df.e, filename, row.names=F )
  
  df.r <- get_form_x( x=x, form.type="R" )
  filename <- paste0( yyyy.mm, "-", "POL-ORGS-SCHED-R.csv" )
  write.csv( df.r, filename, row.names=F )

  f1 <- substr( x, 1, 1 )
  f2 <- substr( x, 2, 2 )
  these <- grepl( "^[12ABDERHF]\\|", x )
  problems <- which( ! these ) # add context
  problems <- c( problems, (problems+1), (problems-1) ) %>% unique() %>% sort()
  fix.these <- x[ problems ]
  filename <- paste0( yyyy.mm, "-", "POL-ORGS-NEED-FIXING.txt" )
  writeLines( fix.these, filename )

  return(NULL)
}






get_form_x <- function( file.name=NULL, x=NULL, form.type )
{
  
  if( is.null(x) )
  {
    x <- read_textfile( file.name )
  }
  


  ## FORM 8871

  varnames.1 <- 
    c("RECORD_TYPE", "FORM_TYPE", "FORM_ID_NUMBER", "INITIAL_REPORT_INDICATOR", 
      "AMENDED_REPORT_INDICATOR", "FINAL_REPORT_INDICATOR", "EIN", 
      "ORGANIZATION_NAME", "MAILING_ADDRESS_1", "MAILING_ADDRESS_2", 
      "MAILING_ADDRESS_CITY", "MAILING_ADDRESS_STATE", "MAILING_ADDRESS_ZIP_CODE", 
      "MAILING_ADDRESS_ZIP_EXT", "E_MAIL_ADDRESS", "ESTABLISHED_DATE", 
      "CUSTODIAN_NAME", "CUSTODIAN_ADDRESS_1", "CUSTODIAN_ADDRESS_2", 
      "CUSTODIAN_ADDRESS_CITY", "CUSTODIAN_ADDRESS_STATE", "CUSTODIAN_ADDRESS_ZIP_CODE", 
      "CUSTODIAN_ADDRESS_ZIP_EXT", "CONTACT_PERSON_NAME", "CONTACT_ADDRESS_1", 
      "CONTACT_ADDRESS_2", "CONTACT_ADDRESS_CITY", "CONTACT_ADDRESS_STATE", 
      "CONTACT_ADDRESS_ZIP_CODE", "CONTACT_ADDRESS_ZIP_EXT", "BUSINESS_ADDRESS_1", 
      "BUSINESS_ADDRESS_2", "BUSINESS_ADDRESS_CITY", "BUSINESS_ADDRESS_STATE", 
      "BUSINESS_ADDRESS_ZIP_CODE", "BUSINESS_ADDRESS_ZIP_EXT", "EXEMPT_8872_INDICATOR", 
      "EXEMPT_STATE", "EXEMPT_990_INDICATOR", "PURPOSE", "MATERIAL_CHANGE_DATE", 
      "INSERT_DATETIME", "RELATED_ENTITY_BYPASS", "EAIN_BYPASS")

  ## FORM 8872
  varnames.2 <-
    c("RECORD_TYPE", "FORM_TYPE", "FORM_ID_NUMBER", "PERIOD_BEGIN_DATE", 
      "PERIOD_END_DATE", "INITIAL_REPORT_INDICATOR", "AMENDED_REPORT_INDICATOR", 
      "FINAL_REPORT_INDICATOR", "CHANGE_OF_ADDRESS_INDICATOR", "ORGANIZATION_NAME", 
      "EIN", "MAILING_ADDRESS_1", "MAILING_ADDRESS_2", "MAILING_ADDRESS_CITY", 
      "MAILING_ADDRESS_STATE", "MAILING_ADDRESS_ZIP_CODE", "MAILING_ADDRESS_ZIP_EXT", 
      "E_MAIL_ADDRESS", "ORG_FORMATION_DATE", "CUSTODIAN_NAME", "CUSTODIAN_ADDRESS_1", 
      "CUSTODIAN_ADDRESS_2", "CUSTODIAN_ADDRESS_CITY", "CUSTODIAN_ADDRESS_STATE", 
      "CUSTODIAN_ADDRESS_ZIP_CODE", "CUSTODIAN_ADDRESS_ZIP_EXT", "CONTACT_PERSON_NAME", 
      "CONTACT_ADDRESS_1", "CONTACT_ADDRESS_2", "CONTACT_ADDRESS_CITY", 
      "CONTACT_ADDRESS_STATE", "CONTACT_ADDRESS_ZIP_CODE", "CONTACT_ADDRESS_ZIP_EXT", 
      "BUSINESS_ADDRESS_1", "BUSINESS_ADDRESS_2", "BUSINESS_ADDRESS_CITY", 
      "BUSINESS_ADDRESS_STATE", "BUSINESS_ADDRESS_ZIP_CODE", "BUSINESS_ADDRESS_ZIP_EXT", 
      "QTR_INDICATOR", "MONTHLY_RPT_MONTH", "PRE_ELECT_TYPE", "PRE_OR_POST_ELECT_DATE", 
      "PRE_OR_POST_ELECT_STATE", "SCHED_A_IND", "TOTAL_SCHED_A", "SCHED_B_IND", 
      "TOTAL_SCHED_B", "INSERT_DATETIME")
  
  ## "FOOTER

  varnames.f <-
    c("RECORD_TYPE_CODE", "TRANSMISSION_DATE", "TRANSMISSION_TIME", 
      "RECORD_COUNT")

  ## HEADER

  varnames.h <-
    c("RECORD_TYPE_CODE", "TRANSMISSION_DATE", "TRANSMISSION_TIME", 
      "FILE_ID_MODIFIER")

  ## SCHED-A

  varnames.a <- 
    c("TYPE", "FORM_ID", "SCHED_A_ID", "ORG_NAME", 
      "EIN", "CONT_NAME", "CONT_ADDRESS_1", "CONT_ADDRESS_2", 
      "CONT_CITY", "CONT_STATE", "CONT_ZIP", 
      "CONT_ZIP_EXT", "CONT_EMPLOYER", "CONT_AMOUNT", 
      "CONT_OCCUPATION", "CONT_AMOUNT_YTD", "CONT_DATE" )

  ## SCHED-B

  varnames.b <-
    c("RECORD_TYPE", "FORM_ID_NUMBER", "SCHED_B_ID", "ORG_NAME", 
      "EIN", "RECIEPIENT_NAME", "RECIEPIENT_ADDRESS_1", "RECIEPIENT_ADDRESS_2", 
      "RECIEPIENT_ADDRESS_CITY", "RECIEPIENT_ADDRESS_ST", "RECIEPIENT_ADDRESS_ZIP_CODE", 
      "RECIEPIENT_ADDRESS_ZIP_EXT", "RECIEPIENT_EMPLOYER", "EXPENDITURE_AMOUNT", 
      "RECIPIENT_OCCUPATION", "EXPENDITURE_DATE", "EXPENDITURE_PURPOSE" )

  ## SCHED-D

  varnames.d <-
    c("RECORD_TYPE", "FORM_ID_NUMBER", "DIRECTOR_ID", "ORG_NAME", 
      "EIN", "ENTITY_NAME", "ENTITY_TITLE", "ENTITY_ADDRESS_1", "ENTITY_ADDRESS_2", 
      "ENTITY_ADDRESS_CITY", "ENTITY_ADDRESS_ST", "ENTITY_ADDRESS_ZIP_CODE", 
      "ENTITY_ADDRESS_ZIP_CODE_EXT")

  ## SCHED-E

  varnames.e <-
    c("RECORD_TYPE", "FORM_ID_NUMBER", "EAIN_ID", "ELECTION_AUTHORITY_ID_NUMBER", 
      "STATE_ISSUED")


  ## SCHED-R

  varnames.r <-
    c("RECORD_TYPE", "FORM_ID_NUMBER", "ENTITY_ID", "ORG_NAME", "EIN", 
      "ENTITY_NAME", "ENTITY_RELATIONSHIP", "ENTITY_ADDRESS_1", "ENTITY_ADDRESS_2", 
      "ENTITY_ADDRESS_CITY", "ENTITY_ADDRESS_ST", "ENTITY_ADDRESS_ZIP_CODE", 
      "ENTITY_ADDRESS_ZIP_EXT")  


  f1 <- substr( x, 1, 1 )
  f2 <- substr( x, 2, 2 )
  
  ### FIX MISSING FIRST LETTER
  
  x[ f1 == "|" ] <- paste0( " ", x[ f1 == "|" ] )
  f1 <- substr( x, 1, 1 )
  f2 <- substr( x, 2, 2 )
  
  line.x <- x[ f1 == form.type & f2 == "|" ]
  
  list.x <- 
    line.x %>% 
    strsplit( "\\|" )
  
  list.length <- 
    sapply( list.x, length )
  
  
  vn <- paste0( "varnames.", tolower( form.type ) )
  n.col <- length( get(vn) )
  
  not.ok <- list.length != n.col
  cat( paste0( sum(not.ok), " problematic records from form ", form.type, " dropped.\n" ) )
  
  these.ok <- list.length == n.col
  line.x.ok <- line.x[ these.ok ]
  
  df <-
    line.x.ok %>% 
    strsplit( "\\|" ) %>%
    do.call( rbind, . ) %>%
    data.frame()
  
  names(df) <- get(vn)
  
  return( df )
  
}





## HELPER FUNCTIONS FOR 
##  VARNAME STANDARDIZATION
##  IN EXCEL 

sanitize_varnames <- function(x)
{
  x <- toupper( x )
  x <- gsub( " ", "_", x )
}

drop_pipes <- function(x)
{
  x <- x[ ! x %in% c("","PIPE_DELIMITER") ]
  return( dput(x) )
}


# x <- readClipboard()
# x <- sanitize_varnames(x)
# x <- drop_pipes(x)
# writeClipboard(x)

