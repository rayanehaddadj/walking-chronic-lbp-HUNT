// Load Data
use "### Your file path ###\Data\2024-04-16_114165_Data.dta", clear

// Set-Up file1
tempfile file1


// Extract Participations Variables & Sociodemographic Variables

keep PID_114165 PartDat_NT4BLM PartDat_NT4CovQ ///
/// Extract Individual Characteristics ///
Sex PartAg_NT4BLM Bmi_NT4BLM BmiEld_NT4BLM ///
/// Extract SES ///
Educ_NT4BLQ1 IncoTot_NT4BLQ1 WorCu_NT4BLI ///
/// Extract Other Confounders ///
SmoStat_NT4BLQ1 HADSDepr_NT4BLQ2 WorTyp_NT4BLI  ///
/// Extract Chronic Pain Data ///
MSPaLY_NT4BLQ2 MSPaLum_NT4BLQ2 MSPaLY_NT4CovQ MSPaLum_NT4CovQ ///
/// Extract Health Status ///
Healt_NT4BLQ1  MSPaChrL4W_NT4BLQ1 MSPaLeiLim_NT4CovQ ///
/// Exract Diabetes/Cancer/CVD ///
DiaEv_NT4BLQ1 CaEv_NT4BLQ1 CarAngEv_NT4BLQ1 CarInfEv_NT4BLQ1 CarFaiEv_NT4BLQ1 ///
CarAtrFibrEv_NT4BLQ1 ApoplEv_NT4BLQ1 ///
/// Extract Self-Reported Exercise ///
ExeF_NT4BLQ1

// Save file1
save `file1'

// Set-Up file2
tempfile file2
save `file2'

// Extract Accelerometer Data Day by Day
foreach i of numlist 1/7 {
    
	// Load Data
	use "### Your file path ###\Data\2024-04-16_114165_Data.dta", clear
    
	// Extract Daily Movement Behaviours
	keep PID_114165 ActDN_NT4BLM LyTmD`i'_NT4ActMX SitTmD`i'_NT4ActMX ///
	StandTmD`i'_NT4ActMX Walk1TmD`i'_NT4ActMX Walk2TmD`i'_NT4ActMX ///
	Walk3TmD`i'_NT4ActMX WalkTmD`i'_NT4ActMX RunTmD`i'_NT4ActMX CyclTmD`i'_NT4ActMX
    
	// Merge iterations
	merge 1:1 PID_114165 using `file2', nogen
    
	// Update file2
    save `file2', replace
}

// Merge Datasets
use `file1', clear
merge 1:1 PID_114165 using `file2', nogen

// Save Data
save "### Your file path ###\Data\Extracted_data_paper1.dta", replace