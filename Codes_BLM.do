clear all
set more off
cd ""
global results ""

local c_date = string(d(`c(current_date)'), "%tdYY-NN-DD" )
local c_time      = c(current_time)
local c_time_date = "`c_date'"+"_" +"`c_time'"
local time_string    = subinstr("`c_time_date'", ":", "_", .)
local time_string    = subinstr("`time_string'", " ", "_", .)

********************************************************************************
*Main Figures and Tables
********************************************************************************

********************Figure 1a***************************************************
use foranalysis2.dta, replace

collapse (mean) num_orders = num_orders, by(blackres period)

sort period blackres

twoway (line num_orders period if blackres==1, lcolor(red)) ///
(line num_orders period if blackres==0, lcolor(gs8)),  xline(0, lp(dash) lcolor(black)) graphregion(color(white)) ///
xtitle("Day", size(medium)) ytitle("# of daily Orders",size(medium)) ///
xlabel(-140(20)140, labsize(medium)) ylabel(0(5)25,labsize(medium)) legend(size(medium)) ///
legend(ring(0) pos(2) col(1) order(1 "Black-owned" 2 "Control")) ysize(3.5in) xsize(6.5in)

graph export "$results\fig1a_`time_string'.png",replace

********************Figure 1b***************************************************
use foranalysis2.dta, replace

quietly reghdfe num_orders blackres day* bd*, noabsorb 
est sto mainunsub
est save mainunsub, replace

est use mainunsub
est store mainunsub

coefplot mainunsub, keep(bd*) vertical recast(connect) yline(0) xline(139, lp(dash)) graphregion(color(white)) ///
xtitle("Day", size(medium)) ytitle("# of daily Orders ",size(medium)) ///
xlabel(-1 "-140" 19 "-120" 39 "-100" 59 "-80"  79 "-60" 99 "-40" 119 "-20" ///
139 "0" 159 "20" 179 "40" 199 "60" 219 "80" 239 "100" ///
259 "120" 279 "140", labsize(medium)) ///
msize(tiny) scheme(sj) connect(i) ciopts(lwidth(0.2) lcolor()) mfcolor(white) /// 
ylabel(,labsize(medium) glcolor(gs14) glwidth(vvthin) angle(vertical)) ysize(3.5in) xsize(6.5in)

graph export "$results\fig1b_`time_string'.png",replace


************************************Table 1*************************************
use foranalysis.dta, replace

local varlist num_orders dollar_orders
foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id date_local pairmonth)  vce(cluster store_id date_local)
	outreg2 using "$results/table1_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p)) ///
	keep(blackres_post)  bdec(3) tdec(2) nocons  label 
	}
	
local varlist dollarperorder2 dollarperorder5	
foreach y of local varlist {
	reghdfe `y' blackres_post, absorb(store_id date_local pairmonth)  vce(cluster store_id date_local)
	outreg2 using "$results/table1_`time_string'_poisson.xls", append  stat(coef tstat pval ci) parent(tstat)  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons  label 
	}

		
***********************************Table 2a*************************************
use foranalysis.dta, replace

local varlist num_orders dollar_orders 

foreach y of local varlist {
	ppmlhdfe `y' blackres_inter blackres_postp, absorb(store_id date_local store_id pairmonth)  vce(cluster store_id date_local)
	outreg2 using "$results/table2a_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_inter blackres_postp) bdec(3) tdec(2) nocons  label 
}
		
***********************************Table 2b*************************************
use foranalysis_protest3.dta, replace

ppmlhdfe num_orders blackres_post blackres_post_cumsizeprotest  logcum_size_protest, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/table2b_`time_string'_poisson.xls", replace eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post blackres_post_cumsizeprotest blackres_post_cumsizeprotestwd cum_size_protest)  bdec(3) tdec(2) nocons  label

ppmlhdfe num_orders blackres_post blackres_post_cumsizeprotest blackres_post_cumsizeprotestwd logcum_size_protest, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/table2b_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post blackres_post_cumsizeprotest blackres_post_cumsizeprotestwd cum_size_protest)  bdec(3) tdec(2) nocons  label

ppmlhdfe dollar_orders blackres_post blackres_post_cumsizeprotest  logcum_size_protest, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/table2b_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post blackres_post_cumsizeprotest blackres_post_cumsizeprotestwd cum_size_protest)  bdec(3) tdec(2) nocons  label
		
ppmlhdfe dollar_orders blackres_post blackres_post_cumsizeprotest blackres_post_cumsizeprotestwd logcum_size_protest, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/table2b_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post blackres_post_cumsizeprotest blackres_post_cumsizeprotestwd cum_size_protest)  bdec(3) tdec(2) nocons  label

