cd "/Users/keyan/Dropbox/WVS copy"
use  WVS_Cross-National_Wave_7_stata_v4_0.dta, clear

*Q1
sort B_COUNTRY
by B_COUNTRY: gen count = _n

**Graphic One: Overrepresentation Index (Pct share of responses/pct share of population)
*Find total in population as of 2019, translate to pct population
total popWB2019 if count == 1
gen poppctcurrent = popWB2019/4690000000
*Repsonse percent: number of responses for given country/total responses (87822)
by B_COUNTRY: gen responsepct = _N/87822
gen overrepindex = responsepct/poppctcurrent
graph bar (mean) overrepindex if overrepindex >= 15 & overrepindex != ., ///
 over(B_COUNTRY, sort(overrepindex))


**Graphic Two: Democracy index
graph pie B_COUNTRY, over(democ)

*2. Simple Regression for Q124 and Q275
asdoc reg Q124 Q275 if Q124 >= 0 & Q275 >= 0, label
asdoc reg Q124 Q275 Q287 Q260 Q262 Q23 Q19 if Q124 >= 0 & Q275 >= 0 & Q287 >= 1 ///
& Q260 >= 1 & Q262 >= 0 & Q23 >= 1 & Q19 >= 1, label

*4. Collapse data:
collapse Q230 incrichest10p polity corrupttransp electintegr ///
if Q230 >= 1 & Q230 != . & incrichest10p != ., by(B_COUNTRY)
*Run simple regression:
asdoc reg Q230 incrichest10p, label
asdoc reg Q230 incrichest10p polity corrupttransp electintegr, label

*5. Append Wave 6 data
use WV6_Data_stata_v20201117.dta, clear
rename V1 A_WAVE
rename V228J Q234
save "WV6_Data_stata_v20201117_Fixed.dta", replace
use WVS_Cross-National_Wave_7_stata_v4_0.dta, clear
append using WV6_Data_stata_v20201117_Fixed.dta
save "WVS_BothWaves.dta", replace

*6. Find what countries appear in both waves: 39
sort B_COUNTRY_ALPHA
collapse A_WAVE, by(B_COUNTRY_ALPHA)
gen inbothwaves = 0
replace inbothwaves = 1 if 6 < A_WAVE  & 7 > A_WAVE
total inbothwaves

*7. Keep only countries that appear in both waves
use WVS_BothWaves.dta, clear
sort B_COUNTRY_ALPHA
egen meanwave = mean(A_WAVE), by(B_COUNTRY_ALPHA)
keep if 6 < meanwave  & 7 > meanwave

*Count total obs, and obs for each wave:
asdoc tabulate A_WAVE, label


*8. Analysis of world values pre and post 2016 election
ttest Q234 if Q234 >= 1, by(A_WAVE)
collapse Q234 if Q234 >= 1, by(B_COUNTRY_ALPHA A_WAVE)
gen hasreading = 1 if Q234 != .
egen bothsurveys = total(hasreading), by (B_COUNTRY_ALPHA)
keep if bothsurveys == 2
tabulate B_COUNTRY_ALPHA, gen(country)

reg Q234 A_WAVE country1 country2 country3 country4 country5 country6 country7 ///
country8 country9 country10 country11 country12 country13 country14 country15 ///
country16 country17 country18 country19 country20 country21 country22 country23 ///
country24 country25 country26 country27 country28 country29
