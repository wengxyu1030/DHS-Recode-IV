////////////////////////////////////////////////////////////////////////////////////////////////////
*** DHS MONITORING: IV
////////////////////////////////////////////////////////////////////////////////////////////////////

//version 15.1
clear all
set matsize 3956, permanent
set more off, permanent
set maxvar 32767, permanent
capture log close
sca drop _all
matrix drop _all
macro drop _all

******************************
*** Define main root paths ***
******************************

//NOTE FOR WINDOWS USERS : use "/" instead of "\" in your paths

* Define root depend on the stata user. 
if "`c(username)'" == "xweng"     local pc = 1
	if "`c(username)'" == "robinwang"     local pc = 4

if `pc' == 1 global root "C:/Users/XWeng/OneDrive - WBG/MEASURE UHC DATA"
	if `pc' == 4 global root "/Users/robinwang/Documents/MEASURE UHC DATA"

* Define path for data sources
global SOURCE "${root}/RAW DATA/Recode IV"
	if `pc' == 4 global SOURCE "/Volumes/Seagate Bas/HEFPI DATA/RAW DATA/DHS/DHS IV"

* Define path for output data
global OUT "${root}/STATA/DATA/SC/FINAL"
	if `pc' == 4 global OUT "${root}/STATA/DATA/SC/FINAL"

* Define path for INTERMEDIATE
global INTER "${root}/STATA/DATA/SC/INTER"
	if `pc' == 4 global INTER "${root}/STATA/DATA/SC/INTER"

* Define path for do-files
if `pc' != 0 global DO "${root}/STATA/DO/SC/DHS/DHS-Recode-IV"
	if `pc' == 4 global DO "/Users/robinwang/Documents/MEASURE UHC DATA/DHS-Recode-IV"

* Define the country names (in globals) in by Recode
do "${DO}/0_GLOBAL.do"
global DHScountries_Recode_IV "Egypt2000 Jordan2002 Chad2004 Armenia2000 Bangladesh2004 Benin2001 Bolivia2003 BurkinaFaso2003 Cambodia2000 Cameroon2004 Colombia2000 DominicanRepublic2002 DominicanRepublic1999 Ethiopia2000 Ghana2003 Haiti2000 Indonesia2002 Kenya2003 Lesotho2004 Madagascar2003 Malawi2004 Malawi2000 Mali2001 Morocco2003 Mozambique2003 Namibia2000 Nepal2001 Nicaragua2001 Nigeria2003 Peru2000 Philippines2003 Rwanda2000 Senegal2005 Tanzania2004 Tanzania1999 Turkey2003 Uganda2000 Vietnam2002 Zambia2001 Zimbabwe1999 Armenia2005 Colombia2005 Egypt2005 Ethiopia2005 Guinea2005 Moldova2005 Rwanda2005"


/*
foreach name in  $DHScountries_Recode_IV  {
    use "${SOURCE}/DHS-`name'/DHS-`name'birth.dta", clear
	capture confirm variable m57a
	if !_rc {
		di " [`name'] has it!"

		if "$placeholder" == "" {
			global placeholder "`name'"
		}
		else {
			global placeholder "$placeholder `name'"
		}
	}
}
	pause on 
	di "............."
	global DHScountries_Recode_IV "$placeholder"
	di "$DHScountries_Recode_IV"
	pause review
	
*/


