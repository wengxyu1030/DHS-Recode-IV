
******************************
*** Antenatal care *********** 
******************************   

rename *,lower
order *,sequential



	*c_anc: 4+ antenatal care visits of births in last 2 years	                                             
	clonevar cnumvisit=m14                   //Last pregnancies in last 2 years of women currently aged 15-49	
	replace cnumvisit=. if cnumvisit==98 | cnumvisit==99 
	
	g c_anc = inrange(cnumvisit,4,97) if cnumvisit!=.

	*c_anc_any: any antenatal care visits of births in last 2 years
	g c_anc_any = inrange(m14,1,97) if m14<98                                       //m14 = 98 is missing 
	
	*c_anc_ear: First antenatal care visit in first trimester of pregnancy of births in last 2 years
	g c_anc_ear = inrange(m13,0,3) if !inlist(m13,.,98,99)
	replace c_anc_ear = 0 if m2n == 1 & inlist(m13,.,98,99)

	* Egypt2000: s521-s523: no antenatal care visits but visit doctors during preg. b/c having problem with the preg. 
	if inlist(name, "Egypt2000"){
		replace c_anc =1 if inrange(s522,4,7) 
		replace c_anc_any =1 if inrange(s522,1,7)
		replace c_anc_ear =1 if inrange(s523,0,3) 
	}
	*c_anc_ear_q: First antenatal care visit in first trimester of pregnancy among ANC users of births in last 2 years
	g c_anc_ear_q = c_anc_ear if c_anc_any == 1 
	
	*anc_skill: Categories as skilled: doctor, nurse, midwife, auxiliary nurse/midwife...
	 if !inlist(name,"DominicanRepublic2002") {
		foreach var of varlist m2a-m2m {
		local lab: variable label `var' 
		replace `var' = . if ///
			!regexm("`lab'","trained") & ///
		(!regexm("`lab'","doctor|nurse|midwife|aide soignante|ma/sacmo|matronne|cs health profession|assistante accoucheuse|clinical officer|health assitant|mch aide|auxiliary birth attendant|physician assistant|professional|ferdsher|skilled|community health care provider|birth attendant|hospital/health center worker|hew|auxiliary|icds|feldsher|mch|vhw|village health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|family welfare visitor|medical assistant|health assistant") ///
		|regexm("`lab'","na^|-na|- na|traditional birth attendant|family welfare visitor|health assistant|obstetrician|trad.birth attendant|untrained|unqualified|empirical midwife") )

		replace `var' = . if !inlist(`var',0,1)
		 }
	}
	 
	 * Take care of peculiar issues discovered by DW team in Apr 2022: Gynecologist/Obstetrician
	 if inlist(name,"DominicanRepublic2002") {
		foreach var of varlist m2a-m2m{
			replace `var' = . if inlist("`var'","m2g","m2k","m2c")
			replace `var' = . if !inlist(`var',0,1)
		 }
	 }	 
	 
   if inlist(name,"Bangladesh2004") {
		replace m2i = .
   }

	/* do consider as skilled if contain words in 
	   the first group but don't contain any words in the second group */
    egen anc_skill = rowtotal(m2a-m2m),mi	
	
	*c_anc_eff: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples) of births in last 2 years
	if inlist(name, "DominicanRepublic1999"){
		ren (s412d s412e s412f s416) (m42c m42d m42e m45)
	}
	if inlist(name, "Tanzania1999"){
		g m42c =.
		g m42d =.
		g m42e =.
		ren s416 m45
	}
	if inlist(name, "Nigeria1999","Vietnam2002"){
		g m42c =.
		g m42d =.
		g m42e =.
		g m45  =.
	}
	
	egen anc_blood = rowtotal(m42c m42d m42e) if m2n == 0
	
	gen c_anc_eff = (c_anc == 1 & anc_skill>0 & anc_blood == 3) 
	replace c_anc_eff = . if c_anc ==. |  anc_skill==. | ((inlist(m42c,.,8,9)|inlist(m42d,.,8,9)|inlist(m42e,.,8,9)) & m2n!=1 )

	*c_anc_eff_q: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples) among ANC users of births in last 2 years
    gen c_anc_eff_q = c_anc_eff if c_anc_any == 1
	
	*c_anc_ski: antenatal care visit with skilled provider for pregnancy of births in last 2 years
	gen c_anc_ski = .
	replace c_anc_ski = 1 if anc_skill >= 1 & anc_skill!=.
	replace c_anc_ski = 0 if anc_skill == 0
	
	*c_anc_ski_q: antenatal care visit with skilled provider among ANC users for pregnancy of births in last 2 years
	gen c_anc_ski_q = c_anc_ski  if c_anc_any == 1 
	
	*c_anc_bp: Blood pressure measured during pregnancy of births in last 2 years
	gen c_anc_bp = 0 if m2n==0   // For m42a to m42e based on women who had seen someone for antenatal care for their last born child
	replace c_anc_bp = 1 if m42c==1  

	*c_anc_bp_q: Blood pressure measured during pregnancy among ANC users of births in last 2 years
	gen c_anc_bp_q = c_anc_bp if c_anc_any == 1 
	
	*c_anc_bs: Blood sample taken during pregnancy of births in last 2 years
	gen c_anc_bs= 0 if m2n==0    // For m42a to m42e based on women who had seen someone for antenatal care for their last born child
	replace c_anc_bs = 1 if m42e==1  
	
	*c_anc_bs_q: Blood sample taken during pregnancy among ANC users of births in last 2 years
	g c_anc_bs_q = c_anc_bs if c_anc_any == 1 
	
	*c_anc_ur: Urine sample taken during pregnancy of births in last 2 years
	gen c_anc_ur = 0 if m2n==0    // For m42a to m42e based on women who had seen someone for antenatal care for their last born child
	replace c_anc_ur = 1 if m42d==1 
	
	*c_anc_ur_q: Urine sample taken during pregnancy among ANC users of births in last 2 years
	g c_anc_ur_q = c_anc_ur if c_anc_any == 1 
	
	*c_anc_ir: iron supplements taken during pregnancy of births in last 2 years
	clonevar c_anc_ir = m45
	replace c_anc_ir = . if inlist(m45,8,9)
	
	if inlist(name,"Moldova2005"){
		drop c_anc_ir
		replace s411f=0 if m2n ==1 // adjust s411f since m2n is filter for s411f
		replace s421=0 if s413g ==0 
		g c_anc_ir =1 if s411f==1 | inlist(s421,1,2) 
		replace c_anc_ir = 0 if s411f==0 & s421==0
	}
	
	if inlist(name,"Bangladesh2004"){
	drop c_anc_bp* c_anc_bs* c_anc_ur*
		gen c_anc_bp = m42c if m42c<8 
		gen c_anc_bp_q = c_anc_bp if c_anc_any == 1 
		gen c_anc_bs = m42e if m42e<8 
		g c_anc_bs_q = c_anc_bs if c_anc_any == 1 
		gen c_anc_ur = m42d if m42d<8 
		g c_anc_ur_q = c_anc_ur if c_anc_any == 1 
	}

	if inlist(name,"Egypt2000"){
	drop c_anc_bp* c_anc_bs* c_anc_ur*
	
		gen c_anc_bp = 0 if m2n==0 | s518y==0 | inrange(m1,1,7)  // For m42a to m42e based on women who had seen someone for antenatal care for their last born child
		replace c_anc_bp = 1 if m42c==1 
		gen c_anc_bp_q = c_anc_bp if c_anc_any == 1 

		gen c_anc_bs = 0 if m2n==0 | s518y==0 | inrange(m1,1,7)
		replace c_anc_bs = 1 if m42e==1
		g c_anc_bs_q = c_anc_bs if c_anc_any == 1 
		
		gen c_anc_ur = 0 if m2n==0 | s518y==0 | inrange(m1,1,7)
		replace c_anc_ur = 1 if m42d==1
		g c_anc_ur_q = c_anc_ur if c_anc_any == 1 
	}
		
	if inlist(name,"Egypt2005"){
	drop c_anc_bp* c_anc_bs* c_anc_ur*
	
		gen c_anc_bp = 0 if m2n==1 & s521y==1 & m1==0  // For m42a to m42e based on women who had seen someone for antenatal care for their last born child
		replace c_anc_bp = 1 if m42c==1 
		gen c_anc_bp_q = c_anc_bp if c_anc_any == 1 

		gen c_anc_bs = 0 if  m2n==1 & s521y==1 & m1==0
		replace c_anc_bs = 1 if m42e==1
		g c_anc_bs_q = c_anc_bs if c_anc_any == 1 
		
		gen c_anc_ur = 0 if  m2n==1 & s521y==1 & m1==0
		replace c_anc_ur = 1 if m42d==1
		g c_anc_ur_q = c_anc_ur if c_anc_any == 1 
	}
	
	*c_anc_ir_q: iron supplements taken during pregnancy among ANC users of births in last 2 years
	gen c_anc_ir_q = c_anc_ir  if c_anc_any == 1 
	
	*c_anc_tet: pregnant women vaccinated against tetanus for last birth in last 2 years
	gen c_anc_tet = .   //no pregnant women tetanus injection information.  
 	gen rh_anc_neotet = . 

    if inlist(name,"Ethiopia2005") {
	ren (s418 s420) (m1a m1d)
	}
	
    if inlist(name,"Madagascar2003") {
	ren s416c m1a
	recode s416dy s416dm (9998 98 =.)
	g tetyr=. // x year ago received the last injection 
	replace tetyr = s416d2 if s416d2<98
	replace tetyr =  v007 - s416dy if inlist(s416d2,.,98) & s416dy!=. // year of interview - year of last shot
	replace tetyr =  tetyr-1 if inlist(s416d2,.,98) & tetyr!=0 & s416dm>v006 & s416dm!=. // make sure it is full year, adjust by "month of interview < month of last shot" 
	ren tetyr m1d
	}
	
	if inlist(name, "Moldova2005"){
	gen m1a = 0  // according to the report and questionnaire, treat m1 as the number of tet injections women received in her lifetime, can generate c_anc_tet w/o m1a
	
	recode s413em s413ey (0 98 99 9998 9999 =.)
	g tetyr=. // generate X years ago received the last injection 
	replace tetyr =  v007 - s413ey if s413ey!=. // year of interview - year of last shot
	replace tetyr =  tetyr-1 if tetyr!=0 & s413em>v006 & s413em!=. // make sure it is full year, adjust by "month of interview < month of last shot" 
	ren tetyr m1d
	}
	
	if inlist(name, "Namibia2000"){
	drop m1
	ren (s487b s487f) (m1 m1a)
	recode s487gm s487gy (98 9998 =.)
	g tetyr=. // x year ago received the last injection 
	replace tetyr = s487h
	replace tetyr =  v007 - s487gy if s487h==. & s487gy!=. // year of interview - year of last shot
	replace tetyr =  tetyr-1 if s487h==. & tetyr!=0 & s487gm>v006 & s487gm!=. // make sure it is full year, adjust by "month of interview < month of last shot" 
	ren tetyr m1d
	}

    if inlist(name,"Tanzania1999") {
	ren (s482 s483) (m1a m1d)
	recode m1d (98=.)
	}
	
	if inlist(name,"Ethiopia2005", "Madagascar2003", "Moldova2005","Namibia2000b", "Tanzania1999") {		
	drop c_anc_tet rh_anc_neotet
	gen tet2lastp = 0                                                                                   //follow the definition by report. might be country specific. 
    replace tet2lastp = 1 if m1 >1 & m1<8
	
	* temporary vars needed to compute the indicator
	gen totet = 0 
	gen ttprotect = 0 				   
	replace totet = m1 if (m1>0 & m1<8)
	replace totet = m1a + totet if (m1a > 0 & m1a < 8) // s416c: times get tetanus injection before last preganancy
	*now generating variable for date of last injection - will be 0 for women with at least 1 injection at last pregnancy
    g lastinj = 9999
	replace lastinj = 0 if (m1 >0 & m1 <8)
	replace lastinj = (m1d  - b8) if m1d  <20 & (m1 ==0 | (m1 >7 & m1 <9996))                           // years ago of last shot - (age at of child), yields some negatives
	
	*now generate summary variable for protection against neonatal tetanus 
	replace ttprotect = 1 if tet2lastp ==1 
	replace ttprotect = 1 if totet>=2 &  lastinj<=2                                                     //at least 2 shots in last 3 years
	replace ttprotect = 1 if totet>=3 &  lastinj<=4                                                     //at least 3 shots in last 5 years
	replace ttprotect = 1 if totet>=4 &  lastinj<=9                                                     //at least 4 shots in last 10 years
	replace ttprotect = 1 if totet>=5                                                                   //at least 2 shots in lifetime
	lab var ttprotect "Full neonatal tetanus Protection"
				   
	gen rh_anc_neotet = ttprotect
	label var rh_anc_neotet "Protected against neonatal tetanus"
		
	gen c_anc_tet = (rh_anc_neotet == 1) if  !mi(rh_anc_neotet) 
	
	*c_anc_tet_q: pregnant women vaccinated against tetanus among ANC users for last birth in last 2 years
	gen c_anc_tet_q = (rh_anc_neotet == 1) if c_anc_any == 1
	replace c_anc_tet_q = . if c_anc_any == 1 & mi(rh_anc_neotet) 
	
	*c_anc_eff2: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples, tetanus vaccination) of births in last 2 years
 	gen c_anc_eff2 = (c_anc == 1 & anc_skill>0 & anc_blood == 3 & rh_anc_neotet == 1) 
	replace c_anc_eff2 = . if c_anc == . | anc_skill == . |  rh_anc_neotet == . | ((inlist(m42c,.,8,9)|inlist(m42d,.,8,9)|inlist(m42e,.,8,9)) & m2n!=1 )
	 
	*c_anc_eff2_q: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples, tetanus vaccination) among ANC users of births in last 2 years
	gen c_anc_eff2_q = c_anc_eff2 if c_anc_any == 1
	 
	*c_anc_eff3: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples, tetanus vaccination, start in first trimester) of births in last 2 years 
	gen c_anc_eff3 = (c_anc == 1 & anc_skill>0 & anc_blood == 3 & rh_anc_neotet == 1 & inrange(m13,0,3)) 
	replace c_anc_eff3 = . if c_anc == . | anc_skill == . | rh_anc_neotet == .|((inlist(m13,.,98)|inlist(m42c,.,8,9)|inlist(m42d,.,8,9)|inlist(m42e,.,8,9)) & m2n!=1 )

	*c_anc_eff3_q: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples, tetanus vaccination, start in first trimester) among ANC users of births in last 2 years
	gen c_anc_eff3_q = c_anc_eff3 if c_anc_any == 1 
	}
	
    if !inlist(name,"Ethiopia2005", "Madagascar2003", "Moldova2005", "Namibia2000b", "Tanzania1999") {
	*c_anc_tet_q: pregnant women vaccinated against tetanus among ANC users for last birth in last 2 years
    gen c_anc_tet_q = .
/*	gen c_anc_tet_q = (rh_anc_neotet == 1) if c_anc_any == 1
	replace c_anc_tet_q = . if c_anc_any == 1 & mi(rh_anc_neotet) */
	
	*c_anc_eff2: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples, tetanus vaccination) of births in last 2 years
    gen c_anc_eff2 = .
