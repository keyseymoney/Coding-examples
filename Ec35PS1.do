cd "/Users/keyan/Dropbox/LSMS Dar copy"
use lsms_household.dta, clear

*Prep for merge:
sort hh_id

/*1. The website states that the number of households visited was 2,397 and that the
 total number of completed interviews was 2,083. How many interviews were
 successfully conducted in the first visit? The second? The third?*/
 
 *First: 1,820
 tab visit1_out_mr
 
 *Second: 199
 tab visit2_out_mr
 
 *Third: 64
 tab visit3_out_mr
 
 /*2. Respondents were asked to subjectively evaluate their wellbeing. How would
 you describe the sample in this regard? Cite specific numbers.*/
 
 * Average: About 1/5 of the way between "just okay" and "struggling" (3.2)
 *Distribution: 86% doing "just okay" or worse, pretty bad overall
 summarize s4_subpov2
 proportion s4_subpov2
 
 *3. Difference between interviewer and respondent subjective assessment of well being:
 gen wellbeinggap = s4_subpov2 - s4_subpov if 1 <= s4_subpov2 <= 6 & 1 <= s4_subpov <= 6
 summarize wellbeinggap
 
 /*4. Now consider the 1,151 households in this sample who report their rent per
 month in their survey response (note: you want to ignore households with -98 or
 -99 as the rent – these are placeholders for homes who did not know or refused
 to answer!). Compute and report the following statistics for these households:*/
 
*4.1 The sample mean of rent per month: 47538.66
mean s5_rentmonth if s5_rentmonth >= 0

*4.2 The sample variance of monthly rent: 6.81 x 10^9
tabstat s5_rentmonth if s5_rentmonth >= 0, statistics(variance)

/*4.3. An estimate of the variance of the mean rent per month based on your
 answer in 4.2 (hint: use the number of observations in this calculation).*/
 *Know sample variance = 6.81 x 10^9 with n = 1,151
 *So, estimate of pop. variance = (1,151/1,150)*6.81*10^9 = 6.82 x 10^9
 
*4.4 The standard error of mean rent per month.
summarize s5_rentmonth if s5_rentmonth >= 0
*SD = 82502.6
*Plug into standard error formula: 2431.8
display 82502.6 / sqrt(1151)

/*4.5. Calculate the lower and upper bounds of a 95% confidence interval for the mean
rent per month in this sample. Then use the appropriate version of the .ci
command to verify your calculation. */
display 47538.66 + 1.96*2431.8
display 47538.66 - 1.96*2431.8
*95% CI = (42767, 52310): basically the same as CI command
ci means s5_rentmonth if s5_rentmonth >= 0

/* 5. Nearly 2,000 households in the sample report on whether or not electricity
 is available in their household. Using the .ci command, construct a 95% 
confidence interval for the proportion of households with electricity in the 
sample (be sure to use the correct form of this command given the nature of the data!).*/
gen elecbinary =.
replace elecbinary = 1 if s5_electricityhh == 1
replace elecbinary = 0 if s5_electricityhh == 2
ci proportion elecbinary
*95% CI: (.6160892, .6590969)

/* 6.  Now let us look at how near versus far away homes are from the central 
business district, using the dist_toCBD variable. What are the mean and median 
distances to the central business district in the full data set? [Note: this 
variable is not available for all households.]*/
tabstat dist_toCBD, statistics(mean median)
*Mean = 12.79, Median = 9.80

/*7. Generate a histogram for dist_toCBD in Stata, with bin width of 1 kilometer,
 showing the distribution of the distances from the central business district in the data.*/
 hist dist_toCBD
 
/*8. Create a dummy variable called above_med_CBD_dist that identifies households
 that are above the median distance from the central business district (be careful
 not to improperly define the dummy variable values for those observations without
 a distance to the central business district in the data). Then compute the mean 
 rent for those above versus below that median distance from the central business
 district [Hint: Your sample for these calculations should total 1,140. Again, be
sure you don’t include people with -98 or -99 values for rent, as noted in question 4.*/
gen above_med_CBD_dist = .
replace above_med_CBD_dist = 1 if dist_toCBD > 9.801385 & dist_toCBD < 100000000000
replace above_med_CBD_dist = 0 if dist_toCBD <= 9.801385 