/*
issue: 
Egypt2005 file C:/Users/XWeng/OneDrive - WBG/MEASURE UHC DATA/RAW DATA/Recode IV/DHS-Egypt2005/DHS-Egypt2005hm.dta not Stata format
- not uniquely identify

Indonesia2002 file C:/Users/XWeng/OneDrive - WBG/MEASURE UHC DATA/RAW DATA/Recode IV/DHS-Indonesia2002/DHS-Indonesia2002birth.dta not Stata format
- not uniquely identify

Madagascar2003 file C:/Users/XWeng/OneDrive - WBG/MEASURE UHC DATA/RAW DATA/Recode IV/DHS-Madagascar2003/DHS-Madagascar2003ind.dta not Stata format

Nepal2001birth file C:/Users/XWeng/OneDrive - WBG/MEASURE UHC DATA/RAW DATA/Recode IV/DHS-Nepal2001/DHS-Nepal2001birth.dta not found
- not uniquely identify

Nicaragua2001 file C:/Users/XWeng/OneDrive - WBG/MEASURE UHC DATA/RAW DATA/Recode   IV/DHS-Nicaragua2001/DHS-Nicaragua2001birth.dta not found
- not uniquely identify

Philippines2003 file C:/Users/XWeng/OneDrive - WBG/MEASURE UHC DATA/RAW DATA/Recode    IV/DHS-Philippines2003/DHS-Philippines2003birth.dta not found
- not uniquely identify

Tanzania2004 file C:/Users/XWeng/OneDrive - WBG/MEASURE UHC DATA/RAW DATA/Recode  IV/DHS-Tanzania2004/DHS-Tanzania2004birth.dta not found
- not uniquely identify

Turkey2003 file C:/Users/XWeng/OneDrive - WBG/MEASURE UHC DATA/RAW DATA/Recode  IV/DHS-Turkey2003/DHS-Turkey2003birth.dta not found
- not uniquely identify

Vietnam2002 file C:/Users/XWeng/OneDrive - WBG/MEASURE UHC DATA/RAW DATA/Recode IV/DHS-Vietnam2002/DHS-Vietnam2002birth.dta not found
- not uniquely identify
*/

