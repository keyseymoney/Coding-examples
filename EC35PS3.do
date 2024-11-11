cd "/Users/keyan/Dropbox/Problem set 3 copy"
use "nlsy2000_2012.dta", clear

*Question One
gen minority = 0
replace minority = 1 if black == 1 | hispanic == 1

label variable age "Age (years)"
label variable income "Monthly income"
label variable married "Married"
label variable yrs_educ "Years of education"
label variable urban "Urban resident"
label variable minority "Minority status"

asdoc summarize male age income minority yrs_educ married urban, replace label save(PS31a.doc)


*Question Two
gen male_educ = male*yrs_educ
label variable male_educ "Male-education interaction"

asdoc reg income male minority yrs_educ, robust nest label save(PS31a.doc)
asdoc reg income male minority yrs_educ married, robust nest label save(PS31a.doc)
asdoc reg income male minority yrs_educ married male_educ, robust nest label save(PS31a.doc)


*Question Three
gen male_married = male*married
asdoc reg income male minority yrs_educ married male_educ male_married, robust save(PS31a.doc)
*F test
asdoc reg income male minority yrs_educ married, robust save(PS31a.doc)
asdoc test yrs_educ married, save(PS31a.doc)

*Question Four
gen min_educ = minority*yrs_educ
la var min_educ "Minority-education interaction"
asdoc reg income minority yrs_educ min_educ, robust label save(PS31a.doc)
gen logincome = log(income)
asdoc reg logincome minority yrs_educ min_educ, robust label save(PS31a.doc)

*Question 5: New data set
use "burkinafaso.dta", clear
asdoc reg hivpositive wealth_index catholic secondary_educ age_at_first_sex rural, robust save(PS31a.doc)

*Question 6
asdoc reg hivpositive wealth_index catholic educ_in_years educ_squared age_at_first_sex rural, robust save(PS31a.doc)

*Question 8
asdoc logit hivpositive i.wealth_index i.catholic i.secondary_educ age_at_first_sex i.rural, robust save(PS31a.doc)
margins catholic, atmeans
marginsplot

