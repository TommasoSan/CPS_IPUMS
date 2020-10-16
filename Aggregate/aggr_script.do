cls 

set more off

global directory = ""

cd "$directory/Aggregate"

capture: log close main_aggr
log using "main_aggr", name("main_aggr") text replace 


timer on 1

*** This script merges together the aggregate datasets

cd "$directory/Selection_04"
use "dataset_4.dta", clear

cd "$directory/Selection_07"
merge 1:1 year month using "Partn_status_flows.dta" 
drop _merge

cd "$directory/Selection_08"
merge 1:1 year month using "Duration.dta"
drop _merge
sort year month

cd "$directory/Selection_06"
merge 1:1 year month using "Cond_tran.dta"
drop _merge

cd "$directory/Selection_10/Correlation"
merge 1:1 year month using "Corr.dta"
drop _merge


order time, after(month)


** Light modification for clarity

foreach x of varlist EE_mr EU_mr EN_mr UE_mr UU_mr UN_mr NE_mr NU_mr NN_mr  {  
   label var `x' "General transition rates" 
   }

*


foreach x of varlist EE_mr_f EU_mr_f EN_mr_f UE_mr_f UU_mr_f UN_mr_f NE_mr_f NU_mr_f NN_mr_f  {  
   label var `x' "Gen. tran. rates, females" 
   }

*

foreach x of varlist EE_mr_m EU_mr_m EN_mr_m UE_mr_m UU_mr_m UN_mr_m NE_mr_m NU_mr_m NN_mr_m  {  
   label var `x' "Gen. tran. rates, males" 
   }

*


cd "$directory/Aggregate"

save "Aggregate.dta", replace

log close main_aggr



timer off 1 
timer list 1
