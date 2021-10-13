
********************
***Demographics*****
********************

*hm_live Alive (1/0)
    gen hm_live = 1          
   
*hm_male Male (1/0)         
    recode hv104 (2 = 0) (9=.),gen(hm_male)  
	
*hm_age_yrs	Age in years       
    clonevar hm_age_yrs = hv105
	replace hm_age_yrs = . if inlist(hv105,98,99)
	
*hm_age_mon	Age in months (children only)	
	if inlist(name, "Tanzania1999") {	
		ren shw1 hc1
		ren shh4c hc32
	} 
	
	if inlist(name, "DominicanRepublic1999","Nigeria1999","Vietnam2002") {	
		gen hc1=.
		gen hc32=.
	} 	

	clonevar hm_age_mon = hc1
	
	if inlist(name, "Chad2004") {	
		drop hm_age_mon
		tempfile t1
	preserve 
		use "${SOURCE}/DHS-Chad2004/DHS-Chad2004birth.dta", clear	
		keep v001 v002 b16 hw1
		drop if hw1==. | b16==0 
		duplicates drop v001 v002 b16, force // dropped 1 child 
		ren (v001 v002  b16) (hv001 hv002 hvidx)
		save `t1',replace 
	restore
		merge 1:1 hv001 hv002 hvidx using `t1'
		tab _m 
		drop _m 
		clonevar hm_age_mon = hw1
	} 
	
	if inlist(name, "Colombia2000") {	
		drop hm_age_mon
		tempfile t1
	preserve 
		use "${SOURCE}/DHS-Colombia2000/DHS-Colombia2000birth.dta", clear	
		keep v001 v002 b16 hw1
		drop if hw1==. | b16==0 
		duplicates drop v001 v002 b16, force // dropped 1 child 
		ren (v001 v002  b16) (hv001 hv002 hvidx)
		save `t1',replace 
	restore
		merge 1:1 hv001 hv002 hvidx using `t1'
		tab _m 
		drop _m 
		clonevar hm_age_mon = hw1
	} 
	
	if inlist(name, "Nigeria2003") {	
		drop hm_age_mon
		tempfile t1
	preserve 
		use "${SOURCE}/DHS-Nigeria2003/DHS-Nigeria2003birth.dta", clear	
		keep v001 v002 b16 hw1
		drop if hw1==. | b16==0 
		duplicates drop v001 v002 b16, force // dropped 1 child 
		ren (v001 v002  b16) (hv001 hv002 hvidx)
		save `t1',replace 
	restore
		merge 1:1 hv001 hv002 hvidx using `t1'
		tab _m 
		drop _m 
		clonevar hm_age_mon = hw1
	} 
	
	if inlist(name, "Peru2000") {	
		drop hm_age_mon
		tempfile t1
	preserve 
		use "${SOURCE}/DHS-Peru2000/DHS-Peru2000birth.dta", clear	
		keep v001 v002 b16 hw1
		drop if hw1==. | b16==0 
		duplicates drop v001 v002 b16, force // dropped 1 child 
		ren (v001 v002  b16) (hv001 hv002 hvidx)
		save `t1',replace 
	restore
		merge 1:1 hv001 hv002 hvidx using `t1'
		tab _m 
		drop _m 
		clonevar hm_age_mon = hw1
	} 

	if inlist(name, "Turkey2003") {	
		drop hm_age_mon hc32
		tempfile t1
	preserve 
		use "${SOURCE}/DHS-Turkey2003/DHS-Turkey2003birth.dta", clear	
		keep v001 v002 v003 b16 hw1 b3
		drop if inlist(b16,0,.)
		isid v001 v002 b16
		ren (v001 v002 b16) (hv001 hv002 hvidx)
		save `t1',replace 
	restore
		merge 1:1 hv001 hv002 hvidx using `t1'
		tab _m 
		drop _m 
		clonevar hm_age_mon = hw1
		ren b3 hc32
	} 


*hm_headrel	Relationship with HH head
	if inlist(name, "Malawi2000","Mali2001", "Uganda2000"){
		replace hv101=98 if hvidx!=hv218 & hv101==1
	} // for points that have hh with multiple hh head, judge hh head by hv218 and recode members hv101=98 if they are not hh head
	
	if inlist(name, "Haiti2000","Rwanda2000"){
		replace hv101=1 if hvidx==hv218 & hv101!=1
	} // for points that have hh with no hh head, judge hh head by hv218 and recode members hv101=1 if they are actually hh head

	clonevar hm_headrel = hv101
	replace hm_headrel = . if inlist(hm_headrel,98,99) 
	
*hm_stay Stayed in the HH the night before the survey (1/0)
    gen hm_stay = hv103 if hv103!= 9 //vary by survey, afg is missing.
	
*hm_dob	date of birth (cmc)
    clonevar hm_dob = hc32  
	
*hm_doi	date of interview (cmc)
    clonevar hm_doi = hv008

*ln	Original line number of household member
    clonevar ln = hvidx
	



