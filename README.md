# irs-527-political-action-committee-disclosures

R scripts for accessing Form 8871 and Form 8872 data on 527 Political Action Committees.

* [FORM 8871](form2/f8871-form-2000.pdf)
* [FORM 8871 Instructions](forms/i8871-instructions-2011.pdf)
* [FORM 8872](forms/f8872-form-current.pdf)
* [FORM 8872 Instructions](forms/f8872-instructions-current.pdf)


## Overview of Filing Requirements

https://www.irs.gov/charities-non-profits/political-organizations/political-organization-filing-and-disclosure

## Download POFD Data (Political Organization Filing Disclosures)

The links above connect to the online database of public filings by Section 527 political organizations. It contains all electronic filings made by 527 organizations. Paper filings go back to January 2012.

https://forms.irs.gov/app/pod/dataDownload/dataDownload

This file is updated every Sunday at 1:00AM.

Download links:

* [DATA LAYOUT FILE](https://forms.irs.gov/app/pod/dataDownload/dataLayout)
* [FULL DATABASE ~ 1.9 gigs unzipped](https://forms.irs.gov/app/pod/dataDownload/fullData)

OR separately by org type: 

* [SUBSET ORGS A-G ~ 1.47 gig](https://forms.irs.gov/app/pod/dataDownload/dataAG)
* [SUBSET ORGS H-M ~ 0.67 gig](https://forms.irs.gov/app/pod/dataDownload/dataHM)
* [SUBSET ORGS N-R ~ 0.22 gig](https://forms.irs.gov/app/pod/dataDownload/dataNR)
* [SUBSET ORGS S-Z ~ 0.13 gig](https://forms.irs.gov/app/pod/dataDownload/dataSZ)


## Example Parsing Script

Demo how to part the ASCII data with R. 

```r
library( dplyr )
library( knitr )
library( stringr )
library( pander )


fileName <- "HMDataFile.txt"
con <- file(fileName,open="r")
line <- readLines(con)
close(con)

f1 <- substr( line, 1, 1 )
f2 <- substr( line, 2, 2 )

head( line[   f2 == "|" ], 25 )
head( line[ ! f2 == "|" ], 25 )

# CHECK PROBLEM LINES
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
```

It appears as if the organization on line 5 may have included pipes or some other special character in it's mission statement, and the IRS did not do validation of that field (check for special characters before ASCII conversion).

These cases need to be fixed by hand (or clever programming). We will ignore them for now. 

```r
### FIX MISSING FIRST LETTER
###   Add a space if line begins with pipe

line[ f1 == "|" ] <- paste0( " ", line[ f1 == "|" ] )
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

```

Types of Forms Available - see **PolOrgsFileLayout.doc** for definitions: 

|valid.f |   Freq|
|:-------|------:|
|A       | 214901|
|B       | 121371|
|D       |  26121|
|1       |  11075|
|2       |   8238|
|R       |   3475|
|E       |   2183|
|space   |      2|
|.       |      1|
|F       |      1|
|H       |      1|

Get Schedule A records: 

```r
line.a <- line[ f1 == "A" & f2 == "|" ]

head( line.a )

list.a <- 
  line.a %>% 
  strsplit( "\\|" )

# should have 17 variables: 

sapply( list.a, length ) %>% table()
#     13     15     17 
#      7     14 214880

list.length <- 
  sapply( list.a, length )

check.these <- list.length != 17
list.a[ check.these ]

which( list.length != 17 )
line.a[ 69284 ]

# check the original entries for context: 

grep( "A\\|9591920\\|1810036", line, value=F ) # first part of problematic case

# line[ 161973:161976 ]
#
# [1] "A|9591920|1810035|Hospital and Healthsystem Assoc  of PA Political Action Comm HAPAC|232125904|Mr. Thomas V. Whalen Jr.|609K Springhouse Road||Allentown|PA|18104|4692|Lehigh Valley Hospital|200|NA|200|20091019|"
# [2] "A|9591920|1810036|Hospital and Healthsystem Assoc  of PA Political Action Comm HAPAC|232125904|Dr. Elliot J. Sussman MD|PO Box 689||Allentown|PA|18105|1556|Lehigh Valley Hospital & Health"                       
# [3] "            Network, Inc.|500|President & CEO|775|20091019|"                                                                                                                                                       
# [4] "A|9591920|1810037|Hospital and Healthsystem Assoc  of PA Political Action Comm HAPAC|232125904|Michael C Mullane|14 Hamlet Hill Road||Baltimore|MD|21210|1501|Temple University Hospital|200|Sr. VP|200|20091019|" 

# RECORD 2 WAS SPLIT ACROSS TWO ROWS - NEEDS MANUAL FIXING
```

Get variable names from the **PolOrgsFileLayout.doc** file by copying the tables into Excel then filtering by lines that are not pipe delimiters.

This is the Schedule A table, for example (FORMTYPE, ORDER, and VARNAME were added): 

|IRS.Field.Name               |Size            |Format       |FORMTYPE | ORDER|VARNAME |
|:----------------------------|:---------------|:------------|:--------|-----:|:-------|
|Record Type                  |1               |Alphanumeric |A        |     1|YES     |
|Pipe Delimiter               |1               |Character    |A        |     2|NO      |
|Form ID Number               |Up to 38 digits |Numeric      |A        |     3|YES     |
|Pipe Delimiter               |1               |Character    |A        |     4|NO      |
|SCHED A ID                   |Up to 38 digits |Numeric      |A        |     5|YES     |
|Pipe Delimiter               |1               |Character    |A        |     6|NO      |
|ORG NAME                     |70              |AlphaNumeric |A        |     7|YES     |
|Pipe Delimiter               |1               |Character    |A        |     8|NO      |
|EIN                          |9               |AlphaNumeric |A        |     9|YES     |
|Pipe Delimiter               |1               |Character    |A        |    10|NO      |
|CONTRIBUTOR NAME             |50              |AlphaNumeric |A        |    11|YES     |
|Pipe Delimiter               |1               |Character    |A        |    12|NO      |
|CONTRIBUTOR ADDRESS 1        |50              |AlphaNumeric |A        |    13|YES     |
|Pipe Delimiter               |1               |Character    |A        |    14|NO      |
|CONTRIBUTOR ADDRESS 2        |50              |AlphaNumeric |A        |    15|YES     |
|Pipe Delimiter               |1               |Character    |A        |    16|NO      |
|CONTRIBUTOR ADDRESS CITY     |50              |AlphaNumeric |A        |    17|YES     |
|Pipe Delimiter               |1               |Character    |A        |    18|NO      |
|CONTRIBUTOR ADDRESS STATE    |2               |AlphaNumeric |A        |    19|YES     |
|Pipe Delimiter               |1               |Character    |A        |    20|NO      |
|CONTRIBUTOR ADDRESS ZIP CODE |5               |AlphaNumeric |A        |    21|YES     |
|Pipe Delimiter               |1               |Character    |A        |    22|NO      |
|CONTRIBUTOR ADDRESS ZIP EXT  |4               |AlphaNumeric |A        |    23|YES     |
|Pipe Delimiter               |1               |Character    |A        |    24|NO      |
|CONTRIBUTOR EMPLOYER         |70              |AlphaNumeric |A        |    25|YES     |
|Pipe Delimiter               |1               |Character    |A        |    26|NO      |
|CONTRIBUTION AMOUNT          |17              |AlphaNumeric |A        |    27|YES     |
|Pipe Delimiter               |1               |Character    |A        |    28|NO      |
|CONTRIBUTOR OCCUPATION       |70              |AlphaNumeric |A        |    29|YES     |
|Pipe Delimiter               |1               |Character    |A        |    30|NO      |
|AGG CONTRIBUTION YTD         |17              |AlphaNumeric |A        |    31|YES     |
|Pipe Delimiter               |1               |Character    |A        |    32|NO      |
|CONTRIBUTION DATE            |8               |AlphaNumeric |A        |    33|YES     |
|Pipe Delimiter               |1               |Character    |A        |    34|NO      |

Variable names shortened: 

```
varnames <- 
  c("TYPE", "FORM_ID", "SCHED_A_ID", "ORG_NAME", 
    "EIN", "CONT_NAME", "CONT_ADDRESS_1", "CONT_ADDRESS_2", 
    "CONT_CITY", "CONT_STATE", "CONT_ZIP", 
    "CONT_ZIP_EXT", "CONT_EMPLOYER", "CONT_AMOUNT", 
    "CONT_OCCUPATION", "CONT_AMOUNT_YTD", "CONT_DATE" )
```

Then create the table with all of the Schedule A lines that are not corrupted. 

```r
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
head( df ) %>% pander( style="rmarkdown" )
```

| TYPE | FORM_ID | SCHED_A_ID |
|:----:|:-------:|:----------:|
|  A   | 9555268 |   38296    |
|  A   | 9555268 |   38297    |
|  A   | 9555268 |   38298    |
|  A   | 9555268 |   38299    |
|  A   | 9555268 |   38300    |
|  A   | 9555268 |   38301    |

Table: Table continues below

 

|                           ORG_NAME                           |    EIN    |
|:------------------------------------------------------------:|:---------:|
| HAWAII STATE TEACHERS ASSOCIATION POLITICAL ACTION COMMITTEE | 521073928 |
| HAWAII STATE TEACHERS ASSOCIATION POLITICAL ACTION COMMITTEE | 521073928 |
| HAWAII STATE TEACHERS ASSOCIATION POLITICAL ACTION COMMITTEE | 521073928 |
| HAWAII STATE TEACHERS ASSOCIATION POLITICAL ACTION COMMITTEE | 521073928 |
| HAWAII STATE TEACHERS ASSOCIATION POLITICAL ACTION COMMITTEE | 521073928 |
| HAWAII STATE TEACHERS ASSOCIATION POLITICAL ACTION COMMITTEE | 521073928 |

Table: Table continues below

 

|             CONT_NAME             |     CONT_ADDRESS_1     | CONT_ADDRESS_2 |
|:---------------------------------:|:----------------------:|:--------------:|
|  National Education Association   |  1201 16th Street, NW  |                |
| Hawaii State Teachers Association | 1200 ALA KAPUNA STREET |                |
| Hawaii State Teachers Association | 1200 ALA KAPUNA STREET |                |
| Hawaii State Teachers Association | 1200 ALA KAPUNA STREET |                |
| Hawaii State Teachers Association | 1200 ALA KAPUNA STREET |                |
| Hawaii State Teachers Association | 1200 ALA KAPUNA STREET |                |

Table: Table continues below

 

| CONT_CITY  | CONT_STATE | CONT_ZIP | CONT_ZIP_EXT | CONT_EMPLOYER |
|:----------:|:----------:|:--------:|:------------:|:-------------:|
| Washington |     DC     |  20036   |     3290     |      n/a      |
|  HONOLULU  |     HI     |  96819   |              |      n/a      |
|  HONOLULU  |     HI     |  96819   |              |      n/a      |
|  HONOLULU  |     HI     |  96819   |              |      n/a      |
|  HONOLULU  |     HI     |  96819   |              |      n/a      |
|  HONOLULU  |     HI     |  96819   |              |      n/a      |

Table: Table continues below

 

| CONT_AMOUNT | CONT_OCCUPATION | CONT_AMOUNT_YTD | CONT_DATE |
|:-----------:|:---------------:|:---------------:|:---------:|
|    5000     |       n/a       |      5000       | 20030214  |
|    15083    |       n/a       |      92298      | 20030630  |
|    15301    |       n/a       |      77215      | 20030531  |
|    15291    |       n/a       |      61914      | 20030430  |
|    15320    |       n/a       |      46623      | 20030331  |
|    15289    |       n/a       |      31303      | 20030228  |


