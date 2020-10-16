cls 

set more off

global directory = "/Users/tommaso/Desktop/RAship_Javier/IPUMS"

cd "$directory/Selection_09"

capture: log close main_09_w_corr
log using "main_09_w_corr", name("main_09_w_corr") text replace 



use "Earner_study.dta", clear


******************************************************************************************************************************
*** Weekly wage, couple study, correlation
******************************************************************************************************************************



******************************************************************************************************************************
*** Initial operations: 
******************************************************************************************************************************


drop rhourwage hourwage rhourwage_sp hourwage_sp

* For the correlation, I care also about the wage of the reference guy, then I drop the employed who don't repot wage.
drop if paidhour == 0 & (empstat == 10 | empstat == 12)  

* Drop employed with zero wage
drop if earnweek == 0 & ( empstat == 10 | empstat == 12 )
drop if earnweek_sp == 0 & ( empstat_sp == 10 | empstat_sp == 12 )


* Trim implausible weekly wage:
drop if rearnweek > 2000 
drop if rearnweek > 0 & rearnweek < 50  
drop if rearnweek_sp>2000 
drop if rearnweek_sp>0 & rearnweek_sp< 50 




** Use log wages
gen log_wage = ln(rearnweek + 1), after(rearnweek)

gen log_wage_sp= ln(rearnweek_sp + 1), after(rearnweek_sp)




******************************************************************************************************************************
*** Compute/graph the yearly avg. correlation of earnings of the couple -conditional on both working, and unconditional too.
******************************************************************************************************************************

sort year month 	

*** General

** Assign a number to each month 
egen group = group(year month)
order group, after(month)


**  Unconditional 
su group, meanonly
gen cor_unc = .
qui forvalues i = 1/`r(max)' {
corr log_wage log_wage_sp [w = earnwt] if group == `i' 
replace cor_unc = r(rho) if group == `i' 
}
*

**  Conditional 
su group, meanonly
gen cor_con = .
qui forvalues i = 1/`r(max)' {
corr log_wage log_wage_sp [w = earnwt] if group == `i' & couple_labor == 3
replace cor_con = r(rho) if group == `i' 
}
*


**** Earnings correlation for age cluster

*** 18 --> 35

**  Unconditional 
su group, meanonly
gen cor_unc_18 = .
qui forvalues i = 1/`r(max)' {
corr log_wage log_wage_sp [w = earnwt] if group == `i' & age < 35
replace cor_unc_18 = r(rho) if group == `i' 
}
*

**  Conditional 
su group, meanonly
gen cor_con_18 = .
qui forvalues i = 1/`r(max)' {
corr log_wage log_wage_sp [w = earnwt] if group == `i' & couple_labor == 3 & age < 35
replace cor_con_18 = r(rho) if group == `i' 
}
*


*** 35 --> 55

**  Unconditional 
su group, meanonly
gen cor_unc_35 = .
qui forvalues i = 1/`r(max)' {
corr log_wage log_wage_sp [w = earnwt] if group == `i' & age > 35 & age < 55
replace cor_unc_35 = r(rho) if group == `i' 
}
*

**  Conditional 
su group, meanonly
gen cor_con_35 = .
qui forvalues i = 1/`r(max)' {
corr log_wage log_wage_sp [w = earnwt] if group == `i' & couple_labor == 3 & age > 35 & age < 55
replace cor_con_35 = r(rho) if group == `i' 
}
*



*** 55 --> 65

**  Unconditional 
su group, meanonly
gen cor_unc_55 = .
qui forvalues i = 1/`r(max)' {
corr log_wage log_wage_sp [w = earnwt] if group == `i' & age > 55 
replace cor_unc_55 = r(rho) if group == `i' 
}
*

**  Conditional 
su group, meanonly
gen cor_con_55 = .
qui forvalues i = 1/`r(max)' {
corr log_wage log_wage_sp [w = earnwt] if group == `i' & couple_labor == 3 & age > 55 
replace cor_con_55 = r(rho) if group == `i' 
}
*




** Collapse. ( Notice: it's important to graph after collapsing, otherwise it takes a while. )

collapse cor_unc cor_con cor_unc_18 cor_con_18 cor_unc_35 cor_con_35 cor_unc_55 cor_con_55, by ( year month )

** Label
label var cor_unc "Wages correlation"
label var cor_con "Wages correlation"
label var cor_unc_18 "Wages correlation"
label var cor_con_18 "Wages correlation"
label var cor_unc_35 "Wages correlation"
label var cor_con_35 "Wages correlation"
label var cor_unc_55 "Wages correlation"
label var cor_con_55 "Wages correlation"


** Generate the time variable
gen time=ym(year ,month), after(month)

*** Plots
graph drop _all

** Correlations

** general
tw line cor_unc time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_unc) title("Earnings correlation, uncoditional")
graph export "$directory/Selection_10/Correlation/corr_unc.png" , replace

tw line cor_con time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_con) title("Earnings correlation, conditional on both working")
graph export "$directory/Selection_10/Correlation/corr_con.png" , replace

** 18-->35
tw line cor_unc_18 time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_unc_18) title("Earnings correlation, uncoditional, 18-35")
graph export "$directory/Selection_10/Correlation/corr_unc_18.png" , replace

tw line cor_con_18 time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_con_18) title("Earnings correlation, conditional on both working, 18-35")
graph export "$directory/Selection_10/Correlation/corr_con_18.png" , replace


** 35-->65
tw line cor_unc_35 time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_unc_35) title("Earnings correlation, uncoditional, 35-55")
graph export "$directory/Selection_10/Correlation/corr_unc_35.png" , replace

tw line cor_con_35 time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_con_35) title("Earnings correlation, conditional on both working, 35-55")
graph export "$directory/Selection_10/Correlation/corr_con_35.png" , replace


** 55-->65
tw line cor_unc_55 time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_unc_55) title("Earnings correlation, uncoditional, 55-65")
graph export "$directory/Selection_10/Correlation/corr_unc_55.png" , replace

tw line cor_con_55 time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_con_55) title("Earnings correlation, conditional on both working, 55-65")
graph export "$directory/Selection_10/Correlation/corr_con_55.png" , replace


cd "$directory/Selection_10/Correlation"
save "Corr.dta", replace


cd "$directory/Selection_09"
log close main_09_w_corr


