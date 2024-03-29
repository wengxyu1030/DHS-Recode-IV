
******************************
*****Household Level Info*****
******************************   

*hh_id	ID (generated)      
    clonevar hh_id = hhid
	
*hh_headed	Head's highest educational attainment (1 = none, 2 = primary, 3 = lower sec or higher)
	if inlist(name, "Malawi2000","Mali2001", "Uganda2000"){
		replace hv101=98 if hvidx!=hv218 & hv101==1
	} // for points that have hh with multiple hh head, judge hh head by hv218 and recode members hv101=98 if they are not hh head
	
    recode hv106 (0 = 1) (1 = 2) (2/3 = 3) (8 9=.) if hv101 == 1,gen(headed)
	bysort hh_id: egen hh_headed = min(headed)
		
* hh_country_code Country code
	clonevar hh_country_code = hv000 							  
	
*hh_region_num	Region of residence numerical (hv024)
    clonevar hh_region_num = hv024
	
*hh_region_lab	Region of residence label (v024)
    decode hv024,gen(hh_region_lab)

*hh_size # of members   
    clonevar hh_size = hv009
           
*hh_urban Resides in urban area (1/0)
    recode hv025 (2=0),gen(hh_urban)
	
*hh_sampleweight Sample weight (v005/1000000)       
    gen hh_sampleweight = hv005/10e6 

	if inlist(name,"Nigeria1999","Vietnam2002","Nicaragua2001","Nepal2001") {
		gen hv270=. 
		gen hv271=.
	}
*hh_wealth_quintile	Wealth quintile    
	capture confirm variable hv270
	if _rc == 0 {
    clonevar hh_wealth_quintile = hv270                          
	}
	if _rc != 0 {
	gen hh_wealth_quintile = . 
	}
	
*hh_wealthscore	Wealth index score   
	capture confirm variable hv271
	if _rc == 0 {
    clonevar hhwealthscore_old = hv271                          
	}
	if _rc != 0 {
	gen hhwealthscore_old = . 
	}
	
	egen hhwealthscore_oldmin=min(hhwealthscore_old) 
	gen hh_wealthscore=hhwealthscore_old-hhwealthscore_oldmin
	replace hh_wealthscore=hh_wealthscore/10e6 

*hh_religion: religion of household head (DW Team Nov 2021)
	cap rename v130 hh_religion
	
*hh_watersource: Water source (hv201 in DHS HH dataset, already coded for MICS)
	rename hv201 hh_watersource

*hh_toilet: Toilet type (hv205 “”, already coded for MICS)
	rename hv205 hh_toilet
	
*hv001 Sampling cluster number (original)
*hv002 Household number (original)
*hv003 Respondent's line number in household roster (original)

duplicates drop hv001 hv002,force
	
