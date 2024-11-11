**Yearly data 1990-2010, US
import excel "/Users/keyan/Downloads/HS861M 1990-2009.xlsx", sheet("US-YTD") firstrow clear
keep if B == "."
rename AA price
save "/Users/keyan/Downloads/1990thru2010_US.xlsx", replace

**Yearly data 2010 onward, US
import excel "/Users/keyan/Downloads/HS861M 2010-.xlsx", sheet("US-YTD") firstrow clear
keep if B == "."
rename W price

**Append
append using "/Users/keyan/Downloads/1990thru2010_US.xlsx"
destring A price, replace
keep A B price
replace B = "US" if B == "."
sort A
save "/Users/keyan/Downloads/1990thruPresent.xlsx", replace

***Same thing but for Texas
**Yearly data 1990-2010, TX
import excel "/Users/keyan/Downloads/HS861M 1990-2009.xlsx", sheet("State-YTD") clear
keep if B == "TX"
rename AA priceTX
save "/Users/keyan/Downloads/1990thru2010_TX.xlsx", replace


**2010 onward, TX
import excel "/Users/keyan/Downloads/HS861M 2010-.xlsx", sheet("State-YTD-States") firstrow clear
keep if B == "TX"
rename W priceTX
append using "/Users/keyan/Downloads/1990thru2010_TX.xlsx"
destring A priceTX, replace
save "/Users/keyan/Downloads/1990thruPresent_TX.xlsx", replace
sort A
keep A B priceTX
merge A using "/Users/keyan/Downloads/1990thruPresent.xlsx"
**Make graphs
line price priceTX A, xline(2002 2007, lcol(black))

*gen preTX = mean priceTX if 1990<=A<=2002
*gen preUS = mean price if 1990<=A<=2002
*gen prediff = preTX - preUS

*gen postTX = mean priceTX if 2007 <= A
*gen postUS = mean price if 2007 <= A
*gen postdiff = postTX - postUS

gen diff = priceTX - price
gen post = 0
replace post = 1 if A >= 2007
drop if 2002<=A & 2007>=A
asdoc ttest diff, by(post)