/* 	gen c_anc_eff2 = (c_anc == 1 & anc_skill>0 & anc_blood == 3 & rh_anc_neotet == 1) 
	replace c_anc_eff2 = . if c_anc == . | anc_skill == . |  rh_anc_neotet == . | ((inlist(m42c,.,8,9)|inlist(m42d,.,8,9)|inlist(m42e,.,8,9)) & m2n!=1 )*/
	
	*c_anc_eff2_q: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples, tetanus vaccination) among ANC users of births in last 2 years
	gen c_anc_eff2_q = c_anc_eff2 if c_anc_any == 1
	 
	*c_anc_eff3: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples, tetanus vaccination, start in first trimester) of births in last 2 years 
    gen c_anc_eff3 = . 
/* 	gen c_anc_eff3 = (c_anc == 1 & anc_skill>0 & anc_blood == 3 & rh_anc_neotet == 1 & inrange(m13,0,3)) 
	replace c_anc_eff3 = . if c_anc == . | anc_skill == . | rh_anc_neotet ==.|((inlist(m13,.,98)|inlist(m42c,.,8,9)|inlist(m42d,.,8,9)|inlist(m42e,.,8,9)) & m2n!=1 )	  */
	
	*c_anc_eff3_q: Effective ANC (4+ antenatal care visits, any skilled provider, blood pressure, blood and urine samples, tetanus vaccination, start in first trimester) among ANC users of births in last 2 years
    gen c_anc_eff3_q = . 