*Above mean = 38120.9
mean s5_rentmonth if s5_rentmonth >= 0 & above_med_CBD_dist == 1

*Below mean = 54470.59
mean s5_rentmonth if s5_rentmonth >= 0 & above_med_CBD_dist == 0

*9. Assuming that these are independent random samples, compute the value of the:

*9.1. Mean difference in rent between “high CBD distance” and “low CBD distance” households (as defined by your above_med_CBD_dist variable).
*Low CBD distance rent is 16,184.9 higher than high CBD distance

*9.2. Standard error of the mean difference (assuming unequal population variances).
*3352.455


/*10. Test the null hypothesis that the two means in question 9 are the same (against 
the alternative that they are different). State your conclusions in both statistical 
terms and practical terms.*/
ttest s5_rentmonth if s5_rentmonth>=0, by(above_med_CBD_dist) unequal
*Stat: reject null hypothesis that means are equal, there is a signficant difference between the samples
*Pract: homes closer to CBD have higher rents
save "/Users/keyan/Dropbox/LSMS Dar copy/lsms_household.dta", replace
 
/*How many unique observations of the id variable exist in s1_hhroster_share.dta?
 How many observations are in the dataset? Is there a discrepancy between these 
 two numbers? Why or why not?*/
 
 *2099 unique values for id, 8143 observations
 *More obs than id values because id indicates household, and hhs have multiple people
use "s1_hhroster_share.dta", clear
unique id

*12. Resulting table represents # of hhs with "count2" number of people in sample 
bysort id: gen count=_n
bysort id: gen count2=_N
tab count2 if count==1

*13. Merge datasets, drop non matches
sort id
merge m:1 id using "/Users/keyan/Dropbox/LSMS Dar copy/lsms_household.dta"
drop if _merge != 3

*Using the s1_hhrtnshp variable, restrict your analysis to the 2,092 heads of household in the sample.
keep if s1_hhrtnshp == 1

*14. Use hwrkyn to create a binary variable d_hwrkyn that is appropriate for data analysis.
gen d_hwrkyn = .
replace d_hwrkyn = 1 if hwrkyn == 1
replace d_hwrkyn = 0 if hwrkyn == 2

*15. Regress the employment status of the head of household on distance to the central business district both with and without the “robust” option.
logit d_hwrkyn dist_toCBD
logit d_hwrkyn dist_toCBD, robust 
*Weak, insignificant, negative effect in both cases, nearly identical except for robust having wider CI

/*16. Coefficients don't change but CIs do, this is bc "robust" command accounts 
for heteroscedasicity and thus uses larger SEs to calculate CI*/

*17. Regress hh head age on CBD distance: more distant households have older heads
**1 km increase in distance assoc. with .11 yr increase in head age
reg s1_age dist_toCBD

*18. Correlation between age and employment: negative
correlate d_hwrkyn s1_age

/*19-20.  Bias on dist_toCBD in regression from (15.) is negative.  If age is added
to the regression, the coefficient of dist_toCBD will become more positive, as the variability
in work status associated with distance to CBD is also negatively associated with age, which 
tends to increase as distance to CBD increases.*/

*21. Yes, dist_toCBD coefficient went from roughly -0.015 to -0.006
logit d_hwrkyn dist_toCBD s1_age

***REGRESSION ANATOMY
keep if hwrkyn !=. & dist_toCBD !=. & s1_age != .

/*22. "predict ehat1, res" is using the regression model to predict the values of 
dist_toCBD using age, then identifying the residuals from the prediction (actual 
value - predicted value) and storing them in the variable ehat1*/
reg dist_toCBD s1_age
predict ehat1, res

/*23. Coefficient of ehat1 is almost exactly the same as coefficient on dist_toCBD
in regression (21)*/
logit d_hwrkyn ehat1






