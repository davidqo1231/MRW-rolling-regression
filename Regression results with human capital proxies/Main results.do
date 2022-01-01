use "Data - tab 1,2.dta"

// Logarithms
foreach i of varlist y1990 y2015 ngd inv secondary tertiary schoolyears humanc cognitive {
gen l_`i' = ln(`i')
}

// tab. 1 - Regressions without constraint
foreach grp in n i {
regress l_y2015 l_inv l_ngd l_secondary if `grp'
outreg2 using Results-`grp'.xls, replace dec(3) adjr2
foreach i of varlist l_tertiary l_schoolyears l_humanc {
	regress l_y2015 l_inv l_ngd `i' if `grp'
	outreg2 using Results-`grp'.xls, append dec(3) adjr2
}
}

// tab. 2 - Regressions with constraint
foreach grp in n i {
foreach i of varlist l_secondary l_tertiary l_schoolyears l_humanc {
constraint 1 _b[l_inv] + _b[l_ngd] + _b[`i'] = 0
cnsreg l_y2015 l_inv `i' l_ngd if `grp', constraint(1)
outreg2 using Results-`grp'.xls, append dec(3) 
nlcom (alpha: _b[l_inv] / (1 + _b[l_inv] + _b[`i'])) (beta: _b[`i'] / (1 + _b[l_inv] + _b[`i'])), post
outreg2 using Results-`grp'.xls, append dec(3) 
}
}

// Previous regressions didn't give us R^2. We can do little manipulation with variables and run regressions again to get R^2:
gen x = l_inv - l_ngd
local j = 1
foreach i of varlist l_secondary l_tertiary l_schoolyears l_humanc {
gen y`j' = `i' - l_ngd 
local ++j
}

// Regressions with newly created variables
foreach grp in n i {
foreach i of num 1/4 {
regress l_y2015 x y`i' if `grp'
}
}










