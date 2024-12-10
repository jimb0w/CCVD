
texdoc init CCVD, replace logdir(logCVD) gropts(optargs(width=0.8\textwidth))
set linesize 100

*ssc install texdoc, replace
*net from http://www.stata-journal.com/production
*net install sjlatex
*copy "http://www.stata-journal.com/production/sjlatex/stata.sty" stata.sty

! rm -r "/home/jimb0w/Documents/CCVD/Library"
cd /home/jimb0w/Documents/CCVD
! git clone https://github.com/jimb0w/Library.git


texdoc stlog, nolog nodo
cd /home/jimb0w/Documents/CCVD
texdoc do CCVD.do
texdoc stlog close


/***

\documentclass[11pt]{article}
\usepackage{fullpage}
\usepackage{siunitx}
\usepackage{hyperref,graphicx,booktabs,dcolumn}
\usepackage{stata}
\usepackage[x11names]{xcolor}
\bibliographystyle{unsrt}
\usepackage{natbib}
\usepackage{pdflscape}
\usepackage[section]{placeins}

\usepackage{chngcntr}
\counterwithin{figure}{section}
\counterwithin{table}{section}

\usepackage{multirow}
\usepackage{booktabs}

\newcommand{\specialcell}[2][c]{%
  \begin{tabular}[#1]{@{}c@{}}#2\end{tabular}}
\newcommand{\thedate}{\today}

\usepackage{pgfplotstable}

\begin{document}


\begin{titlepage}
    \begin{flushright}
        \Huge
        \textbf{Sex and age-specific mortality for cardiovascular disease among people with and without diabetes}
\color{black}
\rule{16cm}{2mm} \\
\Large
\color{black}
\thedate \\
\color{blue}
https://github.com/jimb0w/CCVD \\
\color{black}
       \vfill
    \end{flushright}
        \Large

\noindent
Correspondence to: \\
\noindent
Jedidiah Morton \\
\color{blue}
\href{mailto:Jedidiah.Morton@Monash.edu}{Jedidiah.Morton@monash.edu} \\ 
\color{black}
Research Fellow \\
Baker Heart and Diabetes Institute, Melbourne, Australia \\
Monash University, Melbourne, Australia \\\

\end{titlepage}

\clearpage
\tableofcontents

\clearpage
\section{Data summary}

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
cd /home/jimb0w/Documents/CCVD
*copy /home/jimb0w/Documents/CM/CMdataCVD.dta CMdataCVD.dta
foreach c in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
use CMdataCVD, clear
keep if country == "`c'"
gen hrt_d_dm = chd_d_dm+hfd_d_dm
gen hrt_d_nondm = chd_d_nondm+hfd_d_nondm
save `c', replace
}
clear
set obs 9
gen country = "Australia" if _n == 1
replace country = "Canada (Alberta)" if _n == 2
replace country = "Canada (Ontario)" if _n == 3
replace country = "Denmark" if _n == 4
replace country = "Finland" if _n == 5
replace country = "France" if _n == 6
replace country = "Lithuania" if _n == 7
replace country = "Scotland" if _n == 8
replace country = "South Korea" if _n == 9
colorpalette tol PuBr, n(9) nograph
gen col = ""
forval i = 1/9 {
replace col = "`r(p`i')'" if _n == `i'
}
save ccol, replace
*mkdir CSV
use CMdataCVD, clear
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
bysort country (cal) : egen lb = min(cal)
bysort country (cal) : egen ub = max(cal)
tostring lb ub, replace
gen rang = lb+ "-" + ub
collapse (sum) pys_dm pys_nondm cvd_d_dm-hfd_d_dm cvd_d_nondm-hfd_d_nondm, by(country sex rang)
expand 2
bysort country sex : gen DM = _n-1
tostring sex pys_dm-DM, replace force format(%15.0fc)
gen pys = pys_dm if DM == "1"
replace pys = pys_nondm if DM == "0"
foreach i in cvd chd cbd hfd {
gen `i' = `i'_d_dm if DM == "1"
replace `i' = `i'_d_nondm if DM == "0"
}
keep country-rang DM-hfd
order country rang DM sex
sort country rang DM sex
gen njm = _n
bysort country DM (njm) : replace DM ="" if _n!=1
bysort country (njm) : replace rang ="" if _n!=1
bysort country (njm) : replace country ="" if _n!=1
sort njm
replace DM = "No diabetes" if DM == "0"
replace DM = "Diabetes" if DM == "1"
replace sex = "Female" if sex == "0"
replace sex = "Male" if sex == "1"
drop njm
export delimited using CSV/T1.csv, delimiter(":") novarnames replace
texdoc stlog close

/***
\color{black}

\begin{landscape}

\begin{table}[h!]
  \begin{center}
    \caption{Summary of data included in the analysis.}
	\hspace*{-2.5cm}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{4}{*}{##1}}}},
	  display columns/1/.style={column name=Period,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{4}{*}{##1}}}},
	  display columns/2/.style={column name=Diabetes status,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{2}{*}{##1}}}},
      display columns/3/.style={column name=Sex, column type={l}, text indicator="},
      display columns/4/.style={column name=Person-years of follow-up, column type={r}},
      display columns/5/.style={column name=CVD, column type={r}},
      display columns/6/.style={column name=CHD, column type={r}},
      display columns/7/.style={column name=CBD, column type={r}},
      display columns/8/.style={column name=HF, column type={r}},
      every head row/.style={
        before row={\toprule
					& & & & & \multicolumn{4}{c}{Death counts by cause of death} \\
					},
        after row={\midrule}
            },
        every nth row={4}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/T1.csv}
  \end{center}
Abbreviations: 
CVD -- cardiovascular disease; 
CHD -- coronary heart disease; 
CBD -- cerebrovascular disease;
HF -- heart failure;
\end{table}
\end{landscape}


\clearpage
\section{Crude rates}


\color{Blue4}
***/

