*Step 1: MH Key, append all keys and drop duplicates. 
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("1993") cellrange(A3:E66) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
drop in 63
drop in 62
save "key_1993.dta", replace
clear
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("1994") cellrange(A3:E88) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
drop in 85
drop in 84
save "key_1994.dta", replace
clear
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("1995") cellrange(A3:E121) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
drop in 118
drop in 117
save "key_1995.dta", replace
clear
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("1996") cellrange(A3:E166) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
drop in 163
drop in 162
save "key_1996.dta", replace
clear
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("1997") cellrange(A3:E232) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
drop in 229
drop in 228
save "key_1997.dta", replace
clear
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("1998") cellrange(A3:E276) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
drop in 273
drop in 272
save "key_1998.dta", replace
clear
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("1999") cellrange(A3:E282) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
drop in 279
drop in 278
save "key_1999.dta", replace
clear
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("2000") cellrange(A3:E225) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
drop in 222
drop in 221
save "key_2000.dta", replace
clear
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("2001") cellrange(A3:E215) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
drop in 212
drop in 211
save "key_2001.dta", replace
clear
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("2002") cellrange(A3:E210) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
save "key_2002.dta", replace
drop in 207
drop in 206
clear
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("2003") cellrange(A3:E247) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
destring MH, replace force
save "key_2003.dta", replace
clear
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("2004") cellrange(A3:E231) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
save "key_2004.dta", replace
clear
import excel "/Users/josephthoburn/Desktop/Manufactured Housing Loans/subprime_2006_distributed.xls", sheet("2005") cellrange(A3:E213) firstrow
rename CODE agency_code
gen respondent_id = substr(IDD, 2, .)
save "key_2005.dta", replace
clear

use "key_1993.dta"
append using "key_1994.dta" "key_1995.dta" "key_1996.dta" "key_1997.dta" "key_1998.dta" "key_1999.dta" "key_2000.dta" "key_2001.dta" "key_2002.dta" "key_2003.dta" "key_2004.dta" "key_2005.dta"
duplicates drop IDD, force
save "key.dta", replace
clear
* I dropped duplicates using IDD since that is just the agency code plus the respondent id, thus containing all the information that we needed. The next step is making a system based on fips codes that allow for comparison over time. Based on my conversation with you, I am using 2005 county fips codes.

*Step 2: County Fips Code Check
*https://www2.census.gov/geo/docs/reference/codes/files/national_county.txt
import delimited "/Users/josephthoburn/Desktop/Manufactured Housing Loans/national_county.txt", clear varnames(nonames) delimiter(",")
rename v1 state_abbr
rename v2 state_code
tostring state_code, replace force format(%02.0f)
rename v3 county_code
tostring county_code, replace force format(%03.0f)
rename v4 county_name
rename v5 func_status
save "fipscode_2010.dta", replace
clear
*https://www.census.gov/programs-surveys/geography/technical-documentation/county-changes.html
*The above website shows changes over time, allowing for adjustment. 

*Step 3: Putting it all togther with HMDA

*1993
cd "/Users/josephthoburn/Desktop/Manufactured Housing Loans"
import delimited "HMDA_LAR_1993.txt", clear
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 025 → 086) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_1993.dta", replace
clear

*1994
import delimited "HMDA_LAR_1994.txt", clear
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 086 → 025) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_1994.dta", replace
clear

*1995
import delimited "HMDA_LAR_1995.txt", clear
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 086 → 025) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_1995.dta", replace
clear

*1996
import delimited "HMDA_LAR_1996.txt", clear
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 086 → 025) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_1996.dta", replace
clear


*1997
import delimited "HMDA_LAR_1997.txt", clear
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 086 → 025) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_1997.dta", replace
clear


*1998
import delimited "HMDA_LAR_1998.txt", clear
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 086 → 025) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_1998.dta", replace
clear


*1999
import delimited "HMDA_LAR_1999.txt", clear
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 086 → 025) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_1999.dta", replace
clear


*2000
import delimited "HMDA_LAR_2000.txt", clear
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 086 → 025) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_2000.dta", replace
clear


*2001
import delimited "HMDA_LAR_2001.txt", clear
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 086 → 025) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_2001.dta", replace
clear

*2002
import delimited "HMDA_LAR_2002.txt", clear
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 086 → 025) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_2002.dta", replace
clear

*2003
import delimited "HMDA_LAR_2003.txt", clear
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 086 → 025) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_2003.dta", replace
clear

*2004
import delimited "HMDA_LAR_2004.txt", clear
rename occupancy occupancy_type
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 086 → 025) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_2004.dta", replace
clear

