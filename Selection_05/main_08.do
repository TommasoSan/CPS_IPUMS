cls 

set more off

global directory = "/Users/tommaso/Desktop/RAship_Javier/IPUMS"

cd "$directory/Selection_05"

capture: log close main_08
log using "main_08", name("main_08") text replace 



********************************************************************************
*** Selection of sample for the wage study.
********************************************************************************



********************************************************************************
/*
For the analysis of the wage correlation I need both partners'wages, while for 
the regression I just need the partners' wages.
*/
********************************************************************************


use "Partners.dta", clear


** Keep only the variable I need for this computation (maybe change later but now stay with it)

drop  cpsidp_sp eligorg eligorg_sp relate 


** Keep only the married couples who live together
keep if marst==1
drop marst

** Keep only Outgoing Rotation Group 
keep if mish == 4 | mish == 8 

** Armed forces don't report wages, drop them
drop if empstat == 01
* Drop if the partner is in the army
drop if empstat_sp == 01


* Drop if there are no information about the partner; use age as proxy
drop if age_sp == . 


* I get rid of that 13% of employed workers partners whose wage is not reported: paidhour == 0 implies that wages are not reported, both for hour and weekly wage
* This is to be done both for computing correlation and for regression, therefore i do it here.
drop if paidhour_sp == 0 & (empstat_sp == 10 | empstat_sp == 12)  // 13% of the sample until here.



/* Now the employed partners are divided perfectly in those paid by hour 
and those not paid by hour */

* Nicest order so far, generalize
order cpsid cpsidp year month mish age sex race race_broad child_18 hhtenure hwtfinl statefip empstat labforce jtyears durunemp durunemp_pre tran tran1 rearnweek rhourwage earnweek hourwage uhrsworkorg paidhour otpay lfproxy earnwt ind1950 ind1950_broad ind1950_broad_pre occ1950 occ1950_broad occ1950_broad_pre switch switch1 agr_pa educ classwkr wtfinl mish_sp age_sp sex_sp race_sp race_broad_sp child_18_sp hhtenure_sp statefip_sp empstat_sp labforce_sp jtyears_sp durunemp_sp durunemp_pre_sp tran_sp tran1_sp rearnweek_sp rhourwage_sp earnweek_sp hourwage_sp uhrsworkorg_sp paidhour_sp otpay_sp lfproxy_sp earnwt_sp ind1950_sp ind1950_broad_sp ind1950_broad_pre_sp occ1950_sp occ1950_broad_sp occ1950_broad_pre_sp switch_sp switch1_sp agr_pa_sp educ_sp classwkr_sp wtfinl_sp


***************************************************************
save "ORG_couples.dta", replace
* use "ORG_couples.dta", clear
***************************************************************





**** DESCRIPTIVE STATISTICS 

***Hourwage

** There are not topcoded hourwages

** Dummy for not in the universe hourwage
gen dummy = 0
replace dummy = 1 if hourwage_sp == 99.99
label var dummy "NIU hourwage"
label define lab_0 0 "No" 1 "Yes" 
label values dummy lab_0

tab dummy if paidhour_sp == 1
tab dummy if paidhour_sp == 2


/* Hourwage is reported for 99.99% of workers paid by hour. Ideally, to have 
to use this variable would be better. It is more informative indeed. */





*** Earnweek

** Dummy for not in the universe earnweek
gen dummy3 = 0
replace dummy3 = 1 if earnweek_sp == 9999.99
label var dummy3 "NIU earnweek"
label define lab_3 0 "No" 1 "Yes" 
label values dummy3 lab_3


drop if dummy3 == 1 &  (empstat_sp == 10 | empstat_sp == 12 ) // 5 observations


tab dummy3 if empstat_sp == 10 | empstat_sp == 12 // in the sample so created, everybody reports the earnweek.



** Assign a zero wage to those who are unemployed or NILF
replace rhourwage = 0 if empstat != 10 & empstat != 12
replace rhourwage_sp = 0 if empstat_sp != 10 & empstat_sp != 12

replace rearnweek = 0 if empstat != 10 & empstat != 12
replace rearnweek_sp = 0 if empstat_sp != 10 & empstat_sp != 12




cd "$directory/Selection_09"

save "Earner_study.dta", replace


cd "$directory/Selection_05"

log close main_08


