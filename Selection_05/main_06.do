cls 

set more off

global directory = "/Users/tommaso/Desktop/RAship_Javier/IPUMS"

cd "$directory/Selection_05"

capture: log close main_06
log using "main_06", name("main_06") text replace 

use "Partners.dta", clear

********************************************************************************

* Tommaso Santini

********************************************************************************

********************************************************************************
**** This script compute the individual transtion rates conditional on the partner status. 
********************************************************************************


** Keep only the variable I need for this computation
keep cpsid cpsidp year month sex empstat labforce tran marst cpsidp_sp empstat_sp labforce_sp wtfinl


** I keep only the married couples who live together
keep if marst==1


** Drop if partner's emplyment status is missing
drop if empstat_sp==.     // 605,696 deleted


** I drop invalid transitions
drop if tran==0  // (.)


** I create a variable which contains the broad category of Employed, Unemployed, Not in the labor force. Careful! It refer to the previous observation in time! Hence is not consistent with empstat.
gen empstat_broad = 0, before(tran)
replace empstat_broad =1 if ( tran == 2 | tran == 3 | tran == 5 )
replace empstat_broad =2 if ( tran == 1 | tran == 6 | tran == 8 )
replace empstat_broad =3 if ( tran == 7 | tran == 9 | tran == 4 )

* Define the value labels
label define flows_1 1 "E" 2 "U" 3 "N" 
label values empstat_broad flows_1


** Create broad categories of labor status for the partners
gen empstat_sp_broad = 0
replace empstat_sp_broad = 1 if ( empstat_sp == 01 | empstat_sp == 10 | empstat_sp == 12 )
replace empstat_sp_broad = 2 if ( empstat_sp == 21 | empstat_sp == 22 )
replace empstat_sp_broad = 3 if ( labforce_sp == 1 )

* Define the value labels
label define flows_2 1 "E" 2 "U" 3 "N" 
label values empstat_sp_broad flows_2


** Keep, Sort, order the data
keep cpsid cpsidp year month empstat_sp_broad empstat_broad tran wtfinl
sort year month empstat_sp_broad empstat_broad
order cpsid cpsidp year month empstat_sp_broad empstat_broad tran wtfinl


** Compute the rates, employed partner

** E-->E
generate EE_ind = tran == 3 & empstat_sp_broad == 1
by year month empstat_sp_broad empstat_broad: egen EE_mr = wtmean(100 * EE_ind), weight(wtfinl)

** E-->U 
generate EU_ind = tran == 2 & empstat_sp_broad == 1
by year month empstat_sp_broad empstat_broad: egen EU_mr = wtmean(100 * EU_ind), weight(wtfinl)

** E-->N
generate EN_ind = tran == 5 & empstat_sp_broad == 1
by year month empstat_sp_broad empstat_broad: egen EN_mr = wtmean(100 * EN_ind), weight(wtfinl)

** U-->E
generate UE_ind = tran == 1 & empstat_sp_broad == 1
by year month empstat_sp_broad empstat_broad: egen UE_mr = wtmean(100 * UE_ind), weight(wtfinl)

** U-->U
generate UU_ind = tran == 8 & empstat_sp_broad == 1
by year month empstat_sp_broad empstat_broad: egen UU_mr = wtmean(100 * UU_ind), weight(wtfinl)

** U-->N
generate UN_ind = tran == 6 & empstat_sp_broad == 1
by year month empstat_sp_broad empstat_broad: egen UN_mr = wtmean(100 * UN_ind), weight(wtfinl)

** N-->E
generate NE_ind = tran == 4 & empstat_sp_broad == 1
by year month empstat_sp_broad empstat_broad: egen NE_mr = wtmean(100 * NE_ind), weight(wtfinl)

** N-->U
generate NU_ind = tran == 7 & empstat_sp_broad == 1
by year month empstat_sp_broad empstat_broad: egen NU_mr = wtmean(100 * NU_ind), weight(wtfinl)

** N-->N
generate NN_ind = tran == 9 & empstat_sp_broad == 1
by year month empstat_sp_broad empstat_broad: egen NN_mr = wtmean(100 * NN_ind), weight(wtfinl)

drop UE_ind EU_ind EE_ind NE_ind EN_ind UN_ind NU_ind UU_ind NN_ind

foreach x of varlist EE_mr EU_mr EN_mr UE_mr UU_mr UN_mr NE_mr NU_mr NN_mr {   // rename all of the variables as the "spouse variable"
	rename `x' `x'_E
}
*


** Compute the rates, unemployed partner

** E-->E
generate EE_ind = tran == 3 & empstat_sp_broad == 2
by year month empstat_sp_broad empstat_broad: egen EE_mr = wtmean(100 * EE_ind), weight(wtfinl)

