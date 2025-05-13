// Load Data
use "### Your file path ###\Data\Extracted_data_paper1.dta", clear


////////////////////////////////////////////////////////////////////////////////
// Wear Time ///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Daily Wear Time
foreach i of numlist 1/7 {
	egen wt_D`i' = rowtotal(LyTmD`i'_NT4ActMX SitTmD`i'_NT4ActMX ///
	StandTmD`i'_NT4ActMX Walk1TmD`i'_NT4ActMX Walk2TmD`i'_NT4ActMX ///
	Walk3TmD`i'_NT4ActMX RunTmD`i'_NT4ActMX CyclTmD`i'_NT4ActMX), missing
}

// Convert Seconds to Min
foreach i of numlist 1/7 {
	quietly replace wt_D`i' = wt_D`i' / 60
}

// Exclude Days With 0 min of Lying Down/Sitting/Standing/Walking
foreach i of numlist 1/7 {
	foreach var of varlist Walk1TmD`i'_NT4ActMX Walk2TmD`i'_NT4ActMX Walk3TmD`i'_NT4ActMX WalkTmD`i'_NT4ActMX {
		replace `var' = . if LyTmD`i'_NT4ActMX == 0 | SitTmD`i'_NT4ActMX == 0 | StandTmD`i'_NT4ActMX == 0 | WalkTmD`i'_NT4ActMX == 0
	}
}

// Number of Valid Days
egen valid_days = rownonmiss(wt_D*)

// Number of Valid Days After Filtering
egen valid_days_walk = rownonmiss(WalkTmD*)
label variable valid_days_walk "Valid days of accelerometry, mean (SD)"

// Check if Data are 1440 min
sum wt_D* ActDN_NT4BLM, sep(1)
sum valid_days if valid_days > 0
sum valid_days_walk if valid_days_walk > 0
proportion ActDN_NT4BLM, percent
proportion valid_days, percent
proportion valid_days_walk, percent
codebook ActDN_NT4BLM valid_days valid_days_walk
drop wt_D* ActDN_NT4BLM


////////////////////////////////////////////////////////////////////////////////
// Walking Metrics /////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Mean of Each Walking Speed
foreach i of numlist 1/3 {
	egen walk`i' = rowmean(Walk`i'TmD*)
	quietly replace walk`i' = walk`i' / 60
}

label variable walk1 "Daily Slow Walking (min)"

// Daily Walking Volume
egen walk_tot = rowmean(WalkTmD*)
quietly replace walk_tot = walk_tot / 60
label variable walk_tot "Daily Walking (min)"

// Moderate to Brisk Walking
gen walk_mvpa = walk2 + walk3
label variable walk_mvpa "Daily Moderate to Brisk Walking (min)"

// Average Walking Intensity 
gen walk_mets = (walk1 * 2.8 + walk2 * 3.8 + walk3 * 4.8) / walk_tot
label variable walk_mets "Walking Intensity (MET-min)"

////////////////////////////////////////////////////////////////////////////////
// Other PA and Exercise ///////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

egen run = rowmean(RunTmD*)
egen cycling = rowmean(CyclTmD*)

foreach var in run cycling {
	replace `var' = `var' / 60
}

gen run_cycl = run + cycling

// Excercise Frequency
label define ExeF_NT4BLQ1 1 "Never" 2 "<1 time a week" ///
3 "Once a week" 4 "2-3 times a week" ///
5 "Nearly every day", replace
rename ExeF_NT4BLQ1 exerc_freq
label variable exerc_freq "Exercise frequency"

////////////////////////////////////////////////////////////////////////////////
// Recode Variables ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Participants
label variable PID_114165 "Participants, No."

// Sex
label define Sex 0 "Female" 1 "Male", replace
rename Sex sex
label variable sex "Sex"

// Age
rename PartAg_NT4BLM age
label variable age "Age, mean (SD), y"

gen age65 = 0 if age < 65
replace age65 = 1 if age >= 65

// Education
label define Educ_NT4BLQ1 1 "Primary school" 2 "1-2 y of academic/vocational school" ///
3 "3 y of academic/vocational school" 4 "3-4 y of vocational school/apprentice" ///
5 "University <4 y" 6 "University ≥4 y", replace
rename Educ_NT4BLQ1 education
label variable education "Education"