/*  gen c_anc_eff3_q = c_anc_eff3 if c_anc_any == 1 */
	}
	
	if inlist(name, "Namibia2000","Tanzania1999","Nigeria1999", "Vietnam2002"){
		recode c_anc_bp c_anc_bp_q c_anc_bs c_anc_bs_q  c_anc_ur c_anc_ur_q c_anc_eff* (0=.) // missing m42c, m42d, m42e, recode related variable to missing 
	}
	
	*c_anc_hosp : Received antenatal care in the hospital
	gen c_anc_hosp = .
			* Use m57 vars in birth.dta to identify hospital antenatal care
	replace c_anc_hosp = 0 if !mi(m15)  /// using m15 place-of-delivery is not the best way out

	*c_anc_public : Received antenatal care in public facilities	 
	gen c_anc_public = .
	replace c_anc_public = 0 if !mi(m15)
	

	capture confirm variable m57a
	if !_rc {
		foreach var of varlist m57a-m57x {
			capture confirm variable `var'
			if !_rc {				
				capture decode `var', gen(lower_`var')
				if !_rc {
					replace lower_`var' = lower(lower_`var')
					local lab: variable label lower_`var' 
					
					replace c_anc_hosp = 1 if (regexm("`lab'","medical college|surgical") | (regexm("`lab'","hospital") | regexm("`lab'","hosp")) & !regexm("`lab'","sub-center")) & `var'==1	
				
					*replace c_anc_public = 1 if ((regexm("`lab'","public") | regexm("`lab'","gov") | regexm("`lab'","nation") |regexm("`lab'","govt")|regexm("`lab'","government")) & !regexm("`lab'","private")) & `var'==1			
				}			
			}
		}	
	}

	capture confirm variable m57e
	if !_rc {
		foreach var of varlist m57e-m57l {
			replace c_anc_public = 1 if `var'==1	
		}
	}

	*w_sampleweight.
	gen w_sampleweight = v005/10e6
	
	* For Mali2001 & Senegal2005, the hv002 lost 2-3 digits, fix this issue in main.do, 1.do,4.do,12.do & 13.do
	if inlist(name,"Mali2001","Senegal2005"){
		drop v002
		gen v002 = substr(caseid,8,5)
		order caseid v000 v001 v002 v003
	}	
