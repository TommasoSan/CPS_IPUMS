cls 

set more off

global directory = "/Users/tommaso/Desktop/RAship_Javier/IPUMS"

cd "$directory/Selection_03"

capture: log close main_03
log using "main_03", name("main_03") text replace 


use "Dataset_3.dta", clear

********************************************************************************

* Tommaso Santini

********************************************************************************

********************************************************************************
**** This script computes the general labor transition rates and the aggregate unemployment rate 
********************************************************************************


** I just need the following variables
keep cpsidp year month sex empstat tran wtfinl agr_pa

** I create a variable which contains the broad category of Employed, Unemployed, Not in the labor force. Careful! It refer to the previous observation in time! Hence is not consistent with empstat.
gen empstat_broad = 0, before(tran)
replace empstat_broad =1 if ( tran == 2 | tran == 3 | tran == 5 )
replace empstat_broad =2 if ( tran == 1 | tran == 6 | tran == 8 )
replace empstat_broad =3 if ( tran == 7 | tran == 9 | tran == 4 )

* Define the value labels
label define flows_1 1 "E" 2 "U" 3 "N" 
label values empstat_broad flows_1


** Sort the data
sort year month empstat_broad sex

** Unemployment rate
gen unEmp = 0
replace unEmp = 1 if ( empstat == 21 | empstat == 22) & agr_pa[_n] != 1
by year month: egen unEmp_mr = total(unEmp)

gen Emp = 0
replace Emp = 1 if ( empstat == 10 | empstat == 12) & agr_pa[_n] != 1
by year month: egen Emp_mr = total(Emp)

gen UnEmp_rate = unEmp_mr / ( unEmp_mr + Emp_mr )
drop unEmp unEmp_mr Emp Emp_mr

** I drop invalid transitions
drop if tran==0  // (.)


**** Compute the general transition rates	

** For every combination of year momth and empstat_broad (which is defined with respect
** to the first status of the transtion which refers to the previous observation)
** the script computes percentages of every type of transition. So for E there will 
** be the one of EE, EU, EN and will be zero for the other because by construction
** there is none. Given this, I then change the value from zero to missing.

*** General

** E-->E
generate EE_ind = tran == 3
by year month empstat_broad: egen EE_mr = wtmean(100 * EE_ind), weight(wtfinl)

** E-->U 
generate EU_ind = tran == 2
by year month empstat_broad: egen EU_mr = wtmean(100 * EU_ind), weight(wtfinl)

** E-->N
generate EN_ind = tran == 5
by year month empstat_broad: egen EN_mr = wtmean(100 * EN_ind), weight(wtfinl)

** U-->E
generate UE_ind = tran == 1
by year month empstat_broad: egen UE_mr = wtmean(100 * UE_ind), weight(wtfinl)

** U-->U
generate UU_ind = tran == 8
by year month empstat_broad: egen UU_mr = wtmean(100 * UU_ind), weight(wtfinl)

** U-->N
generate UN_ind = tran == 6
by year month empstat_broad: egen UN_mr = wtmean(100 * UN_ind), weight(wtfinl)

** N-->E
generate NE_ind = tran == 4
by year month empstat_broad: egen NE_mr = wtmean(100 * NE_ind), weight(wtfinl)

** N-->U
generate NU_ind = tran == 7
by year month empstat_broad: egen NU_mr = wtmean(100 * NU_ind), weight(wtfinl)

** N-->N
generate NN_ind = tran == 9
by year month empstat_broad: egen NN_mr = mean(100 * NN_ind)

drop UE_ind EU_ind EE_ind NE_ind EN_ind UN_ind NU_ind UU_ind NN_ind

foreach x of varlist UE_mr EU_mr EE_mr NE_mr EN_mr UN_mr NU_mr UU_mr NN_mr  {  
	replace `x'=. if `x'==0 
}
*

*** Conditional on gender

** Females

** E-->E
generate EE_ind = tran == 3 if sex == 2
by year month empstat_broad sex: egen EE_mr_f = wtmean(100 * EE_ind), weight(wtfinl)

** E-->U 
generate EU_ind = tran == 2 if sex == 2
by year month empstat_broad sex: egen EU_mr_f = wtmean(100 * EU_ind), weight(wtfinl)

** E-->N
generate EN_ind = tran == 5 if sex == 2
by year month empstat_broad sex: egen EN_mr_f = wtmean(100 * EN_ind), weight(wtfinl)