*2005
import delimited "HMDA_LAR_2005.txt", clear
rename occupancy occupancy_type
keep if loan_purpose == 1 & action_taken == 1 & occupancy_type == 1
tostring state_code, replace force format(%02.0f)
tostring county_code, replace force format(%03.0f)
tostring agency_code, replace force
merge m:1 agency_code respondent_id using "key.dta"
gen mh_specialist = (MH==2)
drop _merge 
// 1. Dade County, FL (rename 086 → 025) (happened in 1997)
replace county_code = "086" if state_code == "12" & county_code == "025"
// 2. South Boston City, VA (county 780) → Halifax County (083) (happened in 1995)
replace county_code = "083" if state_code == "51" & county_code == "780"
// 3. Clifton Forge City, VA (560) → Alleghany County (005) (happened in 2001)
replace county_code = "005" if state_code == "51" & county_code == "560"
merge m:1 state_code county_code using "fipscode_2010.dta"
drop if _merge!=3
drop _merge 
tab mh_specialist
replace MH = 0 if MH != 1 & MH != 2
tab MH
save "HMDA_2005.dta", replace
clear

*Aggregate to county level
use "HMDA_1993.dta"
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 1993
save "HMDA_1993_county.dta", replace
clear
use "HMDA_1994.dta"
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 1994
save "HMDA_1994_county.dta", replace
clear
use "HMDA_1995.dta"
destring loan_amount, replace force
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 1995
save "HMDA_1995_county.dta", replace
clear
use "HMDA_1996.dta"
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 1996
save "HMDA_1996_county.dta", replace
clear
use "HMDA_1997.dta"
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 1997
save "HMDA_1997_county.dta", replace
clear
use "HMDA_1998.dta"
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 1998
save "HMDA_1998_county.dta", replace
clear
use "HMDA_1999.dta"
destring loan_amount, replace force
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 1999
save "HMDA_1999_county.dta", replace
clear
use "HMDA_2000.dta"
destring loan_amount, replace force
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 2000
save "HMDA_2000_county.dta", replace
clear
use "HMDA_2001.dta"
destring loan_amount, replace force
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 2001
save "HMDA_2001_county.dta", replace
clear
use "HMDA_2002.dta"
destring loan_amount, replace force
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 2002
save "HMDA_2002_county.dta", replace
clear
use "HMDA_2003.dta"
destring loan_amount, replace force
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 2003
save "HMDA_2003_county.dta", replace
clear
use "HMDA_2004.dta"
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 2004
save "HMDA_2004_county.dta", replace
clear
use "HMDA_2005.dta"
collapse (count) num_originations = loan_amount (sum) total_loan_amount = loan_amount, by(state_code county_code mh_specialist)
gen YEAR = 2005
save "HMDA_2005_county.dta", replace
clear

*Add them up 
use "HMDA_1993_county.dta"
append using "HMDA_1994_county.dta" "HMDA_1995_county.dta" "HMDA_1996_county.dta" "HMDA_1997_county.dta" "HMDA_1998_county.dta" "HMDA_1999_county.dta" "HMDA_2000_county.dta" "HMDA_2001_county.dta" "HMDA_2002_county.dta" "HMDA_2003_county.dta" "HMDA_2004_county.dta" "HMDA_2005_county.dta"

save "HMDA_1993-2005_county.dta", replace
clear

*Step 4: Making the IV, I had ChatGPT put this together, but I went back line by line to make sure the calculation where correct. That is why the style of code changes so much. This first part calculates the county manufacturning home share by useing tempfiles. 
* -----------------------------------------
* STEP 1: Calculate County-Level MH Share in 1993
* -----------------------------------------

* Load data
use "HMDA_1993-2005_county.dta", clear

* Get total loans per county in 1993
preserve
    keep if YEAR == 1993
    collapse (sum) total_loans_1993 = num_originations, by(state_code county_code)
    tempfile total_loans_1993
    save `total_loans_1993'
restore

* Get manufactured-home (MH) loans per county in 1993
preserve
    keep if YEAR == 1993 & mh_specialist == 1
    collapse (sum) mh_loans_1993 = num_originations, by(state_code county_code)
    tempfile mh_loans_1993
    save `mh_loans_1993'
restore

* Merge county MH loans with total county loans
use `total_loans_1993', clear
merge 1:1 state_code county_code using `mh_loans_1993', nogenerate

* Create county-level MH share (1993 baseline)
gen mh_share_1993 = mh_loans_1993 / total_loans_1993
keep state_code county_code mh_share_1993

