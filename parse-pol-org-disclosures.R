library( dplyr )
library( knitr )
library( stringr )


fileName <- "HMDataFile.txt"
con <- file(fileName,open="r")
line <- readLines(con)
close(con)

f1 <- substr( line, 1, 1 )
f2 <- substr( line, 2, 2 )

head( line[   f2 == "|" ], 25 )
head( line[ ! f2 == "|" ], 25 )

# which( line == "questions, hold candidates accountable, elect" )
# line[ 21765:21776 ]

#  [4] "D|9627494|109594|IBEW 481 Legislative Campaign Acct|273917449|Steve Menser|Chairman|1828 N Meridian St|Suite 205|Indianapolis|IN|46202||"                                                                                                                                                                                                                                                                                                                                                                                                                                            
#  [5] "1|8871|9627554|0|1|1|454540511|Higher Heights Political Fund|100 Church Street|S820|New York|NY|10007||no@email|20120215|Lora Haggard|29 Briarwood Drive||Ringgold|GA|30736||Hasoni Pratt|100 Church Street|S820|New York|NY|10007||100 Church Street|S820|New York|NY|10007||0||0|The purpose of the organization shall be to influence and"                                                                                                                                                                                                                                        
#  [6] "impact elections by mobilizing Black women to raise"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
#  [7] "questions, hold candidates accountable, elect"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
#  [8] "more Black women to public office, and support"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
#  [9] "candidates committed to advance policies"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
# [10] "that affect Black women.|20140711|2014-07-11 23:31:50|1|1"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
# [11] "D|9627554|109602|Higher Heights Political Fund|454540511|Hasoni Pratts|Treasurer|100 Church Street|S820|New York|NY|10007||"                                                                                                                                                                                                                                                                                                                                                                                                                                                         
# [12] "1|8871|9627597|0|1|0|464431052|iVote Fund|722 12th Street NW|Third Floor|Washington|DC|20005||no@email|20140106|Ellen Kurz|722 12th Street NW|Third Floor|Washington|DC|20005||Ellen Kurz|722 12th Street NW|Third Floor|Washington|DC|20005||722 12th Street NW|Third Floor|Washington|DC|20005||0||0|To educate and active the general public regarding the importance of voting and the role of Secretaries of State in the voting process and to make independent expenditures in support of or opposition to candidates for Secretary of State|20140711|2014-07-14 01:02:55|0|0"

### FIX VALID CASES WITH MISSING FIRST LETTER

length(line)
line[ f1 == "|" ] <- paste0( " ", line[ f1 == "|" ] )
length(line)

f1 <- substr( line, 1, 1 )
f2 <- substr( line, 2, 2 )

valid.f <- f1[ f2 == "|" ]

unique( valid.f )
# [1] "H" "1" "R" "D" "E" "." " " "2" "A" "B" "F"


valid.f[ valid.f == "" ]  <- "empty"
valid.f[ valid.f == " " ] <- "space"

table(valid.f) %>% 
  sort( decreasing=T ) %>% 
  as.data.frame() 

table(valid.f) %>% 
  sort( decreasing=T ) %>% 
  as.data.frame() %>% 
  kable()


line.a <- line[ f1 == "A" & f2 == "|" ]
head( line.a )

list.a <- 
  line.a %>% 
  strsplit( "\\|" )

sapply( list.a, length ) %>% table()
#     13     15     17 
#      7     14 214880

list.length <- 
  sapply( list.a, length )

check.these <- list.length != 17
list.a[ check.these ]

which( list.length != 17 )
line.a[ 69284 ]

# check for this case in the full file:
#
# grep( "A\\|9591920\\|1810036", line, value=F )  # search for problem line (using first part of string only)

# line[ 161973:161976 ]  # gather context 
#
# [1] "A|9591920|1810035|Hospital and Healthsystem Assoc  of PA Political Action Comm HAPAC|232125904|Mr. Thomas V. Whalen Jr.|609K Springhouse Road||Allentown|PA|18104|4692|Lehigh Valley Hospital|200|NA|200|20091019|"
# [2] "A|9591920|1810036|Hospital and Healthsystem Assoc  of PA Political Action Comm HAPAC|232125904|Dr. Elliot J. Sussman MD|PO Box 689||Allentown|PA|18105|1556|Lehigh Valley Hospital & Health"                       
# [3] "            Network, Inc.|500|President & CEO|775|20091019|"                                                                                                                                                       
# [4] "A|9591920|1810037|Hospital and Healthsystem Assoc  of PA Political Action Comm HAPAC|232125904|Michael C Mullane|14 Hamlet Hill Road||Baltimore|MD|21210|1501|Temple University Hospital|200|Sr. VP|200|20091019|" 

# THESE NEED TO BE FIXED MANUALLY:
#  MUST HAVE HAD A PIPE OR SPECIAL CHARACTER?
# "Lehigh Valley Hospital & Health Network, Inc."  

these.ok <- list.length == 17
line.a.ok <- line.a[ these.ok ]

df <-
  line.a.ok %>% 
  strsplit( "\\|" ) %>%
  do.call( rbind, . ) %>%
  data.frame()

varnames <- 
  c("TYPE", "FORM_ID", "SCHED_A_ID", "ORG_NAME", 
    "EIN", "CONT_NAME", "CONT_ADDRESS_1", "CONT_ADDRESS_2", 
    "CONT_CITY", "CONT_STATE", "CONT_ZIP", 
    "CONT_ZIP_EXT", "CONT_EMPLOYER", "CONT_AMOUNT", 
    "CONT_OCCUPATION", "CONT_AMOUNT_YTD", "CONT_DATE" )

names(df) <- varnames
head( df )