** E-->U 
generate EU_ind = tran == 2 & empstat_sp_broad == 2
by year month empstat_sp_broad empstat_broad: egen EU_mr = wtmean(100 * EU_ind), weight(wtfinl)

** E-->N
generate EN_ind = tran == 5 & empstat_sp_broad == 2
by year month empstat_sp_broad empstat_broad: egen EN_mr = wtmean(100 * EN_ind), weight(wtfinl)

** U-->E
generate UE_ind = tran == 1 & empstat_sp_broad == 2
by year month empstat_sp_broad empstat_broad: egen UE_mr = wtmean(100 * UE_ind), weight(wtfinl)

** U-->U
generate UU_ind = tran == 8 & empstat_sp_broad == 2
by year month empstat_sp_broad empstat_broad: egen UU_mr = wtmean(100 * UU_ind), weight(wtfinl)

** U-->N
generate UN_ind = tran == 6 & empstat_sp_broad == 2
by year month empstat_sp_broad empstat_broad: egen UN_mr = wtmean(100 * UN_ind), weight(wtfinl)

** N-->E
generate NE_ind = tran == 4 & empstat_sp_broad == 2
by year month empstat_sp_broad empstat_broad: egen NE_mr = wtmean(100 * NE_ind), weight(wtfinl)

** N-->U
generate NU_ind = tran == 7 & empstat_sp_broad == 2
by year month empstat_sp_broad empstat_broad: egen NU_mr = wtmean(100 * NU_ind), weight(wtfinl)

** N-->N
generate NN_ind = tran == 9 & empstat_sp_broad == 2
by year month empstat_sp_broad empstat_broad: egen NN_mr = wtmean(100 * NN_ind), weight(wtfinl)

drop UE_ind EU_ind EE_ind NE_ind EN_ind UN_ind NU_ind UU_ind NN_ind

foreach x of varlist EE_mr EU_mr EN_mr UE_mr UU_mr UN_mr NE_mr NU_mr NN_mr {   // rename all of the variables as the "spouse variable"
	rename `x' `x'_U
}
*


** Compute the rates, nilf partner

** E-->E
generate EE_ind = tran == 3 & empstat_sp_broad == 3
by year month empstat_sp_broad empstat_broad: egen EE_mr = wtmean(100 * EE_ind), weight(wtfinl)

** E-->U 
generate EU_ind = tran == 2 & empstat_sp_broad == 3
by year month empstat_sp_broad empstat_broad: egen EU_mr = wtmean(100 * EU_ind), weight(wtfinl)

** E-->N
generate EN_ind = tran == 5 & empstat_sp_broad == 3
by year month empstat_sp_broad empstat_broad: egen EN_mr = wtmean(100 * EN_ind), weight(wtfinl)

** U-->E
generate UE_ind = tran == 1 & empstat_sp_broad == 3
by year month empstat_sp_broad empstat_broad: egen UE_mr = wtmean(100 * UE_ind), weight(wtfinl)

** U-->U
generate UU_ind = tran == 8 & empstat_sp_broad == 3
by year month empstat_sp_broad empstat_broad: egen UU_mr = wtmean(100 * UU_ind), weight(wtfinl)

** U-->N
generate UN_ind = tran == 6 & empstat_sp_broad == 3
by year month empstat_sp_broad empstat_broad: egen UN_mr = wtmean(100 * UN_ind), weight(wtfinl)

** N-->E
generate NE_ind = tran == 4 & empstat_sp_broad == 3
by year month empstat_sp_broad empstat_broad: egen NE_mr = wtmean(100 * NE_ind), weight(wtfinl)

** N-->U
generate NU_ind = tran == 7 & empstat_sp_broad == 3
by year month empstat_sp_broad empstat_broad: egen NU_mr = wtmean(100 * NU_ind), weight(wtfinl)

** N-->N
generate NN_ind = tran == 9 & empstat_sp_broad == 3
by year month empstat_sp_broad empstat_broad: egen NN_mr = wtmean(100 * NN_ind), weight(wtfinl)

drop UE_ind EU_ind EE_ind NE_ind EN_ind UN_ind NU_ind UU_ind NN_ind

drop wtfinl

foreach x of varlist EE_mr EU_mr EN_mr UE_mr UU_mr UN_mr NE_mr NU_mr NN_mr {   // rename all of the variables as the "spouse variable"
	rename `x' `x'_N
}
*


** Change from zero to missing