* Save this baseline
tempfile county_mh_share_1993
save `county_mh_share_1993'

* -----------------------------------------
* STEP 2: Calculate National MH Loan Share by Year
* -----------------------------------------

* Load original data again
use "HMDA_1993-2005_county.dta", clear

* Calculate total national loans per year
collapse (sum) total_national_loans = num_originations, by(YEAR)
tempfile national_total_loans
save `national_total_loans'

* Calculate national MH loans per year
use "HMDA_1993-2005_county.dta", clear
collapse (sum) national_mh_loans = num_originations if mh_specialist == 1, by(YEAR)

* Merge national MH loans and national total loans
merge 1:1 YEAR using `national_total_loans', nogenerate

* Calculate national MH loan share per year explicitly
gen national_mh_share = national_mh_loans / total_national_loans

* Extract explicitly the 1993 baseline national MH share
*This line of code is interesting. summ calculates summary statistics for national_mh_share in 1993 and saves it in temporary memory as the mean. Since there is only one observation, the mean is just itself. Then we use r(mean) so that we can apply it to "national_mh_shift_1993" so it applies to every observation allowing for the IV calculation. An interesting technique. 
summ national_mh_share if YEAR == 1993, meanonly
gen national_mh_share_1993 = r(mean)

* Calculate national shift explicitly
gen national_shift = (national_mh_share - national_mh_share_1993) / national_mh_share_1993

* Keep only needed variables
keep YEAR national_shift national_mh_share_1993

* Save national shift
tempfile national_shift
save `national_shift'

* -----------------------------------------
* STEP 3: Merge Baseline and National Shift to Form Shift-Share IV
* -----------------------------------------

* Reload original data
use "HMDA_1993-2005_county.dta", clear

* Merge county baseline MH shares (1993)
merge m:1 state_code county_code using `county_mh_share_1993', nogenerate

* Merge national shift by YEAR
merge m:1 YEAR using `national_shift', nogenerate

* Generate Shift-Share IV explicitly
gen shift_share_IV = mh_share_1993 * national_shift

* -----------------------------------------
* STEP 4: Predict MH Loans Using IV
* -----------------------------------------

* Calculate total loans per county-year (all lenders)
bysort state_code county_code YEAR: egen county_year_total = total(num_originations)

* Predict MH loans explicitly
gen predicted_MH_loans = shift_share_IV * county_year_total

* -----------------------------------------
* STEP 5: Calculate Actual MH Loans per County-Year
* -----------------------------------------

* Calculate actual MH loans
preserve
    keep if mh_specialist == 1
    collapse (sum) actual_MH_loans = num_originations, by(state_code county_code YEAR)
    tempfile actual_MH_loans
    save `actual_MH_loans'
restore

* Merge actual MH loans back into main data
merge m:1 state_code county_code YEAR using `actual_MH_loans', nogenerate
replace actual_MH_loans = 0 if missing(actual_MH_loans)

* -----------------------------------------
* STEP 6: Plot Predicted vs. Actual MH Loans (1994–2005)
* -----------------------------------------

keep if YEAR >= 1994 & YEAR <= 2005

twoway ///
    (scatter actual_MH_loans predicted_MH_loans, ///
        msymbol(circle_hollow) mcolor(blue)) ///
    (lfit actual_MH_loans predicted_MH_loans, lcolor(red)), ///
    xtitle("Predicted MH Loans (Shift-Share IV)") ///
    ytitle("Actual MH Loans") ///
    title("Predicted vs Actual Manufactured Home Loans (1994-2005)") ///
    legend(off)

preserve
collapse (sum) predicted_MH_loans actual_MH_loans, by(YEAR)

twoway (line actual_MH_loans YEAR, lcolor(blue) lwidth(medium)) ///
       (line predicted_MH_loans YEAR, lcolor(red) lwidth(medium) lpattern(dash)), ///
       xtitle("Year") ///
       ytitle("Number of MH Loans") ///
       title("Actual vs. Predicted MH Loans Over Time (1994-2005)") ///
       legend(order(1 "Actual MH Loans" 2 "Predicted MH Loans")) ///
       xlabel(1994(1)2005)

restore

preserve 
keep if YEAR >= 1994 & YEAR <= 2000

twoway ///
    (scatter actual_MH_loans predicted_MH_loans, ///
        msymbol(circle_hollow) mcolor(blue)) ///
    (lfit actual_MH_loans predicted_MH_loans, lcolor(red)), ///
    xtitle("Predicted MH Loans (Shift-Share IV)") ///
    ytitle("Actual MH Loans") ///
    title("Predicted vs Actual Manufactured Home Loans (1994-2000)") ///
    legend(off)
restore