*******************************Table 2c ****************************************
use foranalysis_protest3.dta, replace

local varlist num_orders dollar_orders 

foreach y of local varlist {
	ppmlhdfe `y' blackres_post if defpolice==0, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/table2c_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons  label
	}

foreach y of local varlist {
	ppmlhdfe `y' blackres_post if defpolice==1, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/table2c_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons  label
	}

************************************Table 3a ***********************************
use foranalysis.dta, replace

local varlist num_orders_blackdom dollar_orders_blackdom num_orders_whitedom dollar_orders_whitedom

foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/table3a_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons  label
	}
	

*************************************Table 3b **********************************
use foranalysis.dta, replace

local varlist num_orders_poorcus dollar_orders_poorcus num_orders_richcus dollar_orders_richcus 

foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/table3b_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons  label
	}	

**********************Table 3c *************************************************
use foranalysis.dta, replace

ppmlhdfe num_orders blackres_post if votedif<=0, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/table3c_`time_string'_poisson.xls", replace eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post)  bdec(3) tdec(2) nocons ctitle(Red_county) label

ppmlhdfe dollar_orders blackres_post if votedif<=0, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/table3c_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post)  bdec(3) tdec(2) nocons ctitle(blue_county) label

ppmlhdfe num_orders blackres_post if votedif>0, absorb(store_id date_local  pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/table3c_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post)  bdec(3) tdec(2) nocons ctitle(blue_county) label

ppmlhdfe dollar_orders blackres_post if votedif>0, absorb(store_id date_local  pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/table3c_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post)  bdec(3) tdec(2) nocons ctitle(blue_county) label


************************************Table 3d ***********************************
use foranalysis.dta, replace

local varlist num_orders_h1 dollar_orders_h1 num_orders_h2 dollar_orders_h2
foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/table3d_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons  label
	}
			
************************************Table 3e ************************************
use foranalysis.dta, replace

local varlist num_orders_oldcus dollar_orders_oldcus num_orders_newcus dollar_orders_newcus
foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/table3e_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons  label
	}	

***********************************Table 4a*************************************
use foranalysis.dta, replace

local varlist  num_orders dollar_orders 
foreach y of local varlist {
	ppmlhdfe `y' blackres_post blackres_post2, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/table4a_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post blackres_post2)  bdec(3) tdec(2) nocons label
}
		
***********************************Table 4b*************************************
use foranalysis.dta, replace