** U-->E
generate UE_ind = tran == 1 if sex == 2
by year month empstat_broad sex: egen UE_mr_f = wtmean(100 * UE_ind), weight(wtfinl)

** U-->U
generate UU_ind = tran == 8 if sex == 2
by year month empstat_broad sex: egen UU_mr_f = wtmean(100 * UU_ind), weight(wtfinl)

** U-->N
generate UN_ind = tran == 6 if sex == 2
by year month empstat_broad sex: egen UN_mr_f = wtmean(100 * UN_ind), weight(wtfinl)

** N-->E
generate NE_ind = tran == 4 if sex == 2
by year month empstat_broad sex: egen NE_mr_f = wtmean(100 * NE_ind), weight(wtfinl)

** N-->U
generate NU_ind = tran == 7 if sex == 2
by year month empstat_broad sex: egen NU_mr_f = wtmean(100 * NU_ind), weight(wtfinl)

** N-->N
generate NN_ind = tran == 9 if sex == 2
by year month empstat_broad sex: egen NN_mr_f = wtmean(100 * NN_ind), weight(wtfinl)

drop UE_ind EU_ind EE_ind NE_ind EN_ind UN_ind NU_ind UU_ind NN_ind

foreach x of varlist UE_mr_f EU_mr_f EE_mr_f NE_mr_f EN_mr_f UN_mr_f NU_mr_f UU_mr_f NN_mr_f  {  
	replace `x'=. if `x'==0 
}
*

** Males

** E-->E
generate EE_ind = tran == 3 if sex == 1
by year month empstat_broad sex: egen EE_mr_m = wtmean(100 * EE_ind), weight(wtfinl)

** E-->U 
generate EU_ind = tran == 2 if sex == 1
by year month empstat_broad sex: egen EU_mr_m = wtmean(100 * EU_ind), weight(wtfinl)

** E-->N
generate EN_ind = tran == 5 if sex == 1
by year month empstat_broad sex: egen EN_mr_m = wtmean(100 * EN_ind), weight(wtfinl)

** U-->E
generate UE_ind = tran == 1 if sex == 1
by year month empstat_broad sex: egen UE_mr_m = wtmean(100 * UE_ind), weight(wtfinl)

** U-->U
generate UU_ind = tran == 8 if sex == 1
by year month empstat_broad sex: egen UU_mr_m = wtmean(100 * UU_ind), weight(wtfinl)

** U-->N
generate UN_ind = tran == 6 if sex == 1
by year month empstat_broad sex: egen UN_mr_m = wtmean(100 * UN_ind), weight(wtfinl)

** N-->E
generate NE_ind = tran == 4 if sex == 1
by year month empstat_broad sex: egen NE_mr_m = wtmean(100 * NE_ind), weight(wtfinl)

** N-->U
generate NU_ind = tran == 7 if sex == 1
by year month empstat_broad sex: egen NU_mr_m = wtmean(100 * NU_ind), weight(wtfinl)

** N-->N
generate NN_ind = tran == 9 if sex == 1
by year month empstat_broad sex: egen NN_mr_m = wtmean(100 * NN_ind), weight(wtfinl)

drop UE_ind EU_ind EE_ind NE_ind EN_ind UN_ind NU_ind UU_ind NN_ind

foreach x of varlist UE_mr_m EU_mr_m EE_mr_m NE_mr_m EN_mr_m UN_mr_m NU_mr_m UU_mr_m NN_mr_m  {  
	replace `x'=. if `x'==0 
}
*


** Collapse the dataset: one obs for each month year combination: the percentage of t

collapse UnEmp_rate EE_mr EU_mr EN_mr UE_mr UU_mr UN_mr NE_mr NU_mr NN_mr EE_mr_f EU_mr_f EN_mr_f UE_mr_f UU_mr_f UN_mr_f NE_mr_f NU_mr_f NN_mr_f EE_mr_m EU_mr_m EN_mr_m UE_mr_m UU_mr_m UN_mr_m NE_mr_m NU_mr_m NN_mr_m, by( year month empstat_broad sex )


*** Graphs

** generate the time variable
gen time=ym(year ,month), after(month)

** lable

label var EE_mr_f "female"
label var EU_mr_f "female"
label var EN_mr_f "female"
label var UE_mr_f "female"
label var UU_mr_f "female"
label var UN_mr_f "female"
label var NE_mr_f "female"
label var NU_mr_f "female"
label var NN_mr_f "female"

