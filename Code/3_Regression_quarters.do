// Load Data
use "### Your file path ###\Paper1_perso\Data\Data_for_analysis_paper1.dta", clear

// Create Word Document
putdocx clear
putdocx begin

// Table 2 Title
putdocx paragraph
putdocx text ("Table 2. Risk of Chronic Low Back Pain at Follow-Up in 2021-2023 Associated with Volume of Daily Walking and Walking Intensity at Baseline in 2017-2019"), bold

// Table 3 Title
putdocx paragraph
putdocx text ("Table 3. Risk of Chronic Low Back Pain at Follow-Up in 2021-2023 Associated with the Joint Association of Daily Walking and Walking Intensity in 2017-2019"), bold


foreach var in volume_qrt intensity_qrt joint_qrt {
	
	// Reinitialize Collect Command
	collect clear
	
	// Number of Participants by Quarter
	quietly collect: table (`var') (var), statistic(count PID_114165) nototal
	
	// Number of Chronic LBP Cases by Quarter
	quietly collect: table (`var') (var) if lbp_t1 == 1, statistic(count PID_114165) nototal append

	// Age-Adjusted Poisson Regression
	quietly collect: poisson lbp_t1 i.`var' age, vce(robust) irr
	
	// Multi-Adjusted Poisson Regression
	quietly collect: poisson lbp_t1 i.`var' age i.sex i.education i.income i.work_status i.smoking i.depression, vce(robust) irr
	
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
	
	// Individual Table Title
	collect style putdocx, layout(autofitcontents) title("Table X. Risk Ratios and 95% CI for Chronic Low Back Pain Associated with `var'")
	
	// Add Table to Word Document	
	putdocx collect
}

// Table Abbreviations
putdocx paragraph
putdocx text ("Abbreviations: RR, risk ratio; CI, confidence interval.")

// Model a Adjustment
putdocx paragraph
putdocx text ("a Adjusted for age (continuous).")

// Model b Adjustment
putdocx paragraph
putdocx text ("b Adjusted for age (continuous), sex (female, male), education (primary school, 1-2 y of academic/vocational school, 3y of academic/vocational school, 3-4y vocational school/apprentice, university <4y, university ≥4y), income (<25 000, 25 000-45 000, 45 100-75 000, 75 100-100 000, >100 000 USD/year), employment status (employed, non-employed), smoking status (never, former, current) and major depression (no, yes).")

// Save Word Document
putdocx save "### Your file path ###\Paper1_perso\Figures\Regression_quarters.docx", replace