foreach name in  $DHScountries_Recode_IV  {

    
tempfile birth ind men hm hiv hh zsc iso wi

************************************
***domains using zsc data***********
************************************
capture confirm file "${SOURCE}/DHS-`name'/DHS-`name'zsc.DTA"	
if _rc == 0 {
    use "${SOURCE}/DHS-`name'/DHS-`name'zsc.dta", clear
    if hwlevel == 2 {
		gen caseid = hwcaseid
		gen bidx = hwline   	  
		merge 1:1 caseid bidx using "${SOURCE}/DHS-`name'/DHS-`name'birth.dta"
    	gen ant_sampleweight = v005/10e6  
    	drop if _!=3
		
		clonevar c_motherln = v003 /*DW Nov 2021 - use v003 from birth.dta in the zsc dependent code chunk*/
		
  		foreach var in hc70 hc71 hc72 {
  	 	replace `var'=. if `var'>900
  	 	replace `var'=`var'/100
  		}
  		replace hc70=. if hc70<-6 | hc70>6
  		replace hc71=. if hc71<-6 | hc71>5
   		replace hc72=. if hc72<-6 | hc72>5

		gen c_stunted=1 if hc70<-2
 		replace c_stunted=0 if hc70>=-2 & hc70!=.
 		gen c_underweight=1 if hc71<-2
 		replace c_underweight=0 if hc71>=-2 & hc71!=.
 		gen c_wasted=1 if hc72<-2
 		replace c_wasted=0 if hc72>=-2 & hc72!=.
		gen c_stunted_sev=1 if hc70<-3
		replace c_stunted_sev=0 if hc70>=-3 & hc70!=.
		gen c_underweight_sev=1 if hc71<-3
		replace c_underweight_sev=0 if hc71>=-3 & hc71!=.
		gen c_wasted_sev=1 if hc72<-3
		replace c_wasted_sev=0 if hc72>=-3 & hc72!=.				

*c_stu_was: Both stunted and wasted
		gen c_stu_was = (c_stunted == 1 & c_wasted ==1) 
		replace c_stu_was = . if c_stunted == . | c_wasted == . 
		label define l_stu_was 1 "Both stunted and wasted"
		label values c_stu_was l_stu_was		

*c_stu_was_sev: Both severely stunted and severely wasted		
		gen c_stu_was_sev = (c_stunted_sev == 1 & c_wasted_sev == 1)
		replace c_stu_was_sev = . if c_stunted_sev == . | c_wasted_sev == . 
		label define l_stu_was_sev 1 "Both severely stunted and severely wasted"
		label values c_stu_was_sev l_stu_was_sev
		
		rename ant_sampleweight c_ant_sampleweight
		keep c_* caseid bidx hwlevel hc70 hc71 hc72
		save "${INTER}/zsc_birth.dta",replace
    }

 	if hwlevel == 1 {
 		gen hhid = hwhhid
 		gen hvidx = hwline
 		merge 1:1 hhid hvidx using "${SOURCE}/DHS-`name'/DHS-`name'hm.dta", keepusing(hv103 hv001 hv002 hv005 hv112)
 		drop if hv103==0
 		gen ant_sampleweight = hv005/10e6
 		drop if _!=3
		gen ant_hm = 1

		gen c_motherln = hv112
		
  		foreach var in hc70 hc71 hc72 {
  	 	replace `var'=. if `var'>900
  	 	replace `var'=`var'/100
  		}
  		replace hc70=. if hc70<-6 | hc70>6
  		replace hc71=. if hc71<-6 | hc71>5
   		replace hc72=. if hc72<-6 | hc72>5
		gen c_stunted=1 if hc70<-2
 		replace c_stunted=0 if hc70>=-2 & hc70!=.
 		gen c_underweight=1 if hc71<-2
 		replace c_underweight=0 if hc71>=-2 & hc71!=.
 		gen c_wasted=1 if hc72<-2
 		replace c_wasted=0 if hc72>=-2 & hc72!=.
		gen c_stunted_sev=1 if hc70<-3
		replace c_stunted_sev=0 if hc70>=-3 & hc70!=.
		gen c_underweight_sev=1 if hc71<-3
		replace c_underweight_sev=0 if hc71>=-3 & hc71!=.
		gen c_wasted_sev=1 if hc72<-3
		replace c_wasted_sev=0 if hc72>=-3 & hc72!=.				

*c_stu_was: Both stunted and wasted
		gen c_stu_was = (c_stunted == 1 & c_wasted ==1) 
		replace c_stu_was = . if c_stunted == . | c_wasted == . 
		label define l_stu_was 1 "Both stunted and wasted"
		label values c_stu_was l_stu_was		

*c_stu_was_sev: Both severely stunted and severely wasted		
		gen c_stu_was_sev = (c_stunted_sev == 1 & c_wasted_sev == 1)
		replace c_stu_was_sev = . if c_stunted_sev == . | c_wasted_sev == . 
		label define l_stu_was_sev 1 "Both severely stunted and severely wasted"
		label values c_stu_was_sev l_stu_was_sev
			    
		rename ant_sampleweight c_ant_sampleweight
		keep c_* hhid hvidx hc70 hc71 hc72
		save "${INTER}/zsc_hm.dta",replace
    }

 }

******************************
*****domains using birth data*
******************************
use "${SOURCE}/DHS-`name'/DHS-`name'birth.dta", clear	

    gen hm_age_mon = (v008 - b3)           //hm_age_mon Age in months (children only)
    gen name = "`name'"
	
    do "${DO}/1_antenatal_care"
    do "${DO}/2_delivery_care"
    do "${DO}/3_postnatal_care"
    do "${DO}/7_child_vaccination"
    do "${DO}/8_child_illness"
    do "${DO}/10_child_mortality"
    do "${DO}/11_child_other"
	
	capture confirm file "${INTER}/zsc_birth.dta"
	if _rc == 0 {
	merge 1:1 caseid bidx using "${INTER}/zsc_birth.dta",nogen
	rename (hc70 hc71 hc72) (c_hc70 c_hc71 c_hc72)
    }
	
*housekeeping for birthdata
   //generate the demographics for child who are dead or no longer living in the hh. 
   
    *hm_live Alive (1/0)
    recode b5 (1=0)(0=1) , ge(hm_live)   
	label var hm_live "died" 
	label define yesno 0 "No" 1 "Yes"
	label values hm_live yesno 

    *hm_dob	date of birth (cmc)
    gen hm_dob = b3  

    *hm_age_yrs	Age in years       
    gen hm_age_yrs = b8        

    *hm_male Male (1/0)         
    recode b4 (2 = 0),gen(hm_male)  
	
    *hm_doi	date of interview (cmc)
    gen hm_doi = v008
	
	if inlist(name,"DominicanRepublic1999","Tanzania1999"){
		ren s219 b16
	}
	if inlist(name,"Vietnam2002"){
		gen  b16 =.
	}
	*identify the case where there is no child line info in hm.dta 
    mdesc b16 
    gen miss_b16 = 1 if r(percent) == 100 

if miss_b16 != 1 {
rename (v001 v002 b16) (hv001 hv002 hvidx)
}

if miss_b16 == 1 {
rename (v001 v002 v003) (hv001 hv002 hvidx) //v003 in birth.dta: mother's line number
}

	* FEB 2022 DW
	gen w_married=(v502==1)
	replace w_married=. if inlist(v502,.,9)
	
keep hv001 hv002 hvidx bidx c_* mor_* w_* hm_* 
save `birth'



******************************
*****domains using ind data***
******************************
use "${SOURCE}/DHS-`name'/DHS-`name'ind.dta", clear	
gen name = "`name'"
gen hm_age_yrs = v012
    do "${DO}/4_sexual_health"
    do "${DO}/5_woman_anthropometrics"
    do "${DO}/16_woman_cancer"
*housekeeping for ind data

    *hm_dob	date of birth (cmc)
    gen hm_dob = v011  
	
	
keep v001 v002 v003 w_* hm_*
rename (v001 v002 v003) (hv001 hv002 hvidx)
save `ind' 


************************************
*****domains using hm level data****
************************************
use "${SOURCE}/DHS-`name'/DHS-`name'hm.dta", clear
gen name = "`name'"
    do "${DO}/13_adult"
    do "${DO}/14_demographics"

capture confirm file "${INTER}/zsc_hm.dta"
	
	if _rc == 0 {
	merge 1:1 hhid hvidx using "${INTER}/zsc_hm.dta",nogen
	rename (hc70 hc71 hc72) (hm_hc70 hm_hc71 hm_hc72)
	}
	
    if _rc != 0 {
	  capture confirm file "${INTER}/zsc_birth.dta"
	    if _rc != 0 {
          do "${DO}/9_child_anthropometrics"  //if there's no zsc related file, then run 9_child_anthropometrics
	      rename ant_sampleweight c_ant_sampleweight
		}
    }	
gen c_placeholder = 1
sort hv001 hv002 hvidx
keep hv001 hv002 hvidx a_* hm_* ln c_* 

save `hm'

gen name = "`name'"
if !inlist(name,"DominicanRepublic2002","Mali2001","Zambia2001"){
capture confirm file "${SOURCE}/DHS-`name'/DHS-`name'hiv.dta"
 	if _rc==0 {
    use "${SOURCE}/DHS-`name'/DHS-`name'hiv.dta", clear
	gen name = "`name'"
    do "${DO}/12_hiv"
 	}
capture confirm file "${SOURCE}/DHS-`name'/DHS-`name'hiv.dta"
 	if _rc!= 0 {
    gen a_hiv = . 
    gen a_hiv_sampleweight = .
    }  
}

if inlist(name,"DominicanRepublic2002","Mali2001","Zambia2001"){
    gen a_hiv = . 
    gen a_hiv_sampleweight = .
}	
keep a_hiv* hv001 hv002 hvidx
sort hv001 hv002 hvidx
save `hiv'

use `hm',clear
merge 1:1 hv001 hv002 hvidx using `hiv'
drop _merge
save `hm',replace

************************************
*****domains using hh level data****
************************************
gen name = "`name'"
if !inlist(name,"Mali2001","Senegal2005"){
use "${SOURCE}/DHS-`name'/DHS-`name'hm.dta", clear
    rename (hv001 hv002 hvidx) (v001 v002 v003)

    merge 1:m v001 v002 v003 using "${SOURCE}/DHS-`name'/DHS-`name'birth.dta"
    rename (v001 v002 v003) (hv001 hv002 hvidx) 
    drop _merge
	gen name = "`name'"
}
* For Mali2001 & Senegal2005, the hv002 lost 2-3 digits, fix this issue in main.do, 1.do,4.do,12.do & 13.do
if inlist(name,"Mali2001","Senegal2005"){
	tempfile birthspec
	use "${SOURCE}/DHS-`name'/DHS-`name'birth.dta",clear
	drop v002
	gen v002 = substr(caseid,8,5)
	save `birthspec',replace
	
	use "${SOURCE}/DHS-`name'/DHS-`name'hm.dta", clear
	drop hv002
	gen hv002 = substr(hhid,8,5)
	isid hv001 hv002 hvidx
	order hhid hv000 hv001 hv002
    rename (hv001 hv002 hvidx) (v001 v002 v003)

    merge 1:m v001 v002 v003 using `birthspec'
    rename (v001 v002 v003) (hv001 hv002 hvidx) 
    drop _merge
	gen name = "`name'"
}
	
capture confirm file "${SOURCE}/DHS-`name'/DHS-`name'wi.dta"
 	if _rc==0 {
	preserve
    use "${SOURCE}/DHS-`name'/DHS-`name'wi.dta", clear
		ren (whhid wlthindf wlthind5) (hhid hv271 hv270)
	save `wi',replace
	restore
	merge m:1 hhid using `wi',nogen
	replace hv271=hv271*10e4
 }
    do "${DO}/15_household"

keep hhid hv001 hv002 hv003 hh_* 
save `hh',replace 


************************************
*****merge to microdata*************
************************************

***match with external iso data
use "${SOURCE}/external/iso", clear 
keep country iso2c iso3c
replace country = "BurkinaFaso" if country == "Burkina Faso"
replace country = "DominicanRepublic" if country == "Dominican Republic"
replace country = "Moldova" if country == "Moldova, Republic of"
replace country = "Tanzania" if country == "Tanzania, United Republic of"
save `iso'

***merge all subset of microdata
use `birth',clear 
mdesc hvidx //identify the case where there is no child line info in hm.dta 
gen miss_b16 = 1 if r(percent) == 1

if miss_b16 == 1 {
   //when b16 is missing, the hm.dta can not be merged with birth.dta, the final microdata would be women and child only.
  
    merge m:1 hv001 hv002 hvidx using `ind',nogen update //merge child in birth.dta to mother in ind.dta
    merge m:m hv001 hv002       using `hh',nogen update 
}

if miss_b16 != 1 {

  use `hm',clear //when b16 is not missing, the hm.dta can be merged with birth.dta, the final microdata has all household member info

    merge 1:m hv001 hv002 hvidx using `birth',update              //missing update is zero, non missing conflict for all matched.(hvidx different) 
    replace hm_headrel = 99 if _merge == 2
	label define hm_headrel_lab 1 "head" 2 "wife/husband" 3 "son/daughter" 4 "son/daughter-in-law" 5 "grandchild" 6 "parent" 7 "parent-in-law" 8 "brother/sister" 10 "other relative" 11 "adopted child" 12 "not related" 13 "foster" 14 "stepchild" 99 "dead/no longer in the household"
	label values hm_headrel hm_headrel_lab
	replace hm_live = 0 if _merge == 2 | inlist(hm_headrel,.,12,98)
	drop _merge
    merge m:m hv001 hv002 hvidx using `ind',nogen update
	merge m:m hv001 hv002       using `hh',nogen update
    
    tab hh_urban,mi  //check whether all hh member + dead child + child lives outside hh assinged hh info
}

capture confirm variable c_hc70 c_hc71 c_hc72
if _rc == 0 {
rename (c_hc70 c_hc71 c_hc72) (hc70 hc71 hc72)
}

capture confirm variable hm_hc70 hm_hc71 hm_hc72
if _rc == 0 {
rename (hm_hc70 hm_hc71 hm_hc72) (hc70 hc71 hc72)
}

rename c_ant_sampleweight ant_sampleweight
drop c_placeholder

***survey level data
    gen survey = "DHS-`name'"
	gen year = real(substr("`name'",-4,.))
	tostring(year),replace
    gen country = regexs(0) if regexm("`name'","([a-zA-Z]+)")
	
    merge m:1 country using `iso',force
    drop if _merge == 2
	drop _merge

*** Quality Control: Validate with DHS official data
gen surveyid = iso2c+year+"DHS"
gen name = "`name'"
 
* to match with HEFPI_DHS.dta surveyid (differ in year)
	if inlist(name,"Colombia2005") {
		replace surveyid = "CO2004DHS"
	}
	 
preserve
	do "${DO}/Quality_control"
	save "${INTER}/quality_control-`name'",replace
	cd "${INTER}"
	do "${DO}/Quality_control_result"
	save "${OUT}/quality_control",replace 
restore 
*** Specify sample size to HEFPI
	
    ***for variables generated from 1_antenatal_care 2_delivery_care 3_postnatal_care
	foreach var of var c_anc	c_anc_any	c_anc_bp	c_anc_bp_q	c_anc_bs	c_anc_bs_q ///
	c_anc_ear	c_anc_ear_q	c_anc_eff	c_anc_eff_q	c_anc_eff2	c_anc_eff2_q ///
	c_anc_eff3	c_anc_eff3_q	c_anc_ir	c_anc_ir_q	c_anc_ski	c_anc_ski_q ///
	c_anc_tet	c_anc_tet_q	c_anc_ur	c_anc_ur_q	c_caesarean	c_earlybreast ///
	c_facdel	c_hospdel	c_sba	c_sba_eff1	c_sba_eff1_q	c_sba_eff2 ///
	c_sba_eff2_q	c_sba_q	c_skin2skin	c_pnc_any	c_pnc_eff	c_pnc_eff_q c_pnc_eff2 ///
	c_pnc_eff2_q c_anc_public c_anc_hosp {
    replace `var' = . if !(inrange(hm_age_mon,0,23)& bidx ==1)
    }
	
	***for variables generated from 7_child_vaccination
	foreach var of var c_bcg c_dpt1 c_dpt2 c_dpt3 c_fullimm c_measles ///
	c_polio1 c_polio2 c_polio3{
    replace `var' = . if !inrange(hm_age_mon,15,23)
    }
	
	***for variables generated from 8_child_illness	
	foreach var of var c_ari c_ari2 c_diarrhea  c_diarrhea_hmf	c_diarrhea_medfor	c_diarrhea_mof	c_diarrhea_pro	c_diarrheaact ///
	c_diarrheaact_q	c_fever	c_fevertreat	c_illness	c_illness2 c_illtreat c_illtreat2 c_sevdiarrhea	c_sevdiarrheatreat ///
	c_sevdiarrheatreat_q	c_treatARI c_treatARI2	c_treatdiarrhea	c_diarrhea_med {
    replace `var' = . if !inrange(hm_age_mon,0,59)
    }
	
	***for vriables generated from 9_child_anthropometrics //
	foreach var of var c_underweight c_underweight_sev c_stunted c_stunted_sev c_wasted c_wasted_sev c_stu_was c_stu_was_sev ant_sampleweight hc70 hc71 hc72 {
    replace `var' = . if !inrange(hm_age_mon,0,59)
    }
	
	***for hive indicators from 12_hiv
	foreach var of var a_hiv*{
	replace `var'=. if hm_age_yrs<15 | (hm_age_yrs>49 & hm_age_yrs!=.)
    }	
	
	***for hive indicators from 13_adult
	foreach var of var a_diab_treat	a_inpatient_1y a_bp_treat a_bp_sys a_bp_dial a_hi_bp140_or_on_med a_bp_meas{
    replace `var'=. if hm_age_yrs<18
    }
	
*** Label variables
	* DW Nov 2021
	rename hc71 c_wfa
	rename hc70 c_hfa
	rename hc72 c_wfh
	
    drop bidx surveyid
    do "${DO}/Label_var" 
*** Clean the intermediate data
    capture confirm file "${INTER}/zsc_birth.dta"
    if _rc == 0 {
    erase "${INTER}/zsc_birth.dta"
    }	
    
	capture confirm file"${INTER}/zsc_hm.dta"
    if _rc == 0 {
    erase "${INTER}/zsc_hm.dta"
    }	
	
save "${OUT}/DHS-`name'.dta", replace   
}