local varlist  num_orders dollar_orders
foreach y of local varlist {
	ppmlhdfe `y' blackres_outage blackres_nonoutage , absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/table4b_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_outage blackres_nonoutage)  bdec(3) tdec(2) nocons label
}



********************************************************************************
*Extended Figures and Tables
********************************************************************************
************************************Extended Fig. 1a****************************
use us_coordinates,clear

gen order = _n
drop if _X < -165 & _X != . &  _ID == 54
replace _X = _X  + 55  if  _X != .  &  _ID == 54
replace _Y = _Y  + 4  if _Y != .  &  _ID == 54

replace _X = _X*.4  -55 if  _X !=  . &  _ID == 17
replace _Y = _Y*.4  + 1 if _Y != .  & _ID == 17
drop if _X > -10 & _X != . & _ID == 17
sort order 
sort _ID
drop order

keep if !inlist(_ID,2,28,29,49,55)

merge using reslist_unsub.dta
line _Y _X, cmiss(n) lcolor(gs0) lwidth(thin)||sc latitude longitude, msize(tiny) mcolor(red) leg(off) xla(-124/-71) yla(,nogrid) ysc(off) xsc(off) graphr(fc(white)) scheme(cleanplots) ylab(, nogrid) xlab(, nogrid) ysize(3.5in) xsize(5in)
graph export "$results\ed_fig1a_`time_string'.png",replace

************************************Extended Table 1****************************
use foranalysis.dta, replace

tabstat num_orders dollar_orders dollarperorder num_orders_blackdom num_orders_whitedom num_orders_poorcus  num_orders_richcus  num_orders_oldcus num_orders_newcus  num_orders_h1 num_orders_h2 if blackres==1 & post==0,  stat(n mean sd )
tabstat num_orders dollar_orders dollarperorder num_orders_blackdom num_orders_whitedom num_orders_poorcus  num_orders_richcus  num_orders_oldcus num_orders_newcus  num_orders_h1 num_orders_h2 if blackres==0 & post==0,  stat(n mean sd )

tabstat num_orders dollar_orders dollarperorder num_orders_blackdom num_orders_whitedom num_orders_poorcus  num_orders_richcus num_orders_oldcus num_orders_newcus  num_orders_h1 num_orders_h2 if blackres==1 & post==1,  stat(n mean sd )
tabstat num_orders dollar_orders dollarperorder num_orders_blackdom num_orders_whitedom num_orders_poorcus  num_orders_richcus num_orders_oldcus num_orders_newcus  num_orders_h1 num_orders_h2 if blackres==0 & post==1,  stat(n mean sd )

local varlist num_orders dollar_orders dollarperorder num_orders_blackdom num_orders_whitedom num_orders_poorcus  num_orders_richcus  num_orders_oldcus num_orders_newcus  num_orders_h1 num_orders_h2

foreach y of local varlist {
ttest `y' if post==0, by(blackres)
}

local varlist num_orders dollar_orders dollarperorder num_orders_blackdom num_orders_whitedom num_orders_poorcus  num_orders_richcus num_orders_oldcus num_orders_newcus  num_orders_h1 num_orders_h2

foreach y of local varlist {
ttest `y' if post==1, by(blackres)
}

use reslist.dta, replace
keep if unsub==1
tabstat age  perc_black_res perc_white_res if blackres==1 ,  stat(n mean sd min p25 p50 p75 max)
tabstat age  perc_black_res  perc_white_res if blackres==0 ,  stat(n mean sd min p25 p50 p75 max)

local varlist age   perc_black_res perc_white_res

foreach y of local varlist {
ttest `y' , by(blackres)
}

************************************Extended Table 2****************************
use foranalysis_placebo2.dta, replace


local varlist num_orders dollar_orders 

foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/ed_table2_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons  label
	}	

************************************Extended Table 3 Panel A ********************
use foranalysis_altcont2.dta, replace


local varlist num_orders dollar_orders 

foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/ed_Table3a_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons  label
	}
	
************************************Extended Table 3 Panel B *******************
use resorder_altcontbroad2.dta, replace
gen period=week_local-22

gen post=0
replace post=1 if period>=0

gen blackres_post=blackres*post

gen month=ceil(week_local/4)

egen pairmonth=group(city_id2 month)


local varlist num_orders dollar_orders 

foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id week_local pairmonth) vce(cluster store_id week_local)
	outreg2 using "$results/ed_Table3b_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons  label
	}
	
************************************Extended Table 4 Panel A********************
use foranalysis_covid1.dta, replace

ppmlhdfe num_orders blackres_post cases_scaled death_scaled, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/ed_Table4a_`time_string'_poisson.xls", replace eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post)  bdec(3) tdec(2) nocons ctitle(Number of orders) label
	
ppmlhdfe dollar_orders blackres_post cases_scaled death_scaled, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/ed_Table4a_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post)  bdec(3) tdec(2) nocons ctitle(Number of orders) label
	
************************************Extended Table 4 Panel B********************
use foranalysis_covid2.dta, replace

ppmlhdfe num_orders blackres_postg0 blackres_postg1 blackres_postg2, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/ed_Table4b_`time_string'_poisson.xls", replace eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_postg0 blackres_postg1 blackres_postg2)  bdec(3) tdec(2) nocons ctitle(Number of orders) label
	
test _b[blackres_postg0] =_b[blackres_postg1] =_b[blackres_postg2]

ppmlhdfe dollar_orders blackres_postg0 blackres_postg1 blackres_postg2, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/ed_Table4b_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_postg0 blackres_postg1 blackres_postg2)  bdec(3) tdec(2) nocons ctitle(Number of orders) label
	
test _b[blackres_postg0] =_b[blackres_postg1] =_b[blackres_postg2]

************************************Extended Table 5 Panel A********************
use foranalysis_goodman.dta, replace

bacondecomp lognum_orders blackres_postp, ddetail
bacondecomp logdollar_orders blackres_postp, ddetail

************************************Extended Table 5 Panel B********************
use foranalysis_goodman.dta, replace

keep if week_rel>=-21 & week_rel<=14
drop if missing(week_rel)

ppmlhdfe num_orders blackres_postp, absorb(county_fips2 groupid week_local) vce(cluster groupid week_rel)
outreg2 using "$results/ed_Table5b_`time_string'_poisson.xls", replace eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_postp)  bdec(3) tdec(2) nocons  label
	
ppmlhdfe dollar_orders blackres_postp, absorb(county_fips2 groupid week_local) vce(cluster groupid week_rel)
outreg2 using "$results/ed_Table5b_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_postp)  bdec(3) tdec(2) nocons  label


************************************Extended Table 6****************************
use foranalysis.dta, replace

ppmlhdfe num_orders blackres_post if votedif<=-0.2, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/ed_Table6_`time_string'_poisson.xls", replace eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))   ///
keep(blackres_post)  bdec(3) tdec(2) nocons ctitle(Red_county) label

ppmlhdfe dollar_orders blackres_post if votedif<=-0.2, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/ed_Table6_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))   ///
keep(blackres_post)  bdec(3) tdec(2) nocons ctitle(blue_county) label

ppmlhdfe num_orders blackres_post if votedif<=0, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/ed_Table6_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post)  bdec(3) tdec(2) nocons ctitle(Red_county) label

ppmlhdfe dollar_orders blackres_post if votedif<=0, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/ed_Table6_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))   ///
keep(blackres_post)  bdec(3) tdec(2) nocons ctitle(blue_county) label

ppmlhdfe num_orders blackres_post if votedif>0, absorb(store_id date_local  pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/ed_Table6_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))   ///
keep(blackres_post)  bdec(3) tdec(2) nocons ctitle(blue_county) label

ppmlhdfe dollar_orders blackres_post if votedif>0, absorb(store_id date_local  pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/ed_Table6_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))   ///
keep(blackres_post)  bdec(3) tdec(2) nocons ctitle(blue_county) label

************************************Extended Table 7****************************
use foranalysis.dta, replace

summ  num_orders_oldcus dollar_orders_oldcus num_orders_oldcus_high num_orders_oldcus_high2 num_orders_oldcus_high3 num_orders_oldcus_low num_orders_newcus

local varlist  num_orders_oldcus_high  dollar_orders_oldcus_high num_orders_oldcus  dollar_orders_oldcus num_orders_newcus dollar_orders_newcus

foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/ed_Table7_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons label
	}


*************Extended Table 8***************************************************
use foranalysis2020.dta, replace

local varlist num_orders dollar_orders 

foreach y of local varlist {
	ppmlhdfe `y' blackres_postfloyd blackres_post140dind, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/ed_Table8_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_postfloyd blackres_post140dind)  bdec(3) tdec(2) nocons ctitle(Number of orders) label
	}

