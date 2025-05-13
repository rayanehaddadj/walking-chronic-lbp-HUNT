putdocx clear


// Comparison Included vs Non-Included Participants
gen included = 0

replace included = 1 if valid_days > 0 & valid_days_walk > 0 & !missing(msp_t0) & ///
lbp_t0 == 0 & !missing(msp_t1) & missing_cov == 0

label define included 0 "Non-included" 1 "Included"

label values included included

// Comparison AX3 vs Non-AX3 Participants
gen ax3 = 0

replace ax3 = 1 if valid_days > 0

label define ax3 0 "No accelerometer data" 1 "Accelerometer data"

label values ax3 ax3

// Comparison Participants With and Without MSK Pain Data
gen msk_data = 0

replace msk_data = 1 if !missing(msp_t0)

label define msk_data 0 "Missing chronic pain data at HUNT4" ///
1 "Available chronic pain data at HUNT4"

label values msk_data msk_data

// Create Descriptive Table
foreach var in included ax3 msk_data {
	dtable, by(`var') column(by(hide)) halign(left) ///
	continuous(PID_114165, statistics(count)) ///
	continuous(age) ///
	factor(sex education3 income work_status smoking depression) ///
	nosample ///
	sformat("(%s)" fvpercent) ///
	nformat(%3.1f mean sd fvpercent) ///
	nformat(%3.0f count frequency fvfrequency) ///
	title(Table 1. Baseline Characteristics of the HUNT Population Comparing ...) ///
	note(Abbreviations: USD, United States dollar.) ///
	note(a Major depression was assessed using the Hospital Anxiety and Depression Scale Depression subscale.) ///
	export("### Your file path ###\Figures\Descriptives\Supplementary_descriptive_`var'.docx", replace)

}

drop included ax3 msk_data