recode education (1 = 1 "Primary school") (2/4 = 2 "Secondary school") (5/6 = 3 "University"), gen(education3)
label variable education3 "Education"

// Income
label define IncoTot_NT4BLQ1 1 "<25 000 USD" 2 "25 000-45 000 USD" 3 "45 100-75 000 USD" 4 "75 100-100 000 USD" 5 ">100 000 USD", replace
rename IncoTot_NT4BLQ1 income
label variable income "Yearly household income"

// Employment Status
recode WorCu_NT4BLI (0 = 1 "Non-employed") (1 = 0 "Employed"), gen (work_status)
drop WorCu_NT4BLI
label variable work_status "Employment status"

// Smoking Status
recode SmoStat_NT4BLQ1 (0 = 0 "Never smoker") (1 4 = 1 "Former smoker") ///
(2 3 = 2 "Current smoker"), gen(smoking)
drop SmoStat_NT4BLQ1
label variable smoking "Smoking status"

// Depression
recode HADSDepr_NT4BLQ2 (0/6 = 0 "No") (7/21 = 1 "Yes"), gen(depression)
drop HADSDepr_NT4BLQ2
label variable depression "Depression"

// Chronic MSK Pain at Baseline
label define MSPaLY_NT4BLQ2 0 "No" 1 "Yes", replace
rename MSPaLY_NT4BLQ2 msp_t0

// Chronic LBP at Baseline
recode MSPaLum_NT4BLQ2 (. = 0 "No") (1 = 1 "Yes") if !missing(msp_t0), gen(lbp_t0)
drop MSPaLum_NT4BLQ2

// Chronic MSK Pain at Follow-Up
label define MSPaLY_NT4CovQ 0 "No" 1 "Yes", replace
rename MSPaLY_NT4CovQ msp_t1

// Chronic LBP at Follow-Up
recode MSPaLum_NT4CovQ (. = 0 "No") (1 = 1 "Yes") if !missing(msp_t1), gen(lbp_t1)
drop MSPaLum_NT4CovQ

// Missing Covariates
egen missing_cov = rowmiss(sex age education income work_status smoking depression)

// Follow-Up Time
gen followup = datediff(PartDat_NT4BLM, PartDat_NT4CovQ, "day")
replace followup = followup/365
label variable followup "Follow-up, mean (SD), y"

rename PartDat_NT4BLM part_t0
rename PartDat_NT4CovQ part_t1

// BMI
gen bmi = Bmi_NT4BLM 
replace bmi = BmiEld_NT4BLM if missing(bmi)
drop Bmi_NT4BLM BmiEld_NT4BLM
 
// Pain 4 Previous Weeks at Baseline
label define MSPaChrL4W_NT4BLQ1 1 "No" 2 "Very mild" 3 "Mild" 4 "Moderate" ///
5 "Strong" 6 "Very strong", replace
rename MSPaChrL4W_NT4BLQ1 pain_4weeks 

// Health Status 
label define Healt_NT4BLQ1 1 "Poor" 2 "Not so good" 3 "Good" 4 "Very good", replace
rename Healt_NT4BLQ1 health_status
label variable health_status "Self-reported health"

// Other Chronic Diseases
label define DiaEv_NT4BLQ1 0 "No" 1 "Yes", replace
rename DiaEv_NT4BLQ1 diabetes

label define CaEv_NT4BLQ1 0 "No" 1 "Yes", replace
rename CaEv_NT4BLQ1 cancer

label define CarAngEv_NT4BLQ1 0 "No" 1 "Yes", replace
rename CarAngEv_NT4BLQ1 angine

label define CarInfEv_NT4BLQ1 0 "No" 1 "Yes", replace
rename CarInfEv_NT4BLQ1 ami

label define CarFaiEv_NT4BLQ1 0 "No" 1 "Yes", replace
rename CarFaiEv_NT4BLQ1 heart_fail

label define CarAtrFibrEv_NT4BLQ1 0 "No" 1 "Yes", replace
rename CarAtrFibrEv_NT4BLQ1 atrial_fibr

