
**************************
*** Child illness ********
**************************

/*
Note: for phase 6: V000 = AM6 CG6 KE6, use the old code for formal provider for ARI and Diarrhea.
Because the for the formal provider, the information can not be captured from the variable label, but only 
from the report/survey, which presented in the adeptfile.
*/

rename *,lower   //make lables all lowercase. 
order *,sequential  //make sure variables are in order. 

*c_diarrhea Child with diarrhea in last 2 weeks
	    gen c_diarrhea=(h11   ==1|h11   ==2) 						/*symptoms in last two weeks*/
		replace c_diarrhea=. if h11  ==8|h11  ==9|h11  ==. 
					 
		gen ccough=(h31  ==1|h31  ==2) 
		replace ccough=. if h31  ==8|h31  ==9|h31  ==. 
					  
*c_treatdiarrhea Child with diarrhea receive oral rehydration salts (ORS)
		cap gen h13b  =. 
		gen c_treatdiarrhea=(h13  ==1|h13  ==2|h13b  ==1) 	if c_diarrhea == 1							/*ORS for diarrhea*/
		replace c_treatdiarrhea=. if (h13  ==8|h13  ==9 | h13  ==.)&(h13b  ==8|h13b  ==9 | h13b  ==.) 
		
*c_diarrhea_hmf	Child with diarrhea received recommended home-made fluids
        gen c_diarrhea_hmf=(h14  ==1|h14  ==2) if c_diarrhea == 1			/* home made fluid for diarrhea*/
		replace c_diarrhea_hmf=. if h14  ==8|h14  ==9 | h14  ==. 
		
*c_diarrhea_pro	The treatment was provided by a formal provider (all public provider except other public, pharmacy, and private sector)
       /*please cross check as there might be case where the diarreha treatment provider is not in h12a-h12x*/
	    order h12a-h12x,sequential
	    foreach var of varlist h12a-h12x {
	    local lab: variable label `var' 	   
        replace `var' = . if ///
	    regexm("`lab'","(other|shop|pharmacy|market|kiosk|relative|friend|oth.priv|church|drug|addo|rescuer|trad|unqualified|stand|cabinet|ayush|^na|-na|- na)") ///
	    & !regexm("`lab'","(ngo|hospital|medical center|worker)")  
	    replace `var' = . if !inlist(`var',0,1) 
	    }
		
		if inlist(name, "Armenia2005") {
			replace h12u =.
		}	
		if inlist(name, "Chad2004") {
			replace h12g =.
		}
		if inlist(name, "Ethiopia2000") {
			replace h12p =.
		}	
		if inlist(name, "Morocco2003") {
			replace h12f =.
		}
		
	   /* do not consider formal if contain words in 
	   the first group but don't contain any words in the second group */

	    egen pro_dia = rowtotal(h12a-h12x),mi

        gen c_diarrhea_pro = 0 if c_diarrhea == 1
        replace c_diarrhea_pro = 1 if c_diarrhea_pro == 0 & pro_dia >= 1 
        replace c_diarrhea_pro = . if pro_dia == . 	
		
	    if inlist(name,"Tanzania1999") {
	        replace c_diarrhea_pro = h12z if c_diarrhea == 1
	    }
		
	   
	   /*for countries below there are categories that identified as formal 
	   provider but not shown in the label*/
	    if inlist(name,"Senegal2014","Senegal2012","Senegal2015"){
			foreach x in a b c d e g h j l m n p q {
            replace c_diarrhea_pro=1 if c_diarrhea==1 & h12`x'==1
            replace c_diarrhea_pro=. if c_diarrhea==1 & h12`x'==9			
			}
		}
			
	    if inlist(name,"Senegal2010") {
 			foreach x in a b c d e j l m n {
            replace c_diarrhea_pro=1 if c_diarrhea==1 & h12`x'==1
            replace c_diarrhea_pro=. if c_diarrhea==1 & h12`x'==9			
			}
		}		
		
