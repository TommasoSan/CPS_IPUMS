cls 

set more off

global directory = "/Users/tommaso/Desktop/RAship_Javier/IPUMS"

cd "$directory/Selection_02"

capture: log close main_02
log using "main_02", name("main_02") text replace 


use "Dataset_2.dta", clear

********************************************************************************

* Tommaso Santini

********************************************************************************

********************************************************************************
/*
This script creates the preliminary variables I need for the analysis; 
then saves a NEW dataset: "Dataset_3"
*/
********************************************************************************


** Create variable which indicates whether an individual has AT LEAST one child younger than 18; note: cannot assess the exact number of children younger than 18.
gen child_18 = 0, before(relate)
replace child = 1 if  yngch < 18
drop yngch


**** Create a dummy for labor status transitions. Explanation in the STATA_book

* Create a dummy to identify workers in either: PA (federal, state, local), agricolture. (the category "armed force" will be handled directly from the variable "empstat")

gen agr_pa=0, before(cpsidp_sp)
replace agr_pa=1 if ind1950==105 | ind1950==916 | ind1950==926 |  ind1950==936


**** Dummy for transition: yesterday --> today
gen tran=0, before(cpsidp_sp)

** U-->E
replace tran=1 if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5 & ( empstat[_n]==10 | empstat[_n]==12 ) &  ( empstat[_n-1]==21 | empstat[_n-1]==22 ) & agr_pa[_n] != 1

** E-->U 
replace tran=2 if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5 & ( empstat[_n-1]==10 | empstat[_n-1]==12 ) &  ( empstat[_n]==21 | empstat[_n]==22 ) & agr_pa[_n-1] != 1

** E-->E
replace tran=3 if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5 & ( empstat[_n-1]==10 | empstat[_n-1]==12 ) &  ( empstat[_n]==10 | empstat[_n]==12 ) & agr_pa[_n-1] != 1  &  agr_pa[_n] != 1

** N-->E
replace tran=4 if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5 &   labforce[_n-1]==01 &  ( empstat[_n]==10 | empstat[_n]==12 )  & agr_pa[_n] != 1

** E-->N
replace tran=5 if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5 &   labforce[_n]==01 &  ( empstat[_n-1]==10 | empstat[_n-1]==12 )  & agr_pa[_n-1] != 1

** U-->N
replace tran=6 if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5 &   labforce[_n]==01 &  ( empstat[_n-1]==21 | empstat[_n-1]==22 )

** N-->U
replace tran=7 if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5 &   labforce[_n-1]==01 &  ( empstat[_n]==21 | empstat[_n]==22 )

** U-->U
replace tran=8 if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5 & ( empstat[_n-1]==21 | empstat[_n-1]==22 ) &  ( empstat[_n]==21 | empstat[_n]==22 )

** N-->N
replace tran=9 if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5 &   labforce[_n-1]==01 &  labforce[_n]==01


**** Dummy for transition: today --> tomorrow
gen tran1 = tran[_n+1]
order tran1,after(tran)


** Define the value labels
label define flows 0 "." 1 "UE" 2 "EU" 3 "EE" 4 "NE" 5 "EN" 6 "UN" 7 "NU" 8 "UU" 9 "NN"
label values tran flows
label values tran1 flows




**** Create dummy for occupational switching

* yesterday --> today
gen switch=0, after(occ1950)
replace switch=1 if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5 & occ1950[_n] != occ1950[_n-1] & occ1950[_n] != 999 & occ1950[_n-1] != 999

* today --> tomorrow
gen switch1 = switch[_n+1], after(switch)


**** Create unemployment duration in previous period
gen durunemp_pre = ., after(durunemp)
replace durunemp_pre = durunemp[_n-1] if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5




**** Create broad category of industry and occupation

** In ipums armed forces are coded together with unemployed for the occupation and NIU in industry, I change that:

replace occ1950 = 980 if empstat == 01
replace ind1950 = 980 if empstat == 01

*** Occupation

gen occ1950_broad = ., after(occ1950)	
	
replace occ1950_broad = 1 if (occ1950 >= 000 & occ1950 <= 010)  	/* Professional, Technical */
replace occ1950_broad = 2 if (occ1950 >= 012 & occ1950 <= 099)  	/* Professors and instructors */
replace occ1950_broad = 3 if (occ1950 >= 100 & occ1950 <= 123)  	/* Farmers */
replace occ1950_broad = 4 if (occ1950 >= 200 & occ1950 <= 290)  	/* Managers, Officials, and Proprietors */
replace occ1950_broad = 5 if (occ1950 >= 300 & occ1950 <= 390)  	/* Clerical and Kindred */
replace occ1950_broad = 6 if (occ1950 >= 400 & occ1950 <= 490)  	/* Sales workers */
replace occ1950_broad = 7 if (occ1950 >= 500 & occ1950 <= 595)  	/* Craftsmen */
replace occ1950_broad = 8 if (occ1950 >= 600 & occ1950 <= 690)  	/* Operatives */
replace occ1950_broad = 9 if (occ1950 >= 700 & occ1950 <= 790)   	/* Service Workers */
replace occ1950_broad = 10 if (occ1950 >= 810 & occ1950 <= 840)  	/* Farm Laborers */
replace occ1950_broad = 11 if (occ1950 >= 910 & occ1950 <= 970) 	/* Laborers */
replace occ1950_broad = 12 if occ1950 == 980 	/* Armed Forces */
replace occ1950_broad = 997 if occ1950 == 997  	/*Not reported/unknown*/
replace occ1950_broad = 999 if occ1950 == 999  	/*NIU, no occupation*/
	