label var EE_mr_m "male"
label var EU_mr_m "male"
label var EN_mr_m "male"
label var UE_mr_m "male"
label var UU_mr_m "male"
label var UN_mr_m "male"
label var NE_mr_m "male"
label var NU_mr_m "male"
label var NN_mr_m "male"

graph drop _all

** general

tw line EE_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EE) title("EE")
graph export "$directory/Selection_04/General/EE.png" , replace

tw line EU_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EU) title("EU")
graph export "$directory/Selection_04/General/EU.png" , replace

tw line EN_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EN) title("EN")
graph export "$directory/Selection_04/General/EN.png" , replace

tw line UE_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(UE) title("UE")
graph export "$directory/Selection_04/General/UE.png" , replace

tw line UU_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(UU) title("UU")
graph export "$directory/Selection_04/General/UU.png" , replace

tw line UN_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(UN) title("UN")
graph export "$directory/Selection_04/General/UN.png" , replace

tw line NE_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(NE) title("NE")
graph export "$directory/Selection_04/General/NE.png" , replace

tw line NU_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(NU) title("NU")
graph export "$directory/Selection_04/General/NU.png" , replace

tw line NN_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(NN) title("NN")
graph export "$directory/Selection_04/General/NN.png" , replace



** Female Male

tw line EE_mr_m EE_mr_f time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EE_gender) title("EE") lpattern(solid longdash)
graph export "$directory/Selection_04/Gender/EE_gender.png" , replace

tw line EU_mr_m EU_mr_f time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EU_gender) title("EU") lpattern(solid longdash)
graph export "$directory/Selection_04/Gender/EU_gender.png" , replace

tw line EN_mr_m EN_mr_f time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EN_gender) title("EN") lpattern(solid longdash)
graph export "$directory/Selection_04/Gender/EN_gender.png" , replace

tw line UE_mr_m UE_mr_f time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(UE_gender) title("UE") lpattern(solid longdash)
graph export "$directory/Selection_04/Gender/UE_gender.png" , replace

tw line UU_mr_m UU_mr_f time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(UU_gender) title("UU") lpattern(solid longdash)
graph export "$directory/Selection_04/Gender/UU_gender.png" , replace

tw line UN_mr_m UN_mr_f time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(UN_gender) title("UN") lpattern(solid longdash)
graph export "$directory/Selection_04/Gender/UN_gender.png" , replace

tw line NE_mr_m NE_mr_f time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(NE_gender) title("NE") lpattern(solid longdash)
graph export "$directory/Selection_04/Gender/NE_gender.png" , replace

tw line NU_mr_m NU_mr_f time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(NU_gender) title("NU") lpattern(solid longdash)
graph export "$directory/Selection_04/Gender/NU_gender.png" , replace

tw line NN_mr_m NN_mr_f time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(NN_gender) title("NN") lpattern(solid longdash)
graph export "$directory/Selection_04/Gender/NN_gender.png" , replace



** Manipulates the final aggregate dataset
drop sex time empstat_broad
collapse UnEmp_rate EE_mr EU_mr EN_mr UE_mr UU_mr UN_mr NE_mr NU_mr NN_mr EE_mr_f EU_mr_f EN_mr_f UE_mr_f UU_mr_f UN_mr_f NE_mr_f NU_mr_f NN_mr_f EE_mr_m EU_mr_m EN_mr_m UE_mr_m UU_mr_m UN_mr_m NE_mr_m NU_mr_m NN_mr_m, by ( year month )
label var UnEmp_rate "Unemployment rate"
label var EE_mr_f "female"
label var EU_mr_f "female"
label var EN_mr_f "female"
label var UE_mr_f "female"
label var UU_mr_f "female"
label var UN_mr_f "female"
label var NE_mr_f "female"
label var NU_mr_f "female"
label var NN_mr_f "female"

label var EE_mr_m "male"
label var EU_mr_m "male"
label var EN_mr_m "male"
label var UE_mr_m "male"
label var UU_mr_m "male"
label var UN_mr_m "male"
label var NE_mr_m "male"
label var NU_mr_m "male"
label var NN_mr_m "male"


cd "$directory/Selection_04"

save "Dataset_4.dta", replace

cd "$directory/Selection_03"

log close main_03
