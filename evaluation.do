clear all

*Dropping unnecessary variables
drop startDate endDate status ipAddress progress duration finished recordedDate _recordId recipientLastName recipientFirstName recipientEmail externalDataReference locationLatitude locationLongitude distributionChannel
*Macro that assigns variable labels
	foreach x of varlist * {
	   label var `x' `"`=`x'[1]'"'
		}
	drop in 1
	foreach x of varlist * {
	   cap destring `x', replace
		}
	desc  

*Merging datasets/groups/blocks that have already had pre- and post-data merged.
use "...\depression_curriculum_1.dta"
append using "...\depression_curriculum_2"
append using "...\depression_curriculum_3"
append using ...\depression_curriculum_4”

*Recoding familiarity with depression question
			capture drop depression_familiarity_post
			gen depression_familiarity_post = 0 if familiar_post == "Prefer not to answer"
			replace depression_familiarity_post = 1 if familiar_post == "Not familiar"
			replace depression_familiarity_post = 2 if familiar_post == "Slightly familiar"
			replace depression_familiarity_post = 3 if familiar_post == "Moderately familiar"
			replace depression_familiarity_post = 4 if familiar_post == "Very familiar"
			replace depression_familiarity_post = 5 if familiar_post == "Extremely familiar"
			capture label drop depression_familiaritylab
			label define depression_familiaritylab 0 "Prefer not to answer" 1 "Not familiar" 2 "Slightly familiar" 3 "Moderately familiar" 4 "Very familiar" 5 "Extremely familiar"
			label value depression_familiarity_post depression_familiaritylab
			tab depression_familiarity_post

*Sources of familiarity – creating a binary variable that marks a particular answer to a question regarding the source of their depression familiarity
		capture drop familiarity_coursework_post familiarity_employment_post familiarity_volunteer_post familiarity_personal_post familiarity_printed_post familiarity_online_post
			replace familiarity_factors_post = lower(familiarity_factors_post)
			gen familiarity_coursework_post = regexm(familiarity_factors_post, "coursework")
			gen familiarity_volunteer_post = regexm(familiarity_factors_post, "prior volunteer experiences")
			gen familiarity_online_post = regexm(familiarity_factors_post, "online resources")
			gen familiarity_personal_post = regexm(familiarity_factors_post, "depression in a close friend, family member, or myself")
			gen familiarity_printed_post = regexm(familiarity_factors_post, "printed materials")
			gen familiarity_employment_post = regexm(familiarity_factors_post, "prior employment")

*Creating a variable that counts these factors
			capture drop familiarity_factorsn_post
			gen familiarity_factorsn_post = 0 if familiarity_coursework_post == 1
			replace familiarity_factorsn_post = 1 if familiarity_volunteer_post == 1 
			replace familiarity_factorsn_post = 2 if familiarity_online_post == 1
			replace familiarity_factorsn_post = 3 if familiarity_personal_post == 1
			replace familiarity_factorsn_post = 4 if familiarity_printed_post == 1
			replace familiarity_factorsn_post = 5 if familiarity_employment_post == 1
			capture label drop familiarity_factorsnlab
			label define familiarity_factorsnlab 0 "Coursework" 1 "Prior volunteer experience" 2 "Online resources" 3 "depression in a close friend, family member, or myself" 4 "Printed materials" 5 "Prior employment" 
			label value familiarity_factorsn_post familiarity_factorsnlab
			tab familiarity_factorsn_post, miss

  *Jefferson Empathy Scale variables
*Macro that converts all responses to numeric (new numeric variables created with an _n appended (eg, QID111 to QID111_n)
				capture drop *_n*
				capture drop *_temp
				local jes QID13 QID106 QID107 QID108 QID109 QID110 QID111 QID113 QID112 QID114 QID116 QID115 QID117 QID118 QID119 QID120 QID121 QID122 QID123 QID124

				foreach j of varlist `jes' {
						 split `j', gen(`j'_n) parse(" ") destring
					   rename `j'_n1 `j'_temp
					   capture  drop `j'_n*
						  rename `j'_temp `j'_n
								}

