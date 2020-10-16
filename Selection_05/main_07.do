cls 

set more off

global directory = "/Users/tommaso/Desktop/RAship_Javier/IPUMS"

cd "$directory/Selection_05"

capture: log close main_07
log using "main_07", name("main_07") text replace 


use "Partners.dta", clear

********************************************************************************

* Tommaso Santini

********************************************************************************

********************************************************************************
/*
This script computes the montly average unemployment duration, unconditional, 
and conditional on partner labor status.
*/
********************************************************************************



** Keep only unemployed workers
keep if empstat == 21 | empstat ==22


** Keep variables I need
keep cpsid cpsidp year month durunemp marst wtfinl empstat_sp labforce_sp
order cpsid cpsidp year month marst durunemp empstat_sp labforce_sp wtfinl

** Create broad categories of labor status for the partners
gen empstat_sp_broad = ., before(empstat_sp)
replace empstat_sp_broad = 1 if ( empstat_sp == 01 | empstat_sp == 10 | empstat_sp == 12 )
replace empstat_sp_broad = 2 if ( empstat_sp == 21 | empstat_sp == 22 )
replace empstat_sp_broad = 3 if ( labforce_sp == 1 )

drop empstat_sp labforce_sp

** Define the value labels
label define flows_2 1 "E" 2 "U" 3 "N" 
label values empstat_sp_broad flows_2

** Sort the data 
sort year month empstat_sp_broad

** Compute the mean unconditional
by year month : egen U_avg = wtmean(durunemp), weight(wtfinl) 

** Compute the conditional
by year month empstat_sp_broad : egen U_avg_cond_E = wtmean(durunemp) if empstat_sp_broad == 1, weight(wtfinl) 

by year month empstat_sp_broad : egen U_avg_cond_U = wtmean(durunemp) if empstat_sp_broad == 2, weight(wtfinl) 

by year month empstat_sp_broad : egen U_avg_cond_N = wtmean(durunemp) if empstat_sp_broad == 3, weight(wtfinl) 


drop wtfinl

** Collapse
collapse U_avg U_avg_cond_E U_avg_cond_U U_avg_cond_N, by (year month) 


** Lable variables
label var U_avg "Continuous weeks unemployed. Monthly average"
label var U_avg_cond_E "Partner employed"
label var U_avg_cond_U "Partner unemployed"
label var U_avg_cond_N "Partner Not in the labor force"



** Plots

** Generate the time variable
gen time=ym(year ,month), after(month)

** Plots
graph drop _all

tw line U_avg time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EE) title("Unemployment duration")
graph export "$directory/Selection_08/Unemp_dur.png" , replace

tw line U_avg_cond_E U_avg_cond_U U_avg_cond_N time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EU) title("Unemp. duration, conditional on partner labor status")
graph export "$directory/Selection_08/Unemp_dur_cond.png" , replace


** Manipulate the dataset
drop time

cd "$directory/Selection_08"

save "Duration.dta", replace


cd "$directory/Selection_05"

log close main_07









