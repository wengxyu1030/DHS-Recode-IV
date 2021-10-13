
******************************
***Postnatal Care************* 
****************************** 
//missing complete information to generate the indicators on pnc for mother and child in Recode IV surveys. 

    *c_pnc_skill: m52,m72 by var label text. (m52 is added in Recode VI.
    gen c_pnc_skill = .
 	if inlist(name,"Tanzania1999") {
		ren (s428 s429 s430) (m50 m51 m52)
}  
 	if inlist(name,"DominicanRepublic1999", "Vietnam2002") {
		g m50 =. 
		g m51 =.
		g m52 =. 
}  
 	gen m52_skill = 0 if !inlist(m50,1,0)   //cited from VI

	if inlist(name,"Armenia2005", "Moldova2005") {
		ren (s445 s446 s447) (m70 m71 m72)
}
/* // Ethiopia2005: child pnc data are collected only if mother delivered at home or other facility, mute relevent code 
	if inlist(name,"Ethiopia2005") { // mother pnc: m50-m52 is a combination of s436-s438 & s441-s443. 
		replace m51 = s437 // m51 in IV use a timing code different from all all other round, change it to 
		replace m51 = s442 if s437==.	
		replace m52 = s443 if m52 ==. 
		label drop m51
		
		ren (s445 s446 s447) (m70 m71 m72)
}
*/
	if inlist(name,"Indonesia2002") {
		ren (s425a s425b s425c) (m70 m71 m72)
}

	if inlist(name,"Bangladesh2004") {
		clonevar m70 = s432a 
		clonevar m71 = s432b 
		
		egen child_skill = rowtotal(s432ca s432cb s432cc s432cd s432ce s432cg),mi
		g m72_skill = child_skill>=1 if child_skill!=.	
		
		foreach var of varlist m52 {
			decode `var', gen(`var'_lab)
			replace `var'_lab = lower(`var'_lab )
			replace  `var'_skill= 1 if ///
			(regexm(`var'_lab,"doctor|nurse|midwife|aide soignante|assistante accoucheuse|clinical officer|mch aide|trained|auxiliary birth attendant|physician assistant|professional|ferdsher|skilled|community health care provider|birth attendant|hospital/health center worker|hew|auxiliary|icds|feldsher|mch|vhw|village health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|family welfare visitor|medical assistant|health assistant") ///
			&!regexm(`var'_lab,"na^|-na|traditional birth attendant|untrained|unquallified|empirical midwife|other")) 
			replace `var'_skill = . if mi(`var') | `var' == 99
		}
}

   if inlist(name,"Armenia2005","Indonesia2002", "Moldova2005") { //"Ethiopia2005"
		gen m72_skill = 0 if !inlist(m70,0,1)   

		foreach var of varlist m52  m72 {
			decode `var', gen(`var'_lab)
			replace `var'_lab = lower(`var'_lab )
			replace  `var'_skill= 1 if ///
			(regexm(`var'_lab,"doctor|nurse|midwife|aide soignante|assistante accoucheuse|clinical officer|mch aide|trained|auxiliary birth attendant|physician assistant|professional|ferdsher|skilled|community health care provider|birth attendant|hospital/health center worker|hew|auxiliary|icds|feldsher|mch|vhw|village health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|family welfare visitor|medical assistant|health assistant") ///
			&!regexm(`var'_lab,"na^|-na|traditional birth attendant|untrained|unquallified|empirical midwife|other")) 
			replace `var'_skill = 0 if `var' == 96
			replace `var'_skill = . if mi(`var') | `var' == 99
		}
}
	/* consider as skilled if contain words in 
	   the first group but don't contain any words in the second group */

	
	*c_pnc_any : mother OR child receive PNC in first six weeks by skilled health worker  //to be decided whether to keep? because m52_skill is missing. 
    gen c_pnc_any = .
	if inlist(name,"Armenia2005", "Indonesia2002", "Bangladesh2004", "Moldova2005") { //"Ethiopia2005",
	recode m70 m50 (8 9 =.) 
		replace c_pnc_any = 0 if !mi(m70) & !mi(m50)  
		replace c_pnc_any = 1 if ((m71 <= 242 | inrange(m71,301,306) | m71 == 299 ) & m72_skill == 1 ) | ((m51 <= 242 | inrange(m51,301,306) | m51 == 299 ) & m52_skill == 1)
		replace c_pnc_any = . if ((inlist(m71,.,399,998,999)|m72_skill ==.) & m70 !=0) | ((inlist(m51,.,399,998,999) | m52_skill == .) & m50 !=0) |inlist(m50,8,9)|inlist(m70,8,9)
	}
	
	*c_pnc_eff: mother AND child in first 24h by skilled health worker		
    gen c_pnc_eff = .
	if inlist(name,"Armenia2005","Indonesia2002", "Bangladesh2004", "Moldova2005") { //,"Ethiopia2005", 
 	replace c_pnc_eff = 0 if !mi(m70) | !mi(m50)  
    replace c_pnc_eff = 1 if ((inrange(m51,100,124) | m51 == 201 | m51 == 199) & m52_skill == 1) & ((inrange(m71,100,124) | m71 == 201 | m71 ==199) & m72_skill == 1 )
    replace c_pnc_eff = . if ((inlist(m71,.,299,998,999)|m72_skill ==.) & m70 !=0) | ((inlist(m51,.,299,998,999) | m52_skill == .) & m50 !=0) |inlist(m50,8,9)|inlist(m70,8,9)
	}
	*c_pnc_eff_q: mother AND child in first 24h by skilled health worker among those with any PNC
	gen c_pnc_eff_q = c_pnc_eff if c_pnc_any == 1
	
	*c_pnc_eff2: mother AND child in first 24h by skilled health worker and cord check, temperature check and breastfeeding counselling within first two days	
	gen c_pnc_eff2 = . 
	
	capture confirm variable m78a m78b m78d                            //m78* only available for Recode VII
	if _rc == 0 {
	egen check = rowtotal(m78a m78b m78d),mi
	replace c_pnc_eff2 = c_pnc_eff
	replace c_pnc_eff2 = 0 if check != 3
	replace c_pnc_eff2 = . if c_pnc_eff == . 
	}
	
	*c_pnc_eff2_q: mother AND child in first 24h weeks by skilled health worker and cord check, temperature check and breastfeeding counselling within first two days among those with any PNC
	gen c_pnc_eff2_q = c_pnc_eff2 if c_pnc_any == 1
/*
 *c_pnc_skill: m52,m72 by var label text. (m52 is added in Recode VI.
	gen m52_skill = 0 if !inlist(m50,0,1)  // 9,. 
	gen m72_skill = 0 if !inlist(m70,0,1) 
	
	foreach var of varlist m52 m72 {
    decode `var', gen(`var'_lab)
	replace `var'_lab = lower(`var'_lab )
	replace  `var'_skill= 1 if ///
	(regexm(`var'_lab,"doctor|nurse|midwife|aide soignante|assistante accoucheuse|clinical officer|mch aide|trained|auxiliary birth attendant|physician assistant|professional|ferdsher|skilled|community health care provider|birth attendant|hospital/health center worker|hew|auxiliary|icds|feldsher|mch|vhw|village health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|family welfare visitor|medical assistant|health assistant") ///
	|!regexm(`var'_lab,"na^|-na|traditional birth attendant|untrained|unquallified|empirical midwife")) 
	replace `var'_skill = . if mi(`var') | `var' == 99
	}