*c_diarrhea_mof	Child with diarrhea received more fluids
	    if inlist(name,"Nigeria1999","Vietnam2002") {
			g h38=.  
			g h39=.
		}

	    if inlist(name,"DominicanRepublic1999","Tanzania1999") {
			recode s473 (5=0 "nothing to drink" ) (1=2 "much less" ) (2=3 "somewhat less") (3=4 "about the same") (4=5  "more"), gen(h38)
			recode s474 (5=0 "stopped food" ) (6=1 "never gave food" ) (1=2 "much less" ) (2=3 "somewhat less") (3=4  "about the same") (4=5 "more") , gen(h39)
		}
        gen c_diarrhea_mof = (h38 == 5) if !inlist(h38,.,8,9) & c_diarrhea == 1

*c_diarrhea_medfor Get formal medicine except (ors hmf home other_med, country specific. 
        egen medfor = rowtotal(h12z h15 h15a h15b h15c h15e h15g h15h ),mi
		gen c_diarrhea_medfor = ( medfor > = 1 ) if c_diarrhea == 1 & medfor!=.
		replace c_diarrhea_medfor = . if inlist(h12z,8,9) |inlist(h15,8,9)|inlist(h15a,8,9)|inlist(h15b,8,9)|inlist(h15c,8,9)|inlist(h15e,8,9)|inlist(h15g,8,9)|inlist(h15h,8,9)

		if inlist(name,"Armenia2005", "Colombia2000","Peru2000","Zimbabwe1999"){
			drop medfor c_diarrhea_medfor
			egen medfor = rowtotal(h12z h15 h15a h15b h15c h15f h15g h15h ),mi  // pedialite, frutiflex, other liquids
			gen c_diarrhea_medfor = ( medfor > = 1 ) if c_diarrhea == 1 & medfor!=.
			replace c_diarrhea_medfor = . if inlist(h12z,8,9) |inlist(h15,8,9)|inlist(h15a,8,9)|inlist(h15b,8,9)|inlist(h15c,8,9)|inlist(h15f,8,9)|inlist(h15g,8,9)|inlist(h15h,8,9)			
		}
		if inlist(name,"Egypt2005","Ethiopia2005" ){
			drop medfor c_diarrhea_medfor
			egen medfor = rowtotal(h12z h15 h15a h15b h15c h15e h15f h15g h15h),mi 
			gen c_diarrhea_medfor = ( medfor > = 1 ) if c_diarrhea == 1 & medfor!=.
			replace c_diarrhea_medfor = . if inlist(h12z,8,9) |inlist(h15,8,9)|inlist(h15a,8,9)|inlist(h15b,8,9)|inlist(h15c,8,9)|inlist(h15e,8,9)|inlist(h15f,8,9)|inlist(h15g,8,9)|inlist(h15h,8,9)
		}		
		if inlist(name,"Moldova2005"){
			drop medfor c_diarrhea_medfor
			egen medfor = rowtotal(h12z h15 h15a h15b h15c h15e h15f h15h),mi 
			gen c_diarrhea_medfor = ( medfor > = 1 ) if c_diarrhea == 1 & medfor!=.
			replace c_diarrhea_medfor = . if inlist(h12z,8,9) |inlist(h15,8,9)|inlist(h15a,8,9)|inlist(h15b,8,9)|inlist(h15c,8,9)|inlist(h15e,8,9)|inlist(h15f,8,9)|inlist(h15h,8,9)
		}			
		if inlist(name,"Mozambique2003"){
			drop medfor c_diarrhea_medfor
			egen medfor = rowtotal(h12z h15 h15a h15b h15c),mi 
			gen c_diarrhea_medfor = ( medfor > = 1 ) if c_diarrhea == 1 & medfor!=.
			replace c_diarrhea_medfor = . if inlist(h12z,8,9) |inlist(h15,8,9)|inlist(h15a,8,9)|inlist(h15b,8,9)|inlist(h15c,8,9)
		}			

		// formal medicine don't include "home remedy, herbal medicine and other"

*c_diarrhea_med	Child with diarrhea received any medicine other than ORS or hmf (country specific)
        egen med = rowtotal(h12z h15 h15a h15b h15c h15d h15e h15f h15g h15h),mi
		gen c_diarrhea_med = ( med > = 1 ) if c_diarrhea == 1 & med!=.
        replace c_diarrhea_med = . if inlist(h12z,8,9) |inlist(h15,8,9)|inlist(h15a,8,9)|inlist(h15b,8,9)|inlist(h15c,8,9)|inlist(h15d,8,9)|inlist(h15e,8,9)|inlist(h15f,8,9)|inlist(h15g,8,9)|inlist(h15h,8,9)

       	if inlist(name,"Colombia2000","Peru2000","Zimbabwe1999"){
			drop med c_diarrhea_med
			egen med = rowtotal(h12z h15 h15a h15b h15c h15d h15f h15g h15h),mi  // pedialite, frutiflex, other liquids
			gen c_diarrhea_med = ( med > = 1 ) if c_diarrhea == 1 & med!=.
			replace c_diarrhea_medfor = . if inlist(h12z,8,9) |inlist(h15,8,9)|inlist(h15a,8,9)|inlist(h15b,8,9)|inlist(h15c,8,9)|inlist(h15f,8,9)|inlist(h15g,8,9)|inlist(h15h,8,9)
		}
		if inlist(name,"Mozambique2003"){
			drop med c_diarrhea_med
			egen med = rowtotal(h12z h15 h15a h15b h15c),mi 
			gen c_diarrhea_med = ( med > = 1 ) if c_diarrhea == 1 & med!=.
			replace c_diarrhea_medfor = . if inlist(h12z,8,9) |inlist(h15,8,9)|inlist(h15a,8,9)|inlist(h15b,8,9)|inlist(h15c,8,9)
		}	
		
*c_diarrheaact	Child with diarrhea seen by provider OR given any form of formal treatment
        gen c_diarrheaact = (c_diarrhea_pro==1 | c_diarrhea_medfor==1 | c_diarrhea_hmf==1 | c_treatdiarrhea==1) if c_diarrhea == 1
		replace c_diarrheaact = . if (c_diarrhea_pro == . | c_diarrhea_medfor == . | c_diarrhea_hmf == . | c_treatdiarrhea == .) & c_diarrhea == 1		
					 					
*c_diarrheaact_q	Child with diarrhea who received any treatment or consultation and received ORS
        gen c_diarrheaact_q = c_treatdiarrhea  if c_diarrheaact == 1

		
*c_fever	Child with a fever in last two weeks
        gen c_fever = (h22 == 1) if !inlist(h22,.,8,9)
		
*c_sevdiarrhea	Child with severe diarrhea
		gen eat = (inlist(h39,0,1,2)) if !inlist(h39,.,8,9) & c_diarrhea == 1
        gen c_sevdiarrhea = (c_diarrhea==1 & (c_fever == 1 | c_diarrhea_mof == 1 | eat == 1)) 
		replace c_sevdiarrhea = . if c_diarrhea == . | c_fever == . | c_diarrhea_mof ==.| eat==.
		/* diarrhea in last 2 weeks AND any of the following three conditions: fever OR offered 
		more than usual to drink OR given much less or nothing to eat or stopped eating */
		
*c_sevdiarrheatreat	Child with severe diarrhea seen by formal healthcare provider
        gen c_sevdiarrheatreat = (c_sevdiarrhea == 1 & c_diarrhea_pro == 1) if c_diarrhea == 1
		replace c_sevdiarrheatreat = . if c_sevdiarrhea == . | c_diarrhea_pro == .
		
*c_sevdiarrheatreat_q	IV (intravenous) treatment of severe diarrhea among children with any formal provider visits
        gen iv = (h15c == 1) if !inlist(h15c,.,8,9) & c_diarrhea == 1
		gen c_sevdiarrheatreat_q = (iv ==1 ) if c_sevdiarrheatreat == 1
		
*c_ari	Children under 5 with cough and rapid breathing in the two weeks preceding the survey which originated from the chest.
        gen c_ari = . 
		
		if inlist(name,"Armenia2005","Ethiopia2005","Moldova2005"){
			ren s533 h31c
		}
		cap confirm variable h31c 
		if _rc== 0 {	
			replace c_ari = 0 if ccough != .
			replace c_ari = 1 if h31b == 1 & ccough == 1 & inlist(h31c,1,3)
			replace c_ari = . if inlist(h31b,8,9) | inlist(h31c,8,9)	
			replace c_ari = . if (ccough==1 & h31b ==.) | (h31b ==1 & h31c ==.)
		}
		
*c_ari2: Children under 5 with cough and rapid breathing in the two weeks preceding the survey.
		gen c_ari2 = 0 if ccough != .
		replace c_ari2 = 1 if h31b == 1 & ccough == 1
		replace c_ari2 = . if inlist(h31b,8,9)
		replace c_ari2 = . if ccough==1 & h31b == .
		
		if inlist(name, "Colombia2000"){
			replace c_ari2 = 0 if ccough != .
			replace c_ari2 = 1 if s469g == 1 & ccough == 1
			replace c_ari2 = . if inlist(s469g,8,9)
			replace c_ari2 = . if ccough==1 & s469g == .
		}
		/*gen c_ari2 = . 
		replace c_ari2 = 1 if h31b == 1
		replace c_ari2 = 0 if h31b == 0 | ccough == 0 */
 
*c_treatARI	Child with acute respiratory infection (ARI) symptoms seen by formal provider
	    /*please cross check as there might be case where the treatment provider is not in h32a-h32x*/

     	gen c_treatARI= 0 if c_ari == 1
        gen c_treatARI2= 0 if c_ari2 == 1	
        
	    order h32a-h32x,sequential
	    foreach var of varlist h32a-h32x {
	    local lab: variable label `var' 
        replace `var' = . if ///
	    regexm("`lab'","(other|shop|pharmacy|market|oth public sector|kiosk|relative|friend|church|oth.priv|oth med.priv|drug|addo|rescuer|trad|unqualified|stand|cabinet|ayush|^na|-na|- na)") ///
	    & !regexm("`lab'","(ngo|hospital|medical center|worker)")  
		replace `var' = . if !inlist(`var',0,1) 
	    }
		
	    if inlist(name,"Benin2001" "BurkinaFaso2003" ) {
			replace h32i =.
			replace h32r =.
		}
		
		if inlist(name,"Morocco2003") {
			replace h32f =.
		}

	    /* do not consider formal if contain words in 
	    the first group but don't contain any words in the second group */
        egen pro_ari = rowtotal(h32a-h32x),mi
		
		foreach var of varlist c_treatARI c_treatARI2 {
        replace `var' = 1 if `var' == 0 & pro_ari >= 1 
        replace `var'  = . if pro_ari == . 	
		}
	
	    if inlist(name,"Chad2004") { // Chad2004, cough and fever sections are seperate, this is cough section
			recode s468a s468b s468c s468d s468f s468g s468h s468i s468j s468k s468n (8 9 =.)
	        foreach var in s468a s468b s468c s468d s468f s468g s468h s468i s468j s468k s468n {
				replace c_treatARI2 = 0 if c_ari2 == 1	
				replace c_treatARI2 = 1 if c_treatARI2 == 0 & `var' == 1 
				replace c_treatARI2 = . if `var' == .
			}
	    }
	
	    if inlist(name,"Tanzania1999") {
	        drop c_treatARI2 
			g c_treatARI2 = h32z if c_ari2==1
	    }
		
*c_fevertreat	Child with fever symptoms seen by formal provider
		gen c_fevertreat = 0 if c_fever == 1

		if inlist(name,"Senegal2014","Senegal2012","Senegal2015","Senegal2010") {
			foreach var in $h32 {
				replace c_fevertreat = 1 if c_fevertreat == 0 & `var' == 1
				replace c_fevertreat = . if `var' == 9 
			}
		}	
		
		if inlist(name,"Malawi2000") {
			foreach k in s463f s463k s463p s463u{ //  government health center,mission health center,private health center, chw
				replace c_fevertreat = 1 if inrange(`k',0,3)  
			} // s463f s463k s463p s463u are subquestion for visit institution, they are missing if pay no visit to those institution, code c_fevertreat=0 if all s463f s463k s463p s463u are missing
		}	
	
		if inlist(name,"Malawi2004") {
			foreach k in s466a1 s466a2 s466a3 s466a4{ //  government health center,mission health center,private health center, community health worker 
				replace c_fevertreat = 1 if inlist(`k',3,4,5,7) & c_fevertreat == 0 
				replace c_fevertreat = . if `k'==12
			} 
		}	
		if inlist(name,"Mozambique2003") {
			foreach k in s466a1 s466a2 s466a3{ //  health facility,health worker
				replace c_fevertreat = 1 if inlist(`k',3,4) & c_fevertreat == 0 
				replace c_fevertreat = . if `k'==98
			} 
		}	
		
		if inlist(name,"Rwanda2000") {
			foreach k in s463ca s463cb s463cc{ //  health facility,health worker
				replace c_fevertreat = 1 if inlist(`k',3,4,5,7) & c_fevertreat == 0 
				replace c_fevertreat = . if `k'==.
			} 

			recode  s463ca s463cb s463cc  (3 4 5 7 =1) (1 2 6 8/10 =0) 
			egen fevertreat = rowtotal(s463ca s463cb s463cc),mi
			replace  c_fevertreat = 1 if c_fevertreat == 0 & fevertreat >= 1
			replace c_fevertreat = . if fevertreat == .
		}
		
	    if inlist(name,"Tanzania1999") {
	        replace c_fevertreat = h32z if c_fever==1
	    }
		
	    if inlist(name,"Vietnam2002") {
	        replace c_fevertreat = .
	    }
		
		if ~inlist(name,"Malawi2000", "Malawi2004","Rwanda2000", "Senegal2014","Senegal2012","Senegal2015","Senegal2010","Tanzania1999","Vietnam2002") {
			replace c_fevertreat = 1 if c_fevertreat == 0 & pro_ari >= 1
			replace c_fevertreat = . if pro_ari == .
		}	
		
		
*c_illness	Child with any illness symptoms in last two weeks
   		gen c_illness = (c_diarrhea == 1 | c_ari == 1 | c_fever == 1) 
		replace c_illness =. if c_diarrhea == . | c_ari == . | c_fever == .
		
		gen c_illness2 = (c_diarrhea == 1 | c_ari2 == 1 | c_fever == 1) 
		replace c_illness2 =. if c_diarrhea == . | c_ari2 == . | c_fever == .
		
*c_illtreat	Child with any illness symptoms taken to formal provider
        gen c_illtreat = (c_fevertreat == 1 | c_diarrhea_pro == 1 | c_treatARI == 1) if c_illness == 1
		replace c_illtreat = . if (c_fever == 1 & c_fevertreat == .) | (c_diarrhea == 1 & c_diarrhea_pro == .) | (c_ari == 1 & c_treatARI == .) 
        gen c_illtreat2 = (c_fevertreat == 1 | c_diarrhea_pro == 1 | c_treatARI == 1) if c_illness2 == 1
		replace c_illtreat2 = . if (c_fever == 1 & c_fevertreat == .) | (c_diarrhea == 1 & c_diarrhea_pro == .) | (c_ari2 == 1 & c_treatARI2 == .) 