** Define the value labels
label define occ  1 "Professional, Technical" 2 "Professors and instructors" 3 "Farmers" 4 "Managers, Officials, and Proprietors" 5 "Clerical and Kindred" 6 "Sales workers" 7 "Craftsmen" 8 "Operatives" 9 "Service Workers" 10 "Farm Laborers" 11 "Laborers" 12 "Armed Forces" 997 "Not reported/unknown" 999 "Unemployed- last worked over x years ag"            
label values occ1950_broad occ

** Create broad occupation in previous period
gen occ1950_broad_pre = ., after(occ1950_broad)
replace occ1950_broad_pre = occ1950_broad[_n-1] if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5
label values occ1950_broad_pre occ
	
	
*** Industry

gen ind1950_broad = ., after(ind1950)

replace ind1950_broad = 0 if ind1950 == 000                  	  /*NIU*/
replace ind1950_broad = 1 if (ind1950 >= 105 & ind1950 <= 126) 	  /*AGRICULTURE, FORESTRY, AND FISHERIES*/
replace ind1950_broad = 2 if (ind1950 >= 206 & ind1950 <= 236) 	  /*MINING*/
replace ind1950_broad = 3 if ind1950 == 246                       /*CONSTRUCTION*/
replace ind1950_broad = 4 if (ind1950 >= 306 & ind1950 <= 499) 	  /*MANUFACTURING*/
replace ind1950_broad = 5 if (ind1950 >= 506 & ind1950 <= 598)	  /*TRANSPORTATION, COMMUNICATIONS, AND OTHER PUBLIC UTILITIES*/
replace ind1950_broad = 6 if (ind1950 >= 606 & ind1950 <= 627)	  /*WHOLESALE TRADE. Note: here Javier keeps separated the two subcategoires, and so do I. According to the criterion I follow for the categories, Wholesale trade and Retail trade should go together*/ 
replace ind1950_broad = 7 if (ind1950 >= 636 & ind1950 <= 699)	  /*RETAIL TRADE*/
replace ind1950_broad = 8 if (ind1950 >= 716 & ind1950 <= 746)	  /*FINANCE, INSURANCE, AND REAL ESTATE*/
replace ind1950_broad = 9 if (ind1950 >= 806 & ind1950 <= 817)	  /*BUSINESS AND REPAIR SERVICES*/
replace ind1950_broad = 10 if (ind1950 >= 826 & ind1950 <= 849)	  /*PERSONAL SERVICES*/
replace ind1950_broad = 11 if (ind1950 >= 856 & ind1950 <= 859)   /*ENTERTAINMENT AND RECREATION SERVICES*/
replace ind1950_broad = 12 if (ind1950 >= 868 & ind1950 <= 899)   /*PROFESSIONAL AND RELATED SERVICES*/
replace ind1950_broad = 13 if (ind1950 >= 906 & ind1950 <= 936)   /*PUBLIC ADMINISTRATION*/
replace ind1950_broad = 14 if ind1950 == 980                      /*ARMED FORCES */


** Define the value labels
label define ind 0 "NIU" 1 "AGRICULTURE, FORESTRY, AND FISHERIES" 2 "MINING" 3 "CONSTRUCTION" 4 "MANUFACTURING" 5 "TRANSPORTATION, COMMUNICATIONS, AND OTHER PUBLIC UTILITIES" 6 "WHOLESALE TRADE" 7 "RETAIL TRADE" 8 "FINANCE, INSURANCE, AND REAL ESTATE" 9 "BUSINESS AND REPAIR SERVICES" 10 "PERSONAL SERVICES" 11 "ENTERTAINMENT AND RECREATION SERVICES" 12 "PROFESSIONAL AND RELATED SERVICES" 13 "PUBLIC ADMINISTRATION" 14 "Armed Forces"            
label values ind1950_broad ind


** Create broad industry in previous period
gen ind1950_broad_pre = ., after(ind1950_broad)
replace ind1950_broad_pre = ind1950_broad[_n-1] if cpsidp[_n]==cpsidp[_n-1] & mish[_n]==mish[_n-1]+1 & mish[_n] != 5
label values ind1950_broad_pre ind



**** Create broad category of race

gen race_broad =., after(race)

replace race_broad = 0 if race == 100
replace race_broad = 1 if race != 100 

* Define the value labels
label define race 0 "White" 1 "Non-white" 
label values race_broad race



**** Create broad category of education; 

gen educ_broad =., after(educ)

replace educ_broad = 0 if educ >= 2 & educ <= 71
replace educ_broad = 1 if educ == 73
replace educ_broad = 2 if educ == 81
replace educ_broad = 3 if educ >= 91 & educ <= 111
replace educ_broad = 4 if educ >= 123 & educ <= 125

* Define the value labels
label define educ 0 "No highschool diploma" 1 "Highschool diploma" 2 "Some college but not degree" 3 "Associate or Bachelor degree" 4 "More than Associate or Bachelor degree" 
label values educ_broad educ




**** Create real wages: 

* Hour
gen rhourwage = (hourwage / cpi) * 100, after(hourwage)
label var rhourwage "reale hour wage"
* Week
gen rearnweek = (earnweek / cpi) * 100, after(earnweek)
label var rearnweek "reale weekly wage"

* Drop cpi
drop cpi





cd "$directory/Selection_03"
save "Dataset_3.dta", replace


cd "$directory/Selection_02"
log close main_02




