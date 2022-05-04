
******************************
*** Child vaccination ********
******************************   

*Apr2022 add h1 as denominator condition

*c_measles	child			Child received measles1/MMR1 vaccination
        gen c_measles  =. 
		replace c_measles = 1 if (h9 ==1 | h9 ==2 | h9 ==3)  
     	replace c_measles = 0 if h9 ==0 
		replace c_measles = 0 if missing(c_measles) & !missing(h1)		
		replace c_measles  = . if h9 > 3	
			
if inlist(name,"Azerbaijan2006"){
		drop c_measles
		gen c_measles = 1 if (h9 ==1 | h9 ==2 | h9 ==3 | inrange(s506mr,1,3))  
     	replace c_measles = 0 if h9 ==0 & s506mr == 0  
		replace c_measles = 0 if missing(c_measles) & !missing(h1)		
		replace c_measles  = . if h9 > 3 | s506mr > 3
		}
		
if inlist(name,"Colombia2000"){
		drop c_measles
		gen c_measles = 1 if (h9 ==1 | h9 ==2 | h9 ==3 | inrange(s456t,1,3))  
     	replace c_measles = 0 if h9 ==0 & s456t == 0  
		replace c_measles = 0 if missing(c_measles) & !missing(h1)		
		replace c_measles  = . if h9 > 3 | s456t > 3	
		
		}	
if inlist(name,"Malawi2000"){
		replace c_measles = 1 if h36a ==1 | h36b ==1 | h36c ==1  
		replace c_measles = 0 if missing(c_measles) & !missing(h1)		
		replace c_measles  = . if h36a > 3 | h36b > 3 | h36c > 3
		}	 
		
if inlist(name,"Zambia2001"){
		replace c_measles = 1 if s465cd ==1  
		replace c_measles = 0 if missing(c_measles) & !missing(h1)		
		replace c_measles  = . if h9 > 3 | s465cd > 3
		}		

*c_dpt1	child	Child received DPT1/Pentavalent 1 vaccination	
        gen c_dpt1  = . 
		replace c_dpt1  = 1 if (h3 ==1 | h3 ==2 | h3 ==3)  
		replace c_dpt1  = 0 if h3 ==0  
			replace c_dpt1  = 0 if missing(c_dpt1) & !missing(h1)
			replace c_dpt1  = . if h3 > 3	
			
*c_dpt2	child			Child received DPT2/Pentavalent2 vaccination				
		gen c_dpt2  = . 
		replace c_dpt2  = 1 if (h5 ==1 | h5 ==2 | h5 ==3)  
		replace c_dpt2  = 0 if h5 ==0  
			replace c_dpt2  = 0 if missing(c_dpt2) & !missing(h1)
			replace c_dpt2  = . if h5 > 3
			
*c_dpt3	child			Child received DPT3/Pentavalent3 vaccination				
		gen c_dpt3  = . 
		replace c_dpt3  = 1 if (h7 ==1 | h7 ==2 | h7 ==3)  
		replace c_dpt3  = 0 if h7 ==0  
			replace c_dpt3  = 0 if missing(c_dpt3) & !missing(h1)
			replace c_dpt3  = . if h7 > 3
			
*c_bcg	child			Child received BCG vaccination
		gen c_bcg  = . 
		replace c_bcg  = 1 if (h2 ==1 | h2 ==2 | h2 ==3)  
		replace c_bcg  = 0 if h2 ==0
			replace c_bcg  = 0 if missing(c_bcg) & !missing(h1)
			replace c_bcg  = . if h2 > 3
			
		gen cpolio0  = .  
		replace cpolio0  = 1 if (h0 ==1 | h0 ==2 | h0 ==3)  
		replace cpolio0  = 0 if h0 ==0  
			replace cpolio0  = 0 if missing(cpolio0) & !missing(h1)
			replace cpolio0  = . if h0 > 3
		
*c_polio1	child			Child received polio1/OPV1 vaccination
		gen c_polio1  = .  
		replace c_polio1  = 1 if (h4 ==1 | h4 ==2 | h4 ==3)  
		replace c_polio1  = 0 if h4 ==0  
			replace c_polio1  = 0 if missing(c_polio1) & !missing(h1)
			replace c_polio1  = . if h4 > 3
			
*c_polio2	child			Child received polio2/OPV2 vaccination				
		gen c_polio2  = .  
		replace c_polio2  = 1 if (h6 ==1 | h6 ==2 | h6 ==3)  
		replace c_polio2  = 0 if h6 ==0  
			replace c_polio2  = 0 if missing(c_polio2) & !missing(h1)
			replace c_polio2  = . if h6 > 3
			
