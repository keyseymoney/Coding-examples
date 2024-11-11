import delimited using /Users/keyan/Dropbox/Summer2021Research/COVID-Vaccinations_in_the_United_States_County.csv, clear
keep date fips recip_county series_complete_pop_pct

*Generate variable for percent of ppl not fully vaccinated, sort by this in increasing order (most vaccinated first)
*Then, keep only the highest reading from each county
gen notcomplete_pct = 100 - series_complete_pop_pct
gen realfips = real(fips)
sort realfips notcomplete_pct
by realfips: gen count = _n
keep if count == 1
save /Users/keyan/Dropbox/Summer2021Research/CountyVaccinationsFipsSorted.dta, replace

*Import election data, keep one observation per county, generate Biden share
import delimited using /Users/keyan/Dropbox/Summer2021Research/2020-CountyLevel.csv, clear
keep if year == 2020 & candidate == "JOSEPH R BIDEN JR"
gen realfips = real(county_fips)
sort realfips
egen totalBiden = total(real(candidatevotes)), by(realfips)
egen fulltotalvotes = total(real(totalvotes)), by(realfips)
gen percentBiden = totalBiden/fulltotalvotes
by realfips: gen count = _n
keep if count == 1
*Merge data sets
merge 1:1 realfips using /Users/keyan/Dropbox/Summer2021Research/CountyVaccinationsFipsSorted.dta, gen(BidenShareVaccinated_County)
gen vaccinatedfrac = series_complete_pop_pct/100
*Hawaii and Texas don't report by county, Alaska uses different districts for presidential election and census
drop if state == "HAWAII" | state == "TEXAS" | state == "ALASKA"
*Create state + county combined variable for merging with census data
gen statecounty = state + recip_county
save /Users/keyan/Dropbox/Summer2021Research/County_VaxBidenMerge.dta, replace

*Biden share positively and significantly correlated with vaccine series completion rate: Beta = 0.38, p < 0.0005
pwcorr vaccinatedfrac percentBiden, star(0.0005)

*Scatter
graph twoway (scatter vaccinatedfrac percentBiden) (lfitci vaccinatedfrac percentBiden)


*Education data from Ag Dept. ERS
import delimited using /Users/keyan/Dropbox/Summer2021Research/CountyEducation.csv, clear
gen pctnocollege2019 = v44 + v45
drop if state == "HI" | state == "TX" | state == "AK" | state == "US" | state == "PR"
rename ïfipscode realfips
sort state realfips
by state: gen count = _n
drop if count == 1

merge 1:1 realfips using /Users/keyan/Dropbox/Summer2021Research/County_VaxBidenMerge.dta, gen(EducationMerge)
gen pctcollege2019 = (100-pctnocollege2019)/100

reg vaccinatedfrac percentBiden pctcollege2019

save /Users/keyan/Dropbox/Summer2021Research/County_VaxBiden_EducationMerge.dta, replace

*Merge in census data	
import delimited using /Users/keyan/Dropbox/Summer2021Research/CC-EST2020-ALLDATA.csv, clear
drop if stname == "Hawaii" | stname == "Texas" | stname == "Alaska"
keep if year == 13
gen upperstate = upper(stname)
gen statecounty = upperstate + ctyname

reshape wide aac_male aac_female nac_male nac_female nh_male nh_female nhwa_male nhwa_female nhba_male nhba_female tot_pop tot_male tot_female wa_male wa_female ba_male ba_female ia_male ia_female aa_male aa_female na_male na_female tom_male tom_female wac_male wac_female bac_male bac_female iac_male iac_female nhia_male nhia_female nhaa_male nhaa_female nhna_male nhna_female nhtom_male nhtom_female nhwac_male nhwac_female nhbac_male nhbac_female nhiac_male nhiac_female nhaac_male nhaac_female nhnac_male nhnac_female h_male h_female hwa_male hwa_female hba_male hba_female hia_male hia_female haa_male haa_female hna_male hna_female htom_male htom_female hwac_male hwac_female hbac_male hbac_female hiac_male hiac_female haac_male haac_female hnac_male hnac_female, i(statecounty) j(agegrp)

*Percentage of people between ages of 14  and 35
gen pctyoungpeople = (real(tot_pop4) + real(tot_pop5) + real(tot_pop6) + real(tot_pop7)) / real(tot_pop0)

rename state statenumber
save /Users/keyan/Dropbox/Summer2021Research/CountyCensusData.dta, replace

use /Users/keyan/Dropbox/Summer2021Research/CountyCensusData.dta
merge 1:1 _n using /Users/keyan/Dropbox/Summer2021Research/County_VaxBiden_EducationMerge.dta, gen(MergeWithCensus)

reg vaccinatedfrac percentBiden pctcollege2019 pctyoungpeople
reg vaccinatedfrac percentBiden pctcollege2019 pctyoungpeople pctwhite
reg vaccinatedfrac percentBiden pctcollege2019  pctwhite

save /Users/keyan/Dropbox/Summer2021Research/County_VaxBiden_Education_RaceAgeMerge.dta


