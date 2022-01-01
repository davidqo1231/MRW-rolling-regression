//////////////
////LEGEND////
//////////////
// Number in gdppw variable refers to year by following key: gddppw1 = GDP in 1960, gdppw58 - GDP in 2017.
// Number in variables inv, school, ngd refers to ending year of 25yr average: inv1 = average of inv/GDP between 1960-1985. inv3 refers to average inv/GDP between 1962-1987 and so on.

// Data imported from MRW paper - gdppw25, school0, inv0, ngd0

use "Data - fig 1, 2.dta" 

// Logarithms
foreach i of num 1/58 {
gen l_gdppw`i' = ln(gdppw`i')
}

foreach i of num 0/35 {
gen l_ngd`i' = ln(ngd`i')
gen l_inv`i' = ln(inv`i')
}

foreach i of num 0/31 {
gen l_school`i' = ln(school`i')
}


// Figure 1: //

// 25 years rolling regressions from 1960-1985 to 1992-2017. 2 groups of countries: non-oil (n), intermediate (i).
// Example: 1.period: 1960-1985
// 			2.period: 1961-1986...

local j = 0
foreach grp in n i {
foreach i of num 25/58 {
	constraint 1 _b[l_inv`j'] + _b[l_ngd`j'] = 0
	cnsreg l_gdppw`i' l_inv`j' l_ngd`j' if `grp', constraint(1)
	nlcom alpha: _b[l_inv`j'] / (1 + _b[l_inv`j']), post
	eststo N`grp'`j'
	local ++j
}
local j = 0
}

// Plot estimates of output elasticity of physical capital alpha over time:
coefplot Nn*, bylabel(Non-oil) || Ni*, bylabel(Intermediate) ||, drop(_cons) nokey

estimates clear
eststo clear


// Figure 2: //

// Rolling regressions with human capital. First period: 1960-1985, last period: 1990-2015. Due to lack of observetions in schooling database. 

local j = 0
foreach grp in n i {
foreach i of num 25/56 {
	constraint 1 _b[l_inv`j'] + _b[l_ngd`j'] + _b[l_school`j'] = 0
	cnsreg l_gdppw`i' l_inv`j' l_school`j' l_ngd`j' if `grp', constraint(1)
	nlcom (alpha: _b[l_inv`j'] / (1 + _b[l_inv`j'] + _b[l_school`j'])) (beta: _b[l_school`j'] / (1 + _b[l_inv`j'] + _b[l_school`j'])), post	
	eststo N`grp'`j'
	local ++j
}
local j = 0
}

// Output elasticity of physical capital: alpha
// Output elasticity of human capital: beta
// xline shows predictions from Solow model (MRW, 1992)
coefplot Nn*, bylabel(Non-oil) || Ni*, bylabel(Intermediate) ||, drop(_cons) xline(0.3) nokey

estimates clear
eststo clear

