cls 
clear all
program drop _all
set more off

global directory = "/Users/tommaso/Desktop/RAship_Javier/IPUMS"

cd "$directory/Selection_9"

capture: log close main_8
log using "log_8", name("main_8") text replace 

timer on 2



use "Earner_study_second.dta", clear

********************************************************************************

* Tommaso Santini

********************************************************************************


********************************************************************************
*Hourly wage, couple study
********************************************************************************



********************************************************************************
*Initial operations
********************************************************************************


drop rearnweek earnweek rearnweek_sp earnweek_sp

drop if paidhour_sp == 1

** the 655 who are employed but have a zero wage (spouse)
drop if hourwage_sp == 0 & ( empstat_sp == 10 | empstat_sp == 12 )


* Of those employed and paid by hour, somebody don't report the wage (132)
drop if ( empstat_sp == 10 | empstat_sp == 12 )  & hourwage_sp == 99.99




* Trim implausible hourly wage:

drop if rhourwage_sp>100 // 0%
drop if rhourwage_sp>0 & rhourwage_sp<1  // 976


/*
** Use log wages
gen log_wage = ln(rhourwage), after(rhourwage)
replace log_wage = 0 if log_wage==.

gen log_wage_sp = ln(rhourwage_sp),  after(rhourwage_sp)
replace log_wage_sp = 0 if log_wage_sp==.

hist log_wage
hist rhourwage
*/


** Use log wages
gen log_wage = ln(rhourwage + 1), after(rhourwage)

gen log_wage_sp= ln(rhourwage_sp + 1), after(rhourwage_sp)


********************************************************************************
*** Compute/graph the yearly avg. correlation of earnings of the couple -conditional on both working, and unconditional too.
********************************************************************************


* Open here to see the code.
{
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


}
*




********************************************************************************
*** PROBIT REGRESSIONS
********************************************************************************


sort cpsidp year month


******** Generate the variables



* Transit from Unemp. to Emp. (UE)
gen tran_org = ., after(tran1)
replace tran_org = 0 if ( tran == 1 | tran == 6 | tran == 8 ) // Unemployed at previous period
replace tran_org = 1 if tran == 1 // Employed in "Current"
label var tran_org "U-->E"



* Create quintiles
egen q_wage_sp = xtile(log_wage_sp) if empstat_sp == 10 | empstat_sp == 12, w(earnwt) n(5)
order q_wage_sp, after(log_wage_sp)

** Generate dummies for the 6 categories I need:

* UN
gen UN_ind_sp = 0, after(q_wage_sp)
replace UN_ind_sp = 1 if empstat_sp != 10 & empstat_sp != 12
* Q1
gen q1_ind_sp = 0, after(UN_ind_sp)
replace q1_ind_sp = 1 if q_wage_sp == 1
* Q2
gen q2_ind_sp = 0, after(q1_ind_sp)
replace q2_ind_sp = 1 if q_wage_sp == 2
* Q3
gen q3_ind_sp = 0, after(q2_ind_sp)
replace q3_ind_sp = 1 if q_wage_sp == 3
* Q4
gen q4_ind_sp = 0, after(q3_ind_sp)
replace q4_ind_sp = 1 if q_wage_sp == 4
* Q5
gen q5_ind_sp = 0, after(q4_ind_sp)
replace q5_ind_sp = 1 if q_wage_sp == 5


** Get the unemployemnt rate from Dataset_3.dta, then take the log:
cd "$directory/Selection_4"
merge m:1 year month using "Dataset_3.dta"
drop EE_mr EU_mr EN_mr UE_mr UU_mr UN_mr NE_mr NU_mr NN_mr EE_mr_f EU_mr_f EN_mr_f UE_mr_f UU_mr_f UN_mr_f NE_mr_f NU_mr_f NN_mr_f EE_mr_m EU_mr_m EN_mr_m UE_mr_m UU_mr_m UN_mr_m NE_mr_m NU_mr_m NN_mr_m
drop _merge

gen log_unEmp = log(UnEmp_rate + 1)


** generate the time variable
gen time=ym(year ,month), after(month)

** Polynomial of age
gen age2 = age^2


******** UE Probit regression; omit one dummy to avoid collinearity; 
set matsize 700

qui probit tran_org age age2 log_unEmp time durunemp_pre  child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp i.time i.educ_broad i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip [pweight = earnwt] 
estimates table, drop(i.time i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip) star // this is manly done to suppres all the coefficient on i.time etc. (see h estimates table" for details)

