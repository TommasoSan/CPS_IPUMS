cls 

set more off

global directory = "/Users/tommaso/Desktop/RAship_Javier/IPUMS"

cd "$directory/Selection_03"

capture: log close main_04
log using "main_04", name("main_04") text replace 



use "Dataset_3.dta", clear

********************************************************************************

* Tommaso Santini

********************************************************************************

********************************************************************************
**** Build partner connection and creates the couples's labor characteristic variable
********************************************************************************


** I keep only the married couples who live together
keep if marst==1

** Among married individuals, some observations don't report the partner's id. I drop them
drop if cpsidp_sp==.  // 218 deleted


sort cpsidp_sp
order cpsid cpsidp_sp cpsidp


foreach x of var * {   // rename all of the variables as the "spouse variable"
	rename `x' `x'_sp 
}
*


rename cpsid_sp cpsid
rename cpsidp_sp cpsidp
rename cpsidp_sp_sp cpsidp_sp
rename year_sp year  
rename month_sp month  // take it back to the original after the loop


rename cpsidp_sp cpsidp_temp 
rename cpsidp cpsidp_sp_temp

rename cpsidp_temp cpsidp
rename cpsidp_sp_temp cpsidp_sp //  careful: I do this to match the partners with the references: but while the original cpsidp is present and non-missing for every observation, cpsidp_sp is missing for many



save "Partners_tmp.dta", replace
use "Dataset_3.dta", clear

merge 1:1 cpsidp year month using "partners_tmp.dta"

drop if _merge==2  // Two things can happen: we can have that a person is not married and this goes to master only. But we can also have that the person is married, we have the identifier but for that specific month and year the partner is missing and is therefore not present as cpsidp in the dataset_03    
drop _merge

erase "Partners_tmp.dta"
save "Partners_tmp.dta", replace




********************************************************************************
**** Create the couples's labor characteristic variable
********************************************************************************

**** I keep only the variables I need for this computation: 
keep cpsid cpsidp year month sex child_18 relate marst empstat labforce tran cpsidp_sp sex_sp marst_sp empstat_sp labforce_sp mish

** Drop if partner's employment status is missing
drop if empstat_sp==.     // 605,696 deleted

** I now need to define the observation related to the couple. That is, I have to be careful not to count one couple twice, once for each partner, I can just get rid of the female.
drop if sex== 2


*** Create a new variable wich indicates the labor market caracteristic of the couple, according to the definition of Nezih.
gen couple_labor=0

** UE ( first letter: male; second letter: spouse )
replace couple_labor=1 if ( empstat==21 | empstat==22 ) & ( empstat_sp==10 | empstat_sp==12 | empstat_sp==01 )

** EU
replace couple_labor=2 if ( empstat==10 | empstat==12 | empstat==01 ) & ( empstat_sp==21 | empstat_sp==22 )

** EE
replace couple_labor=3 if ( empstat==10 | empstat==12 | empstat==01 ) &  ( empstat_sp==10 | empstat_sp==12 | empstat_sp==01 ) 

** NE
replace couple_labor=4 if labforce==01 &  ( empstat_sp==10 | empstat_sp==12 | empstat_sp==01 ) 

** EN
replace couple_labor=5 if ( empstat==10 | empstat==12 | empstat==01 ) & labforce_sp==01 

** UN
replace couple_labor=6 if ( empstat==21 | empstat==22 ) & labforce_sp==01 

** NU
replace couple_labor=7 if labforce==01 & ( empstat_sp==21 | empstat_sp==22 )

** UU
replace couple_labor=8 if ( empstat==21 | empstat==22 ) &  ( empstat_sp==21 | empstat_sp==22 )

** NN
replace couple_labor=9 if labforce==01 &  labforce_sp==01

** Define the value labels
label define link 1 "UE" 2 "EU" 3 "EE" 4 "NE" 5 "EN" 6 "UN" 7 "NU" 8 "UU" 9 "NN"
label values couple_labor link


save "Partners_tmp_2.dta", replace
use "Partners_tmp.dta", clear


merge 1:1 cpsidp year month using "Partners_tmp_2.dta"
drop _merge


erase "Partners_tmp_2.dta"





cd "$directory/Selection_05"

save "Partners.dta", replace



cd "$directory/Selection_03"

erase "Partners_tmp.dta"

log close main_04



