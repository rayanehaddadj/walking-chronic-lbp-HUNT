// Load Data
use "### Your file path ###\Paper1_perso\Data\Data_for_analysis_paper1.dta", clear

// Create Word Document
putdocx clear
putdocx begin
putdocx paragraph


////////////////////////////////////////////////////////////////////////////////
// Analyses Stratified on Age 65 ///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

foreach var in volume_qrt intensity_qrt {
	
	forval i = 0/1 {
		
		collect clear
		
		// Number of Participants by Quarter
		quietly collect: table (`var') (var) if age65 == `i', ///
		statistic(count PID_114165) nototal
		
		// Number of Chronic LBP Cases by Quarter
		quietly collect: table (`var') (var) if age65 == `i' & lbp_t1 == 1, ///
		statistic(count PID_114165) nototal append
		
		// Age-Adjusted Poisson Regression
		quietly collect: poisson lbp_t1 i.`var' age if age65 == `i', vce(robust) irr
		
		// Stratified Poisson Regression
		quietly collect: poisson lbp_t1 i.`var' age i.sex i.education i.income i.work_status i.smoking i.depression if age65 == `i', vce(robust) irr
	
		// Label Row Headers
		collect label values cmdset 1 "No. of participants" 2 "No. of cases" 3 "Age-adjusted, RR (95% CI)a" 4 "Multi-adjusted, RR (95% CI)b"
		
		// Format Cells Values
		collect style cell result[count], nformat(%9.0f)	
		collect style cell result[_r_b], nformat(%3.2f)
		collect style cell result[_r_ci], nformat(%3.2f) sformat("(%s)") cidelimiter("-") 
		
		// Format Cells Headers and Borders
		collect style header result, level(hide)
		collect style header colname_remainder, level(hide)
		collect style cell, border(right, pattern(nil))
		collect style cell, halign(left)
		
		// Create Layout for Table
		quietly collect layout (`var') (cmdset[1 2]#result[count] cmdset[3]#result[_r_b _r_ci] cmdset[4]#result[_r_b _r_ci])
	
		collect style putdocx, layout(autofitcontents) ///
		title("Table X. Risk Ratios and 95% CI for Chronic Low Back Pain Associated with `var' Stratified on Age65 = `i'")
		
		putdocx collect
	}
}

putdocx paragraph
putdocx text ("Abbreviations: RR, risk ratio; CI, confidence interval.")

putdocx paragraph
putdocx text ("a Adjusted for age (continuous), sex (female, male), education (primary school, 1-2 y of academic/vocational school, 3y of academic/vocational school, 3-4y vocational school/apprentice, university <4y, university ≥4y), income (<25 000, 25 000-45 000, 45 100-75 000, 75 100-100 000, >100 000 USD/year), employment status (employed, non-employed), smoking status (never, former, current) and major depression (no, yes).")


////////////////////////////////////////////////////////////////////////////////
// Analyses Stratified on Sex //////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

foreach var in volume_qrt intensity_qrt {
	
	forval i = 0/1 {
		
		collect clear
		
		// Number of Participants by Quarter
		quietly collect: table (`var') (var) if sex == `i', ///
		statistic(count PID_114165) nototal
		
		// Number of Chronic LBP Cases by Quarter
		quietly collect: table (`var') (var) if sex == `i' & lbp_t1 == 1, ///
		statistic(count PID_114165) nototal append
		
		// Age-Adjusted Poisson Regression
		quietly collect: poisson lbp_t1 i.`var' age if sex == `i', vce(robust) irr
		
		// Stratified Poisson Regression
		quietly collect: poisson lbp_t1 i.`var' age i.education i.income i.work_status i.smoking i.depression if sex == `i', vce(robust) irr
	
		// Label Row Headers
		collect label values cmdset 1 "No. of participants" 2 "No. of cases" 3 "Age-adjusted, RR (95% CI)a" 4 "Multi-adjusted, RR (95% CI)b"
		
		// Format Cells Values
		collect style cell result[count], nformat(%9.0f)	
		collect style cell result[_r_b], nformat(%3.2f)
		collect style cell result[_r_ci], nformat(%3.2f) sformat("(%s)") cidelimiter(" - ") 
		
		// Format Cells Headers and Borders
		collect style header result, level(hide)
		collect style header colname_remainder, level(hide)
		collect style cell, border(right, pattern(nil))
		collect style cell, halign(left)
		
		// Create Layout for Table
		quietly collect layout (`var') (cmdset[1 2]#result[count] cmdset[3]#result[_r_b _r_ci] cmdset[4]#result[_r_b _r_ci])
	
		collect style putdocx, layout(autofitcontents) ///
		title("Table X. Risk Ratios and 95% CI for Chronic Low Back Pain Associated with `var' Stratified on Sex = `i'")
		
		putdocx collect
	}
}

putdocx paragraph
putdocx text ("Abbreviations: RR, risk ratio; CI, confidence interval.")

putdocx paragraph
putdocx text ("a Adjusted for age (continuous).")

putdocx paragraph
putdocx text ("b Adjusted for age (continuous), sex (female, male), education (primary school, 1-2 y of academic/vocational school, 3y of academic/vocational school, 3-4y vocational school/apprentice, university <4y, university ≥4y), income (<25 000, 25 000-45 000, 45 100-75 000, 75 100-100 000, >100 000 USD/year), employment status (employed, non-employed), smoking status (never, former, current) and major depression (no, yes).")


////////////////////////////////////////////////////////////////////////////////
// Walking Volume Stratified on Walking Intensity //////////////////////////////
////////////////////////////////////////////////////////////////////////////////

forval i = 1/4 {
	
	collect clear
		
	// Number of Participants by Quarter
	quietly collect: table (volume_qrt) (var) if intensity_qrt == `i', ///
	statistic(count PID_114165) nototal
		
	// Number of Chronic LBP Cases by Quarter
	quietly collect: table (volume_qrt) (var) if intensity_qrt == `i' & lbp_t1 == 1, ///
	statistic(count PID_114165) nototal append
	
	// Age-Adjusted Poisson Regression
	quietly collect: poisson lbp_t1 i.volume_qrt age if intensity_qrt == `i', vce(robust) irr
	
	// Multi-Adjusted Poisson Regression
	quietly collect: poisson lbp_t1 i.volume_qrt age i.sex i.education i.income i.work_status i.smoking i.depression if intensity_qrt == `i', vce(robust) irr
	
	// Label Row Headers
	collect label values cmdset 1 "No. of participants" 2 "No. of cases" 3 "Age-adjusted, RR (95% CI)a" 4 "Multi-adjusted, RR (95% CI)b"
		
	// Format Cells Values
	collect style cell result[count], nformat(%9.0f)	
	collect style cell result[_r_b], nformat(%3.2f)
	collect style cell result[_r_ci], nformat(%3.2f) sformat("(%s)") cidelimiter(" - ") 
		
	// Format Cells Headers and Borders
	collect style header result, level(hide)
	collect style header colname_remainder, level(hide)
	collect style cell, border(right, pattern(nil))
	collect style cell, halign(left)
		
	// Create Layout for Table
	quietly collect layout (volume_qrt) (cmdset[1 2]#result[count] cmdset[3]#result[_r_b _r_ci] cmdset[4]#result[_r_b _r_ci])
	
	collect style putdocx, layout(autofitcontents) ///
	title("Table X. Risk Ratios and 95% CI for Chronic Low Back Pain Associated with `var' Stratified on Walking Intensity Quarter = `i'")
		
	putdocx collect
}

putdocx paragraph
putdocx text ("Abbreviations: RR, risk ratio; CI, confidence interval.")

putdocx paragraph
putdocx text ("a Adjusted for age (continuous).")

putdocx paragraph
putdocx text ("n Adjusted for age (continuous), sex (female, male), education (primary school, 1-2 y of academic/vocational school, 3y of academic/vocational school, 3-4y vocational school/apprentice, university <4y, university ≥4y), income (<25 000, 25 000-45 000, 45 100-75 000, 75 100-100 000, >100 000 USD/year), employment status (employed, non-employed), smoking status (never, former, current) and major depression (no, yes).")


// Save Word Document
putdocx save "### Your file path ###\Paper1_perso\Figures\Regression_quarters_stratified.docx", replace