*c_polio3	child			Child received polio3/OPV3 vaccination				
		gen c_polio3  = .  
		replace c_polio3  = 1 if (h8 ==1 | h8 ==2 | h8 ==3)  
		replace c_polio3  = 0 if h8 ==0  
			replace c_polio3  = 0 if missing(c_polio3) & !missing(h1)
			replace c_polio3  = . if h8 > 3	
			
if inlist(name,"Armenia2005"){
		replace c_bcg  = 1 if s512==1 & (c_bcg==. |c_bcg==0)
		replace c_bcg  = 0 if s512==2 & c_bcg==. 	
			replace c_bcg  = 0 if missing(c_bcg) & !missing(h1)
			replace c_bcg  = . if h2 > 3 | s512 > 3
					
		replace c_measles  = 1 if s512h==1 & (c_measles==. |c_measles==0)
		replace c_measles  = 0 if s512h==2 & c_measles==. 	
		replace c_measles = 0 if missing(c_measles) & !missing(h1)		
		replace c_measles  = . if h9 > 3 | s512h > 3	
		
		replace c_dpt1  = 1 if s512g<=7 & (c_dpt1==. |c_dpt1==0)
		replace c_dpt1  = 0 if s512f==2 & (c_dpt1==. |c_dpt1==0)
			replace c_dpt1  = 0 if missing(c_dpt1) & !missing(h1)
			replace c_dpt1  = . if h3 > 3 | s512f>=8
		
		replace c_dpt2  = 1 if s512g<=7 & s512g>=2 & (c_dpt2==. |c_dpt2==0)
		replace c_dpt2  = 0 if s512f==2 & (c_dpt2==. |c_dpt2==0)
		replace c_dpt2  = 0 if s512g<2 & c_dpt2==. 
			replace c_dpt2  = 0 if missing(c_dpt2) & !missing(h1)
			replace c_dpt2  = . if h5 > 3 | s512f>=8
		
		replace c_dpt3  = 1 if s512g<=7 & s512g>=3 & (c_dpt3==. |c_dpt3==0)
		replace c_dpt3  = 0 if s512f==2 & (c_dpt3==. |c_dpt3==0)		
		replace c_dpt3  = 0 if s512g<3 & c_dpt3==. 
			replace c_dpt3  = 0 if missing(c_dpt3) & !missing(h1)
			replace c_dpt3  = . if h7 > 3 | s512f>=8
			
		replace c_polio1  = 1 if s512e<=7 & (c_polio1==. |c_polio1==0)
		replace c_polio1  = 0 if s512d==2 & (c_polio1==. |c_polio1==0)
			replace c_polio1  = 0 if missing(c_polio1) & !missing(h1)
			replace c_polio1  = . if h4 > 3 | s512d>=8

		replace c_polio2  = 1 if s512e<=7 & s512e>=2 & (c_polio2==. |c_polio2==0)
		replace c_polio2  = 0 if s512d==2 & (c_polio2==. |c_polio2==0)
		replace c_polio2  = 0 if s512g<2 & c_polio2==. 
			replace c_polio2  = 0 if missing(c_polio2) & !missing(h1)
			replace c_polio2  = . if h6 > 3 | s512d>=8
			
		replace c_polio3  = 1 if s512e<=7 & s512e>=3 & (c_polio3==. |c_polio3==0)
		replace c_polio3  = 0 if s512d==2 & (c_polio3==. |c_polio3==0)	
		replace c_polio3  = 0 if s512g<3 & c_polio3==. 
			replace c_polio3  = 0 if missing(c_polio3) & !missing(h1)
			replace c_polio3  = . if h8 > 3 | s512d>=8
		}
		
if inlist(name,"Colombia2005"){
		drop c_measles c_dpt* 
		
		gen c_measles = 1 if (h9 ==1 | h9 ==2 | h9 ==3 | inrange(s506t,1,3))
     	replace c_measles = 0 if h9 ==0 & s506t == 0 
		replace c_measles = 0 if missing(c_measles) & !missing(h1)		
		replace c_measles  = . if h9 > 3 | s506t > 3
		
		gen c_dpt1 = 1 if (h3==1 | h3==2 | h3==3|inrange(spv1,1,3))
		replace c_dpt1 = 0 if h3==0 & spv1==0 
			replace c_dpt1  = 0 if missing(c_dpt1) & !missing(h1)
			replace c_dpt1  = . if h3 > 3 | spv1>3
			
		gen c_dpt2 = 1 if (h5==1 | h5==2 | h5==3|inrange(spv2,1,3))
		replace c_dpt2 = 0 if h5==0 & spv2==0 
			replace c_dpt2  = 0 if missing(c_dpt2) & !missing(h1)
			replace c_dpt2  = . if h5 > 3 | spv2>3
			
		gen c_dpt3 = 1 if (h7==1 | h7==2 | h7==3|inrange(spv3,1,3))
		replace c_dpt3 = 0 if h7==0 & spv3==0
			replace c_dpt3  = 0 if missing(c_dpt3) & !missing(h1)
			replace c_dpt3  = . if h7 > 3 | spv3>3
}

