*Thank you for your paitence on this. Today is July 13, 2025 and this file contains the "New Workstreams Code" parts 1 and 2. This was all done with Social Explorer. 
cd "/Users/josephthoburn/Desktop/July 13"
*1990, tables used: T1, H43, H41, and H12.
import delimited "R13890865_SL050.txt"
gen mobile_share = (rc1990sf1_rc1990sf1_006_h041_010/rc1990sf1_rc1990sf1_006_h041_001)*100
sum mobile_share, d 
*Median is 13.08001 for mobile home share in 1990.
gen high_mh = 0
replace high_mh = 1 if mobile_share >= 13.08001
keep high_mh geo_fips
save "key.dta", replace

*We will come back to 1990. Next, for a consistent comparison, we are only looking at counties that made it into the 2006 ACS 1-Year.

*2006, tables used A00001, B25032, and B25007.
import delimited "R13890869_SL050.txt", clear
keep geo_fips
merge 1:1 geo_fips using "key.dta"
drop if _merge!=3
drop _merge
save "key.dta", replace
clear

*For 2006-2023 (skipping 2020), can we make a loop to save on code?
*Tables used: A00001, B25032, and B25007.
*Let's rename the files so it can fit into this loop. This is the only part you will have to change if you rerun the code.
import delimited "R13890869_SL050.txt", clear
save "acs06_data.dta", replace
import delimited "R13890872_SL050.txt", clear
save "acs07_data.dta", replace
import delimited "R13890873_SL050.txt", clear
save "acs08_data.dta", replace
import delimited "R13890874_SL050.txt", clear
save "acs09_data.dta", replace
import delimited "R13890875_SL050.txt", clear
save "acs10_data.dta", replace
import delimited "R13890876_SL050.txt", clear
save "acs11_data.dta", replace
import delimited "R13890877_SL050.txt", clear
save "acs12_data.dta", replace
import delimited "R13890878_SL050.txt", clear
save "acs13_data.dta", replace
import delimited "R13890879_SL050.txt", clear
save "acs14_data.dta", replace
import delimited "R13890880_SL050.txt", clear
save "acs15_data.dta", replace
import delimited "R13890881_SL050.txt", clear
save "acs16_data.dta", replace
import delimited "R13890882_SL050.txt", clear
save "acs17_data.dta", replace
import delimited "R13890883_SL050.txt", clear
save "acs18_data.dta", replace
import delimited "R13890884_SL050.txt", clear
rename geo__geoid_ geo_fips
save "acs19_data.dta", replace
*Skipping 2020
import delimited "R13890885_SL050.txt", clear
rename geo__geoid_ geo_fips
save "acs21_data.dta", replace
import delimited "R13890886_SL050.txt", clear
rename geo__geoid_ geo_fips
save "acs22_data.dta", replace
import delimited "R13890887_SL050.txt", clear
rename geo__geoid_ geo_fips
save "acs23_data.dta", replace
clear
* Loop through 2006 to 2023, excluding 2020
forvalues y = 6/23 {
    
    * Skip 2020 (i.e., y == 20)
    if `y' == 20 continue
    
    * Generate padded year string
    local yy : display %02.0f `y'   // 6 becomes "06", 10 becomes "10"
    local prefix = "acs`yy'_"

    * Load the dataset for this year (adjust file extension as needed)
    use "acs`yy'_data.dta", clear
	merge 1:1 geo_fips using "key.dta"
	drop if _merge!=3
	
	rename se_a00001_001 pop

    * Homeownership by age
    gen homeownership_under35 = ///
        (`prefix'b25007003 + `prefix'b25007004) / ///
        (`prefix'b25007003 + `prefix'b25007004 + `prefix'b25007013 + `prefix'b25007014)*100

    gen homeownership_over55 = ///
        (`prefix'b25007007 + `prefix'b25007008 + `prefix'b25007009 + `prefix'b25007010 + `prefix'b25007011) / ///
        (`prefix'b25007007 + `prefix'b25007008 + `prefix'b25007009 + `prefix'b25007010 + `prefix'b25007011 + ///
         `prefix'b25007017 + `prefix'b25007018 + `prefix'b25007019 + `prefix'b25007020 + `prefix'b25007021)*100

    * Homeownership by structure type
    gen homeownership_mobile = ///
        `prefix'b25032011 / (`prefix'b25032011 + `prefix'b25032022)*100

    gen homeownership_sitebuilt = ///
        (`prefix'b25032003 + `prefix'b25032004 + `prefix'b25032005 + `prefix'b25032006 + ///
         `prefix'b25032007 + `prefix'b25032008 + `prefix'b25032009 + `prefix'b25032010) / ///
        (`prefix'b25032003 + `prefix'b25032004 + `prefix'b25032005 + `prefix'b25032006 + ///
         `prefix'b25032007 + `prefix'b25032008 + `prefix'b25032009 + `prefix'b25032010 + ///
         `prefix'b25032014 + `prefix'b25032015 + `prefix'b25032016 + `prefix'b25032017 + ///
         `prefix'b25032018 + `prefix'b25032019 + `prefix'b25032020 + `prefix'b25032021)*100

    * Add year variable
    gen year = 2000 + `y'
	
	keep year geo_fips high_mh pop homeownership_under35 homeownership_over55 homeownership_mobile homeownership_sitebuilt

    * Save temp file for appending later
    tempfile tmp`yy'
    save `tmp`yy'', replace
}

	* Append years, skipping 2020
	use `tmp06', clear
	foreach y in 07 08 09 10 11 12 13 14 15 16 17 18 19 21 22 23 {
    append using `tmp`y''
}

* Save the appended dataset
save "homeownership.dta", replace

*1990
import delimited "R13890865_SL050.txt", clear

* Merge in high_mh flag from key.dta
merge 1:1 geo_fips using "key.dta"
drop if _merge != 3
drop _merge

* Add population variable from T1
rename se_t001_001 pop

* Homeownership rate: Under 35
gen homeownership_under35 = ///
    (rc1990sf1_rc1990sf1_005_h012_003 + rc1990sf1_rc1990sf1_005_h012_004) / ///
    (rc1990sf1_rc1990sf1_005_h012_003 + rc1990sf1_rc1990sf1_005_h012_004 + ///
     rc1990sf1_rc1990sf1_005_h012_011 + rc1990sf1_rc1990sf1_005_h012_012) * 100

* Homeownership rate: Over 55
gen homeownership_over55 = ///
    (rc1990sf1_rc1990sf1_005_h012_007 + rc1990sf1_rc1990sf1_005_h012_008 + rc1990sf1_rc1990sf1_005_h012_009) / ///
    (rc1990sf1_rc1990sf1_005_h012_007 + rc1990sf1_rc1990sf1_005_h012_008 + rc1990sf1_rc1990sf1_005_h012_009 + ///
     rc1990sf1_rc1990sf1_005_h012_015 + rc1990sf1_rc1990sf1_005_h012_016 + rc1990sf1_rc1990sf1_005_h012_017) * 100

* Homeownership rate: Mobile homes
gen homeownership_mobile = rc1990sf1_rc1990sf1_006_h043_011 / ///
    (rc1990sf1_rc1990sf1_006_h043_011 + rc1990sf1_rc1990sf1_006_h043_022) * 100

* Homeownership rate: Site-built homes (1-unit to 50+ units)
gen homeownership_sitebuilt = ///
    (rc1990sf1_rc1990sf1_006_h043_003 + rc1990sf1_rc1990sf1_006_h043_004 + rc1990sf1_rc1990sf1_006_h043_005 + ///
     rc1990sf1_rc1990sf1_006_h043_006 + rc1990sf1_rc1990sf1_006_h043_007 + rc1990sf1_rc1990sf1_006_h043_008 + ///
     rc1990sf1_rc1990sf1_006_h043_009 + rc1990sf1_rc1990sf1_006_h043_010) / ///
    (rc1990sf1_rc1990sf1_006_h043_003 + rc1990sf1_rc1990sf1_006_h043_004 + rc1990sf1_rc1990sf1_006_h043_005 + ///
     rc1990sf1_rc1990sf1_006_h043_006 + rc1990sf1_rc1990sf1_006_h043_007 + rc1990sf1_rc1990sf1_006_h043_008 + ///
     rc1990sf1_rc1990sf1_006_h043_009 + rc1990sf1_rc1990sf1_006_h043_010 + ///
     rc1990sf1_rc1990sf1_006_h043_014 + rc1990sf1_rc1990sf1_006_h043_015 + rc1990sf1_rc1990sf1_006_h043_016 + ///
     rc1990sf1_rc1990sf1_006_h043_017 + rc1990sf1_rc1990sf1_006_h043_018 + rc1990sf1_rc1990sf1_006_h043_019 + ///
     rc1990sf1_rc1990sf1_006_h043_020 + rc1990sf1_rc1990sf1_006_h043_021) * 100

* Add year identifier
gen year = 1990

* Keep only relevant variables for appending
keep year geo_fips high_mh pop homeownership_under35 homeownership_over55 homeownership_mobile homeownership_sitebuilt

append using "homeownership.dta"
sort year
save "homeownership.dta", replace

*2000, tables used: T1, H32, and H16.
import delimited "R13890888_SL050.txt", clear
* Merge in high_mh flag from key.dta
merge 1:1 geo_fips using "key.dta"
drop if _merge != 3
drop _merge

* Add population
rename se_t001_001 pop

* Homeownership rate: Under 35 (15–34)
gen homeownership_under35 = ///
    (rc2000sf1_rc2000sf1_013_h016003 + rc2000sf1_rc2000sf1_013_h016004) / ///
    (rc2000sf1_rc2000sf1_013_h016003 + rc2000sf1_rc2000sf1_013_h016004 + ///
     rc2000sf1_rc2000sf1_013_h016012 + rc2000sf1_rc2000sf1_013_h016013) * 100

* Homeownership rate: Over 55 (55–85+)
gen homeownership_over55 = ///
    (rc2000sf1_rc2000sf1_013_h016007 + rc2000sf1_rc2000sf1_013_h016008 + rc2000sf1_rc2000sf1_013_h016009 + ///
     rc2000sf1_rc2000sf1_013_h016010) / ///
    (rc2000sf1_rc2000sf1_013_h016007 + rc2000sf1_rc2000sf1_013_h016008 + rc2000sf1_rc2000sf1_013_h016009 + ///
     rc2000sf1_rc2000sf1_013_h016010 + rc2000sf1_rc2000sf1_013_h016016 + rc2000sf1_rc2000sf1_013_h016017 + ///
     rc2000sf1_rc2000sf1_013_h016018 + rc2000sf1_rc2000sf1_013_h016019) * 100

* Homeownership rate: Mobile homes
gen homeownership_mobile = rc2000sf3_rc2000sf3_022_h032011 / ///
    (rc2000sf3_rc2000sf3_022_h032011 + rc2000sf3_rc2000sf3_022_h032022) * 100

* Homeownership rate: Site-built
gen homeownership_sitebuilt = ///
    (rc2000sf3_rc2000sf3_022_h032003 + rc2000sf3_rc2000sf3_022_h032004 + rc2000sf3_rc2000sf3_022_h032005 + ///
     rc2000sf3_rc2000sf3_022_h032006 + rc2000sf3_rc2000sf3_022_h032007 + rc2000sf3_rc2000sf3_022_h032008 + ///
     rc2000sf3_rc2000sf3_022_h032009 + rc2000sf3_rc2000sf3_022_h032010) / ///
    (rc2000sf3_rc2000sf3_022_h032003 + rc2000sf3_rc2000sf3_022_h032004 + rc2000sf3_rc2000sf3_022_h032005 + ///
     rc2000sf3_rc2000sf3_022_h032006 + rc2000sf3_rc2000sf3_022_h032007 + rc2000sf3_rc2000sf3_022_h032008 + ///
     rc2000sf3_rc2000sf3_022_h032009 + rc2000sf3_rc2000sf3_022_h032010 + ///
     rc2000sf3_rc2000sf3_022_h032014 + rc2000sf3_rc2000sf3_022_h032015 + rc2000sf3_rc2000sf3_022_h032016 + ///
     rc2000sf3_rc2000sf3_022_h032017 + rc2000sf3_rc2000sf3_022_h032018 + rc2000sf3_rc2000sf3_022_h032019 + ///
     rc2000sf3_rc2000sf3_022_h032020 + rc2000sf3_rc2000sf3_022_h032021) * 100

* Add year
gen year = 2000

* Keep consistent structure for appending
keep year geo_fips high_mh pop homeownership_under35 homeownership_over55 homeownership_mobile homeownership_sitebuilt
append using "homeownership.dta"
sort year
save "homeownership.dta", replace

* Weighted means by year and high_mh group (0 = low-MH, 1 = high-MH)
collapse (mean) ///
    homeownership_under35 ///
    homeownership_over55 ///
    homeownership_mobile ///
    homeownership_sitebuilt [pw=pop], ///
    by(year high_mh)

* Save aggregated version
save "homeownership_summary.dta", replace

twoway ///
    (line homeownership_under35 year if high_mh == 1, lcolor(blue) lpattern(solid)) ///
    (line homeownership_under35 year if high_mh == 0, lcolor(red) lpattern(dash)), ///
    legend(label(1 "High-MH") label(2 "Low-MH")) ///
    title("Homeownership Rate: Age Under 35") ///
    ytitle("Percent") xtitle("Year") ///
    ylabel(, angle(0)) ///
    graphregion(color(white))
	
twoway ///
    (line homeownership_over55 year if high_mh == 1, lcolor(blue) lpattern(solid)) ///
    (line homeownership_over55 year if high_mh == 0, lcolor(red) lpattern(dash)), ///
    legend(label(1 "High-MH") label(2 "Low-MH")) ///
    title("Homeownership Rate: Age 55 and Over") ///
    ytitle("Percent") xtitle("Year") ///
    graphregion(color(white))
	
* Graph 1: High-MH Counties Only
twoway ///
    (line homeownership_mobile year if high_mh == 1, lcolor(blue) lpattern(solid)) ///
    (line homeownership_sitebuilt year if high_mh == 1, lcolor(red) lpattern(dash)), ///
    legend(label(1 "Manufactured Homes") label(2 "Site-Built Homes")) ///
    title("Homeownership Rate by Structure Type (High-MH Counties)") ///
    ytitle("Percent") xtitle("Year") ///
    ylabel(, angle(0)) ///
    graphregion(color(white))	
	

* Graph 2: Low-MH Counties Only
twoway ///
    (line homeownership_mobile year if high_mh == 0, lcolor(blue) lpattern(solid)) ///
    (line homeownership_sitebuilt year if high_mh == 0, lcolor(red) lpattern(dash)), ///
    legend(label(1 "Manufactured Homes") label(2 "Site-Built Homes")) ///
    title("Homeownership Rate by Structure Type (Low-MH Counties)") ///
    ytitle("Percent") xtitle("Year") ///
    ylabel(, angle(0)) ///
    graphregion(color(white))
	
use "homeownership.dta", clear
collapse (mean) ///
    homeownership_mobile ///
    homeownership_sitebuilt [pw=pop], ///
    by(year)
	
twoway ///
    (line homeownership_mobile year, lcolor(blue) lpattern(solid)) ///
    (line homeownership_sitebuilt year, lcolor(red) lpattern(dash)), ///
    legend(label(1 "Manufactured Homes") label(2 "Site-Built Homes")) ///
    title("Homeownership Rate by Structure Type (All Counties)") ///
    ytitle("Percent") xtitle("Year") ///
    ylabel(, angle(0)) ///
    graphregion(color(white))

*Are young people living with their parents instead of buying? Well, let's check out IPUMS USA and select age and relate. I did this as one large file. Took awhile. . .
* Create an empty master dataset
tempfile master
save `master', emptyok replace

* List of years to loop over
local years 1990 2000
forvalues y = 2006/2023 {
    local years `years' `y'
}

* Loop through each year
foreach yr of local years {

    di "Processing year `yr'..."

    * Load and filter data
    do usa_00007.do
    keep if year == `yr'

    * Build FIPS code
    gen geo_fips = statefip * 1000 + countyfip

    * Merge in high/low MH classification
    merge m:1 geo_fips using "key.dta"
    drop if _merge != 3
    drop _merge

    * Flag co-residence among 18–34-year-olds
    gen age18_34 = age >= 18 & age <= 34
    gen with_parent = (age18_34 == 1 & relate == 3)

    * Collapse to county-year level
    collapse (sum) num_with_parent = with_parent denom = age18_34 [pw=perwt], by(geo_fips high_mh)

    * Calculate co-residence rate
    gen coresidence_rate = 100 * num_with_parent / denom
    gen year = `yr'

    * Collapse to MH group for this year
    collapse (mean) coresidence_rate [pw=denom], by(year high_mh)

    * Append to master dataset
    append using `master'
    save `master', replace
}

* Load full result
use `master', clear

* Plot result
twoway ///
    (line coresidence_rate year if high_mh == 1, lcolor(blue)) ///
    (line coresidence_rate year if high_mh == 0, lcolor(red) lpattern(dash)), ///
    legend(label(1 "High-MH Counties") label(2 "Low-MH Counties")) ///
    title("Share of 18–34-Year-Olds Living with Parents") ///
    ytitle("Percent") xtitle("Year") ///
    graphregion(color(white))

*This needs to be recalculated.	
save "livingwithparents.dta",replace 	

