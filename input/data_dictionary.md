# Data Dictionary

**Source:** 1991 Survey of Income and Program Participation (SIPP)  
**File:** `sipp1991.dta`  
**Observations:** 9,915  
**Original use:** Chernozhukov et al. (2017), AER P&P; Chernozhukov & Hansen (2004)

| Variable | Role | Description | Units |
|----------|------|-------------|-------|
| net_tfa | Outcome (Y) | Net total financial assets: sum of IRA balances, 401(k) balances, checking accounts, saving bonds, interest-earning accounts, stocks, and mutual funds, less non-mortgage debt | USD |
| e401 | Treatment (D) | Indicator for eligibility to enroll in a 401(k) plan | Binary (0/1) |
| age | Covariate | Age of respondent | Years |
| inc | Covariate | Annual income | USD |
| educ | Covariate | Years of education completed | Years |
| fsize | Covariate | Family size | Count |
| marr | Covariate | Married indicator | Binary (0/1) |
| twoearn | Covariate | Two-earner household indicator | Binary (0/1) |
| db | Covariate | Defined benefit pension plan indicator | Binary (0/1) |
| pira | Covariate | IRA participation indicator | Binary (0/1) |
| hown | Covariate | Home ownership indicator | Binary (0/1) |
| nifa | Unused | Non-IRA financial assets | USD |
| tw | Unused | Total wealth | USD |
| p401 | Unused | 401(k) participation indicator (endogenous) | Binary (0/1) |
