// Load Data
use "### Your file path ###\Data\Data_for_analysis_paper1.dta", clear

// Label Walking Intensity
label variable walk_mets "Walking intensity, mean (SD), METs-min"

// Create Table 1
dtable, by(volume_qrt) column(by(hide)) halign(left) ///
continuous(PID_114165, statistics(count)) ///
continuous(age) ///
factor(sex) ///
continuous(valid_days_walk walk_mets) ///
factor(education3 income work_status smoking depression) ///
nosample ///
sformat("(%s)" fvpercent) ///
nformat(%3.1f mean sd fvpercent) ///
nformat(%3.0f count frequency fvfrequency) ///
title(Table 1. Baseline Characteristics of the Study Population Stratified by Quartile of Daily Walking) ///
note(Abbreviations: MET, metabolic equivalent of task; USD, United States dollar.) ///
note(a Depression was assessed using the Hospital Anxiety and Depression Scale Depression subscale.) ///
export("### Your file path ###\Figures\Descriptives\Descriptive_table_quarters_volume.docx", replace)

// Supplement Table Including Exercise Frequency and Occupational PA
dtable, by(volume_qrt) column(by(hide)) halign(left) ///
continuous(PID_114165, statistics(count)) ///
continuous(age) ///
factor(sex) ///
continuous(valid_days_walk walk_mets) ///
factor(exerc_freq work_type) ///
nosample ///
sformat("(%s)" fvpercent) ///
nformat(%3.1f mean sd fvpercent) ///
nformat(%3.0f count frequency fvfrequency) ///
title(Table 1. Baseline Characteristics of the Study Population Stratified by Quartile of Daily Walking) ///
note(Abbreviations: MET, metabolic equivalent of task; USD, United States dollar.) ///
note(a Depression was assessed using the Hospital Anxiety and Depression Scale Depression subscale.) ///
export("### Your file path ###\Figures\Descriptives\Descriptive_table_quarters_volume_supplement.docx", replace)