*Creating JESQ01-20 variable names
			rename (QID13_n QID106_n QID107_n QID108_n QID109_n QID110_n QID111_n QID113_n QID112_n QID114_n QID116_n QID115_n QID117_n QID118_n QID119_n QID120_n QID121_n QID122_n QID123_n QID124_n) (jesqpost01 jesqpost02 jesqpost03 jesqpost04 jesqpost05 jesqpost06 jesqpost07 jesqpost08 jesqpost09 jesqpost10 jesqpost11 jesqpost12 jesqpost13 jesqpost14 jesqpost15 jesqpost16 jesqpost17 jesqpost18 jesqpost19 jesqpost20)  

*Multiple items in the JES are reverse coded
		     recode jesqpost01 jesqpost03 jesqpost06 jesqpost07 jesqpost08 jesqpost11 jesqpost12 jesqpost14 jesqpost18 jesqpost19 (7=1) (6=2) (5=3) (4=4) (3=5) (2=6) (1=7)

*Summing Jefferson Empathy Scale Post Score
				capture drop jes_sum_post
				egen jes_sum_post = rsum(jesqpost01 jesqpost02 jesqpost03 jesqpost04 jesqpost05 jesqpost06 jesqpost07 jesqpost08 jesqpost09 jesqpost10 jesqpost11 jesqpost12 jesqpost13 jesqpost14 jesqpost15 jesqpost16 jesqpost17 jesqpost18 jesqpost19 jesqpost20)
				summarize jes_sum_post, detail

*Depression Stigma Scale variables
*Macro that converts all responses to numeric (new numeric variables created with an _n appended (eg, QID111 to QID111_n)

		local stigma QID146 QID163 QID164 QID165 QID166 QID167 QID180 QID168 QID169 QID170 QID171 QID172 QID173 QID175 QID176 QID177 QID178 QID179
			foreach j of varlist `stigma' {
					gen `j'_n =.
					replace `j'_n = 0 if `j'== "Strongly disagree"
					replace `j'_n = 1 if `j'== "Disagree"
					replace `j'_n = 2 if `j'== "Neither agree nor disagree"
					replace `j'_n = 3 if `j'== "Agree"
					replace `j'_n = 4 if `j'== "Strongly agree"
			}
			
			rename (QID146_n QID163_n QID164_n QID165_n QID166_n QID167_n QID180_n QID168_n QID169_n QID170_n QID171_n QID172_n QID173_n QID175_n QID176_n QID177_n QID178_n QID179_n) (dssqpost01 dssqpost02 dssqpost03 dssqpost04 dssqpost05 dssqpost06 dssqpost07 dssqpost08 dssqpost09 dssqpost10 dssqpost11 dssqpost12 dssqpost13 dssqpost14 dssqpost15 dssqpost16 dssqpost17 dssqpost18)

*Summing Depression Stigma Scale Personal Post Score
				egen dss_personal_sum_post = rsum(dssqpost01 dssqpost02 dssqpost03 dssqpost04 dssqpost05 dssqpost06 dssqpost07 dssqpost08 dssqpost09)
				summarize dss_personal_sum_post, detail

			*Depression Stigma Scale Perceived Post Score
				egen dss_perceived_sum_post = rsum(dssqpost10 dssqpost11 dssqpost12 dssqpost13 dssqpost14 dssqpost15 dssqpost16 dssqpost17 dssqpost18)
				summarize dss_perceived_sum_post, detail
				
*Creating variables and labels for the differences between post- and pre- Jefferson Empathy Scale scores
	gen jes_diff = jes_sum_post-jes_sum_pre
label variable jes_diff "Empathy score pre-post difference"
	gen dss_personal_diff = dss_personal_sum_post-dss_personal_sum_pre
label variable dss_personal_diff "Personal stigma score pre-post difference"
	gen dss_perceived_diff = dss_perceived_sum_post-dss_perceived_sum_pre
label variable dss_perceived_diff "Perceived stigma score pre-post difference"

*Creating Jefferson Empathy Scale subgroups for high and low pre-scores that had a mean of 116 
	Univar jes_sum_pre
capture drop jes_high
	generate jes_high = 0
	replace jes_high = 1 if jes_sum_pre >116.39
	replace jes_high = . if jes_sum_pre == .
	tab jes_high, col miss

*Creating Depression Stigma Scale-Personal subgroups for high and low pre-scores that had a mean of 6
univar dss_personal_sum_pre 
capture drop dss_personal_high
	generate dss_personal_high = 0
	replace dss_personal_high = 1 if dss_personal_sum_pre >5.75
	replace dss_personal_high = . if dss_personal_sum_pre == .
	tab dss_personal_high, col miss