foreach x of varlist EE_mr_E EU_mr_E EN_mr_E UE_mr_E UU_mr_E UN_mr_E NE_mr_E NU_mr_E NN_mr_E EE_mr_U EU_mr_U EN_mr_U UE_mr_U UU_mr_U UN_mr_U NE_mr_U NU_mr_U NN_mr_U EE_mr_N EU_mr_N EN_mr_N UE_mr_N UU_mr_N UN_mr_N NE_mr_N NU_mr_N NN_mr_N  {  
	replace `x'=. if `x'==0 
}
*


collapse EE_mr_E EU_mr_E EN_mr_E UE_mr_E UU_mr_E UN_mr_E NE_mr_E NU_mr_E NN_mr_E EE_mr_U EU_mr_U EN_mr_U UE_mr_U UU_mr_U UN_mr_U NE_mr_U NU_mr_U NN_mr_U EE_mr_N EU_mr_N EN_mr_N UE_mr_N UU_mr_N UN_mr_N NE_mr_N NU_mr_N NN_mr_N, by( year month empstat_sp_broad empstat_broad )


*** Graphs

** generate the time variable
gen time=ym(year ,month), after(month)


** Change label

foreach x of varlist EE_mr_E EU_mr_E EN_mr_E UE_mr_E UU_mr_E UN_mr_E NE_mr_E NU_mr_E NN_mr_E  {  
   label var `x' "Partner Employed" 
   }

*

foreach x of varlist EE_mr_U EU_mr_U EN_mr_U UE_mr_U UU_mr_U UN_mr_U NE_mr_U NU_mr_U NN_mr_U  {  
  label var `x' "Partner Unemployed" 
   }

*

foreach x of varlist EE_mr_N EU_mr_N EN_mr_N UE_mr_N UU_mr_N UN_mr_N NE_mr_N NU_mr_N NN_mr_N  {  
   label var `x' "Partner Not in the labor force" 
   }

*


** Plots

graph drop _all

tw line EE_mr_E EE_mr_U EE_mr_N time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EE) title("EE")
graph export "$directory/Selection_07/EE.png" , replace

tw line EU_mr_E EU_mr_U EU_mr_N time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EU) title("EU")
graph export "$directory/Selection_07/EU.png" , replace

tw line EN_mr_E EN_mr_U EN_mr_N time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(EN) title("EN")
graph export "$directory/Selection_07/EN.png" , replace

tw line UE_mr_E UE_mr_U UE_mr_N time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(UE) title("UE")
graph export "$directory/Selection_07/UE.png" , replace

tw line UU_mr_E UU_mr_U UU_mr_N time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(UU) title("UU")
graph export "$directory/Selection_07/UU.png" , replace

tw line UN_mr_E UN_mr_U UN_mr_N time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(UN) title("UN")
graph export "$directory/Selection_07/UN.png" , replace

tw line NE_mr_E NE_mr_U NE_mr_N time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(NE) title("NE")
graph export "$directory/Selection_07/NE.png" , replace

tw line NU_mr_E NU_mr_U NU_mr_N time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(NU) title("NU")
graph export "$directory/Selection_07/NU.png" , replace

tw line NN_mr_E NN_mr_U NN_mr_N time , xtick(407.5(12)695.5, tlength(*1.5)) xlabel(425.5(24)689.5, noticks format(%tmYY))  xtitle("") name(NN) title("NN")
graph export "$directory/Selection_07/NN.png" , replace




** Manipulates the final aggregate dataset
drop time empstat_broad empstat_sp_broad
collapse EE_mr_E EU_mr_E EN_mr_E UE_mr_E UU_mr_E UN_mr_E NE_mr_E NU_mr_E NN_mr_E EE_mr_U EU_mr_U EN_mr_U UE_mr_U UU_mr_U UN_mr_U NE_mr_U NU_mr_U NN_mr_U EE_mr_N EU_mr_N EN_mr_N UE_mr_N UU_mr_N UN_mr_N NE_mr_N NU_mr_N NN_mr_N, by ( year month )



** Change label

foreach x of varlist EE_mr_E EU_mr_E EN_mr_E UE_mr_E UU_mr_E UN_mr_E NE_mr_E NU_mr_E NN_mr_E  {  
   label var `x' "Partner Employed" 
   }

*

foreach x of varlist EE_mr_U EU_mr_U EN_mr_U UE_mr_U UU_mr_U UN_mr_U NE_mr_U NU_mr_U NN_mr_U  {  
  label var `x' "Partner Unemployed" 
   }

*

foreach x of varlist EE_mr_N EU_mr_N EN_mr_N UE_mr_N UU_mr_N UN_mr_N NE_mr_N NU_mr_N NN_mr_N  {  
   label var `x' "Partner Not in the labor force" 
   }
*





cd "$directory/Selection_07"

save "Partn_status_flows.dta", replace


cd "$directory/Selection_05"

log close main_06

















