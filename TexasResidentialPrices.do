**Yearly data 1990-2010, US
import excel "/Users/keyan/Downloads/HS861M 1990-2009.xlsx", sheet("US-YTD") firstrow clear
keep if B == "."
rename G resprice
save "/Users/keyan/Downloads/1990thru2010_US.xlsx", replace

**Yearly data 2010 onward, US
import excel "/Users/keyan/Downloads/HS861M 2010-.xlsx", sheet("US-YTD") firstrow clear
keep if B == "."
rename G resprice

**Append
append using "/Users/keyan/Downloads/1990thru2010_US.xlsx"
destring A resprice, replace
keep A B resprice
replace B = "US" if B == "."
sort A
save "/Users/keyan/Downloads/1990thruPresent.xlsx", replace

***Same thing but for Texas
**Yearly data 1990-2010, TX
import excel "/Users/keyan/Downloads/HS861M 1990-2009.xlsx", sheet("State-YTD") firstrow clear
keep if B == "TX"
rename G respriceTX
save "/Users/keyan/Downloads/1990thru2010_TX.xlsx", replace


**2010 onward, TX
import excel "/Users/keyan/Downloads/HS861M 2010-.xlsx", sheet("State-YTD-States") firstrow clear
keep if B == "TX"
rename G respriceTX
append using "/Users/keyan/Downloads/1990thru2010_TX.xlsx"
destring A respriceTX, replace
save "/Users/keyan/Downloads/1990thruPresent_TX.xlsx", replace
sort A
keep A B respriceTX
merge A using "/Users/keyan/Downloads/1990thruPresent.xlsx"
**Make graphs
line resprice respriceTX A, xline(2002 2007, lcol(black))

gen diff = respriceTX - resprice
gen post = 0
replace post = 1 if A >= 2007
drop if 2002<=A & 2007>=A
asdoc ttest diff, by(post)
