// Load Data
use "### Your file path ###\Data\Data_for_analysis_paper1.dta", clear

// Create Word Document
putdocx clear
putdocx begin
putdocx paragraph


////////////////////////////////////////////////////////////////////////////////
// Further Adjustement on BMI //////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

foreach var in volume_qrt intensity_qrt {
	
	if ("`var'" == "volume_qrt") {
		local main walk_tot
		local title "quarters of Walking Volume"
	}
	else if ("`var'" == "intensity_qrt") {
		local main walk_mets
		local title "quarters of Walking Intensity"
	}
	
	drop `var'
	
	xtile `var' = `main' if !missing(bmi), nquantile(4)
	label values `var' quarter
	
	quietly collect: table (`var') (var) if !missing(bmi), statistic(count PID_114165) nototal
	quietly collect: table (`var') (var) if lbp_t1 == 1 & !missing(bmi), statistic(count PID_114165) nototal append

	quietly collect: poisson lbp_t1 i.`var' age if !missing(bmi), vce(robust) irr
	quietly collect: poisson lbp_t1 i.`var' age i.sex i.education i.income i.work_status i.smoking i.depression bmi, vce(robust) irr
	
	collect label values cmdset 1 "No. of participants" 2 "No. of cases" 3 "Model 1" 4 "Model 2"
	
	collect style cell result[count], nformat(%9.0f)	
	collect style cell result[_r_b], nformat(%3.2f)
	collect style cell result[_r_ci], nformat(%3.2f) sformat("(%s)") cidelimiter("-") 
	
	collect style header result, level(hide)
	collect style header colname_remainder, level(hide)
	collect style cell, border(right, pattern(nil))
	collect style cell, halign(left)
	
	collect layout (`var') (cmdset[1 2]#result[count] cmdset[3]#result[_r_b _r_ci] cmdset[4]#result[_r_b _r_ci])
	
	collect style putdocx, layout(autofitcontents) title("Supplement xx. Risk of Chronic Low Back Pain Associated  with `title' Adjusting on BMI")
	putdocx collect
}


////////////////////////////////////////////////////////////////////////////////
// Further Adjustement on Other PA /////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

foreach var in volume_qrt intensity_qrt {
	
	if ("`var'" == "volume_qrt") {
		local main walk_tot
		local title "quarters of Walking Volume"
	}
	else if ("`var'" == "intensity_qrt") {
		local main walk_mets
		local title "quarters of Walking Intensity"
	}
	
	drop `var'
	
	xtile `var' = `main', nquantile(4)
	label values `var' quarter
	
	quietly collect: table (`var') (var), statistic(count PID_114165) nototal
	quietly collect: table (`var') (var) if lbp_t1 == 1, statistic(count PID_114165) nototal append

	quietly collect: poisson lbp_t1 i.`var' age, vce(robust) irr
	quietly collect: poisson lbp_t1 i.`var' age i.sex i.education i.income i.work_status i.smoking i.depression run_cycl, vce(robust) irr
	
	collect label values cmdset 1 "No. of participants" 2 "No. of cases" 3 "Model 1" 4 "Model 2"
	
	collect style cell result[count], nformat(%9.0f)	
	collect style cell result[_r_b], nformat(%3.2f)
	collect style cell result[_r_ci], nformat(%3.2f) sformat("(%s)") cidelimiter("-") 
	
	collect style header result, level(hide)
	collect style header colname_remainder, level(hide)
	collect style cell, border(right, pattern(nil))
	collect style cell, halign(left)
	
	collect layout (`var') (cmdset[1 2]#result[count] cmdset[3]#result[_r_b _r_ci] cmdset[4]#result[_r_b _r_ci])
	
	collect style putdocx, layout(autofitcontents) title("Supplement xx. Risk of Chronic Low Back Pain Associated  with `title' Adjusting on other physical activity")
	putdocx collect
}

////////////////////////////////////////////////////////////////////////////////
// Exclusion of Participants with <4 valid days ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

foreach var in volume_qrt intensity_qrt {
	
	if ("`var'" == "volume_qrt") {
		local main walk_tot
	}
	else if ("`var'" == "intensity_qrt") {
		local main walk_mets
	}
	
	drop `var'
		
	xtile `var' = `main' if valid_days_walk >= 4, nquantile(4)
	label values `var' quarter

	quietly collect: table (`var') (var) if valid_days_walk >= 4, statistic(count PID_114165) nototal
	quietly collect: table (`var') (var) if lbp_t1 == 1 & valid_days_walk >= 4, statistic(count PID_114165) nototal append

	quietly collect: poisson lbp_t1 i.`var' age if valid_days_walk >= 4, vce(robust) irr
	quietly collect: poisson lbp_t1 i.`var' age i.sex i.education i.income i.work_status i.smoking i.depression if valid_days_walk >= 4, vce(robust) irr
	
	collect label values cmdset 1 "No. of participants" 2 "No. of cases" 3 "Model 1" 4 "Model 2"
	
	collect style cell result[count], nformat(%9.0f)	
	collect style cell result[_r_b], nformat(%3.2f)
	collect style cell result[_r_ci], nformat(%3.2f) sformat("(%s)") cidelimiter("-") 
	
	collect style header result, level(hide)
	collect style header colname_remainder, level(hide)
	collect style cell, border(right, pattern(nil))
	collect style cell, halign(left)
	
	collect layout (`var') (cmdset[1 2]#result[count] cmdset[3]#result[_r_b _r_ci] cmdset[4]#result[_r_b _r_ci])
	
	collect style putdocx, layout(autofitcontents) title("Supplement xx. Risk of Chronic Low Back Pain Associated  with `title' Excluding Participants with Less than 4 Valid Days of Accelerometry")
	putdocx collect
}


////////////////////////////////////////////////////////////////////////////////
// Exluding Participants with MSK Pain at Baseline /////////////////////////////
////////////////////////////////////////////////////////////////////////////////

foreach var in volume_qrt intensity_qrt {
	
	if ("`var'" == "volume_qrt") {
		local main walk_tot
	}
	else if ("`var'" == "intensity_qrt") {
		local main walk_mets
	}
	
	drop `var'
	
	xtile `var' = `main' if msp_t0 == 0, nquantile(4)
	label values `var' quarter

	quietly collect: table (`var') (var) if msp_t0 == 0, statistic(count PID_114165) nototal
	quietly collect: table (`var') (var) if lbp_t1 == 1 & msp_t0 == 0, statistic(count PID_114165) nototal append

	quietly collect: poisson lbp_t1 i.`var' age if msp_t0 == 0, vce(robust) irr
	quietly collect: poisson lbp_t1 i.`var' age i.sex i.education i.income i.work_status i.smoking i.depression if msp_t0 == 0, vce(robust) irr
	
	collect label values cmdset 1 "No. of participants" 2 "No. of cases" 3 "Model 1" 4 "Model 2"
	
	collect style cell result[count], nformat(%9.0f)	
	collect style cell result[_r_b], nformat(%3.2f)
	collect style cell result[_r_ci], nformat(%3.2f) sformat("(%s)") cidelimiter("-") 
	
	collect style header result, level(hide)
	collect style header colname_remainder, level(hide)
	collect style cell, border(right, pattern(nil))
	collect style cell, halign(left)
	
	collect layout (`var') (cmdset[1 2]#result[count] cmdset[3]#result[_r_b _r_ci] cmdset[4]#result[_r_b _r_ci])
	
	collect style putdocx, layout(autofitcontents) title("Supplement xx. Risk of Chronic Low Back Pain Associated  with `title' Excluding Participants Reporting MSK Pain at Baseline")
	putdocx collect
}


////////////////////////////////////////////////////////////////////////////////
// Exluding Participants with ≥Moderate Level of Pain at Baseline //////////////
////////////////////////////////////////////////////////////////////////////////

foreach var in volume_qrt intensity_qrt {
	
	if ("`var'" == "volume_qrt") {
		local main walk_tot
	}
	else if ("`var'" == "intensity_qrt") {
		local main walk_mets
	}
	
	drop `var'
	
	xtile `var' = `main' if pain_4weeks < 4, nquantile(4)
	label values `var' quarter

	
	quietly collect: table (`var') (var) if pain_4weeks < 4, statistic(count PID_114165) nototal
	quietly collect: table (`var') (var) if lbp_t1 == 1 & pain_4weeks < 4, statistic(count PID_114165) nototal append

	quietly collect: poisson lbp_t1 i.`var' age if pain_4weeks < 4, vce(robust) irr
	quietly collect: poisson lbp_t1 i.`var' age i.sex i.education i.income i.work_status i.smoking i.depression if pain_4weeks < 4, vce(robust) irr
	
	collect label values cmdset 1 "No. of participants" 2 "No. of cases" 3 "Model 1" 4 "Model 2"
	
	collect style cell result[count], nformat(%9.0f)	
	collect style cell result[_r_b], nformat(%3.2f)
	collect style cell result[_r_ci], nformat(%3.2f) sformat("(%s)") cidelimiter("-") 
	
	collect style header result, level(hide)
	collect style header colname_remainder, level(hide)
	collect style cell, border(right, pattern(nil))
	collect style cell, halign(left)
	
	collect layout (`var') (cmdset[1 2]#result[count] cmdset[3]#result[_r_b _r_ci] cmdset[4]#result[_r_b _r_ci])
	
	collect style putdocx, layout(autofitcontents) title("Supplement xx. Risk of Chronic Low Back Pain Associated  with `title' Excluding Participants Reporting Moderate Overall Level of Pain or Stronger at Baseline")
	putdocx collect
}


////////////////////////////////////////////////////////////////////////////////
// Exluding Participants with Poor Health Status at Baseline ///////////////////
////////////////////////////////////////////////////////////////////////////////

foreach var in volume_qrt intensity_qrt {
	
	if ("`var'" == "volume_qrt") {
		local main walk_tot
	}
	else if ("`var'" == "intensity_qrt") {
		local main walk_mets
	}
	
	drop `var'
	
	xtile `var' = `main' if health_status > 2, nquantile(4)
	label values `var' quarter
		
	quietly collect: table (`var') (var) if health_status > 2, statistic(count PID_114165) nototal
	quietly collect: table (`var') (var) if lbp_t1 == 1 & health_status > 2, statistic(count PID_114165) nototal append

	quietly collect: poisson lbp_t1 i.`var' age if health_status > 2, vce(robust) irr
	quietly collect: poisson lbp_t1 i.`var' age i.sex i.education i.income i.work_status i.smoking i.depression if health_status > 2, vce(robust) irr
	
	collect label values cmdset 1 "No. of participants" 2 "No. of cases" 3 "Model 1" 4 "Model 2"
	
	collect style cell result[count], nformat(%9.0f)	
	collect style cell result[_r_b], nformat(%3.2f)
	collect style cell result[_r_ci], nformat(%3.2f) sformat("(%s)") cidelimiter("-") 
	
	collect style header result, level(hide)
	collect style header colname_remainder, level(hide)
	collect style cell, border(right, pattern(nil))
	collect style cell, halign(left)
	
	collect layout (`var') (cmdset[1 2]#result[count] cmdset[3]#result[_r_b _r_ci] cmdset[4]#result[_r_b _r_ci])
	
	collect style putdocx, layout(autofitcontents) title("Supplement xx. Risk of Chronic Low Back Pain Associated  with `title' Excluding Participants Reporting Poor Health Status at Baseline")
	putdocx collect
}


////////////////////////////////////////////////////////////////////////////////
// Exluding Participants Other Chronic Diseases ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

foreach var in volume_qrt intensity_qrt {
	
	if ("`var'" == "volume_qrt") {
		local main walk_tot
	}
	else if ("`var'" == "intensity_qrt") {
		local main walk_mets
	}
	
	drop `var'
	
	xtile `var' = `main' if other_chr_dis == 0, nquantile(4)
	label values `var' quarter
		
	quietly collect: table (`var') (var) if other_chr_dis == 0, statistic(count PID_114165) nototal
	quietly collect: table (`var') (var) if lbp_t1 == 1 & other_chr_dis == 0, statistic(count PID_114165) nototal append

	quietly collect: poisson lbp_t1 i.`var' age if other_chr_dis == 0, vce(robust) irr
	quietly collect: poisson lbp_t1 i.`var' age i.sex i.education i.income i.work_status i.smoking i.depression if other_chr_dis == 0, vce(robust) irr
	
	collect label values cmdset 1 "No. of participants" 2 "No. of cases" 3 "Model 1" 4 "Model 2"
	
	collect style cell result[count], nformat(%9.0f)	
	collect style cell result[_r_b], nformat(%3.2f)
	collect style cell result[_r_ci], nformat(%3.2f) sformat("(%s)") cidelimiter("-") 
	
	collect style header result, level(hide)
	collect style header colname_remainder, level(hide)
	collect style cell, border(right, pattern(nil))
	collect style cell, halign(left)
	
	collect layout (`var') (cmdset[1 2]#result[count] cmdset[3]#result[_r_b _r_ci] cmdset[4]#result[_r_b _r_ci])
	
	collect style putdocx, layout(autofitcontents) title("Supplement xx. Risk of Chronic Low Back Pain Associated  with `title' Excluding Participants Reporting Other Chronic Diseases")
	putdocx collect
}


////////////////////////////////////////////////////////////////////////////////
// Severe Chronic LBP as Outcome ///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

foreach var in volume_qrt intensity_qrt {
	
	if ("`var'" == "volume_qrt") {
		local main walk_tot
	}
	else if ("`var'" == "intensity_qrt") {
		local main walk_mets
	}
	
	drop `var'
	
	xtile `var' = `main' if !missing(severe_lbp), nquantile(4)
	label values `var' quarter
		
	quietly collect: table (`var') (var) if !missing(severe_lbp), statistic(count PID_114165) nototal
	quietly collect: table (`var') (var) if severe_lbp == 1 & !missing(severe_lbp), statistic(count PID_114165) nototal append

	quietly collect: poisson severe_lbp i.`var' age, vce(robust) irr
	quietly collect: poisson severe_lbp i.`var' age i.sex i.education i.income i.work_status i.smoking i.depression, vce(robust) irr
	
	collect label values cmdset 1 "No. of participants" 2 "No. of cases" 3 "Model 1" 4 "Model 2"
	
	collect style cell result[count], nformat(%9.0f)	
	collect style cell result[_r_b], nformat(%3.2f)
	collect style cell result[_r_ci], nformat(%3.2f) sformat("(%s)") cidelimiter("-") 
	
	collect style header result, level(hide)
	collect style header colname_remainder, level(hide)
	collect style cell, border(right, pattern(nil))
	collect style cell, halign(left)
	
	collect layout (`var') (cmdset[1 2]#result[count] cmdset[3]#result[_r_b _r_ci] cmdset[4]#result[_r_b _r_ci])
	
	collect style putdocx, layout(autofitcontents) title("Supplement xx. Risk of Severe Chronic Low Back Pain Associated  with `title'")
	putdocx collect
}


putdocx save "### Your file path ###\Figures\Regression_quarters_sensitivity.docx", replace