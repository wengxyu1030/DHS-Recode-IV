******************************
*** Delivery Care************* 
******************************
gen DHS_phase=substr(v000, 3, 1)
destring DHS_phase, replace

gen country_year="`name'"
gen year = regexs(1) if regexm(country_year, "([0-9][0-9][0-9][0-9])[\-]*[0-9]*[ a-zA-Z]*$")
destring year, replace
gen country = regexs(1) if regexm(country_year, "([a-zA-Z]+)")

rename *,lower   //make lables all lowercase. 
order *,sequential  //make sure variables are in order. 

    *sba_skill (not nailed down yet, need check the result)
	foreach var of varlist m3a-m3m {
	local lab: variable label `var' 
    replace `var' = . if ///
	 (!regexm("`lab'","doctor|nurse|Assistance|midwife|lady|mifwife|aide soignante|pediatriatian|health profess.|assistante accoucheuse|clinical officer|mch aide|auxiliary birth attendant|physician assistant|professional|ferdsher|feldshare|skilled|birth attendant|hospital/health center worker|auxiliary|icds|feldsher|mch|village health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|medical assistant|general practitioner") ///
	|regexm("`lab'","na^|-na|na -|Na- |NA -|- na|- Na|- NA|husband/partner|mchw|matron |Hilot|tradictional|Daya|mch worker.|family welfare|'matrone' (cs)|unqualified|Family welfare|student|homeopath|hakim|herself|traditionnel|Other|neighbor|provider|vhw|Friend|Relative|fieldworker|Health Worker|other|health worker|friend|relative|traditional birth attendant|hew|health assistant|untrained|unqualified|sub-assistant|empirical midwife|box")) ///
	& !(regexm("`lab'","doctor") & regexm("`lab'","other")) & !(regexm("`lab'","(aide soignante)") & regexm("`lab'","health assistant"))& !regexm("`lab'","lady health worker") 
	replace `var' = . if !inlist(`var',0,1)
	 }