*Creating Depression Stigma Scale-Perceived subgroups for high and low pre-scores that had a mean of 21
univar dss_perceived_sum_pre 
capture drop dss_perceived_high
generate dss_perceived_high = 0
replace dss_perceived_high = 1 if dss_perceived_sum_pre >20.88
replace dss_perceived_high = . if dss_perceived_sum_pre == .
tab dss_perceived_high intervention, col miss chi2

*Creating an indicator to track whether empathy increased or decreased in Jefferson Empathy Scale
capture drop improved_empathy
gen improved_empathy = 0
replace improved_empathy = 1 if jes_sum_pre<jes_sum_post
replace improved_empathy = 2 if jes_sum_pre==jes_sum_post
tab improved_empathy, miss

*Satisfaction with program questions

			rename (QID70 QID191 QID194 QID200 QID199) (prog_sat1 prog_sat2 prog_sat3 prog_sat4 prog_sat5)
			tab prog_sat1, miss
			tab prog_sat2, miss
			tab prog_sat3, miss
			tab prog_sat4, miss
			tab prog_sat5, miss

*Remember to save these new variables to the combined dataset and load it again if you want to continue working on it
save ...\depression_curriculum_1-4, replace
use "...\depression_curriculum_1-4.dta"

Demographics and baseline scores tables (Tables 1 and 2)

*To create Table 1 with gender, age, and race categories reported
log using "...\Table_1.statalog", replace text
	tab genderf, col miss
	tab age_cat, col miss
	tab race_cat, col miss
log close

*To create Table 2 with scale results for empathy and stigma in the baseline/pre period with raw values and provide descriptive characteristics 
log using "...\Table_2.statalog", replace text
	tab jes_sum_pre, col miss 
	tab dss_personal_sum_pre, col miss 
	tab dss_perceived_sum_pre, col miss 
	univar jes_sum_pre
	univar dss_personal_sum_pre 
	univar dss_perceived_sum_pre
log close

Analysis (Tables 3-6)

*To create Table 3 describing whether students learned what they hoped about depression, whether their ideas changed, and what element of the rotation influenced their work/thinking with depression

log using "...\Table_3.statalog", replace text

	tab prog_sat1, col miss chi2
	tab prog_sat2, col miss chi2
	tab prog_sat3, col miss chi2
	tab prog_sat4, col miss chi2
	tab prog_sat5, col miss chi2

*To create Table 4 on raw values for depression and depression familiarity and ANOVA testing via Kruskal Wallis
log using "...\Table_4.statalog", replace text

	tab familiar, col miss
	tab depression_familiarity_post, col miss
	
	kwallis depression_familiarity_post
	kwallis depression_familiarity

log close
*To create Table 5 with depression familiarity by reporting pre/post variables
log using "...\Table_5.statalog", replace text
      
		*pre
		tab familiarity_coursework, col miss 
		tab familiarity_volunteer, col miss 
		tab familiarity_online, col miss 
		tab familiarity_personal, col miss 
		tab familiarity_printed, col miss 
		tab familiarity_employment, col miss 
		
		*post
		tab familiarity_coursework_post, col miss 
		tab familiarity_volunteer_post, col miss 
		tab familiarity_online_post, col miss 
		tab familiarity_personal_post, col miss 
		tab familiarity_printed_post, col miss 
		tab familiarity_employment_post, col miss 
		
log close

*To create Table 5 with empathy pre/post scores and differences and one-way ANOVA testing – coded as oneway [independent] [dependent] 
log using "...\Table_5.statalog", replace text

	univar jes_sum_pre 
	univar jes_sum_post
	
	oneway jes_diff 
	oneway jes_diff if jes_high==1
	oneway jes_diff if jes_high==0
	
log close
*To create Table 6 summarizing Depression Stigma Scale (DSS) Perceived and Personal subscales			
log using "...\Table_6.statalog", replace text	

*DSS Perceived
	univar dss_perceived_sum_pre
	univar dss_perceived_sum_post 
	
	oneway dss_perceived_diff 
	oneway dss_perceived_diff if dss_perceived_high==1
	oneway dss_perceived_diff if dss_perceived_high==0
	

	
*DSS Personal
	univar dss_personal_sum_pre
	univar dss_personal_sum_post 

	oneway dss_personal_diff
	oneway dss_personal_diff if dss_personal_high==1
	oneway dss_personal_diff if dss_personal_high==0

log close
