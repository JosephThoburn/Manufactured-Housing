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

* -----------------------------------------
* STEP 4 (continued): Merge Everything Together
* -----------------------------------------
* MH + Total loans per county in 1993
use "HMDA_1993-2005_county.dta", clear

* Total loans
preserve
    keep if YEAR == 1993
    collapse (sum) total_loans_1993 = num_originations, by(state_code county_code)
    tempfile total_loans_1993
    save `total_loans_1993'
restore

* MH loans
preserve
    keep if YEAR == 1993 & mh_specialist == 1
    collapse (sum) mh_loans_1993 = num_originations, by(state_code county_code)
    tempfile mh_loans_1993
    save `mh_loans_1993'
restore

* Merge and create share
use `total_loans_1993', clear
merge 1:1 state_code county_code using `mh_loans_1993', nogenerate
gen mh_share_1993 = mh_loans_1993 / total_loans_1993
keep state_code county_code mh_share_1993
tempfile county_mh_share_1993
save `county_mh_share_1993'

use "HMDA_1993-2005_county.dta", clear

* Collapse to national MH totals per year
collapse (sum) mh_loans_nat = num_originations if mh_specialist == 1, by(YEAR)

* Generate national lagged values manually
keep if inlist(YEAR, 1993, 1995, 2000, 2005)
gen mh_nat_lag = .

replace mh_nat_lag = mh_loans_nat[_n-1] if YEAR == 1995  // Lag = 1993
replace mh_nat_lag = mh_loans_nat[_n-1] if YEAR == 2000  // Lag = 1995
replace mh_nat_lag = mh_loans_nat[_n-1] if YEAR == 2005  // Lag = 2000

* Compute national % change
gen pct_change_nat_mh = 100 * (mh_loans_nat - mh_nat_lag) / mh_nat_lag

* Keep only the rows for 1995, 2000, 2005 (the panel)
keep if inlist(YEAR, 1995, 2000, 2005)
tempfile nat_change
save `nat_change'

* Load total loans by county-year
use "HMDA_1993-2005_county.dta", clear
collapse (sum) total_loans = num_originations, by(state_code county_code YEAR)
tempfile all_loans
save `all_loans'

* Load MH loans by county-year
use "HMDA_1993-2005_county.dta", clear
keep if mh_specialist == 1
collapse (sum) mh_loans = num_originations, by(state_code county_code YEAR)
tempfile mh_loans
save `mh_loans'

* Merge total and MH loans together
use `all_loans', clear
merge 1:1 state_code county_code YEAR using `mh_loans', nogenerate
replace mh_loans = 0 if missing(mh_loans)

* Merge predicted change IV and baseline loan levels
merge m:1 state_code county_code using `total_loans_1993', nogenerate
merge m:1 state_code county_code using `mh_loans_1993', nogenerate
merge m:1 state_code county_code using `county_mh_share_1993', nogenerate
merge m:1 YEAR using `nat_change', nogenerate

* Recalculate predicted IV level 
gen predicted_change_mh = mh_share_1993 * pct_change_nat_mh
gen predicted_MH_loans_change = predicted_change_mh * total_loans_1993

* Keep years where first differences are valid
keep if inlist(YEAR, 1995, 2000, 2005)

* Calculate actual changes since 1993
gen actual_change_mh_loans = mh_loans - mh_loans_1993
gen actual_change_total_loans = total_loans - total_loans_1993

* -----------------------------------------
* STEP 5: Run Regressions
* -----------------------------------------

* Reduced form: substitution (does the IV affect total loans?)
reg actual_change_total_loans predicted_MH_loans_change, robust

* First-stage: IV strength (does the IV predict ∆MH loans?)
reg actual_change_mh_loans predicted_MH_loans_change, robust