test _b[blackres_postfloyd] =_b[blackres_post140dind] 


********************************************************************************
*Supplementary Information
********************************************************************************

*************Supplementary Table 1**********************************************
use yelpblack.dta, replace

local varlist num_orders dollar_orders 

foreach y of local varlist {
	ppmlhdfe `y' blackres9_post , absorb(store_id weekofyear_local2 pairmonth) vce(cluster store_id weekofyear_local2)
	outreg2 using "$results/si_Table1_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres9_post)  bdec(3) tdec(2) nocons  label
	}

*************Supplementary Table 2**********************************************
use foranalysis_highblackpop.dta, replace

local varlist  num_orders  dollar_orders 

foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/si_Table2_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons label
	}	
	
use foranalysis_targetcuisine.dta, replace

local varlist  num_orders  dollar_orders
foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/si_Table2_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons label
}	

*************Supplementary Table 3A**********************************************
use existing2.dta, replace

local varlist  num_orders dollar_orders  

foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/si_Table3a_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons label
	}	

*************Supplementary Table 3B**********************************************
use foranalysis2020.dta, replace

summ num_orders num_orders_oldcus num_orders_oldcusm1 num_orders_oldcusm2 num_orders_oldcusm3 num_orders_newcus

local varlist  num_orders dollar_orders  

foreach y of local varlist {
	ppmlhdfe `y' blackres_post, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
	outreg2 using "$results/si_Table3b_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
	keep(blackres_post)  bdec(3) tdec(2) nocons label
	}	

	
*************Supplementary Table 4**********************************************
use foranalysis_spill.dta, replace

ppmlhdfe num_orders blackres_post blackres_beforeotther blackres_postotther, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/si_Table4_`time_string'_poisson.xls", replace eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post blackres_beforeotther blackres_postotther)  bdec(3) tdec(2) nocons ctitle(Number of orders) label

test _b[blackres_beforeotther] =_b[blackres_postotther]

	
ppmlhdfe dollar_orders blackres_post blackres_beforeotther blackres_postotther, absorb(store_id date_local pairmonth) vce(cluster store_id date_local)
outreg2 using "$results/si_Table4_`time_string'_poisson.xls", append eform stat(coef tstat pval ci) parent(tstat) addstat(Pseudo R-squared, e(r2_p))  ///
keep(blackres_post blackres_beforeotther blackres_postotther)  bdec(3) tdec(2) nocons ctitle(Number of orders) label
	
test _b[blackres_beforeotther] =_b[blackres_postotther]



