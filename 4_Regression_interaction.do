// Load data
use "### Your file path ###\Data\Data_for_analysis_paper1.dta", clear

// LR Test of Interaction Term for Age ± 65 Using Poisson Regression
poisson lbp_t1 i.volume_qrt i.sex i.age65 i.education i.income i.work_status i.smoking i.depression

estimate store model1

poisson lbp_t1 i.volume_qrt##i.age65 i.sex i.education i.income i.work_status i.smoking i.depression

lrtest model1

// LR Test of Interaction Term for Sex Using Poisson Regression
poisson lbp_t1 i.volume_qrt i.sex age i.education i.income i.work_status i.smoking i.depression

estimate store model1

poisson lbp_t1 i.volume_qrt##i.sex age i.education i.income i.work_status i.smoking i.depression

lrtest model1