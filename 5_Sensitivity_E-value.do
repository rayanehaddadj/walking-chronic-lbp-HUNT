// Load Data
use "### Your file path ###\Data\Data_for_analysis_paper1.dta", clear

// E-Values for Quaters of Volume and Itensity of Walking
foreach var in volume_qrt intensity_qrt {
	
	// Store Variable's Number of Level
	levelsof `var'
	local level = r(r)
	
	// Multi-Adjusted Poisson Regression
	quietly collect: poisson lbp_t1 i.`var' age i.sex i.education i.income i.work_status i.smoking i.depression, vce(robust) irr
	
	forval i = 2/`level' {
		
		// Store Log Risk
		local coeff = _b[`i'.`var']
	
		// Store Standard-Error
		local se = _se[`i'.`var']
	
		// Compute Risk Ratio
		local rr = exp(`coeff')
	
		// Compute 95% Confidence Interval
		local ic95_lb = exp((`coeff' - 1.96 * `se'))
		local ic95_ub = exp((`coeff' + 1.96 * `se'))
	
		// Compute E-Value if Significant Estimate
		if `rr' < 1 & `ic95_ub' < 1 {
		evalue rr `rr', lcl(`ic95_lb') ucl(`ic95_ub')
		}
	}
}