cd "$directory/Selection_9/Table"
outreg2 age age2 log_unEmp time durunemp_pre child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp using prob1_1.doc, replace tex ctitle(UE Probit) drop(i.time i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip)
cd "$directory/Selection_9"




******** Job switching Probit regression; omit one dummy to avoid collinearity; 

qui probit switch age age2 log_unEmp time durunemp_pre  child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp i.time i.educ_broad i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip [pweight = earnwt] if tran_org == 1
estimates table, drop(i.time i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip) star // this is manly done to suppres all the coefficient on i.time etc. (see h estimates table" for details)

cd "$directory/Selection_9/Table"
outreg2 age age2 log_unEmp time durunemp_pre child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp using prob1_2.doc, replace tex ctitle(Occ switch) drop(i.time i.educ i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip)
cd "$directory/Selection_9"


save "until_here2.dta", replace
use "until_here2.dta", clear





********************************************************************************
*** COX REGRESSION
********************************************************************************

******** UE Cox hazard model

drop if tran_org == . 

stset durunemp_pre [pweight = earnwt] , failure(tran_org == 1)

qui stcox age age2 log_unEmp time child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp i.time i.educ_broad i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip, nohr 
estimates table, drop(i.time i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip) star // this is manly done to suppres all the coefficient on i.time etc. (see h estimates table" for details)

cd "$directory/Selection_9/Table"
outreg2 age age2 log_unEmp time child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp using probH_1.doc, replace tex ctitle(Hazard UE) drop(i.time i.educ i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip)
cd "$directory/Selection_9"



******** Job switch Cox hazard model

stset durunemp_pre [pweight = earnwt] , failure(switch == 1)

qui stcox age age2 log_unEmp time child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp i.time i.educ_broad i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip if tran_org == 1, nohr 
estimates table, drop(i.time i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip) star // this is manly done to suppres all the coefficient on i.time etc. (see h estimates table" for details)

cd "$directory/Selection_9/Table"
outreg2 age age2 log_unEmp time child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp using probH_2.doc, replace tex ctitle(Hazard Occ Switch) drop(i.time i.educ i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip)
cd "$directory/Selection_9"



use "until_here2.dta", clear



collapse cor_unc cor_con cor_unc_18 cor_con_18 cor_unc_35 cor_con_35 cor_unc_55 cor_con_55 pr_unc_1 UE_mr_org_unc pr_con_1 UE_mr_org_con pr_unc_2 SW_mr_org_unc pr_con_2 SW_mr_org_con, by ( year month )

** Label
label var cor_unc "Correlation"
label var cor_con "Correlation"
label var cor_unc_18 "Correlation"
label var cor_con_18 "Correlation"
label var cor_unc_35 "Correlation"
label var cor_con_35 "Correlation"
label var cor_unc_55 "Correlation"
label var cor_con_55 "Correlation"


** generate the time variable
gen time=ym(year ,month), after(month)

*** Plots
graph drop _all

** Correlations

** general
tw line cor_unc time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_unc) title("Earnings correlation, uncoditional")
graph export "$directory/Selection_10/corr_unc.png" , replace

tw line cor_con time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_con) title("Earnings correlation, conditional on both working")
graph export "$directory/Selection_10/corr_con.png" , replace

** 18-->35
tw line cor_unc_18 time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_unc_18) title("Earnings correlation, uncoditional, 18-35")
graph export "$directory/Selection_10/corr_unc_18.png" , replace

tw line cor_con_18 time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_con_18) title("Earnings correlation, conditional on both working, 18-35")
graph export "$directory/Selection_10/corr_con_18.png" , replace


** 35-->65
tw line cor_unc_35 time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_unc_35) title("Earnings correlation, uncoditional, 35-55")
graph export "$directory/Selection_10/corr_unc_35.png" , replace

tw line cor_con_35 time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_con_35) title("Earnings correlation, conditional on both working, 35-55")
graph export "$directory/Selection_10/corr_con_35.png" , replace


** 55-->65
tw line cor_unc_55 time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_unc_55) title("Earnings correlation, uncoditional, 55-65")
graph export "$directory/Selection_10/corr_unc_55.png" , replace

tw line cor_con_55 time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(Corr_con_55) title("Earnings correlation, conditional on both working, 55-65")
graph export "$directory/Selection_10/corr_con_55.png" , replace





cd "$directory/Selection_9"
log close main_8








