cls 

set more off

global directory = "/Users/tommaso/Desktop/RAship_Javier/IPUMS"


cd "$directory/Selection_05"

capture: log close main_05
log using "main_05", name("main_05") text replace 

use "Partners.dta", clear

********************************************************************************

* Tommaso Santini

********************************************************************************

********************************************************************************
**** This script computes the monthly stocks for couples'labor characteristic
********************************************************************************


** I keep only the variables I need for this computation
keep cpsid cpsidp year month sex  relate marst empstat_sp couple_labor hwtfinl


** I keep only the married couples who live together
keep if marst==1


** Drop if partner's emplyment status is missing
drop if empstat_sp==.     // 605,696 deleted


** I now need to define the observation related to the couple. That is, I have to be careful not to count one couple twice, once for each partner, get rid of females.
drop if sex == 2



*** I compute the monthly rate for each kind of couples as a percentage of the couples in the sample
	
sort year month 	

	
** UE
generate UE_ind = couple_labor == 1
by year month: egen UE_mr = wtmean(100 * UE_ind), weight(hwtfinl)

** EU 
generate EU_ind = couple_labor == 2
by year month: egen EU_mr = wtmean(100 * EU_ind), weight(hwtfinl)

** EE
generate EE_ind = couple_labor == 3
by year month: egen EE_mr = wtmean(100 * EE_ind), weight(hwtfinl)

** NE
generate NE_ind = couple_labor == 4
by year month: egen NE_mr = wtmean(100 * NE_ind), weight(hwtfinl)

** EN
generate EN_ind = couple_labor == 5
by year month: egen EN_mr = wtmean(100 * EN_ind), weight(hwtfinl)

** UN
generate UN_ind = couple_labor == 6
by year month: egen UN_mr = wtmean(100 * UN_ind), weight(hwtfinl)

** NU
generate NU_ind = couple_labor == 7
by year month: egen NU_mr = wtmean(100 * NU_ind), weight(hwtfinl)

** UU
generate UU_ind = couple_labor == 8
by year month: egen UU_mr = wtmean(100 * UU_ind), weight(hwtfinl)

** NN
generate NN_ind = couple_labor == 9
by year month: egen NN_mr = wtmean(100 * NN_ind), weight(hwtfinl)


drop UE_ind EU_ind EE_ind NE_ind EN_ind UN_ind NU_ind UU_ind NN_ind

keep cpsidp year month UE_mr EU_mr EE_mr NE_mr EN_mr UN_mr NU_mr UU_mr NN_mr 

collapse UE_mr EU_mr EE_mr NE_mr EN_mr UN_mr NU_mr UU_mr NN_mr, by(year month)



*** Graphs

** generate the time variable
gen time=ym(year ,month), after(month)


graph drop _all

** General

tw line UE_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(UE) title("UE")
graph export "$directory/Selection_06/ue.png" , replace

tw line EU_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EU) title("EU")
graph export "$directory/Selection_06/eu.png" , replace

tw line EE_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EE) title("EE")
graph export "$directory/Selection_06/ee.png" , replace

tw line NE_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(NE) title("NE")
graph export "$directory/Selection_06/ne.png" , replace

tw line EN_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EN) title("EN")
graph export "$directory/Selection_06/en.png" , replace

tw line UN_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(UN) title("UN")
graph export "$directory/Selection_06/un.png" , replace

tw line NU_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(NU) title("NU")
graph export "$directory/Selection_06/nu.png" , replace

tw line UU_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(UU) title("UU")
graph export "$directory/Selection_06/uu.png" , replace

tw line NN_mr time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(NN) title("NN")
graph export "$directory/Selection_06/nn.png" , replace


*** Manipulate the final dataset
drop time
order year month EE_mr EU_mr EN_mr UE_mr UU_mr UN_mr NE_mr NU_mr NN_mr

** Change the name of the variable to distinguish them from the general transition rates
foreach x of varlist UE_mr EU_mr EE_mr NE_mr EN_mr UN_mr NU_mr UU_mr NN_mr  {  
   rename  `x' `x'_couple 
   }

*


foreach x of varlist UE_mr EU_mr EE_mr NE_mr EN_mr UN_mr NU_mr UU_mr NN_mr  {  
   label var `x' "Couple characteristic" 
   }

*

cd "$directory/Selection_06"

save "Cond_tran.dta", replace


cd "$directory/Selection_05"

log close main_05