label define ApoplEv_NT4BLQ1 0 "No" 1 "Yes", replace
rename ApoplEv_NT4BLQ1 stroke

gen other_chr_dis = 1 if diabetes == 1 | cancer == 1 | angine == 1 | ami == 1 | ///
heart_fail == 1 | atrial_fibr == 1 | stroke == 1

replace other_chr_dis = 0 if diabetes == 0 & cancer == 0 & angine == 0 & ami == 0 & ///
heart_fail == 0 & atrial_fibr == 0 & stroke == 0

drop diabetes cancer angine ami heart_fail atrial_fibr stroke

// Physical Demand at Work
replace WorTyp_NT4BLI = 0 if missing(WorTyp_NT4BLI) & work_status == 1
label define WorTyp_NT4BLI 0 "Non worker" 1 "Mostly sedentary" 2 "Lot of walking" ///
3 "Lot of walking and lifting" 4 "Heavy manual labour", replace
rename WorTyp_NT4BLI work_type
label variable work_type "Physical demand at work"

// Leisure-Time Limitations at Follow-Up
label define MSPaLeiLim_NT4CovQ 0 "No" 1 "Yes", replace
rename MSPaLeiLim_NT4CovQ limit_leisure

// Severe Chronic LBP at Follow-Up
gen severe_lbp = 0 if !missing(msp_t1)
replace severe_lbp = 1 if lbp_t1 == 1 & limit_leisure == 1
drop limit_leisure


////////////////////////////////////////////////////////////////////////////////
// Drop PA Variables ///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

foreach i of numlist 1/7 {
    drop LyTmD`i'_NT4ActMX SitTmD`i'_NT4ActMX StandTmD`i'_NT4ActMX /// 
	Walk1TmD`i'_NT4ActMX Walk2TmD`i'_NT4ActMX Walk3TmD`i'_NT4ActMX ///
	WalkTmD`i'_NT4ActMX RunTmD`i'_NT4ActMX CyclTmD`i'_NT4ActMX
}


////////////////////////////////////////////////////////////////////////////////
// Comparisons Included/Non-Included Participants //////////////////////////////
////////////////////////////////////////////////////////////////////////////////

do "### Your file path ###\Scripts\1_Descriptive_included_excluded.do"


////////////////////////////////////////////////////////////////////////////////
// Apply Inclusion Criteria ////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Exclude Participants Without Valid Accelerometer Data
drop if valid_days == 0

// Futher Filter Participants With Valid Accelerometer Data
drop if valid_days_walk == 0

// Exclude Participants Missing Chronic Pain Data at Baseline
drop if missing(msp_t0)

// Exclude Participants Reporting Chronic LBP at Baseline
drop if lbp_t0 == 1

// Exclude Participants Missing Chronic Pain Data at Follow-Up
drop if missing(msp_t1)

// Exclude Participants Missing Covariate Information
drop if missing_cov > 0

// Delete Valid Days Variable
drop valid_days

////////////////////////////////////////////////////////////////////////////////
// Categories of Walking Volume and Intensity //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Define Label for Quarters Variables
label define quarter 1 "quarter 1" 2 "quarter 2" 3 "quarter 3" 4 "quarter 4"

// Walking Volume Quarters
xtile volume_qrt = walk_tot, nquantile(4)
label values volume_qrt quarter

// Walking Intensity Quarters
xtile intensity_qrt = walk_mets, nquantile(4)
label values intensity_qrt quarter

// Joint Categories of Volume and Intensity
egen joint_qrt = group(volume_qrt intensity_qrt)
label values joint_qrt joint_qrt


////////////////////////////////////////////////////////////////////////////////
// Order Variables /////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

order part_t0 part_t1 followup ///
sex age age65 ///
education education3 income work_status smoking depression missing_cov ///
msp_t0 lbp_t0 msp_t1 lbp_t1 severe_lbp ///
work_type ///
bmi pain_4weeks health_status other_chr_dis ///
valid_days_walk ///
walk1 walk2 walk3 walk_mvpa walk_tot walk_mets ///
volume_qrt intensity_qrt joint_qrt ///
run cycling run_cycl exerc_freq ///
, after(PID_114165)


// Save Data
save "### Your file path ###\Data\Data_for_analysis_paper1.dta", replace
