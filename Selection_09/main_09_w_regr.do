cls 

set more off

global directory = "/Users/tommaso/Desktop/RAship_Javier/IPUMS"

cd "$directory/Selection_09"

capture: log close main_09_w_regr
log using "main_09_w_regr", name("main_09_w_regr") text replace 



use "Earner_study.dta", clear


******************************************************************************************************************************
*** Weekly wage, couple study; probit regression, cox hazard estimation
******************************************************************************************************************************



******************************************************************************************************************************
*** Initial operations: 
******************************************************************************************************************************

* Keep only weekly wage
drop rhourwage hourwage rhourwage_sp hourwage_sp

* Drop reference's wage, I just need the partner's wage
drop earnweek rearnweek

* Drop employed with zero wage; for the regression analysis, I care only about partner's wage.
drop if earnweek_sp == 0 & ( empstat_sp == 10 | empstat_sp == 12 )


* Of those employed and paid by hour, somebody doesn't report the wage (#132)
drop if earnweek_sp == 99.99  & ( empstat_sp == 10 | empstat_sp == 12 ) 


* Trim implausible weekly wage:
drop if rearnweek_sp>2000 
drop if rearnweek_sp>0 & rearnweek_sp<50   


** Use log wages
gen log_wage_sp= ln(rearnweek_sp + 1), after(rearnweek_sp)


****************************************************************************************************************************** 
*** PROBIT REGRESSIONS
******************************************************************************************************************************


sort cpsidp year month


*** Generate the variables

** Transit from Unemp. to Emp. (UE)
gen tran_org = ., after(tran1)
replace tran_org = 0 if ( tran == 1 | tran == 6 | tran == 8 ) // Unemployed at previous period
replace tran_org = 1 if tran == 1 // Employed in "Current"
label var tran_org "U-->E"



** Create quintiles
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
cd "$directory/Selection_04"
merge m:1 year month using "Dataset_4.dta"
drop EE_mr EU_mr EN_mr UE_mr UU_mr UN_mr NE_mr NU_mr NN_mr EE_mr_f EU_mr_f EN_mr_f UE_mr_f UU_mr_f UN_mr_f NE_mr_f NU_mr_f NN_mr_f EE_mr_m EU_mr_m EN_mr_m UE_mr_m UU_mr_m UN_mr_m NE_mr_m NU_mr_m NN_mr_m
drop _merge

gen log_unEmp = log(UnEmp_rate + 1)


** generate the time variable
gen time=ym(year ,month), after(month)

** Polynomial of age
gen age2 = age^2




*** UE Probit regression; omit one dummy to avoid collinearity; 
set matsize 700

qui probit tran_org age age2  time durunemp_pre UnEmp_rate  child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp i.time i.educ_broad i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip [pweight = earnwt] 
estimates table, drop(i.time i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip) star // this is manly done to suppres all the coefficient on i.time etc. (see h estimates table for details)

cd "$directory/Selection_10/Table"
outreg2 age age2 log_unEmp time durunemp_pre child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp using prob1_1_w.doc, replace tex ctitle(UE Probit) drop(i.time i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip)
cd "$directory/Selection_09"





******** Job switching Probit regression; omit one dummy to avoid collinearity; 

qui probit switch age age2 log_unEmp time durunemp_pre  child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp i.time i.educ_broad i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip [pweight = earnwt] if tran_org == 1
estimates table, drop(i.time i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip) star // this is manly done to suppres all the coefficient on i.time etc. (see h estimates table" for details)

cd "$directory/Selection_10/Table"
outreg2 age age2 log_unEmp time durunemp_pre child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp using prob1_2_w.doc, replace tex ctitle(Occ switch) drop(i.time i.educ i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip)
cd "$directory/Selection_09"




****************************************************************************************************************************** 
*** COX REGRESSION
******************************************************************************************************************************

******** UE Cox, hazard model

drop if tran_org == . 

stset durunemp_pre [pweight = earnwt] , failure(tran_org == 1)

qui stcox age age2 log_unEmp time child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp i.time i.educ_broad i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip, nohr 
estimates table, drop(i.time i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip) star // this is manly done to suppres all the coefficient on i.time etc. (see h estimates table" for details)

cd "$directory/Selection_10/Table"
outreg2 age age2 log_unEmp time child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp using probH_1_w.doc, replace tex ctitle(Hazard UE) drop(i.time i.educ i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip)
cd "$directory/Selection_09"



******** Job switch, Cox hazard model

stset durunemp_pre [pweight = earnwt] , failure(switch == 1)

qui stcox age age2 log_unEmp time child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp i.time i.educ_broad i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip if tran_org == 1, nohr 
estimates table, drop(i.time i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip) star // this is manly done to suppres all the coefficient on i.time etc. (see h estimates table" for details)

cd "$directory/Selection_10/Table"
outreg2 age age2 log_unEmp time child_18 race_broad UN_ind_sp q1_ind_sp q2_ind_sp q3_ind_sp q4_ind_sp q5_ind_sp using probH_2_w.doc, replace tex ctitle(Hazard Occ Switch) drop(i.time i.educ i.occ1950_broad_pre i.ind1950_broad_pre i.hhtenure i.statefip)
cd "$directory/Selection_09"


log close main_09_w_regr