texdoc stlog, cmdlog nodo
*mkdir GPH
foreach c in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
use `c', clear
if "`c'" == "Canada1" {
local co = "Canada (Alberta)"
}
else if "`c'" == "Canada2" {
local co = "Canada (Ontario)"
}
else if "`c'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`c'"
}
collapse (sum) pys_dm pys_nondm cvd_d_dm-hfd_d_dm cvd_d_nondm-hfd_d_nondm, by(calendar sex)
foreach i in cvd chd cbd hfd {
if "`i'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`i'" == "chd" {
local oo = "Coronary heart disease"
}
if "`i'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`i'" == "hfd" {
local oo = "Heart failure"
}
foreach iii in dm nondm {
if "`iii'" == "dm" {
local dd = "with"
}
if "`iii'" == "nondm" {
local dd = "without"
}
gen `iii'_`i' = 1000*`i'_d_`iii'/pys_`iii'
twoway ///
(connected `iii'_`i' cal if sex == 0, col(red)) ///
(connected `iii'_`i' cal if sex == 1, col(blue)) ///
, graphregion(color(white)) ///
ytitle(Mortality rate (per 1,000 person-years), margin(a+2)) ///
xtitle(Calendar year) ///
legend(order( ///
1 "Females" ///
2 "Males" ///
) cols(1) position(3) region(lcolor(none) color(none))) ///
ylabel(,angle(0) format(%9.2f)) ///
title("People `dd' diabetes", placement(west) size(medium) col(black))
graph save GPH/cr_`i'_`iii'_`c', replace
}
graph combine ///
GPH/cr_`i'_dm_`c'.gph ///
GPH/cr_`i'_nondm_`c'.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(10)
}
}
texdoc stlog close
texdoc stlog, nolog
foreach c in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
use `c', clear
if "`c'" == "Canada1" {
local co = "Canada (Alberta)"
}
else if "`c'" == "Canada2" {
local co = "Canada (Ontario)"
}
else if "`c'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`c'"
}
collapse (sum) pys_dm pys_nondm cvd_d_dm-hfd_d_dm cvd_d_nondm-hfd_d_nondm, by(calendar sex)
foreach i in cvd chd cbd hfd {
if "`i'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`i'" == "chd" {
local oo = "Coronary heart disease"
}
if "`i'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`i'" == "hfd" {
local oo = "Heart failure"
}
foreach iii in dm nondm {
if "`iii'" == "dm" {
local dd = "with"
}
if "`iii'" == "nondm" {
local dd = "without"
}
gen `iii'_`i' = 1000*`i'_d_`iii'/pys_`iii'
twoway ///
(connected `iii'_`i' cal if sex == 0, col(red)) ///
(connected `iii'_`i' cal if sex == 1, col(blue)) ///
, graphregion(color(white)) ///
ytitle(Mortality rate (per 1,000 person-years), margin(a+2)) ///
xtitle(Calendar year) ///
legend(order( ///
1 "Females" ///
2 "Males" ///
) cols(1) position(3) region(lcolor(none) color(none))) ///
ylabel(,angle(0) format(%9.2f)) ///
title("People `dd' diabetes", placement(west) size(medium) col(black))
graph save GPH/cr_`i'_`iii'_`c', replace
}
graph combine ///
GPH/cr_`i'_dm_`c'.gph ///
GPH/cr_`i'_nondm_`c'.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(10)
texdoc graph, label(cr_`i'_`c') figure(h!) cabove ///
caption(Crude mortality rate by cause of death, sex, and diabetes status. `oo'. `co'.)
}
texdoc stlog close
/***
\clearpage
***/
texdoc stlog, nolog
}
texdoc stlog close

/***
\color{black}

\clearpage
Coding issues are present for Finland and Lithuania for heart failure; deaths
from heart failure in these countries will not be presented. 


\clearpage
\section{Age-specific rates and MRRs}

Model fit checks have been performed in prior work (REF). 
Here, we just plot the age-specific mortality rates in people with and without diabetes,
as well as age-specific mortality rate ratios (MRRs). 

For rates, we will use age-period-cohort models.
Each model will be a Poisson model, parameterised using 
spline effects of age, period, and cohort (period-age), with log 
of person-years as the offset. We will then use these models to estimate mortality
rates for each country by age and sex. 

For MRRs, we will use a model with spline effects of 
calendar time, a binary effect of sex, and an interaction between spline effects of age and diabetes status. 
We will then use this model to estimate the MRR for each country by age and sex. 

All rates and MRRs are predicted in 2017

\color{Blue4}
***/


texdoc stlog, cmdlog nodo
*mkdir MD
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in cvd chd cbd hfd hrt {
foreach iii in dm nondm {
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = calendar-2009.5
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 10 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
clear
set obs 500
gen age = (_n/10)+39.9
gen calendar = 2017.5-2009.5
gen coh = calendar-age
gen pys_`iii' = 1
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 9.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
predict errr, stdp
replace _Rate = _Rate*1000
gen lb = exp(ln(_Rate)-1.96*errr)
gen ub = exp(ln(_Rate)+1.96*errr)
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
gen sex = `iiii'
keep age _Rate lb-sex
save MD/R_`i'_`ii'_`iii'_`iiii', replace
}
}
}
}
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
use `i', clear
expand 2
bysort cal age_dm sex : gen dm = _n-1
foreach ii in cvd_d chd_d cbd_d hfd_d hrt_d pys age {
gen `ii' = `ii'_dm if dm == 1
replace `ii' = `ii'_nondm if dm == 0
drop `ii'_dm `ii'_nondm
}
drop if age==.
save `i'_long, replace
}
quietly {
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in cvd chd cbd hfd hrt {
forval iii = 0/1 {
use `i'_long, clear
replace calendar = calendar-2009.5
gen coh = calendar-age
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 10 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
preserve
clear
set obs 500
gen age = (_n/10)+39.9
gen calendar = 2017.5-2009.5
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
forval a = 1/500 {
local A1`a' = agesp1[`a']
local A2`a' = agesp2[`a']
local A3`a' = agesp3[`a']
}
local T1 = timesp1[1]
restore
}
else if inrange(`rang',10,14.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
preserve
clear
set obs 500
gen age = (_n/10)+39.9
gen calendar = 2017.5-2009.5
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
forval a = 1/500 {
local A1`a' = agesp1[`a']
local A2`a' = agesp2[`a']
local A3`a' = agesp3[`a']
}
local T1 = timesp1[1]
local T2 = timesp2[1]
restore
}
else {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
preserve
clear
set obs 500
gen age = (_n/10)+39.9
gen calendar = 2017.5-2009.5
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
forval a = 1/500 {
local A1`a' = agesp1[`a']
local A2`a' = agesp2[`a']
local A3`a' = agesp3[`a']
}
local T1 = timesp1[1]
local T2 = timesp2[1]
local T3 = timesp3[1]
restore
}
keep if sex == `iii'
poisson `ii'_d timesp* c.agesp*##i.dm, exposure(pys)
matrix A = (.,.,.)
if `rang' < 10 {
forval a = 1/500 {
margins, dydx(dm) at(timesp1==`T1' agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else if inrange(`rang',10,14.9) {
forval a = 1/500 {
margins, dydx(dm) at(timesp1==`T1' timesp2==`T2' agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else {
forval a = 1/500 {
margins, dydx(dm) at(timesp1==`T1' timesp2==`T2' timesp3==`T3' agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
clear
svmat A
replace A1 = exp(A1)
replace A2 = exp(A2)
replace A3 = exp(A3)
drop if A1==.
gen age = (_n/10)+39.9
gen sex = `iii'
gen OC = "`ii'"
gen country = "`i'"
save MD/SMRa_`i'_`ii'_`iii', replace
}
}
}
}
foreach ii in cvd chd cbd hfd hrt {
forval iiii = 0/1 {
foreach iii in dm nondm {
if `iiii' == 0 {
local s = "Females"
}
if `iiii' == 1 {
local s = "Males"
}
if "`iii'" == "dm" {
local w = "with"
}
if "`iii'" == "nondm" {
local w = "without"
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using MD/R_`i'_`ii'_`iii'_`iiii'
}
keep if sex == `iiii'
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
merge 1:1 country using ccol, keep(3) nogen
forval i = 1/9 {
local C`i' = country[`i']
local col`i' = col[`i']
}
restore
if "`ii'" == "hfd" | "`ii'" == "hrt" {
twoway ///
(rarea ub lb age if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb age if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb age if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb age if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb age if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb age if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C8'", color("`col8'") lpattern(solid)) ///
(rarea ub lb age if country == "`C9'", color("`col9'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C9'", color("`col9'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C6'" ///
12 "`C8'" ///
14 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.0001 "0.0001" 0.001 "0.001" 0.01 "0.01" 0.1 "0.1" 1 10 100, grid angle(0)) ///
xscale(range(40 90)) ///
xlabel(40(10)90, nogrid) ///
yscale(log range(0.00007 120)) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Age") ///
title("`s' `w' diabetes", placement(west) color(black) size(medium))
}
else {
twoway ///
(rarea ub lb age if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb age if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb age if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb age if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb age if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb age if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb age if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb age if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C8'", color("`col8'") lpattern(solid)) ///
(rarea ub lb age if country == "`C9'", color("`col9'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if country == "`C9'", color("`col9'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'" ///
18 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.0001 "0.0001" 0.001 "0.001" 0.01 "0.01" 0.1 "0.1" 1 10 100, grid angle(0)) ///
xscale(range(40 90)) ///
xlabel(40(10)90, nogrid) ///
yscale(log range(0.00007 120)) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Age") ///
title("`s' `w' diabetes", placement(west) color(black) size(medium))
}
graph save GPH/MD_`ii'_`iii'_`iiii', replace
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using MD/SMRa_`i'_`ii'_`iiii'
}
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
if "`ii'" == "hfd" | "`ii'" == "hrt" {
twoway ///
(rarea A3 A2 age if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C8'", color("`col8'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C9'", color("`col9'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C9'", color("`col9'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C6'" ///
12 "`C8'" ///
14 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.2 "0.2" 0.5 "0.5" 1 2 5 10 20 50 100 200 500, grid angle(0)) ///
xscale(range(40 90)) ///
xlabel(40(10)90, nogrid) ///
yline(1, lcol(black)) yscale(log range(0.08 700)) ///
ytitle("Mortality rate ratio", margin(a+2)) ///
xtitle("Age") ///
title("`s'", placement(west) color(black) size(medium))
}
else {
twoway ///
(rarea A3 A2 age if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C8'", color("`col8'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C9'", color("`col9'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C9'", color("`col9'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'" ///
18 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.2 "0.2" 0.5 "0.5" 1 2 5 10 20 50 100 200 500, grid angle(0)) ///
xscale(range(40 90)) ///
xlabel(40(10)90, nogrid) ///
yline(1, lcol(black)) yscale(log range(0.08 700)) ///
ytitle("Mortality rate ratio", margin(a+2)) ///
xtitle("Age") ///
title("`s'", placement(west) color(black) size(medium))
}
graph save GPH/SMRa_`ii'_`iiii', replace
}
}
texdoc stlog close

/***
\color{black}

\clearpage

\color{Blue4}
***/

texdoc stlog, cmdlog
foreach ii in cvd chd cbd hfd hrt {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Coronary heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
}
if "`ii'" == "hfd" {
local oo = "Heart deaths"
}
graph combine ///
GPH/MD_`ii'_dm_0.gph ///
GPH/MD_`ii'_nondm_0.gph ///
GPH/SMRa_`ii'_0.gph ///
GPH/MD_`ii'_dm_1.gph ///
GPH/MD_`ii'_nondm_1.gph ///
GPH/SMRa_`ii'_1.gph ///
, graphregion(color(white)) cols(3) altshrink xsize(10)
texdoc graph, label(gph_`ii') figure(h!) cabove ///
caption(Mortality rate in people with and without diabetes and mortality rate ratio by age. `oo'.)
}
texdoc stlog close

/***
\color{black}

\clearpage
\section{Age-specific rates over time}

Same models as above, just presented differently. 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in cvd chd cbd hfd {
foreach iii in dm nondm {
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = calendar-2009.5
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 10 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
keep calendar
bysort cal : keep if _n == 1
expand 10
bysort cal : replace cal = cal+((_n-6)/10)
expand 6
bysort cal : gen age = (_n*10)+30
gen coh = calendar-age
gen pys_`iii' = 1
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 9.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
predict errr, stdp
replace _Rate = _Rate*1000
gen lb = exp(ln(_Rate)-1.96*errr)
gen ub = exp(ln(_Rate)+1.96*errr)
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
gen sex = `iiii'
keep age _Rate lb-sex cal
replace cal = cal+2009.5
save MD/R2_`i'_`ii'_`iii'_`iiii', replace
}
}
}
}
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in cvd chd cbd hfd {
foreach iii in dm nondm {
foreach iiii in 0 1 {
if `iiii' == 0 {
local s = "Females"
}
if `iiii' == 1 {
local s = "Males"
}
if "`iii'" == "dm" {
local w = "with"
}
if "`iii'" == "nondm" {
local w = "without"
}
colorpalette inferno, n(7) nograph
use MD/R2_`i'_`ii'_`iii'_`iiii', clear
sort age cal
twoway ///
(rarea ub lb cal if age ==40, color("`r(p1)'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cal if age == 40, color("`r(p1)'") lpattern(solid)) ///
(rarea ub lb cal if age ==50, color("`r(p2)'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cal if age == 50, color("`r(p2)'") lpattern(solid)) ///
(rarea ub lb cal if age ==60, color("`r(p3)'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cal if age == 60, color("`r(p3)'") lpattern(solid)) ///
(rarea ub lb cal if age ==70, color("`r(p4)'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cal if age == 70, color("`r(p4)'") lpattern(solid)) ///
(rarea ub lb cal if age ==80, color("`r(p5)'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cal if age == 80, color("`r(p5)'") lpattern(solid)) ///
(rarea ub lb cal if age ==90, color("`r(p6)'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cal if age == 90, color("`r(p6)'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(12 "90" ///
10 "80" ///
8 "70" ///
6 "60" ///
4 "50" ///
2 "40") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.00001 "0.00001" 0.0001 "0.0001" 0.001 "0.001" 0.01 "0.01" 0.1 "0.1" 1 "1" 10 "10" 100 "100", grid angle(0)) ///
xlabel(, nogrid) ///
yscale(log range(0.00001 100)) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Age") ///
title("`s' `w' diabetes", placement(west) color(black) size(medium))
graph save GPH/MD2_`i'_`ii'_`iii'_`iiii', replace
}
}
}
}
texdoc stlog close
texdoc stlog, cmdlog nodo
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
if "`i'" == "Canada1" {
local co = "Canada (Alberta)"
}
else if "`i'" == "Canada2" {
local co = "Canada (Ontario)"
}
else if "`i'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`i'"
}
foreach ii in cvd chd cbd hfd {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Coronary heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
}
if ("`i'" == "Finland" | "`i'" == "Lithuania") & "`ii'" == "hfd" {
}
else {
graph combine ///
GPH/MD2_`i'_`ii'_dm_0.gph ///
GPH/MD2_`i'_`ii'_nondm_0.gph ///
GPH/MD2_`i'_`ii'_dm_1.gph ///
GPH/MD2_`i'_`ii'_nondm_1.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(5)
}
}
}
texdoc stlog close
texdoc stlog, nolog
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
if "`i'" == "Canada1" {
local co = "Canada (Alberta)"
}
else if "`i'" == "Canada2" {
local co = "Canada (Ontario)"
}
else if "`i'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`i'"
}
foreach ii in cvd chd cbd hfd {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Coronary heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
}
if ("`i'" == "Finland" | "`i'" == "Lithuania") & "`ii'" == "hfd" {
}
else {
graph combine ///
GPH/MD2_`i'_`ii'_dm_0.gph ///
GPH/MD2_`i'_`ii'_nondm_0.gph ///
GPH/MD2_`i'_`ii'_dm_1.gph ///
GPH/MD2_`i'_`ii'_nondm_1.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(5)
texdoc graph, label(gph2_`i'`ii') figure(h!) cabove ///
caption(Mortality rate in people with and without diabetes by age and calendar time. `co'. `oo'.)
}
}
texdoc stlog close
/***
\clearpage
***/
texdoc stlog, nolog
}
texdoc stlog close


/***
\color{black}

\clearpage
\section{Annual percent changes}

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
quietly {
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in cvd chd cbd hfd hrt {
foreach iii in dm nondm {
use `i', clear
replace calendar = (calendar-2009.5)/5
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
poisson `ii'_d_`iii' cal c.agesp*##sex, exposure(pys_`iii')
matrix A_`i'_`ii'_`iii' = (r(table)[1,1], r(table)[5,1], r(table)[6,1], r(table)[4,1])
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = (calendar-2009.5)/5
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
poisson `ii'_d_`iii' cal c.agesp*, exposure(pys_`iii')
matrix A_`i'_`ii'_`iii'_`iiii' = (r(table)[1,1], r(table)[5,1], r(table)[6,1], r(table)[4,1])
}
}
}
}
matrix A = (.,.,.,.,.,.,.,.)
local a1 = 0
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
local a1 = `a1'+1
local a2 = 0
foreach ii in cvd chd cbd hfd hrt {
local a2 = `a2'+1
local a3 = 0
foreach iii in dm nondm {
local a3 = `a3'+1
matrix A = (A\0`a1',`a2',`a3',2,A_`i'_`ii'_`iii')
foreach iiii in 0 1 {
matrix A = (A\0`a1',`a2',`a3',`iiii',A_`i'_`ii'_`iii'_`iiii')
}
}
}
}
clear
svmat A
sort A1 A2 A3 A4
drop if A1==.
tostring A2-A3, replace format(%9.0f) force
gen country=""
local a1 = 0
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
local a1 = `a1'+1
replace country = "`i'" if A1 == `a1'
local a2 = 0
foreach ii in cvd chd cbd hfd hrt {
local a2 = `a2'+1
replace A2 = "`ii'" if A2 == "`a2'"
local a3 = 0
foreach iii in dm nondm {
local a3 = `a3'+1
replace A3 = "`iii'" if A3 == "`a3'"
}
}
}
replace A5 = 100*(exp(A5)-1)
replace A6 = 100*(exp(A6)-1)
replace A7 = 100*(exp(A7)-1)
save APCs, replace
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in cvd chd cbd hfd hrt {
use `i'_long, clear
replace calendar = (calendar-2009.5)/5
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
poisson `ii'_d agesp* sex c.cal*##i.dm, exposure(pys)
matrix A_`i'_`ii' = (r(table)[1,9], r(table)[5,9], r(table)[6,9], r(table)[4,9])
foreach iii in 0 1 {
use `i'_long, clear
keep if sex == `iii'
replace calendar = (calendar-2009.5)/5
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
poisson `ii'_d agesp* sex c.cal*##i.dm, exposure(pys)
matrix A_`i'_`ii'_`iii' = (r(table)[1,9], r(table)[5,9], r(table)[6,9], r(table)[4,9])
}
}
}
matrix A = (.,.,.,.,.,.,.)
local a1 = 0
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
local a1 = `a1'+1
local a2 = 0
foreach ii in cvd chd cbd hfd hrt {
local a2 = `a2'+1
matrix A = (A\0`a1',`a2',2,A_`i'_`ii')
foreach iii in 0 1 {
matrix A = (A\0`a1',`a2',`iii',A_`i'_`ii'_`iii')
}
}
}
clear
svmat A
sort A1 A2 A3
drop if A1==.
tostring A2, replace format(%9.0f) force
gen country=""
local a1 = 0
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
local a1 = `a1'+1
replace country = "`i'" if A1 == `a1'
local a2 = 0
foreach ii in cvd chd cbd hfd hrt {
local a2 = `a2'+1
replace A2 = "`ii'" if A2 == "`a2'"
}
}
replace A4 = 100*(exp(A4)-1)
replace A5 = 100*(exp(A5)-1)
replace A6 = 100*(exp(A6)-1)
save SMR_APCs, replace
}
use APCs, clear
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
tostring A5-A7, force format(%9.1f) replace
gen APC = A5 + " (" + A6 + ", " + A7 + ")"
drop A5-A8
reshape wide APC, i(A1 country A3 A4) j(A2) string
drop A1
tostring A4, replace force
replace A4 = "Female" if A4 == "0"
replace A4 = "Male" if A4 == "1"
replace A4 = "Overall" if A4 == "2"
replace A3 = "No diabetes" if A3 == "nondm"
replace A3 = "Diabetes" if A3 == "dm"
replace APChfd = "" if country == "Finland" | country == "Lithuania"
replace APChrt = "" if country == "Finland" | country == "Lithuania"
gen njm = _n
preserve
keep if A4 == "Overall"
bysort country (njm) : replace country ="" if _n!=1
drop A4
order country A3 APCcvd APCchd APCcbd APChfd APChrt
drop njm
export delimited using CSV/APC.csv, delimiter(":") novarnames replace
restore
drop if A4 == "Overall"
bysort country A3 (njm) : replace A3 ="" if _n!=1
bysort country (njm) : replace country ="" if _n!=1
order country A3 A4 APCcvd APCchd APCcbd APChfd APChrt
drop njm
export delimited using CSV/APCS.csv, delimiter(":") novarnames replace
use SMR_APCs, clear
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
tostring A4-A6, force format(%9.1f) replace
gen APC = A4 + " (" + A5 + ", " + A6 + ")"
drop A4-A7
reshape wide APC, i(A1 country A3) j(A2) string
drop A1
tostring A3, replace force
replace A3 = "Female" if A3 == "0"
replace A3 = "Male" if A3 == "1"
replace A3 = "Overall" if A3 == "2"
replace APChfd = "" if country == "Finland" | country == "Lithuania"
replace APChrt = "" if country == "Finland" | country == "Lithuania"
preserve
keep if A3 == "Overall"
drop A3
order country APCcvd APCchd APCcbd APChfd APChrt
export delimited using CSV/SMR_APC.csv, delimiter(":") novarnames replace
restore
gen njm = _n
drop if A3 == "Overall"
bysort country (njm) : replace country ="" if _n!=1
order country A3 APCcvd APCchd APCcbd APChfd APChrt
drop njm
export delimited using CSV/SMR_APCS.csv, delimiter(":") novarnames replace
forval s = 0/2 {
if `s' == 0 {
local ss = "females"
}
if `s' == 1 {
local ss = "males"
}
if `s' == 2 {
local ss = "people"
}
use APCs, clear
replace A5 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace A6 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace A7 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort A1 : keep if _n == 1
forval c = 1/9 {
local C`c' = country[`c']
}
restore
gen AA = .
forval c = 1/9 {
replace AA = -`c' if country == "`C`c''"
}
replace AA = AA+0.2 if A2 == "chd"
replace AA = AA-0.2 if A2 == "hfd"
twoway ///
(rcap A7 A6 AA if A2 == "chd" & A3 == "dm" & A4 == `s', horizontal col("0 0 255")) ///
(scatter AA A5 if A2 == "chd" & A3 == "dm" & A4 == `s', col("0 0 255")) ///
(rcap A7 A6 AA if A2 == "cbd" & A3 == "dm" & A4 == `s', horizontal col("0 125 0")) ///
(scatter AA A5 if A2 == "cbd" & A3 == "dm" & A4 == `s', col("0 125 0")) ///
(rcap A7 A6 AA if A2 == "hfd" & A3 == "dm" & A4 == `s', horizontal col("255 0 255")) ///
(scatter AA A5 if A2 == "hfd" & A3 == "dm" & A4 == `s', col("255 0 255")) ///
, graphregion(color(white)) legend(order( ///
2 "Coronary heart disease" 4 "Cerebrovascular disease" 6 "Heart failure") cols(1) ///
ring(0) region(lcolor(none) color(none)) position(1)) ///
ylabel( ///
-1 "`C1'" ///
-2 "`C2'" ///
-3 "`C3'" ///
-4 "`C4'" ///
-5 "`C5'" ///
-6 "`C6'" ///
-7 "`C7'" ///
-8 "`C8'" ///
-9 "`C9'" ///
, angle(0) nogrid) ytitle("") xline(0, lcol(black)) ///
xlabel(-50(10)50, format(%9.0f)) xtitle(5-year percent change) ///
title("Mortality rate, `ss' with diabetes", placement(west) col(black) size(medium))
graph save GPH/APCo_DM_`s', replace
use APCs, clear
replace A5 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace A6 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace A7 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort A1 : keep if _n == 1
forval c = 1/9 {
local C`c' = country[`c']
}
restore
gen AA = .
forval c = 1/9 {
replace AA = -`c' if country == "`C`c''"
}
replace AA = AA+0.2 if A2 == "chd"
replace AA = AA-0.2 if A2 == "hfd"
twoway ///
(rcap A7 A6 AA if A2 == "chd" & A3 == "nondm" & A4 == `s', horizontal col("0 0 255")) ///
(scatter AA A5 if A2 == "chd" & A3 == "nondm" & A4 == `s', col("0 0 255")) ///
(rcap A7 A6 AA if A2 == "cbd" & A3 == "nondm" & A4 == `s', horizontal col("0 125 0")) ///
(scatter AA A5 if A2 == "cbd" & A3 == "nondm" & A4 == `s', col("0 125 0")) ///
(rcap A7 A6 AA if A2 == "hfd" & A3 == "nondm" & A4 == `s', horizontal col("255 0 255")) ///
(scatter AA A5 if A2 == "hfd" & A3 == "nondm" & A4 == `s', col("255 0 255")) ///
, graphregion(color(white)) legend(order( ///
2 "Coronary heart disease" 4 "Cerebrovascular disease" 6 "Heart failure") cols(1) ///
ring(0) region(lcolor(none) color(none)) position(1)) ///
ylabel( ///
-1 "`C1'" ///
-2 "`C2'" ///
-3 "`C3'" ///
-4 "`C4'" ///
-5 "`C5'" ///
-6 "`C6'" ///
-7 "`C7'" ///
-8 "`C8'" ///
-9 "`C9'" ///
, angle(0) nogrid) ytitle("") xline(0, lcol(black)) ///
xlabel(-50(10)50, format(%9.0f)) xtitle(5-year percent change) ///
title("Mortality rate, `ss' without diabetes", placement(west) col(black) size(medium))
graph save GPH/APCo_nonDM_`s', replace
use SMR_APCs, clear
replace A4 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace A5 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace A6 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort A1 : keep if _n == 1
forval c = 1/9 {
local C`c' = country[`c']
}
restore
gen AA = .
forval c = 1/9 {
replace AA = -`c' if country == "`C`c''"
}
replace AA = AA+0.2 if A2 == "chd"
replace AA = AA-0.2 if A2 == "hfd"
twoway ///
(rcap A6 A5 AA if A2 == "chd" & A3 == `s', horizontal col("0 0 255")) ///
(scatter AA A4 if A2 == "chd" & A3 == `s', col("0 0 255")) ///
(rcap A6 A5 AA if A2 == "cbd" & A3 == `s', horizontal col("0 125 0")) ///
(scatter AA A4 if A2 == "cbd" & A3 == `s', col("0 125 0")) ///
(rcap A6 A5 AA if A2 == "hfd" & A3 == `s', horizontal col("255 0 255")) ///
(scatter AA A4 if A2 == "hfd" & A3 == `s', col("255 0 255")) ///
, graphregion(color(white)) legend(order( ///
2 "Coronary heart disease" 4 "Cerebrovascular disease" 6 "Heart failure") cols(1) ///
ring(0) region(lcolor(none) color(none)) position(1)) ///
ylabel( ///
-1 "`C1'" ///
-2 "`C2'" ///
-3 "`C3'" ///
-4 "`C4'" ///
-5 "`C5'" ///
-6 "`C6'" ///
-7 "`C7'" ///
-8 "`C8'" ///
-9 "`C9'" ///
, angle(0) nogrid) ytitle("") xline(0, lcol(black)) ///
xlabel(-50(10)50, format(%9.0f)) xtitle(5-year percent change) ///
title("Mortality rate ratio, `ss'", placement(west) col(black) size(medium))
graph save GPH/APCo_MRR_`s', replace
}
foreach o in chd cbd hfd {
foreach dm in dm nondm {

if "`o'" == "chd" {
local oo = "CHD"
}
if "`o'" == "cbd" {
local oo = "CBD"
}
if "`o'" == "hfd" {
local oo = "HF"
}
if "`dm'" == "dm" {
local ndm = "with"
}
if "`dm'" == "nondm" {
local ndm = "without"
}

use APCs, clear
replace A5 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace A6 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace A7 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
drop if A4 == 2
keep if A2 == "`o'"
keep if A3 == "`dm'"
keep A1 country A4-A7
reshape wide A5-A7, i(A1 country) j(A4)
preserve
bysort country : keep if _n == 1
merge 1:1 country using ccol, keep(3) nogen
forval i = 1/9 {
local C`i' = country[`i']
local col`i' = col[`i']
}
restore
if "`o'" == "hfd"  {
twoway ///
(scatter A50 A51 if country == "`C1'", color("`col1'")) ///
(rcap A70 A60 A51 if country =="`C1'", color("`col1'")) ///
(rcap A71 A61 A50 if country =="`C1'", color("`col1'") horizontal) ///
(scatter A50 A51 if country == "`C2'", color("`col2'")) ///
(rcap A70 A60 A51 if country =="`C2'", color("`col2'")) ///
(rcap A71 A61 A50 if country =="`C2'", color("`col2'") horizontal) ///
(scatter A50 A51 if country == "`C3'", color("`col3'")) ///
(rcap A70 A60 A51 if country =="`C3'", color("`col3'")) ///
(rcap A71 A61 A50 if country =="`C3'", color("`col3'") horizontal) ///
(scatter A50 A51 if country == "`C4'", color("`col4'")) ///
(rcap A70 A60 A51 if country =="`C4'", color("`col4'")) ///
(rcap A71 A61 A50 if country =="`C4'", color("`col4'") horizontal) ///
(scatter A50 A51 if country == "`C6'", color("`col6'")) ///
(rcap A70 A60 A51 if country =="`C6'", color("`col6'")) ///
(rcap A71 A61 A50 if country =="`C6'", color("`col6'") horizontal) ///
(scatter A50 A51 if country == "`C8'", color("`col8'")) ///
(rcap A70 A60 A51 if country =="`C8'", color("`col8'")) ///
(rcap A71 A61 A50 if country =="`C8'", color("`col8'") horizontal) ///
(scatter A50 A51 if country == "`C9'", color("`col9'")) ///
(rcap A70 A60 A51 if country =="`C9'", color("`col9'")) ///
(rcap A71 A61 A50 if country =="`C9'", color("`col9'") horizontal) ///
(function y=x, range(-50 50) col(gs7%50) lpattern(dash)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "`C1'" ///
4 "`C2'" ///
7 "`C3'" ///
10 "`C4'" ///
13 "`C6'" ///
16 "`C8'" ///
19 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(, grid angle(0)) ///
xlabel(, grid) ///
ytitle("5-year percent change (Females)") ///
xtitle("5-year percent change (Males)") ///
title("`oo' mortality rate, people `ndm' diabetes", placement(west) color(black) size(medium))
}
else {
twoway ///
(scatter A50 A51 if country == "`C1'", color("`col1'")) ///
(rcap A70 A60 A51 if country =="`C1'", color("`col1'")) ///
(rcap A71 A61 A50 if country =="`C1'", color("`col1'") horizontal) ///
(scatter A50 A51 if country == "`C2'", color("`col2'")) ///
(rcap A70 A60 A51 if country =="`C2'", color("`col2'")) ///
(rcap A71 A61 A50 if country =="`C2'", color("`col2'") horizontal) ///
(scatter A50 A51 if country == "`C3'", color("`col3'")) ///
(rcap A70 A60 A51 if country =="`C3'", color("`col3'")) ///
(rcap A71 A61 A50 if country =="`C3'", color("`col3'") horizontal) ///
(scatter A50 A51 if country == "`C4'", color("`col4'")) ///
(rcap A70 A60 A51 if country =="`C4'", color("`col4'")) ///
(rcap A71 A61 A50 if country =="`C4'", color("`col4'") horizontal) ///
(scatter A50 A51 if country == "`C5'", color("`col5'")) ///
(rcap A70 A60 A51 if country =="`C5'", color("`col5'")) ///
(rcap A71 A61 A50 if country =="`C5'", color("`col5'") horizontal) ///
(scatter A50 A51 if country == "`C6'", color("`col6'")) ///
(rcap A70 A60 A51 if country =="`C6'", color("`col6'")) ///
(rcap A71 A61 A50 if country =="`C6'", color("`col6'") horizontal) ///
(scatter A50 A51 if country == "`C7'", color("`col7'")) ///
(rcap A70 A60 A51 if country =="`C7'", color("`col7'")) ///
(rcap A71 A61 A50 if country =="`C7'", color("`col7'") horizontal) ///
(scatter A50 A51 if country == "`C8'", color("`col8'")) ///
(rcap A70 A60 A51 if country =="`C8'", color("`col8'")) ///
(rcap A71 A61 A50 if country =="`C8'", color("`col8'") horizontal) ///
(scatter A50 A51 if country == "`C9'", color("`col9'")) ///
(rcap A70 A60 A51 if country =="`C9'", color("`col9'")) ///
(rcap A71 A61 A50 if country =="`C9'", color("`col9'") horizontal) ///
(function y=x, range(-50 50) col(gs7%50) lpattern(dash)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "`C1'" ///
4 "`C2'" ///
7 "`C3'" ///
10 "`C4'" ///
13 "`C5'" ///
16 "`C6'" ///
19 "`C7'" ///
22 "`C8'" ///
25 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(, grid angle(0)) ///
xlabel(, grid) ///
ytitle("5-year percent change (Females)") ///
xtitle("5-year percent change (Males)") ///
title("`oo' mortality rate, people `ndm' diabetes", placement(west) color(black) size(medium))
}

graph save GPH/APC_mf_`o'_`dm', replace

}
}
foreach o in chd cbd hfd {

if "`o'" == "chd" {
local oo = "CHD"
}
if "`o'" == "cbd" {
local oo = "CBD"
}
if "`o'" == "hfd" {
local oo = "HF"
}

use SMR_APCs, clear
replace A4 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace A5 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace A6 = . if (country == "Finland" | country == "Lithuania") & A2 == "hfd"
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
drop if A3 == 2
keep if A2 == "`o'"
keep A1 country A3-A6
reshape wide A4-A6, i(A1 country) j(A3)
preserve
bysort country : keep if _n == 1
merge 1:1 country using ccol, keep(3) nogen
forval i = 1/9 {
local C`i' = country[`i']
local col`i' = col[`i']
}
restore
if "`o'" == "hfd"  {
twoway ///
(scatter A40 A41 if country == "`C1'", color("`col1'")) ///
(rcap A60 A50 A41 if country =="`C1'", color("`col1'")) ///
(rcap A61 A51 A40 if country =="`C1'", color("`col1'") horizontal) ///
(scatter A40 A41 if country == "`C2'", color("`col2'")) ///
(rcap A60 A50 A41 if country =="`C2'", color("`col2'")) ///
(rcap A61 A51 A40 if country =="`C2'", color("`col2'") horizontal) ///
(scatter A40 A41 if country == "`C3'", color("`col3'")) ///
(rcap A60 A50 A41 if country =="`C3'", color("`col3'")) ///
(rcap A61 A51 A40 if country =="`C3'", color("`col3'") horizontal) ///
(scatter A40 A41 if country == "`C4'", color("`col4'")) ///
(rcap A60 A50 A41 if country =="`C4'", color("`col4'")) ///
(rcap A61 A51 A40 if country =="`C5'", color("`col5'") horizontal) ///
(scatter A40 A41 if country == "`C6'", color("`col6'")) ///
(rcap A60 A50 A41 if country =="`C6'", color("`col6'")) ///
(rcap A61 A51 A40 if country =="`C6'", color("`col6'") horizontal) ///
(scatter A40 A41 if country == "`C8'", color("`col8'")) ///
(rcap A60 A50 A41 if country =="`C8'", color("`col8'")) ///
(rcap A61 A51 A40 if country =="`C8'", color("`col8'") horizontal) ///
(scatter A40 A41 if country == "`C9'", color("`col9'")) ///
(rcap A60 A50 A41 if country =="`C9'", color("`col9'")) ///
(rcap A61 A51 A40 if country =="`C9'", color("`col9'") horizontal) ///
(function y=x, range(-50 50) col(gs7%50) lpattern(dash)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "`C1'" ///
4 "`C2'" ///
7 "`C3'" ///
10 "`C4'" ///
13 "`C6'" ///
16 "`C8'" ///
19 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(, grid angle(0)) ///
xlabel(, grid) ///
ytitle("5-year percent change (Females)") ///
xtitle("5-year percent change (Males)") ///
title("`oo' mortality rate ratio", placement(west) color(black) size(medium))
}
else {
twoway ///
(scatter A40 A41 if country == "`C1'", color("`col1'")) ///
(rcap A60 A50 A41 if country =="`C1'", color("`col1'")) ///
(rcap A61 A51 A40 if country =="`C1'", color("`col1'") horizontal) ///
(scatter A40 A41 if country == "`C2'", color("`col2'")) ///
(rcap A60 A50 A41 if country =="`C2'", color("`col2'")) ///
(rcap A61 A51 A40 if country =="`C2'", color("`col2'") horizontal) ///
(scatter A40 A41 if country == "`C3'", color("`col3'")) ///
(rcap A60 A50 A41 if country =="`C3'", color("`col3'")) ///
(rcap A61 A51 A40 if country =="`C3'", color("`col3'") horizontal) ///
(scatter A40 A41 if country == "`C4'", color("`col4'")) ///
(rcap A60 A50 A41 if country =="`C4'", color("`col4'")) ///
(rcap A61 A51 A40 if country =="`C4'", color("`col4'") horizontal) ///
(scatter A40 A41 if country == "`C5'", color("`col5'")) ///
(rcap A60 A50 A41 if country =="`C5'", color("`col5'")) ///
(rcap A61 A51 A40 if country =="`C5'", color("`col5'") horizontal) ///
(scatter A40 A41 if country == "`C6'", color("`col6'")) ///
(rcap A60 A50 A41 if country =="`C6'", color("`col6'")) ///
(rcap A61 A51 A40 if country =="`C6'", color("`col6'") horizontal) ///
(scatter A40 A41 if country == "`C7'", color("`col7'")) ///
(rcap A60 A50 A41 if country =="`C7'", color("`col7'")) ///
(rcap A61 A51 A40 if country =="`C7'", color("`col7'") horizontal) ///
(scatter A40 A41 if country == "`C8'", color("`col8'")) ///
(rcap A60 A50 A41 if country =="`C8'", color("`col8'")) ///
(rcap A61 A51 A40 if country =="`C8'", color("`col8'") horizontal) ///
(scatter A40 A41 if country == "`C9'", color("`col9'")) ///
(rcap A60 A50 A41 if country =="`C9'", color("`col9'")) ///
(rcap A61 A51 A40 if country =="`C9'", color("`col9'") horizontal) ///
(function y=x, range(-50 50) col(gs7%50) lpattern(dash)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "`C1'" ///
4 "`C2'" ///
7 "`C3'" ///
10 "`C4'" ///
13 "`C5'" ///
16 "`C6'" ///
19 "`C7'" ///
22 "`C8'" ///
25 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(, grid angle(0)) ///
xlabel(, grid) ///
ytitle("5-year percent change (Females)") ///
xtitle("5-year percent change (Males)") ///
title("`oo' mortality rate ratio", placement(west) color(black) size(medium))
}

graph save GPH/SMRAPC_mf_`o', replace

}
texdoc stlog close
texdoc stlog, cmdlog
graph combine ///
GPH/APCo_DM_0.gph GPH/APCo_DM_1.gph GPH/APCo_DM_2.gph ///
GPH/APCo_nonDM_0.gph GPH/APCo_nonDM_1.gph GPH/APCo_nonDM_2.gph ///
GPH/APCo_MRR_0.gph GPH/APCo_MRR_1.gph GPH/APCo_MRR_2.gph ///
, graphregion(color(white)) cols(3) altshrink xsize(7)
texdoc graph, label(APCfig) figure(h!) cabove ///
caption(5-year percent change in cause-specific mortality rates for people with and without diabetes ///
and mortality rate ratios for people with vs. without diabetes, by cause of death and country.)
graph combine ///
GPH/APC_mf_chd_dm.gph ///
GPH/APC_mf_chd_nondm.gph ///
GPH/SMRAPC_mf_chd.gph ///
GPH/APC_mf_cbd_dm.gph ///
GPH/APC_mf_cbd_nondm.gph ///
GPH/SMRAPC_mf_cbd.gph ///
GPH/APC_mf_hfd_dm.gph ///
GPH/APC_mf_hfd_nondm.gph ///
GPH/SMRAPC_mf_hfd.gph ///
, graphregion(color(white)) cols(3) altshrink xsize(7)
texdoc graph, label(APCfigmf) figure(h!) cabove ///
caption(5-year percent change in cause-specific mortality rates for people with and without diabetes ///
and mortality rate ratios for people with vs. without diabetes, comparing males and females.)
texdoc stlog close

/***
\color{black}

\begin{landscape}
\begin{table}[h!]
  \begin{center}
    \caption{5-year percent change in cause-specific mortality rates by country and diabetes status.}
    \label{APC}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{2}{*}{##1}}}},
      display columns/1/.style={column name=Diabetes status, column type={l}, text indicator="},
      display columns/2/.style={column name=CVD, column type={r}},
      display columns/3/.style={column name=CHD, column type={r}},
      display columns/4/.style={column name=CBD, column type={r}},
      display columns/5/.style={column name=HF, column type={r}},
      display columns/6/.style={column name=Cardiac, column type={r}},
      every head row/.style={
        before row={\toprule
					& & \multicolumn{4}{c}{Cause of death} \\
					},
        after row={\midrule}
            },
        every nth row={2}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/APC.csv}
  \end{center}
Abbreviations: 
CVD -- cardiovascular disease; 
CHD -- coronary heart disease; 
CBD -- cerebrovascular disease;
HF -- heart failure;
Cardiac -- heart death.
\end{table}


\begin{table}[h!]
  \begin{center}
    \caption{5-year percent change in cause-specific mortality rate ratios by country and diabetes status.}
	\label{SMRAPC}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
      display columns/0/.style={column name=Country, column type={l}, text indicator="},
      display columns/1/.style={column name=CVD, column type={r}},
      display columns/2/.style={column name=CHD, column type={r}},
      display columns/3/.style={column name=CBD, column type={r}},
      display columns/4/.style={column name=HF, column type={r}},
      display columns/5/.style={column name=Cardiac, column type={r}},
      every head row/.style={
        before row={\toprule
					& \multicolumn{4}{c}{Cause of death} \\
					},
        after row={\midrule}
            },
        every last row/.style={after row=\bottomrule},
    ]{CSV/SMR_APC.csv}
  \end{center}
Abbreviations: 
CVD -- cardiovascular disease; 
CHD -- coronary heart disease; 
CBD -- cerebrovascular disease;
HF -- heart failure;
Cardiac -- heart death.
\end{table}


\begin{table}[h!]
  \begin{center}
    \caption{5-year percent change in cause-specific mortality rates by country, sex, and diabetes status.}
    \label{APCS}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{4}{*}{##1}}}},
	  display columns/1/.style={column name=Diabetes status,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{2}{*}{##1}}}},
      display columns/2/.style={column name=Sex, column type={l}, text indicator="},
      display columns/3/.style={column name=CVD, column type={r}},
      display columns/4/.style={column name=CHD, column type={r}},
      display columns/5/.style={column name=CBD, column type={r}},
      display columns/6/.style={column name=HF, column type={r}},
      display columns/7/.style={column name=Cardiac, column type={r}},
      every head row/.style={
        before row={\toprule
					& & & \multicolumn{4}{c}{Cause of death} \\
					},
        after row={\midrule}
            },
        every nth row={4}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/APCS.csv}
  \end{center}
Abbreviations: 
CVD -- cardiovascular disease; 
CHD -- coronary heart disease; 
CBD -- cerebrovascular disease;
HF -- heart failure;
Cardiac -- heart death.
\end{table}


\begin{table}[h!]
  \begin{center}
    \caption{5-year percent change in cause-specific mortality rate ratios by country, sex, and diabetes status.}
    \label{SMRAPCS}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{2}{*}{##1}}}},
      display columns/1/.style={column name=Sex, column type={l}, text indicator="},
      display columns/2/.style={column name=CVD, column type={r}},
      display columns/3/.style={column name=CHD, column type={r}},
      display columns/4/.style={column name=CBD, column type={r}},
      display columns/5/.style={column name=HF, column type={r}},
      display columns/6/.style={column name=Cardiac, column type={r}},
      every head row/.style={
        before row={\toprule
					& & \multicolumn{4}{c}{Cause of death} \\
					},
        after row={\midrule}
            },
        every nth row={2}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/SMR_APCS.csv}
  \end{center}
Abbreviations: 
CVD -- cardiovascular disease; 
CHD -- coronary heart disease; 
CBD -- cerebrovascular disease;
HF -- heart failure;
Cardiac -- heart death.
\end{table}


\end{landscape}


\clearpage

It's also worth looking at variation in mortality rate trends by age. 
For this, we will use two models: the first includes the interaction 
between a spline effect of age and a log-linear effect of calendar time (plotted in the left
panels of the combined figures); 
the second includes a spline effect of age and the 
product of log-linear effects of age and calendar time (plotted on the right in the figures). 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
quietly {
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in cvd chd cbd hfd {
noisily di "`i' `ii'"
foreach iii in dm nondm {
use `i', clear
replace calendar = calendar-2009.5
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
preserve
clear
set obs 51
gen age = (_n)+39
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
forval a = 1/51 {
local A1`a' = agesp1[`a']
local A2`a' = agesp2[`a']
local A3`a' = agesp3[`a']
}
restore
poisson `ii'_d_`iii' c.agesp*##c.cal, exposure(pys_`iii')
matrix A = (.,.,.,.)
forval a = 1/51 {
margins, dydx(cal) at(agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'') atmeans predict(xb)
matrix A = (A\(`a')+39,r(table)[1,1],r(table)[5,1],r(table)[6,1])
}
matrix A_`i'_`ii'_`iii'_1 = A
poisson `ii'_d_`iii' c.agesp* c.age_`iii'##c.cal, exposure(pys_`iii')
matrix A = (.,.,.,.)
forval a = 1/51 {
margins, dydx(cal) at(age_`iii'==`A1`a'' agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'') atmeans predict(xb)
matrix A = (A\(`a')+39,r(table)[1,1],r(table)[5,1],r(table)[6,1])
}
matrix A_`i'_`ii'_`iii'_2 = A
forval iiii = 0/1 {
preserve
keep if sex == `iiii'
poisson `ii'_d_`iii' c.agesp*##c.cal, exposure(pys_`iii')
matrix A = (.,.,.,.)
forval a = 1/51 {
margins, dydx(cal) at(agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'') atmeans predict(xb)
matrix A = (A\(`a')+39,r(table)[1,1],r(table)[5,1],r(table)[6,1])
}
matrix A_`i'_`ii'_`iii'_`iiii'_1 = A
poisson `ii'_d_`iii' c.agesp* c.age_`iii'##c.cal, exposure(pys_`iii')
matrix A = (.,.,.,.)
forval a = 1/51 {
margins, dydx(cal) at(age_`iii'==`A1`a'' agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'') atmeans predict(xb)
matrix A = (A\(`a')+39,r(table)[1,1],r(table)[5,1],r(table)[6,1])
}
matrix A_`i'_`ii'_`iii'_`iiii'_2 = A
restore
}
forval a = 1/2 {
clear
svmat A_`i'_`ii'_`iii'_`a'
rename (A_`i'_`ii'_`iii'_`a'1 A_`i'_`ii'_`iii'_`a'2 A_`i'_`ii'_`iii'_`a'3 A_`i'_`ii'_`iii'_`a'4) (age apc lb ub)
drop if age==.
replace apc = 100*(exp(apc)-1)
replace lb = 100*(exp(lb)-1)
replace ub = 100*(exp(ub)-1)
gen country = "`i'"
gen oc = "`ii'"
gen dm = "`iii'"
save MD/APCage_`i'_`ii'_`iii'_`a', replace
forval iiii = 0/1 {
clear
svmat A_`i'_`ii'_`iii'_`iiii'_`a'
rename (A_`i'_`ii'_`iii'_`iiii'_`a'1 A_`i'_`ii'_`iii'_`iiii'_`a'2 A_`i'_`ii'_`iii'_`iiii'_`a'3 A_`i'_`ii'_`iii'_`iiii'_`a'4) (age apc lb ub)
drop if age==.
replace apc = 100*(exp(apc)-1)
replace lb = 100*(exp(lb)-1)
replace ub = 100*(exp(ub)-1)
gen country = "`i'"
gen oc = "`ii'"
gen dm = "`iii'"
gen sex = `iiii'
save MD/APCage_`i'_`ii'_`iii'_`iiii'_`a', replace
}
}
clear all
}
}
}
}
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in cvd chd cbd hfd {
forval a = 1/2 {
clear
foreach iii in dm nondm {
append using MD/APCage_`i'_`ii'_`iii'_`a'
}
twoway ///
(rarea ub lb age if dm == "dm", color("dknavy%30") fintensity(inten80) lwidth(none)) ///
(line apc age if dm == "dm", color("dknavy") lpattern(solid)) ///
(rarea ub lb age if dm == "nondm", color("magenta%30") fintensity(inten80) lwidth(none)) ///
(line apc age if dm == "nondm", color("magenta") lpattern(solid)) ///
,legend(ring(0) symxsize(0.13cm) position(2) region(lcolor(white) color(none)) ///
order(2 "Diabetes" ///
4 "No diabetes") ///
cols(1)) ///
bgcolor(white) graphregion(color(white)) ///
ytitle("Annual change in incidence rates (%)", xoffset(-1)) ///
yline(0, lcolor(gs0)) ///
ylabel(-10(5)10, angle(0)) yscale(range(-10 10)) ///
xtitle("Age (years)") ///
xlabel(40(10)90) ///
title("Overall", placement(west) size(medium) color(gs0))
graph save "Graph" GPH/APCage_`i'_`ii'_`a', replace
forval iiii = 0/1 {
clear
foreach iii in dm nondm {
append using MD/APCage_`i'_`ii'_`iii'_`iiii'_`a'
}
if `iiii' == 0 {
local s = "Females"
}
else {
local s = "Males"
}
twoway ///
(rarea ub lb age if dm == "dm", color("dknavy%30") fintensity(inten80) lwidth(none)) ///
(line apc age if dm == "dm", color("dknavy") lpattern(solid)) ///
(rarea ub lb age if dm == "nondm", color("magenta%30") fintensity(inten80) lwidth(none)) ///
(line apc age if dm == "nondm", color("magenta") lpattern(solid)) ///
,legend(ring(0) symxsize(0.13cm) position(2) region(lcolor(white) color(none)) ///
order(2 "Diabetes" ///
4 "No diabetes") ///
cols(1)) ///
bgcolor(white) graphregion(color(white)) ///
ytitle("Annual change in incidence rates (%)", xoffset(-1)) ///
yline(0, lcolor(gs0)) ///
ylabel(-10(5)10, angle(0)) yscale(range(-10 10)) ///
xtitle("Age (years)") ///
xlabel(40(10)90) ///
title("`s'", placement(west) size(medium) color(gs0))
graph save "Graph" GPH/APCage_`i'_`ii'_`iiii'_`a', replace
}
}
}
}
texdoc stlog close
texdoc stlog, cmdlog nodo
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
if "`i'" == "Canada1" {
local co = "Canada (Alberta)"
}
else if "`i'" == "Canada2" {
local co = "Canada (Ontario)"
}
else if "`i'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`i'"
}
foreach ii in cvd chd cbd hfd {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Coronary heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
}
if ("`i'" == "Finland" | "`i'" == "Lithuania") & "`ii'" == "hfd" {
}
else {
graph combine ///
GPH/APCage_`i'_`ii'_1.gph ///
GPH/APCage_`i'_`ii'_2.gph ///
GPH/APCage_`i'_`ii'_0_1.gph ///
GPH/APCage_`i'_`ii'_0_2.gph ///
GPH/APCage_`i'_`ii'_1_1.gph ///
GPH/APCage_`i'_`ii'_1_2.gph ///
, altshrink rows(3) xsize(3.5) graphregion(color(white))
}
}
}
texdoc stlog close
texdoc stlog, nolog
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
if "`i'" == "Canada1" {
local co = "Canada (Alberta)"
}
else if "`i'" == "Canada2" {
local co = "Canada (Ontario)"
}
else if "`i'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`i'"
}
foreach ii in cvd chd cbd hfd {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Coronary heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
}
if ("`i'" == "Finland" | "`i'" == "Lithuania") & "`ii'" == "hfd" {
}
else {
graph combine ///
GPH/APCage_`i'_`ii'_1.gph ///
GPH/APCage_`i'_`ii'_2.gph ///
GPH/APCage_`i'_`ii'_0_1.gph ///
GPH/APCage_`i'_`ii'_0_2.gph ///
GPH/APCage_`i'_`ii'_1_1.gph ///
GPH/APCage_`i'_`ii'_1_2.gph ///
, altshrink rows(3) xsize(3.5) graphregion(color(white))
texdoc graph, label(`i'`ii'apcage) figure(h!) cabove caption(Annual percent change in mortality rates ///
by diabetes status and sex. `co'. `oo'. Values are predicted from a Poisson model with a ///
spline effect of attained age, a log-linear effect of calendar time, and an interaction ///
between age and calendar time. The left panels use a spline term for age in the interaction, the right panels use the product of ///
age and calendar time in the interaction.)
}
}
texdoc stlog close
/***
\clearpage
***/
texdoc stlog, nolog
}
texdoc stlog close


/***
\color{black}

\clearpage
\section{Age- and sex-standardised rates}

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
pwd
*copy /home/jimb0w/Documents/CM/refpop.dta refpop.dta
*copy /home/jimb0w/Documents/CM/refpops.dta refpops.dta
quietly {
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in cvd chd cbd hfd hrt {
foreach iii in dm nondm {
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = calendar-2009.5
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 10 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
keep sex calendar pys_`iii' age_`iii'
if "`i'" == "Scotland" & "`iii'" == "nondm" {
keep if inrange(age_`iii',40,89)
expand 10 if age_`iii'!=87.5
expand 20 if age_`iii'==87.5
replace pys = pys/10 if age_`iii'!=87.5
replace pys = pys/20 if age_`iii'==87.5
bysort cal age : replace age = age+_n-6 if age_`iii'!=87.5
bysort cal age : replace age = age+_n-8.5 if age_`iii'==87.5
drop if age_`iii' >= 90
}
else {
keep if inrange(age_`iii',40,89)
expand 10
replace pys = pys/10
bysort cal age : replace age = age+_n-6
}
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 9.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
save MD/STDi_`i'_`ii'_`iii'_`iiii', replace
rename age_`iii' age
merge m:1 age using refpop
drop _merge
gen double expdeath = _Rate*B
bysort cal : egen double expdeath1 = sum(expdeath)
gen stdrate = 1000*expdeath1
gen SEC1 = ((B^2)*(_Rate*(1-_Rate)))/pys_`iii'
bysort cal : egen double SEC2 = sum(SEC1)
gen double SE = sqrt(SEC2)
gen lb = 1000*(expdeath1-1.96*SE)
gen ub = 1000*(expdeath1+1.96*SE)
bysort cal (age) : keep if _n == 1
count if lb < 0
if r(N) != 0 {
noisily di "`i'" " " "`ii'" " " "`iii'" " " "`iiii'"
}
keep cal stdrate lb ub sex
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
replace cal = cal+2009.5
save MD/STD_`i'_`ii'_`iii'_`iiii', replace
}
clear
append using MD/STDi_`i'_`ii'_`iii'_0 MD/STDi_`i'_`ii'_`iii'_1
rename age_`iii' age
merge m:1 sex age using refpops
drop _merge
gen double expdeath = _Rate*B
bysort cal : egen double expdeath1 = sum(expdeath)
gen stdrate = 1000*expdeath1
gen SEC1 = ((B^2)*(_Rate*(1-_Rate)))/pys_`iii'
bysort cal : egen double SEC2 = sum(SEC1)
gen double SE = sqrt(SEC2)
gen lb = 1000*(expdeath1-1.96*SE)
gen ub = 1000*(expdeath1+1.96*SE)
bysort cal (age) : keep if _n == 1
count if lb < 0
if r(N) != 0 {
noisily di "`i'" " " "`ii'" " " "`iii'"
replace lb = 0.001 if lb < 0
}
keep cal stdrate lb ub
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
replace cal = cal+2009.5
save MD/STD_`i'_`ii'_`iii', replace
}
}
}
}
texdoc stlog close
texdoc stlog
quietly {
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in cvd chd cbd hfd hrt {
foreach iii in dm nondm {
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = calendar-2009.5
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 10 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
keep sex calendar pys_`iii' age_`iii'
if "`i'" == "Scotland" & "`iii'" == "nondm" {
keep if inrange(age_`iii',40,89)
expand 10 if age_`iii'!=87.5
expand 20 if age_`iii'==87.5
replace pys = pys/10 if age_`iii'!=87.5
replace pys = pys/20 if age_`iii'==87.5
bysort cal age : replace age = age+_n-6 if age_`iii'!=87.5
bysort cal age : replace age = age+_n-8.5 if age_`iii'==87.5
drop if age_`iii' >= 90
}
else {
keep if inrange(age_`iii',40,89)
expand 10
replace pys = pys/10
bysort cal age : replace age = age+_n-6
}
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 9.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
save MD/STDi_`i'_`ii'_`iii'_`iiii', replace
rename age_`iii' age
merge m:1 age using refpop
drop _merge
gen double expdeath = _Rate*B
bysort cal : egen double expdeath1 = sum(expdeath)
gen stdrate = 1000*expdeath1
gen SEC1 = ((B^2)*(_Rate*(1-_Rate)))/pys_`iii'
bysort cal : egen double SEC2 = sum(SEC1)
gen double SE = sqrt(SEC2)
gen lb = 1000*(expdeath1-1.96*SE)
gen ub = 1000*(expdeath1+1.96*SE)
bysort cal (age) : keep if _n == 1
count if lb < 0
if r(N) != 0 {
noisily di "`i'" " " "`ii'" " " "`iii'" " " "`iiii'"
}
keep cal stdrate lb ub sex
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
replace cal = cal+2009.5
save MD/STD_`i'_`ii'_`iii'_`iiii', replace
}
clear
append using MD/STDi_`i'_`ii'_`iii'_0 MD/STDi_`i'_`ii'_`iii'_1
rename age_`iii' age
merge m:1 sex age using refpops
drop _merge
gen double expdeath = _Rate*B
bysort cal : egen double expdeath1 = sum(expdeath)
gen stdrate = 1000*expdeath1
gen SEC1 = ((B^2)*(_Rate*(1-_Rate)))/pys_`iii'
bysort cal : egen double SEC2 = sum(SEC1)
gen double SE = sqrt(SEC2)
gen lb = 1000*(expdeath1-1.96*SE)
gen ub = 1000*(expdeath1+1.96*SE)
bysort cal (age) : keep if _n == 1
count if lb < 0
if r(N) != 0 {
noisily di "`i'" " " "`ii'" " " "`iii'"
replace lb = 0.001 if lb < 0
}
keep cal stdrate lb ub
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
replace cal = cal+2009.5
save MD/STD_`i'_`ii'_`iii', replace
}
}
}
}
texdoc stlog close
texdoc stlog, cmdlog nodo
foreach ii in cvd chd cbd hfd hrt {
foreach iii in dm nondm {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Coronary heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
}
if "`ii'" == "hrt" {
local oo = "Heart death"
}
if "`iii'" == "dm" {
local w = "with"
}
if "`iii'" == "nondm" {
local w = "without"
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using MD/STD_`i'_`ii'_`iii'
}
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
merge 1:1 country using ccol
forval i = 1/9 {
local C`i' = country[`i']
local col`i' = col[`i']
}
restore
if "`ii'" == "hfd" | "`ii'" == "hrt" {
replace stdrate=. if country == "Finland" | country == "Lithuania"
replace lb =. if country == "Finland" | country == "Lithuania"
replace ub =. if country == "Finland" | country == "Lithuania"
}
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C9'", color("`col9'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C9'", color("`col9'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'" ///
18 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.01 "0.01"0.1 1 10 100, grid angle(0)) ///
yscale(log range(0.01 100)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo', people `w' diabetes", placement(west) color(black) size(medium))
graph save GPH/STD_GPH_`ii'_`iii', replace
forval iiii = 0/1 {
if `iiii' == 0 {
local s = "females"
}
if `iiii' == 1 {
local s = "males"
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using MD/STD_`i'_`ii'_`iii'_`iiii'
}
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
merge 1:1 country using ccol
forval i = 1/9 {
local C`i' = country[`i']
local col`i' = col[`i']
}
restore
if "`ii'" == "hfd" | "`ii'" == "hrt" {
replace stdrate=. if country == "Finland" | country == "Lithuania"
replace lb =. if country == "Finland" | country == "Lithuania"
replace ub =. if country == "Finland" | country == "Lithuania"
}
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C9'", color("`col9'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C9'", color("`col9'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'" ///
18 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.01 "0.01"0.1 1 10 100, grid angle(0)) ///
yscale(log range(0.01 100)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo', `s' `w' diabetes", placement(west) color(black) size(medium))
graph save GPH/STD_GPH_`ii'_`iii'_`iiii', replace
}
}
}
texdoc stlog close
texdoc stlog, cmdlog 
foreach ii in cvd chd cbd hfd hrt {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Coronary heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
}
if "`ii'" == "hrt" {
local oo = "Heart death"
}
graph combine ///
GPH/STD_GPH_`ii'_dm.gph ///
GPH/STD_GPH_`ii'_nondm.gph ///
GPH/STD_GPH_`ii'_dm_0.gph ///
GPH/STD_GPH_`ii'_nondm_0.gph ///
GPH/STD_GPH_`ii'_dm_1.gph ///
GPH/STD_GPH_`ii'_nondm_1.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(4)
texdoc graph, label(STDMRF_`ii') figure(h!) cabove ///
caption(Age-standardised mortality rate by cause of death, people aged 40-89. `oo'.)
}
texdoc stlog close
texdoc stlog, cmdlog nodo
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
if "`i'" == "Canada1" {
local co = "Canada (Alberta)"
}
else if "`i'" == "Canada2" {
local co = "Canada (Ontario)"
}
else if "`i'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`i'"
}
foreach iii in dm nondm {
if "`iii'" == "dm" {
local w = "with"
}
if "`iii'" == "nondm" {
local w = "without"
}
clear
foreach ii in cvd chd cbd hfd {
append using MD/STD_`i'_`ii'_`iii'
}
if "`i'" == "Finland" | "`i'" == "Lithuania" {
replace stdrate=. if OC == "hfd"
replace lb =. if OC == "hfd"
replace ub =. if OC == "hfd"
}

local col1 = "0 0 0"
local col2 = "0 0 255"
local col3 = "0 125 0"
local col4 = "255 0 255"
twoway ///
(rarea ub lb calendar if OC == "cvd", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if OC == "cvd", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if OC == "chd", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if OC == "chd", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if OC == "cbd", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if OC == "cbd", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if OC == "hfd", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if OC == "hfd", color("`col4'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "Cardiovascular disease" ///
4 "Coronary heart disease" ///
6 "Cerebrovascular disease" ///
8 "Heart failure") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.01 "0.01" 0.02 "0.02" 0.05 "0.05" 0.1 "0.1" 0.2 "0.2" 0.5 "0.5" 1 2 5 10 20, grid angle(0)) ///
yscale(log range(0.01 30)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`co', people `w' diabetes", placement(west) color(black) size(medium))
graph save GPH/STDcvd_GPH_`i'_`iii', replace
forval iiii = 0/1 {
if `iiii' == 0 {
local s = "females"
}
if `iiii' == 1 {
local s = "males"
}
clear
foreach ii in cvd chd cbd hfd {
append using MD/STD_`i'_`ii'_`iii'_`iiii'
}
if "`i'" == "Finland" | "`i'" == "Lithuania" {
replace stdrate=. if OC == "hfd"
replace lb =. if OC == "hfd"
replace ub =. if OC == "hfd"
}
local col1 = "0 0 0"
local col2 = "0 0 255"
local col3 = "0 125 0"
local col4 = "255 0 255"
twoway ///
(rarea ub lb calendar if OC == "cvd", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if OC == "cvd", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if OC == "chd", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if OC == "chd", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if OC == "cbd", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if OC == "cbd", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if OC == "hfd", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if OC == "hfd", color("`col4'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "Cardiovascular disease" ///
4 "Coronary heart disease" ///
6 "Cerebrovascular disease" ///
8 "Heart failure") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.01 "0.01" 0.02 "0.02" 0.05 "0.05" 0.1 "0.1" 0.2 "0.2" 0.5 "0.5" 1 2 5 10 20, grid angle(0)) ///
yscale(log range(0.01 30)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`co', `s' `w' diabetes", placement(west) color(black) size(medium))
graph save GPH/STDcvd_GPH_`i'_`iii'_`iiii', replace
}
}
}
texdoc stlog close
texdoc stlog, cmdlog 
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
if "`i'" == "Canada1" {
local co = "Canada (Alberta)"
}
else if "`i'" == "Canada2" {
local co = "Canada (Ontario)"
}
else if "`i'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`i'"
}
graph combine ///
GPH/STDcvd_GPH_`i'_dm.gph ///
GPH/STDcvd_GPH_`i'_nondm.gph ///
GPH/STDcvd_GPH_`i'_dm_0.gph ///
GPH/STDcvd_GPH_`i'_nondm_0.gph ///
GPH/STDcvd_GPH_`i'_dm_1.gph ///
GPH/STDcvd_GPH_`i'_nondm_1.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(4)
texdoc graph, label(STDMRF_`ii') figure(h!) cabove ///
caption(Age-standardised mortality rate by cause of death, people aged 40-89. `co'.)
}
texdoc stlog close



/***
\color{black}

\clearpage
\section{Cause-specific mortality rate ratios}

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
quietly {
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in cvd chd cbd hfd hrt {
use `i'_long, clear
replace calendar = calendar-2009.5
gen coh = calendar-age
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
local minn = r(min)
if `rang' < 10 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
preserve
clear
local rang1 = `rang'+1
set obs `rang1'
gen calendar = _n-1+`minn'
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
forval a = 1/`rang1' {
local A1`a' = timesp1[`a']
}
restore
}
else if inrange(`rang',10,14.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
preserve
clear
local rang1 = `rang'+1
set obs `rang1'
gen calendar = _n-1+`minn'
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
forval a = 1/`rang1' {
local A1`a' = timesp1[`a']
local A2`a' = timesp2[`a']
}
restore
}
else {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
preserve
clear
local rang1 = `rang'+1
set obs `rang1'
gen calendar = _n-1+`minn'
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
forval a = 1/`rang1' {
local A1`a' = timesp1[`a']
local A2`a' = timesp2[`a']
local A3`a' = timesp3[`a']
}
restore
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
preserve
poisson `ii'_d agesp* sex c.timesp*##i.dm, exposure(pys)
matrix A = (.,.,.)
if `rang' < 10 {
forval a = 1/`rang1' {
margins, dydx(dm) at(timesp1==`A1`a'') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else if inrange(`rang',10,14.9) {
forval a = 1/`rang1' {
margins, dydx(dm) at(timesp1==`A1`a'' timesp2==`A2`a'') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else {
forval a = 1/`rang1' {
margins, dydx(dm) at(timesp1==`A1`a'' timesp2==`A2`a'' timesp3==`A3`a'') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
local rang2 = `rang1'+1
mat A = A[2..`rang2',1..3]
keep country cal
bysort cal : keep if _n == 1
svmat A
replace A1 = exp(A1)
replace A2 = exp(A2)
replace A3 = exp(A3)
gen OC = "`ii'"
replace cal = cal+2009.5
save MD/SMR_`i'_`ii', replace
restore
forval iii = 0/1 {
preserve
su agesp1
local B1 = r(mean)
su agesp2
local B2 = r(mean)
su agesp3
local B3 = r(mean)
keep if sex == `iii'
poisson `ii'_d agesp* c.timesp*##i.dm, exposure(pys)
matrix A = (.,.,.)
if `rang' < 10 {
forval a = 1/`rang1' {
margins, dydx(dm) at(timesp1==`A1`a'' agesp1==`B1' agesp2==`B2' agesp3==`B3') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else if inrange(`rang',10,14.9) {
forval a = 1/`rang1' {
margins, dydx(dm) at(timesp1==`A1`a'' timesp2==`A2`a'' agesp1==`B1' agesp2==`B2' agesp3==`B3') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else {
forval a = 1/`rang1' {
margins, dydx(dm) at(timesp1==`A1`a'' timesp2==`A2`a'' timesp3==`A3`a'' agesp1==`B1' agesp2==`B2' agesp3==`B3') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
local rang2 = `rang1'+1
mat A = A[2..`rang2',1..3]
keep country cal
bysort cal : keep if _n == 1
svmat A
replace A1 = exp(A1)
replace A2 = exp(A2)
replace A3 = exp(A3)
gen OC = "`ii'"
replace cal = cal+2009.5
save MD/SMR_`i'_`ii'_`iii', replace
restore
}
}
}
}
foreach ii in cvd chd cbd hfd hrt {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Coronary heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
}
if "`ii'" == "hrt" {
local oo = "Heart death"
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using MD/SMR_`i'_`ii'
}
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
merge 1:1 country using ccol
forval i = 1/9 {
local C`i' = country[`i']
local col`i' = col[`i']
}
restore
if "`ii'" == "hfd" | "`ii'" == "hrt" {
replace A1 =. if country == "Finland" | country == "Lithuania"
replace A2 =. if country == "Finland" | country == "Lithuania"
replace A3 =. if country == "Finland" | country == "Lithuania"
}
twoway ///
(rarea A3 A2 calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C9'", color("`col9'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C9'", color("`col9'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'" ///
18 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.5 "0.5" 1 2 3, grid angle(0)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
yline(1, lcol(black)) yscale(log range(0.5 3)) ///
ytitle("Mortality rate ratio", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo'", placement(west) color(black) size(medium))
graph save GPH/SMR_`ii', replace
forval iii = 0/1 {
if `iii' == 0 {
local s = "females"
}
if `iii' == 1 {
local s = "males"
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using MD/SMR_`i'_`ii'_`iii'
}
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
merge 1:1 country using ccol
forval i = 1/9 {
local C`i' = country[`i']
local col`i' = col[`i']
}
restore
if "`ii'" == "hfd" | "`ii'" == "hrt" {
replace A1 =. if country == "Finland" | country == "Lithuania"
replace A2 =. if country == "Finland" | country == "Lithuania"
replace A3 =. if country == "Finland" | country == "Lithuania"
}
twoway ///
(rarea A3 A2 calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C9'", color("`col9'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C9'", color("`col9'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'" ///
18 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.5 "0.5" 1 2 3, grid angle(0)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
yline(1, lcol(black)) yscale(log range(0.5 3)) ///
ytitle("Mortality rate ratio", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo', `s'", placement(west) color(black) size(medium))
graph save GPH/SMR_`ii'_`iii', replace
}
}
texdoc stlog close
texdoc stlog, cmdlog 
foreach ii in cvd chd cbd hfd hrt {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Coronary heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
}
if "`ii'" == "hrt" {
local oo = "Heart death"
}
graph combine ///
GPH/SMR_`ii'.gph ///
GPH/SMR_`ii'_0.gph ///
GPH/SMR_`ii'_1.gph ///
, graphregion(color(white)) cols(1) altshrink xsize(2.5)
texdoc graph, label(STDMRF_`ii') figure(h!) cabove ///
caption(Mortality rate ratio by cause of death and sex. `oo')
}
texdoc stlog close
texdoc stlog, nolog nodo
*Figure 1
foreach ii in chd cbd hfd {
foreach iii in dm nondm {
if "`ii'" == "chd" & "`iii'" == "dm" {
local oo = "a"
}
if "`ii'" == "chd" & "`iii'" == "nondm" {
local oo = "b"
}
if "`ii'" == "cbd" & "`iii'" == "dm" {
local oo = "c"
}
if "`ii'" == "cbd" & "`iii'" == "nondm" {
local oo = "d"
}
if "`ii'" == "hfd" & "`iii'" == "dm" {
local oo = "e"
}
if "`ii'" == "hfd" & "`iii'" == "nondm" {
local oo = "f"
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using MD/STD_`i'_`ii'_`iii'
}
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
merge 1:1 country using ccol
forval i = 1/9 {
local C`i' = country[`i']
local col`i' = col[`i']
}
restore
if "`ii'" == "hfd" | "`ii'" == "hrt" {
replace stdrate=. if country == "Finland" | country == "Lithuania"
replace lb =. if country == "Finland" | country == "Lithuania"
replace ub =. if country == "Finland" | country == "Lithuania"
}
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C9'", color("`col9'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C9'", color("`col9'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'" ///
18 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.01 "0.01"0.1 1 10 100, grid angle(0)) ///
yscale(log range(0.01 100)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo'", placement(west) color(black) size(large))
graph save GPH/STD_GPH_`ii'_`iii'_F1, replace
}
}
*Figure 2
foreach ii in chd cbd hfd {
if "`ii'" == "chd" {
local oo = "a"
}
if "`ii'" == "cbd" {
local oo = "b"
}
if "`ii'" == "hfd" {
local oo = "c"
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using MD/SMR_`i'_`ii'
}
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
merge 1:1 country using ccol
forval i = 1/9 {
local C`i' = country[`i']
local col`i' = col[`i']
}
restore
if "`ii'" == "hfd" | "`ii'" == "hrt" {
replace A1 =. if country == "Finland" | country == "Lithuania"
replace A2 =. if country == "Finland" | country == "Lithuania"
replace A3 =. if country == "Finland" | country == "Lithuania"
}
twoway ///
(rarea A3 A2 calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C9'", color("`col9'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C9'", color("`col9'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'" ///
18 "`C9'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.5 "0.5" 1 2 3, grid angle(0)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
yline(1, lcol(black)) yscale(log range(0.5 3)) ///
ytitle("Mortality rate ratio", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo'", placement(west) color(black) size(large))
graph save GPH/SMR_`ii'_F2, replace
}
texdoc stlog close

/***
\color{black}

\clearpage
\section{Ontario sensitivity analysis}

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
import delimited "/home/jimb0w/Documents/CM/Consortium COD database v8.csv", clear
set seed 1312765
keep if substr(country,1,9)=="Canada (O"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
replace pys_nondm = pys_totpop-pys_dm
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
di "`i'"
ta age_gp1 if `i'_d_pop ==.
gen min_`i' = max(`i'_d_dm,1) if `i'_d_dm!=.
replace min_`i' = 1 if `i'_d_dm==.
replace `i'_d_dm=0 if `i'_d_pop==0 
quietly replace `i'_d_pop = runiformint(min_`i',5) if `i'_d_pop==.
ta age_gp1 if `i'_d_dm ==.
gen max_`i' = min(`i'_d_pop,5)
quietly replace `i'_d_dm = runiformint(1,max_`i') if `i'_d_dm ==.
}
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
di "`i'"
count if `i'_d_dm > `i'_d_pop
}
count if cvd_d_pop + can_d_pop + dmd_d_pop + inf_d_pop + flu_d_pop + res_d_pop + liv1_d_pop + ckd_d_pop + azd_d_pop > alldeath_d_pop
count if cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm
count if chd_d_pop + cbd_d_pop + hfd_d_pop > cvd_d_pop
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
ta age_gp1 if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
replace max_chd = min(cvd_d_dm,5)
replace chd_d_dm = runiformint(1,max_chd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(chd_d_dm,1,5)
replace max_cbd = min(cvd_d_dm-chd_d_dm,5)
replace cbd_d_dm = runiformint(0,max_cbd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(cbd_d_dm,1,5)
replace max_hfd = min(cvd_d_dm-chd_d_dm-cbd_d_dm,5)
replace hfd_d_dm = runiformint(0,max_hfd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(hfd_d_dm,1,5)
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
count if liv1_d_pop < liv2_d_pop
ta age_gp1 if liv1_d_pop < liv2_d_pop
replace max_liv2 = min(liv1_d_pop,9)
replace liv2_d_pop = runiformint(1,max_liv2) if liv1_d_pop < liv2_d_pop & inrange(liv2_d_pop,1,9)
count if liv1_d_pop < liv2_d_pop
count if liv1_d_dm < liv2_d_dm
ta age_gp1 if liv1_d_dm < liv2_d_dm
replace max_liv2 = min(liv1_d_dm,9)
replace liv2_d_dm = runiformint(1,max_liv2) if liv1_d_dm < liv2_d_dm & inrange(liv2_d_dm,1,9)
count if liv1_d_dm < liv2_d_dm
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
quietly replace `i'_d_nondm = `i'_d_pop-`i'_d_dm
}
count if cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv1_d_nondm + ckd_d_nondm + azd_d_nondm > alldeath_d_nondm
keep if age_gp1!=""
replace country = "Canada2"
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
keep country calendar sex alldeath_d_dm alldeath_d_nondm age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Canada2_s, replace
texdoc stlog close
texdoc stlog, cmdlog
use Canada2_s, clear
replace country = "Canada (Ontario)" if country == "Canada2"
bysort country (cal) : egen lb = min(cal)
bysort country (cal) : egen ub = max(cal)
tostring lb ub, replace
gen rang = lb+ "-" + ub
collapse (sum) pys_dm pys_nondm cvd_d_dm-hfd_d_dm cvd_d_nondm-hfd_d_nondm, by(country sex rang)
expand 2
bysort country sex : gen DM = _n-1
tostring sex pys_dm-DM, replace force format(%15.0fc)
gen pys = pys_dm if DM == "1"
replace pys = pys_nondm if DM == "0"
foreach i in cvd chd cbd hfd {
gen `i' = `i'_d_dm if DM == "1"
replace `i' = `i'_d_nondm if DM == "0"
}
keep country-rang DM-hfd
order country rang DM sex
sort country rang DM sex
gen njm = _n
bysort country DM (njm) : replace DM ="" if _n!=1
bysort country (njm) : replace rang ="" if _n!=1
bysort country (njm) : replace country ="" if _n!=1
sort njm
replace DM = "No diabetes" if DM == "0"
replace DM = "Diabetes" if DM == "1"
replace sex = "Female" if sex == "0"
replace sex = "Male" if sex == "1"
drop njm
texdoc stlog close
texdoc stlog
list
texdoc stlog close
foreach c in Canada2_s {
use `c', clear
if "`c'" == "Canada1" {
local co = "Canada (Alberta)"
}
else if "`c'" == "Canada2" {
local co = "Canada (Ontario)"
}
else if "`c'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`c'"
}
collapse (sum) pys_dm pys_nondm cvd_d_dm-hfd_d_dm cvd_d_nondm-hfd_d_nondm, by(calendar sex)
foreach i in cvd chd cbd hfd {
if "`i'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`i'" == "chd" {
local oo = "Coronary heart disease"
}
if "`i'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`i'" == "hfd" {
local oo = "Heart failure"
}
foreach iii in dm nondm {
if "`iii'" == "dm" {
local dd = "with"
}
if "`iii'" == "nondm" {
local dd = "without"
}
gen `iii'_`i' = 1000*`i'_d_`iii'/pys_`iii'
twoway ///
(connected `iii'_`i' cal if sex == 0, col(red)) ///
(connected `iii'_`i' cal if sex == 1, col(blue)) ///
, graphregion(color(white)) ///
ytitle(Mortality rate (per 1,000 person-years), margin(a+2)) ///
xtitle(Calendar year) ///
legend(order( ///
1 "Females" ///
2 "Males" ///
) cols(1) position(3) region(lcolor(none) color(none))) ///
ylabel(,angle(0) format(%9.2f)) ///
title("People `dd' diabetes", placement(west) size(medium) col(black))
graph save GPH/cr_`i'_`iii'_`c', replace
}
graph combine ///
GPH/cr_`i'_dm_`c'.gph ///
GPH/cr_`i'_nondm_`c'.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(10)
texdoc graph, label(cr_`i'_`c') figure(h!) cabove ///
caption(Crude mortality rate by cause of death, sex, and diabetes status. `oo'. `co'.)
}
}

/***
\color{black}

\end{document}
***/

texdoc close

cd /home/jimb0w/Documents/CCVD

graph combine ///
GPH/STD_GPH_chd_dm_F1.gph ///
GPH/STD_GPH_chd_nondm_F1.gph ///
GPH/STD_GPH_cbd_dm_F1.gph ///
GPH/STD_GPH_cbd_nondm_F1.gph ///
GPH/STD_GPH_hfd_dm_F1.gph ///
GPH/STD_GPH_hfd_nondm_F1.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(5)
graph export "/home/jimb0w/Documents/CCVD/F1.pdf", as(pdf) name("Graph") replace

graph combine ///
GPH/SMR_chd_F2.gph ///
GPH/SMR_cbd_F2.gph ///
GPH/SMR_hfd_F2.gph ///
, graphregion(color(white)) cols(1) altshrink xsize(2.5)
graph export "/home/jimb0w/Documents/CCVD/F2.pdf", as(pdf) name("Graph") replace

graph combine ///
GPH/APCo_DM_0.gph GPH/APCo_DM_1.gph ///
GPH/APCo_nonDM_0.gph GPH/APCo_nonDM_1.gph ///
GPH/APCo_MRR_0.gph GPH/APCo_MRR_1.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(5)
graph export "/home/jimb0w/Documents/CCVD/F3.pdf", as(pdf) name("Graph") replace


! pdflatex CCVD
! pdflatex CCVD
! pdflatex CCVD

erase CCVD.aux
erase CCVD.log
erase CCVD.out
erase CCVD.toc


! git init .
! git add CCVD.do CCVD.pdf
! git commit -m "0"
! git remote remove origin
! git remote add origin https://github.com/jimb0w/CCVD.git
! git remote set-url origin git@github.com:jimb0w/CCVD.git
! git push --set-upstream origin master