if inlist(name,"Nicaragua2001"){
		drop c_dpt1 c_dpt2 c_dpt3 
		
		gen c_dpt1 = .
		replace c_dpt1 = 1 if (h3==1 | h3==2 | h3==3|inrange(spv1,1,3)) 
		replace c_dpt1 = 0 if h3==0 & spv1==0 
			replace c_dpt1  = 0 if missing(c_dpt1) & !missing(h1)
			replace c_dpt1  = . if h3 > 3 | spv1>3
			
		gen c_dpt2 = .
		replace c_dpt2 = 1 if (h5==1 | h5==2 | h5==3|inrange(sd2,1,3)) 
		replace c_dpt2 = 0 if h5==0 & sd2==0 
			replace c_dpt2  = 0 if missing(c_dpt2) & !missing(h1)
			replace c_dpt2  = . if h5 > 3 | sd2>3
			
		gen c_dpt3 = .
		replace c_dpt3 = 1 if (h7==1 | h7==2 | h7==3|inrange(sd3,1,3)) 
		replace c_dpt3 = 0 if h7==0 & sd3==0 
			replace c_dpt3  = 0 if missing(c_dpt3) & !missing(h1)
			replace c_dpt3  = . if h7 > 3 | sd3>3
		}	

if inlist(name,"Tanzania2004"){
		drop c_dpt1 c_dpt2 c_dpt3
		
		gen c_dpt1 = .
		replace c_dpt1 = 1 if (h3==1 | h3==2 | h3==3|inrange(hb1,1,3)) 
		replace c_dpt1 = 0 if h3==0 & hb1==0 
			replace c_dpt1  = 0 if missing(c_dpt1) & !missing(h1)
			replace c_dpt1  = . if h3 > 3 | hb1>3
			
		gen c_dpt2 = .
		replace c_dpt2 = 1 if (h5==1 | h5==2 | h5==3|inrange(hb2,1,3)) 
		replace c_dpt2 = 0 if h5==0 & hb2==0 
			replace c_dpt2  = 0 if missing(c_dpt2) & !missing(h1)
			replace c_dpt2  = . if h5 > 3 | hb2>3
			
		gen c_dpt3 = .
		replace c_dpt3 = 1 if (h7==1 | h7==2 | h7==3|inrange(hb3,1,3)) 
		replace c_dpt3 = 0 if h7==0 & hb3==0 
			replace c_dpt3  = 0 if missing(c_dpt3) & !missing(h1)
			replace c_dpt3  = . if h7 > 3 | hb3>3
}	
*c_fullimm	child			Child fully vaccinated						
		gen c_fullimm =.  										/*Note: polio0 is not part of allvacc- see DHS final report*/
		replace c_fullimm =1 if (c_measles==1 & c_dpt1 ==1 & c_dpt2 ==1 & c_dpt3 ==1 & c_bcg ==1 & c_polio1 ==1 & c_polio2 ==1 & c_polio3 ==1)  
		replace c_fullimm =0 if (c_measles==0 | c_dpt1 ==0 | c_dpt2 ==0 | c_dpt3 ==0 | c_bcg ==0 | c_polio1 ==0 | c_polio2 ==0 | c_polio3 ==0)  
		replace c_fullimm =. if b5 ==0  
						
*c_vaczero: Child did not receive any vaccination		
		gen c_vaczero = (c_measles == 0 & c_polio1 == 0 & c_polio2 == 0 & c_polio3 == 0 & c_bcg == 0 & c_dpt1 == 0 & c_dpt2 == 0 & c_dpt3 == 0)
		foreach var in c_measles c_polio1 c_polio2 c_polio3 c_bcg c_dpt1 c_dpt2 c_dpt3{
			replace c_vaczero = . if `var' == .
		}					
		*label var c_vaczero "1 if child did not receive any vaccinations"
