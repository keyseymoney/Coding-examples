** UChicago E&E Coding Test - Keyan Shayegan
clear
set more off
capture log close

******************Data Exploration*******************

***For each year, compute the weighted average of price over all states with both
*price and production data in that year, where each state’s weight is its
*production in bushels in that year. Then, plot this weighted average over years 
*1990-2017. 

*Read in production data
import delimited using "/Users/keyan/downloads/Files for Applicant/Barley_production.csv"

sort state year

***Find total amount of barley produced in each state each year by summing up production
*across all districts

*Change value (district-level production) from string to int
destring value, replace ignore(",")

*sum production across all districts for each state in each year
egen stateproduction = total(value), by(state year)

*Drop down to one row, containing stateproduction var which represents total 
*barley production for a given state in a given year
by state year: gen n = _n
keep if n == 1

*Rename value variable to avoid confusion with price datset
rename value districtproduction
save "/Users/keyan/downloads/Files for Applicant/Barley_production_modified.csv", replace

*Read in price data
import delimited using "/Users/keyan/downloads/Files for Applicant/Barley_price.csv", clear

sort state year


*Merge price and production datasets, dropping unmatched rows
merge 1:1 state year using "/Users/keyan/downloads/Files for Applicant/Barley_production_modified.csv", force
keep if _merge == 3
sort year

*Save merged data set for later analysis
save "/Users/keyan/downloads/Files for Applicant/Barley_data_merged.csv", replace

*Calculate state revenue of barley sales in US in a given year
gen staterev = stateproduction * value

*Calculate total national revenue in a given year
egen natrev = total(staterev), by(year)

*Divide by total national production to determine average price
egen natprod = total(stateproduction), by(year)
gen weightedprice = natrev/natprod

*Plot weighted average price over the years 1990-2017
twoway (line weightedprice year, sort), title("Average National Price of Barley in U.S., 1990-2017") ytitle(Price)

***Create a summary table where the rows are specific states (Idaho, Minnesota,
* Montana, North Dakota, and Wyoming) and the columns are decades (1990-1999, 
*2000-2009, and 2010-2017). The elements of the table are mean annual state-level
*production, by decade and state. Scale the production variable so that it is in
*units of millions of bushels. 

*Pare down to desired states 
keep if state == "IDAHO" | state == "MINNESOTA" | state == "MONTANA" | state == "MINNESOTA" | state == "WYOMING" |state == "NORTH DAKOTA"

*Create decade identifier variable
gen decade = ""
replace decade = "1990-1999" if year <= 1999
replace decade = "2000-2009" if 2000 <= year 
replace decade = "2010-2017" if 2010 <= year

sort state decade year

*Scale production to millions of bushels
replace stateproduction = stateproduction/1000000

*Create table
table state decade, contents(mean stateproduction)

******************Interpretation*******************

**Your friend wants to estimate the sensitivity of US farmers’ barley production
*to barley price, using the provided data at the level of agricultural district by year. 

*First write down the equation of a linear model of production on price. 
*Do not transform any variables yet. Ensure that the terms are properly indexed. 

*Access dataset including produciton and price
use "/Users/keyan/downloads/Files for Applicant/Barley_data_merged.csv", clear

*Run linear regression of production on price
**NOTE: do not have district-level data for price, so using state-level data instead
reg stateproduction value

*Your friend wants the coefficient of interest on price to have the interpretation of 
*an elasticity. Write down a regression equation that satisfies your friend’s desire. 

*Logarithmically transform variables
gen logstateproduction = log(stateproduction)
gen logprice = log(value)

*Run regression
reg logstateproduction logprice

*Your friend also wants to include annual time fixed effects in addition to state 
*fixed effects. Write down an equation for this model. Run this regression on the
*provided data and report the coefficient estimate and standard error for the
*parameter of interest (price). Please provide a short interpretation of this result.

*Generate numeric variable of state for transformation to panel data
egen statenum = group(state)
xtset statenum year, yearly

*Save panelized data to be turned in
save "/Users/keyan/downloads/Files for Applicant/Panelized_barley_data.csv", replace

*Run regression
xtreg stateproduction value i.year, fe



