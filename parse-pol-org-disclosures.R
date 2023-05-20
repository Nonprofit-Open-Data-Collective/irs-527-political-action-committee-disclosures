library( dplyr )
library( knitr )
library( stringr )


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

dd <- 
  get_form_x( 
    file.name="HMDataFile.txt",
    form.type="A" )

dd <- 
  get_form_x( 
    x=line,
    form.type="A" )

get_form_x <- function( file.name=NULL, x=NULL, form.type )
{
  
  if( is.null(x) )
  {
    con <- file(file.name,open="r")
    x <- readLines(con)
    close(con)
  }
  
  
  varnames.a <- 
    c("TYPE", "FORM_ID", "SCHED_A_ID", "ORG_NAME", 
      "EIN", "CONT_NAME", "CONT_ADDRESS_1", "CONT_ADDRESS_2", 
      "CONT_CITY", "CONT_STATE", "CONT_ZIP", 
      "CONT_ZIP_EXT", "CONT_EMPLOYER", "CONT_AMOUNT", 
      "CONT_OCCUPATION", "CONT_AMOUNT_YTD", "CONT_DATE" )
  
  
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

