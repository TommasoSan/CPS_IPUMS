cls 
/*
clear all
program drop _all
*/
set more off

global directory = ""

cd "$directory/Selection_01"

capture: log close main_01
log using "main_01", name("main_01") text replace 


use "dataset_1.dta", clear

********************************************************************************

* Tommaso Santini

********************************************************************************

********************************************************************************
/*
This script gets the raw data, analyzes the errors, and performs the trimming
strategy. 
*/
********************************************************************************


keep cpsid cpsidp year month age sex race marst ind1950 relate

sort cpsidp year month
********************************************************************************

*** check whether CPSIDP is correct:

** check with age (one year tolerance)
gen check_age_tol=0
replace  check_age_tol=1 if cpsidp[_n]==cpsidp[_n-1]   &  age[_n] != age[_n-1]   &   age[_n] != age[_n-1]+1   &   age[_n] != age[_n-1]+2

by cpsidp: egen check_1_age_tol = total(check_age_tol)

gen  check_2_age_tol=0
replace check_2_age_tol=1 if check_1_age_tol != 0  // 6% 



** check with age (zero tolerance)
gen check_age=0
replace check_age=1 if cpsidp[_n]==cpsidp[_n-1]   &  age[_n] != age[_n-1]   &   age[_n] != age[_n-1]+1  

by cpsidp: egen check_1_age = total(check_age)

gen check_2_age=0
replace check_2_age=1 if check_1_age != 0  //  7%


** check with sex:
gen check_sex=0
replace check_sex=1 if cpsidp[_n]==cpsidp[_n-1] & sex[_n] != sex[_n-1] 

by cpsidp: egen check_1_sex = total(check_sex)

gen check_2_sex=0 //
replace check_2_sex=1 if check_1_sex != 0  // 1%


** check with race:
gen check_race=0
replace check_race=1 if cpsidp[_n]==cpsidp[_n-1] &  race[_n] != race[_n-1] 

by cpsidp: egen check_1_race = total(check_race)

gen check_2_race=0
replace check_2_race=1 if check_1_race != 0  // 1%


** check with marital status (just for double check)
gen check_mar=0
replace check_mar=1 if cpsidp[_n]==cpsidp[_n-1] &  marst[_n] != marst[_n-1] 

by cpsidp: egen check_1_mar = total(check_mar)

gen check_2_mar=0
replace check_2_mar=1 if check_1_mar != 0 

** check with industry (just for double check)
gen check_ind=0
replace check_ind=1 if cpsidp[_n]==cpsidp[_n-1] &  ind1950[_n] != ind1950[_n-1] 

by cpsidp: egen check_1_ind = total(check_ind)

gen check_2_ind=0
replace check_2_ind=1 if check_1_ind != 0 


** check with positon in th hh (just for double check)
gen check_hh=0
replace check_hh=1 if cpsidp[_n]==cpsidp[_n-1] &  relate[_n] != relate[_n-1] 

by cpsidp: egen check_1_hh = total(check_hh)

gen check_2_hh=0
replace check_2_hh=1 if check_1_hh != 0 



********************************************************************************


*** Trimming strategy


** Keep only between 18 and 65
keep if age >= 18 & age <= 65 


** I also drop the problematic months. Not possible to link observations. 
drop if year == 1995 & ( month == 5 | month == 6 |month == 7 |month == 8 |month == 9 ) 
drop if year == 1994 & month ==1   


** Drop errors
drop if check_2_age_tol==1  &  check_2_race==1
drop if check_2_age_tol==1  &  check_2_sex==1
drop if check_2_age_tol==1  &  check_2_mar==1 
drop if check_2_age_tol==1  &  check_2_hh==1 
* so I keep 258,513 that jump more than two years of age but these other variables are consistent.


drop if check_2_age==1 & check_2_race==1  // 9186 deleted 
drop if check_2_age==1 & check_2_sex==1   // 10979 deleted
drop if check_2_race==1 & check_2_sex==1  // 7173 deleted
drop if check_2_age_tol==1 & check_2_ind==1 //482,382 deleted

drop check_age_tol check_1_age_tol check_2_age_tol check_age check_1_age check_2_age check_sex check_1_sex check_2_sex check_race check_1_race check_2_race check_mar check_1_mar check_2_mar check_ind check_1_ind check_2_ind check_hh check_1_hh check_2_hh

********************************************************************************

** Merge with the raw dataset

merge 1:1 cpsid cpsidp year month using "Dataset_1"
drop if _merge !=3
drop _merge


********************************************************************************

cd "$directory/Selection_02"
save "Dataset_2.dta", replace


cd "$directory/Selection_01"
log close main_01