//!regexm("`lab'"," trained") &   trained birth att.
	if inlist(name,"Bangladesh2004") {
	replace m3j = . //cs other person (unqualified doctor)
	}
	if inlist(name,"Zimbabwe1999") {
	replace m3i	= . //traditional midwife - training uncertain
	}

	/* do consider as skilled if contain words in 
	   the first group but don't contain any words in the second group */
    egen sba_skill = rowtotal(m3a-m3m),mi

	*c_hospdel: child born in hospital of births in last 2 years  
	decode m15, gen(m15_lab)
	replace m15_lab = lower(m15_lab)
	
	gen c_hospdel = 0 if !mi(m15)
	replace c_hospdel = 1 if ///
    regexm(m15_lab,"medical college|surgical") | ///
	regexm(m15_lab,"hospital") & !regexm(m15_lab,"center|sub-center|post|clinic")
	replace c_hospdel = . if mi(m15) | m15 == 99 | m15 == 98 | mi(m15_lab)	
    // please check this indicator in case it's country specific	
	// Jordan2002: m15=24 (royal medical services)
	if inlist(name,"Armenia2000") {
		replace c_hospdel = (inlist(m15,21,22)) if !missing(m15)
	}	
	
	*c_facdel: child born in formal health facility of births in last 2 years
	gen c_facdel = 0 if !mi(m15)
	replace c_facdel = 1 if regexm(m15_lab,"hospital") | ///
	!regexm(m15_lab,"home|other private|other$|pharmacy|non medical|private nurse|religious|abroad")
	replace c_facdel = . if mi(m15) | m15 == 99 | m15 == 98 | mi(m15_lab)

	*c_earlybreast: child breastfed within 1 hours of birth of births in last 2 years
	gen c_earlybreast = 0
	replace c_earlybreast = 1 if inlist(m34,0,100)
	replace c_earlybreast = . if inlist(m34,999,199)
	replace c_earlybreast = . if m34 ==. & m4 != 94 // case where m34 is missing that is not due to "no breastfeed"
	
	if inlist(name, "Tanzania1999"){
	recode c_earlybreast (0=.) // missing m34, recode c_earlybreast to make it missing 
	}
    
	*c_skin2skin: child placed on mother's bare skin immediately after birth of births in last 2 years
	capture confirm variable m77
	if _rc == 0{
	gen c_skin2skin = (m77 == 1) if !mi(m77)               //though missing but still a place holder.(the code might change depends on how missing represented in surveys)
	}
	gen c_skin2skin = .
	
	if inlist(name, "Armenia2005"){
	replace c_skin2skin = s455a==1 if !inlist(s455a,.,8,9)
	}
	
	*c_sba: Skilled birth attendance of births in last 2 years: go to report to verify how "skilled is defined"
	gen c_sba = . 
	replace c_sba = 1 if sba_skill>=1 & sba_skill!=.
	replace c_sba = 0 if sba_skill==0 
	  
	*c_sba_q: child placed on mother's bare skin and breastfeeding initiated immediately after birth among children with sba of births in last 2 years
	gen c_sba_q = (c_skin2skin == 1 & c_earlybreast == 1) if c_sba == 1
	replace c_sba_q = . if c_skin2skin == . | c_earlybreast == .
	
	*c_caesarean: Last birth in last 2 years delivered through caesarean                    
	clonevar c_caesarean = m17 
	replace c_caesarean = . if c_caesarean ==9
	
	replace c_caesarean = . if inlist(m15,.,99,98)
	
	if inlist(name,"DominicanRepublic1999"){
		replace c_caesarean =  0 if m17==. & inlist(m15,11,12,96) 
	}	
	if inlist(name,"Uganda2000"){
		replace c_caesarean =  0 if m17==. & m15==13 
	}
	
    *c_sba_eff1: Effective delivery care (baby delivered in facility, by skilled provider, mother and child stay in facility for min. 24h, breastfeeding initiated in first 1h after birth)
    //gen c_sba_eff1 = . //Time spent at place of delivery is missing in Recode IV.

	gen stay = .
	
	if inlist(name, "Armenia2000"){ 
		ren s426a m61
		replace stay = 0
		replace stay = 1 if inrange(m61,124,198)|inrange(m61,200,298)|inrange(m61,301,399)
		replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,12,96) // filter question, based on m15		
	}	
	
	if inlist(name,  "Ethiopia2005"){ 
		ren s434 m61
		replace stay = 0
		replace stay = 1 if inrange(m61,124,198)|inrange(m61,200,298)|inrange(m61,301,399)
		replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,12,96) // filter question, based on m15		
	}	
	
	if inlist(name, "Egypt2005"){
		ren s537 m61
		replace stay = 0
		replace stay = 1 if inrange(m61,124,198)|inrange(m61,200,298)|inrange(m61,301,399)
		replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,12,96) // filter question, based on m15		
	}
	
	if inlist(name, "Armenia2005","Moldova2005"){ 
		ren s434 m61
		replace stay = 0
		replace stay = 1 if inrange(m61,124,198)|inrange(m61,200,298)|inrange(m61,301,399)
		replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,96) // filter question, based on m15	
	}		
	
	
	gen c_sba_eff1 = (c_facdel == 1 & c_sba == 1 & stay == 1 & c_earlybreast == 1) 
	replace c_sba_eff1 = . if c_facdel == . | c_sba == . | stay == . | c_earlybreast == . 
	
	*c_sba_eff1_q: Effective delivery care (baby delivered in facility, by skilled provider, mother and child stay in facility for min. 24h, breastfeeding initiated in first 1h after birth) among those with any SBA
    gen c_sba_eff1_q = c_sba_eff1 if c_sba == 1
	
	*c_sba_eff2: Effective delivery care (baby delivered in facility, by skilled provider, mother and child stay in facility for min. 24h, breastfeeding initiated in first 1h after birth, skin2skin contact)
	gen c_sba_eff2 = (c_facdel == 1 & c_sba == 1 & stay == 1 & c_earlybreast == 1 & c_skin2skin == 1) 
	replace c_sba_eff2 = . if c_facdel == . | c_sba == . | stay == . | c_earlybreast == . | c_skin2skin == .
	
	*c_sba_eff2_q: Effective delivery care (baby delivered in facility, by skilled provider, mother and child stay in facility for min. 24h, breastfeeding initiated in first 1h after birth, skin2skin contact) among those with any SBA
	gen c_sba_eff2_q = c_sba_eff2 if c_sba == 1
	



	
