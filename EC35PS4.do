cd "/Users/keyan/Dropbox/Problem set 4 copy"
use "emotions_sports.dta", clear

*Q1
asdoc reg e_excited teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust nest save(EC35Ps4F.doc)6
asdoc reg e_happy teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust nest save(EC35Ps4F.doc)
asdoc reg e_sad teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust nest save(EC35Ps4F.doc)
asdoc reg e_nervous teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust nest save(EC35Ps4F.doc)
asdoc reg e_angry teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust nest save(EC35Ps4F.doc)
asdoc reg e_disappointed teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust nest save(EC35Ps4F.doc)
asdoc reg e_proud teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust nest save(EC35Ps4F.doc)

*Q3
eststo clear
eststo: reg e_excited teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust  beta
eststo: reg e_happy teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust  beta
eststo: reg e_sad teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust  beta
eststo: reg e_nervous teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust  beta
eststo: reg e_angry teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust  beta
eststo: reg e_disappointed teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust  beta
eststo: reg e_proud teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust  beta
asdoc esttab, compress beta not save(EC35Ps4F.doc)

*Q5
asdoc reg negemotion teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust save(EC35Ps4F.doc)

*Q7
twoway (scatter negemotion scorediff), xline(0)

*Q8
gen positivescore = 0
replace positivescore = 1 if scorediff > 0
asdoc reg negemotion scorediff positivescore positivescore#c.scorediff, robust nest reset save(EC35Ps4F.doc)

*Q9
asdoc reg negemotion scorediff positivescore positivescore#c.scorediff female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust nest save(EC35Ps4F.doc)

*Q11 
asdoc reg riskaversion negemotion female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust beta save(EC35Ps4F.doc)

*Q13
asdoc reg negemotion teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust nest reset save(EC35Ps4F.doc)

asdoc reg riskaversion teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree, robust nest save(EC35Ps4F.doc)

asdoc ivregress 2sls riskaversion female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree (negemotion = teamwon female age30up hhincome educ_somecollege educ_collegedegree educ_graddegree), robust nest save(EC35Ps4F.doc)
