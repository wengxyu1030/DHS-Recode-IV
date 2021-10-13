********************
*** adult***********
********************
*a_inpatient	18y+ household member hospitalized, recall period as close to 12 months as possible  (1/0)
    gen a_inpatient_1y = . 
	
*a_inpatient_ref	18y+ household member hospitalized recall period (in month), as close to 12 months as possible
    gen a_inpatient_ref = . 
	
	if inlist(name, "Namibia2000"){
		replace a_inpatient_1y = sh44 if sh44<8
		replace a_inpatient_ref =  12
	}
	
	if inlist(name, "Nicaragua2001"){
		replace a_inpatient_1y = sh90 if sh90<8
		replace a_inpatient_ref =  12
	}

	if inlist(name, "Rwanda2005"){
		tempfile t1 
		preserve 
		use "${SOURCE}/DHS-Rwanda2005/DHS-Rwanda2005ind.dta", clear
		keep v001 v002 v003 s119b
		save `t1',replace
		
		use "${SOURCE}/DHS-Rwanda2005/DHS-Rwanda2005men.dta", clear
		keep mv001 mv002 mv003 sm129ab
		ren (mv001 mv002 mv003 sm129ab) (v001 v002 v003 s119b)
		
		append using `t1'
		isid v001 v002 v003
		ren (v001 v002 v003) (hv001 hv002 hvidx)
		save `t1',replace 
		restore 
		merge 1:1 hv001 hv002 hvidx using `t1'
		tab _m
		drop _m // fully merged
		
		replace a_inpatient_1y = s119b if s119b<8
		replace a_inpatient_ref =  1
	}
	
*a_bp_treat	18y + being treated for high blood pressure 
    gen a_bp_treat = . 
	
/*	capture confirm variable sh250
	if _rc == 0 {
	replace a_bp_treat=0 if sh250!=. 
	replace a_bp_treat=1 if sh250==1 
	} */
	
*a_bp_sys 18y+ systolic blood pressure (mmHg) in adult population 
    gen  a_bp_sys = . 

/*	capture confirm variable sh246s sh255s sh264s
	if _rc == 0 {
	egen a_bp_sys = rowmean(sh246s sh255s sh264s)
	}
	if _rc!= 0 {
	gen  a_bp_sys = . 
	} */
	
*a_bp_dial	18y+ diastolic blood pressure (mmHg) in adult population 
	gen a_bp_dial = .
/*	capture confirm variable sh246d sh255d sh264d
	if _rc == 0 {
	egen a_bp_dial = rowmean(sh246d sh255d sh264d)
	}
	if _rc != 0{
	gen a_bp_dial = .
	} */
	
*a_hi_bp140_or_on_med	18y+ with high blood pressure or on treatment for high blood pressure	
	gen a_hi_bp140=.
    replace a_hi_bp140=1 if a_bp_sys>=140 | a_bp_dial>=90 
    replace a_hi_bp140=0 if a_bp_sys<140 & a_bp_dial<90 
	replace a_hi_bp140 = . if a_bp_sys==. & a_bp_dial ==. 
	
	gen a_hi_bp140_or_on_med = .
	replace a_hi_bp140_or_on_med=1 if a_bp_treat==1 | a_hi_bp140==1
    replace a_hi_bp140_or_on_med=0 if a_bp_treat==0 & a_hi_bp140==0
		
*a_bp_meas				18y+ having their blood pressure measured by health professional in the last year  
    gen a_bp_meas = . 
	
*a_diab_treat				18y+ being treated for raised blood glucose or diabetes 
    gen a_diab_treat = .

	capture confirm variable sh257 sh258 sh259  
    if _rc==0 {
    gen a_diab_diag=(sh258==1)
    replace a_diab_diag=. if sh257==.|sh257==8|sh257==9|sh258==9

    replace a_diab_treat=(sh259==1)
    replace a_diab_treat=. if sh257==.|sh257==8|sh257==9|sh259==9
    }


	if inlist(name, "Armenia2005") {	
		drop a_bp_treat a_bp_meas  a_inpatient_1y a_inpatient_ref
		tempfile t1 t2
		preserve 
		use "${SOURCE}/DHS-Armenia2005/DHS-Armenia2005ind.dta", clear	
		keep v001 v002 v003 s1007b s1007c s1008 s1009 s1011 s1016a s1016b s1016c s1016d s1016e s1016f s1016g
		gen a_inpatient_1y =(s1007b==1 |s1007c==1) if !(s1007b==9 |s1007c==9)
		gen a_inpatient_ref =12	
		drop s1007b s1007c
		save `t1'	
		use "${SOURCE}/DHS-Armenia2005/DHS-Armenia2005men.dta", clear	
		keep mv001 mv002 mv003 sm707c sm708 sm709 sm711 sm716a sm716b sm716c sm716d sm716e sm716f sm716g
		ren (mv001 mv002 mv003 sm708 sm709 sm711 sm716a sm716b sm716c sm716d sm716e sm716f sm716g) (v001 v002 v003 s1008 s1009 s1011 s1016a s1016b s1016c s1016d s1016e s1016f s1016g)
		recode s1016a s1016b s1016c s1016d s1016e s1016f s1016g (3 8 9=.)
		gen a_inpatient_1y =sm707c==1 if sm707c!=9
		gen a_inpatient_ref =12	
		drop sm707c
		append using `t1'
		
		gen a_bp_meas=(s1008==1 & s1009<=2) if !(s1008==9|inlist(s1009,8,9))
		
		gen a_bp_diag=s1011==1 
		replace a_bp_diag=. if s1008==9 |inlist(s1011,8,9)
		
		egen bpcontrol = rowtotal(s1016a s1016b s1016c s1016d s1016e s1016f s1016g),mi
		egen bptreat = rowtotal(s1016a s1016b),mi
		gen a_bp_treat = 0 if s1011==1
		replace a_bp_treat = 1 if bptreat>=1 & bptreat !=. 
		replace a_bp_treat = . if bptreat==. & s1011!=0
		
		keep v001 v002 v003 a_bp_treat a_bp_diag a_bp_meas a_inpatient_1y a_inpatient_ref
		ren (v001 v002 v003) (hv001 hv002 hvidx) 
		save `t2',replace 
		restore
		
		merge 1:1 hv001 hv002 hvidx using `t2'
		tab _m // fully merged 
		drop _m 
	} 
	
	* For Mali2001 & Senegal2005, the hv002 lost 2-3 digits, fix this issue in main.do, 1.do,4.do,12.do & 13.do
	if inlist(name,"Mali2001","Senegal2005"){
		drop hv002
		gen hv002 = substr(hhid,8,5)
		isid hv001 hv002 hvidx
		order hhid hvidx hv000 hv001 hv002
	}
