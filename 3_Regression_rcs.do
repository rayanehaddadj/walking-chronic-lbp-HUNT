// Create Word Document
putdocx clear
putdocx begin
putdocx paragraph


foreach var in walk_tot walk_mets {
	
	// Load Data
	use "### Your file path ###\Data\Data_for_analysis_paper1.dta", clear
	
	// Variable Descriptives for Knots and Plot Scale
	quietly sum `var', detail
	local min = r(min)
	local max = r(max)
	local p10 = r(p10)
	local p50 = r(p50)
	local p90 = r(p90)

	// Define X-Axis Title
	local label: variable label `var'
	
	// Define X-Axis Scale
	if (`max' >= 100) {
		local incr_spline = 0.25
		local incr_x = 30
		local frmt %3.0f
		local max_x = `max'
	}
	else {
		local incr_spline = 0.01
		local incr_x = 0.2
		local frmt %3.1f
		local max_x = 4.2
	}
	
	// Define Plot Label
	if (`var' == walk_tot) {
		local letter "A"
		local title "Daily walking and risk of chronic low back pain"
	}
	else if (`var' == walk_mets) {
		local letter "B"
		local title "Walking intensity and risk of chronic low back pain"
	}
	
	// Create Knots for RCS
	quietly mkspline `var'_spline = `var', cubic nknots(3) knots(`p10' `p50' `p90') displayknots
	mat knots = r(knots)
	
	// Multi-Adjusted RCS Poisson Regression
	poisson lbp_t1 `var'_spline* age i.sex i.education i.income i.work_status i.smoking i.depression, vce(robust)
	
	// Generate Estimates Based on RCS Poisson Regression
	quietly xbrcspline `var'_spline, values(`min'(`incr_spline')`max') ref(`p10') eform matknots(knots) gen(`var'_rcs rr lb ub)

	// Use 95% CI Boundaries for Y-Axis Scale
	quietly sum lb
	local min_lb = r(min)
	quietly sum ub
	local max_ub = r(max)
	local max_ub2 = `max_ub' + 0.18
	
	// Define Y-Axis Scale and Increment
	if (`max_ub' == 1 & `min_lb' <= 0.4) {
		local min_y 0.2
		local incr_y1 0.2(0.1)0.9
	} 
	else if (`max_ub'< 2 & `min_lb'> 0.4) {
		local min_y 0.3
		local incr_y1 0.3(0.1)0.9
		local incr_y2 1.2(0.2)`max_ub2'
	} 
	else {
		local min_y 0.3
		local incr_y1 0.3(0.1)0.9
		local incr_y2 1.2(0.2)`max_ub2'
	}
	
   	twoway ///	
	(rarea lb ub `var'_rcs, lwidth(none) acolor(navy%50) sort yaxis(1)) ///
	(line rr `var'_rcs, lcolor(navy%100) sort yaxis(1)) ///
	(histogram `var'_spline1, frequency fc(dimgray) ls(black) bin(50) yaxis(2)), ///
	legend(off) plotregion(margin(zero)) ///
	ytitle("{bf: Adjuted Risk Ratio}", size(small) axis(1)) ///
	yscale(log range(`min_y' `max_ub') lwidth(vthin) lcolor(black) axis(1)) ///
	ylabel(`incr_y1' 1 "1" `incr_y2', tlcolor(black) labsize(small) format(%2.1f) glstyle(grid) glcolor(gray%15) axis(1)) /// glstyle(grid) or nogrid
	xtitle("{bf: `label'}", size(small) margin(vsmall)) ///
	xscale(range(`min' `max') lwidth(vthin) lcolor(black)) ///
	xlabel(`min'(`incr_x')`max_x', tlcolor(black) labsize(small) format(`frmt') nogrid) ///
	ytitle("{bf: Histogram frequency}", size(small) axis(2)) ///
	yscale(range(0 4500) lwidth(vthin) lcolor(black) axis(2)) ///
	ylabel(0(500)1000, tlcolor(black) labsize(small) format(%2.0f) axis(2)) ///
	title("{bf:`letter' } `title'", size(small) span position(11) margin(2.5 0 3.5 0)) ///
	graphregion(margin(small))
	
	graph save "### Your file path ###\Figures\Graph\\`var'.gph", replace
	graph export "### Your file path ###\Figures\Graph\\`var'.png", replace
	putdocx image "### Your file path ###\Figures\Graph\\`var'.png"
}


////////////////////////////////////////////////////////////////////////////////
// Dual Plot Volume and Intensity of Walking ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Combine Plots
graph combine "### Your file path ###\Figures\Graph\walk_tot.gph" ///
"### Your file path ###\Figures\Graph\walk_mets.gph", ///
col(1) xsize(4) graphregion(margin(zero))

// Export Plot in PDF and Png
graph export "### Your file path ###\Figures\Graph\duo_rcs.pdf", replace
graph export "### Your file path ###\Figures\Graph\duo_rcs.png", replace

// Plot Title
putdocx text ("Figure X. Dose-Response Association of Volume of Daily Walking Volume and Walking Intensity at Baseline in 2017-2019 with Risk of Chronic Low Back Pain at Follow-up in 2021-2023"), bold

// Add Plot to Word Document
putdocx image "### Your file path ###\Figures\Graph\duo_rcs.png"

// Plot Legend
putdocx text ("The left y-axis is a log scale with the shaded area representing 95% CIs. Model are adjusted for age, sex, education, income, employment status, smoking status and depression. Reference is set at the 10th percentile of the distribution. Abbreviation: MET, Metabolic Equivalent of Task.")

// Save Word Document
putdocx save "### Your file path ###\Figures\Regression_rcs_plots.docx", replace