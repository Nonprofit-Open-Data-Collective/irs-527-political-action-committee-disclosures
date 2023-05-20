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

### FIX MISSING FIRST LETTER

length(line)
line[ f1 == "|" ] <- paste0( " ", line[ f1 == "|" ] )
length(line)

f1 <- substr( line, 1, 1 )
f2 <- substr( line, 2, 2 )

valid.f <- f1[ f2 == "|" ]

unique( valid.f )
[1] "H" "1" "R" "D" "E" "." " " "2" "A" "B" "F"


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

xx <- head( line.a )

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

# back to original: 

grep( "A\\|9591920\\|1810036", line, value=F )
line[ 161973:161976 ]

# [1] "A|9591920|1810035|Hospital and Healthsystem Assoc  of PA Political Action Comm HAPAC|232125904|Mr. Thomas V. Whalen Jr.|609K Springhouse Road||Allentown|PA|18104|4692|Lehigh Valley Hospital|200|NA|200|20091019|"
# [2] "A|9591920|1810036|Hospital and Healthsystem Assoc  of PA Political Action Comm HAPAC|232125904|Dr. Elliot J. Sussman MD|PO Box 689||Allentown|PA|18105|1556|Lehigh Valley Hospital & Health"                       
# [3] "            Network, Inc.|500|President & CEO|775|20091019|"                                                                                                                                                       
# [4] "A|9591920|1810037|Hospital and Healthsystem Assoc  of PA Political Action Comm HAPAC|232125904|Michael C Mullane|14 Hamlet Hill Road||Baltimore|MD|21210|1501|Temple University Hospital|200|Sr. VP|200|20091019|" 



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

  TYPE FORM_ID SCHED_A_ID
1    A 9555268      38296
2    A 9555268      38297
3    A 9555268      38298
4    A 9555268      38299
5    A 9555268      38300
6    A 9555268      38301
                                                      ORG_NAME       EIN
1 HAWAII STATE TEACHERS ASSOCIATION POLITICAL ACTION COMMITTEE 521073928
2 HAWAII STATE TEACHERS ASSOCIATION POLITICAL ACTION COMMITTEE 521073928
3 HAWAII STATE TEACHERS ASSOCIATION POLITICAL ACTION COMMITTEE 521073928
4 HAWAII STATE TEACHERS ASSOCIATION POLITICAL ACTION COMMITTEE 521073928
5 HAWAII STATE TEACHERS ASSOCIATION POLITICAL ACTION COMMITTEE 521073928
6 HAWAII STATE TEACHERS ASSOCIATION POLITICAL ACTION COMMITTEE 521073928
                          CONT_NAME         CONT_ADDRESS_1 CONT_ADDRESS_2  CONT_CITY
1    National Education Association   1201 16th Street, NW                Washington
2 Hawaii State Teachers Association 1200 ALA KAPUNA STREET                  HONOLULU
3 Hawaii State Teachers Association 1200 ALA KAPUNA STREET                  HONOLULU
4 Hawaii State Teachers Association 1200 ALA KAPUNA STREET                  HONOLULU
5 Hawaii State Teachers Association 1200 ALA KAPUNA STREET                  HONOLULU
6 Hawaii State Teachers Association 1200 ALA KAPUNA STREET                  HONOLULU
  CONT_STATE CONT_ZIP CONT_ZIP_EXT CONT_EMPLOYER CONT_AMOUNT CONT_OCCUPATION
1         DC    20036         3290           n/a        5000             n/a
2         HI    96819                        n/a       15083             n/a
3         HI    96819                        n/a       15301             n/a
4         HI    96819                        n/a       15291             n/a
5         HI    96819                        n/a       15320             n/a
6         HI    96819                        n/a       15289             n/a
  CONT_AMOUNT_YTD CONT_DATE
1            5000  20030214
2           92298  20030630
3           77215  20030531
4           61914  20030430
5           46623  20030331
6           31303  20030228


------------------------------------------------------------------------
 TYPE   FORM_ID   SCHED_A_ID             ORG_NAME                EIN    
------ --------- ------------ ------------------------------ -----------
  A     9555268     38296         HAWAII STATE TEACHERS       521073928 
                               ASSOCIATION POLITICAL ACTION             
                                        COMMITTEE                       

  A     9555268     38297         HAWAII STATE TEACHERS       521073928 
                               ASSOCIATION POLITICAL ACTION             
                                        COMMITTEE                       

  A     9555268     38298         HAWAII STATE TEACHERS       521073928 
                               ASSOCIATION POLITICAL ACTION             
                                        COMMITTEE                       

  A     9555268     38299         HAWAII STATE TEACHERS       521073928 
                               ASSOCIATION POLITICAL ACTION             
                                        COMMITTEE                       

  A     9555268     38300         HAWAII STATE TEACHERS       521073928 
                               ASSOCIATION POLITICAL ACTION             
                                        COMMITTEE                       

  A     9555268     38301         HAWAII STATE TEACHERS       521073928 
                               ASSOCIATION POLITICAL ACTION             
                                        COMMITTEE                       
------------------------------------------------------------------------

Table: Table continues below

 
--------------------------------------------------------------------------
           CONT_NAME                  CONT_ADDRESS_1       CONT_ADDRESS_2 
-------------------------------- ------------------------ ----------------
 National Education Association    1201 16th Street, NW                   

     Hawaii State Teachers        1200 ALA KAPUNA STREET                  
          Association                                                     

     Hawaii State Teachers        1200 ALA KAPUNA STREET                  
          Association                                                     

     Hawaii State Teachers        1200 ALA KAPUNA STREET                  
          Association                                                     

     Hawaii State Teachers        1200 ALA KAPUNA STREET                  
          Association                                                     

     Hawaii State Teachers        1200 ALA KAPUNA STREET                  
          Association                                                     
--------------------------------------------------------------------------

Table: Table continues below

 
-------------------------------------------------------------------
 CONT_CITY    CONT_STATE   CONT_ZIP   CONT_ZIP_EXT   CONT_EMPLOYER 
------------ ------------ ---------- -------------- ---------------
 Washington       DC        20036         3290            n/a      

  HONOLULU        HI        96819                         n/a      

  HONOLULU        HI        96819                         n/a      

  HONOLULU        HI        96819                         n/a      

  HONOLULU        HI        96819                         n/a      

  HONOLULU        HI        96819                         n/a      
-------------------------------------------------------------------

Table: Table continues below

 
-------------------------------------------------------------
 CONT_AMOUNT   CONT_OCCUPATION   CONT_AMOUNT_YTD   CONT_DATE 
------------- ----------------- ----------------- -----------
    5000             n/a              5000         20030214  

    15083            n/a              92298        20030630  

    15301            n/a              77215        20030531  

    15291            n/a              61914        20030430  

    15320            n/a              46623        20030331  

    15289            n/a              31303        20030228  
-------------------------------------------------------------

