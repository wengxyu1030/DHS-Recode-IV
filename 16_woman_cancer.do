
***********************
*** Woman Cancer*******
***********************
	
*w_papsmear	Women received a pap smear  (1/0) 
*w_mammogram	Women received a mammogram (1/0)

gen w_papsmear = .
gen w_mammogram = .

/*
capture confirm variable s714dd s714ee 
if _rc==0 {
    replace w_papsmear=1 if s714dd==1 & s714ee==1
	replace w_papsmear=0 if s714dd==0 | s714ee==0
	replace w_papsmear=. if s714dd==9 | s714ee==9
}

capture confirm variable s1011a s1011 s1012c s1012b
if _rc == 0 {
    ren v012 wage	
	replace s1011a=. if s1011a==98|s1011a==99
    replace w_papsmear=1 if (s1011==1&s1011a<=23)
    replace w_papsmear=0 if s1011==0
    replace w_papsmear=0 if w_papsmear == . & s1011a>35 & s1011a<100
    replace w_papsmear=. if s1011==.
    tab wage if w_papsmear!=. /*DHS sample is women aged 15-49*/
    replace w_papsmear=. if wage<20|wage>49
	
	replace w_mammogram=1 if s1012c==1
    replace w_mammogram=0 if s1012c==0|s1012b==0
    tab wage if w_mammogram!=. /*DHS sample is women aged 15-49*/
    replace w_mammogram=. if wage<40|wage>49
}
*/
if inlist(name, "Bolivia2003"){
	replace w_papsmear = s254 ==1 if s254<=1
    ren v012 wage	
    tab wage if w_papsmear!=. /*DHS sample is women aged 15-49*/
    replace w_papsmear=. if wage<20|wage>49
}

if inlist(name, "Colombia2005"){
	replace w_papsmear = 0 if s902!=.  
	replace w_papsmear = 1 if s904==1	
	replace w_papsmear = 0 if s905a==1 
    ren v012 wage	
    tab wage if w_papsmear!=. /*DHS sample is women aged 18-49*/
    replace w_papsmear=. if wage<20|wage>49
	
	replace w_mammogram=s927 if s927<=1
    tab wage if w_mammogram!=. /*DHS sample is women aged 18-49*/
    replace w_mammogram=. if wage<40|wage>49
}

if inlist(name, "DominicanRepublic1999"){
	replace w_papsmear = s333
    ren v012 wage	
    tab wage if w_papsmear!=. /*DHS sample is women aged 15-49*/
    replace w_papsmear=. if wage<20|wage>49
	
	replace w_mammogram=1 if inlist(s335,1,3)
    replace w_mammogram=0 if inlist(s335,2,4)
    tab wage if w_mammogram!=. /*DHS sample is women aged 15-49*/
    replace w_mammogram=. if wage<40|wage>49
}

if inlist(name, "DominicanRepublic2002"){
	replace w_papsmear = s334 ==1 if s334<=1
    ren v012 wage	
    tab wage if w_papsmear!=. /*DHS sample is women aged 15-49*/
    replace w_papsmear=. if wage<20|wage>49
	
	replace w_mammogram=1 if inlist(s335,1,3)
    replace w_mammogram=0 if inlist(s335,2,4)
    tab wage if w_mammogram!=. /*DHS sample is women aged 15-49*/
    replace w_mammogram=. if wage<40|wage>49
}

if inlist(name, "Namibia2000"){
	replace w_papsmear = s484 ==1 if s484<=1
    ren v012 wage	
    tab wage if w_papsmear!=. /*DHS sample is women aged 15-49*/
    replace w_papsmear=. if wage<20|wage>49
}

if inlist(name, "Nicaragua2001"){
	replace w_papsmear = s330b ==1 if s330b<=1
    ren v012 wage	
    tab wage if w_papsmear!=. /*DHS sample is women aged 15-49*/
    replace w_papsmear=. if wage<20|wage>49
	
	replace w_mammogram=inlist(s330f,1,3) if s330f<=3
    tab wage if w_mammogram!=. /*DHS sample is women aged 15-49*/
    replace w_mammogram=. if wage<40|wage>49
}

if inlist(name, "Peru2000"){
	replace w_papsmear = s491 ==1 if s490<=1
    ren v012 wage	
    tab wage if w_papsmear!=. /*DHS sample is women aged 15-49*/
    replace w_papsmear=. if wage<20|wage>49
}

if inlist(name, "Philippines2003"){
	replace w_papsmear = s334 ==1 if s334<=8   // if don't know pap, regard as never take the pap test
    ren v012 wage	
    tab wage if w_papsmear!=. /*DHS sample is women aged 15-49*/
    replace w_papsmear=. if wage<20|wage>49
}
/*
capture confirm variable qs415 qs416u 
if _rc==0 {
    ren qs23 wage
    replace w_mammogram=(qs415==1&qs416u==1)
    replace w_mammogram=. if qs415==.|qs415==8|qs415==9|qs416u==9
    tab wage if w_mammogram!=. /*DHS sample is women aged 15-49*/
    replace w_mammogram=. if wage<50|wage>69
}


capture confirm variable s490a
if _rc==0 {
	replace  w_mammogram = s490a
	replace  w_mammogram = . if !inrange(v012,20,49)
}
*/
*Add reference period.
//if not in adeptfile, please generate value, otherwise keep it missing. 
//if the preferred recall is not available (3 years for pap, 2 years for mam) use shortest other available recall 

gen w_mammogram_ref = ""  //use string in the list: "1yr","2yr","5yr","ever"; or missing as ""
gen w_papsmear_ref = ""   //use string in the list: "1yr","2yr","3yr","5yr","ever"; or missing as ""


if inlist(name, "Bolivia2003") {
	replace w_papsmear_ref = "3yr"
}
if inlist(name, "Colombia2005") {
	replace w_papsmear_ref = "3yr"
	replace w_mammogram_ref = "ever"
}
if inlist(name, "Jordan2002") {
	replace w_mammogram_ref = "1yr"
}

if inlist(name, "Namibia2000") {
	replace w_papsmear_ref = "ever"
}

if inlist(name, "Nicaragua2001","DominicanRepublic1999","DominicanRepublic2002") {
	replace w_papsmear_ref = "1yr"
	replace w_mammogram_ref = "1yr"
}

if inlist(name, "Peru2000","Philippines2003") {
	replace w_papsmear_ref = "5yr"
}


* Add Age Group.
//if not in adeptfile, please generate value, otherwise keep it missing. 

gen w_mammogram_age = "" //use string in the list: "20-49","20-59"; or missing as ""
gen w_papsmear_age = ""  //use string in the list: "40-49","20-59"; or missing as ""


if inlist(name, "Bolivia2003","Colombia2005", "DominicanRepublic1999","DominicanRepublic2002", "Namibia2000", "Nicaragua2001","Peru2000","Philippines2003") {
	replace w_papsmear_age = "20-49"
}

if inlist(name,"Colombia2005", "DominicanRepublic1999","DominicanRepublic2002", "Jordan2002") {
	replace w_mammogram_age = "40-49"
}

