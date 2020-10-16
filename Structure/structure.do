cls 

set more off

global directory = "/Users/tommaso/Desktop/RAship_Javier/IPUMS"

cd "$directory/Structure"
capture: log close log_structure
log using "log_structure", name("log_structure") text replace 

********************************************************************************

* Tommaso Santini

********************************************************************************


********************************************************************************
/*
This script, illustrates the procedure to get the final datasets from the 
raw starting one. It runs all the separate scripts and records the time. It 
takes 1:20 h on my Mac (3.3 GHz Dual-Core Intel Core i7).
*/
********************************************************************************
timer on 12


cd "$directory/Selection_01"
timer on 1 
do main_01.do
timer off 1


cd "$directory/Selection_02"
timer on 2
do main_02.do
timer off 2


cd "$directory/Selection_03"
timer on 3
do main_03.do
timer off 3

timer on 4
do main_04.do
timer off 4


cd "$directory/Selection_05"
timer on 5
do main_05.do
timer off 5

timer on 6
do main_06.do
timer off 6

timer on 7
do main_07.do
timer off 7

timer on 8
do main_08.do
timer off 8


cd "$directory/Selection_09"
timer on 9
do main_09_w_corr.do
timer off 9

timer on 10
do main_09_w_regr.do
timer off 10


cd "$directory/Aggregate"
timer on 11
do aggr_script.do
timer off 11


timer off 12


timer list 1
timer list 2
timer list 3
timer list 4
timer list 5
timer list 6
timer list 7
timer list 8
timer list 9
timer list 10
timer list 11
timer list 12







cd "$directory/Structure"
log close log_structure
