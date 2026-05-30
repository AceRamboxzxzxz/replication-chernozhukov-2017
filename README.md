# Replication: Chernozhukov et al. (2017)

This project replicates the primary empirical result from:

> Chernozhukov, V., Chetverikov, D., Demirer, M., Duflo, E., Hansen, C., and Newey, W. (2017). *Double/Debiased/Neyman Machine Learning of Treatment Effects.* American Economic Review: Papers & Proceedings, 107(5): 261–265.

The replication targets **Table 1, Panel B (Partially Linear Model, 2-fold cross-fitting), Ensemble column** from the online appendix. Specifically, it reproduces the estimated Average Treatment Effect (ATE) of 401(k) eligibility on net financial assets using the Double/Debiased Machine Learning (Double ML) framework.

## Results Summary

The original paper reports that 401(k) eligibility increases net financial assets by approximately **$9,043**. Using the original data and replication code, this project estimates an Average Treatment Effect of approximately **$8,970**, less than 1% away from the published result.

|                          |    Mean ATE | Std. Error |
| ------------------------ | ----------: | ---------: |
| Paper reports (Ensemble) |      $9,043 |      1,432 |
| This replication         |      $8,970 |      1,407 |
| Difference               | -$73 (0.8%) |            |

## Data

Data source:

https://www.openicpsr.org/openicpsr/project/113505/version/V1/view

Download:

```text
sipp1991.dta
```

and place it in:

```text
input/
```

The file contains data from the 1991 Survey of Income and Program Participation (SIPP) and includes 9,915 observations.

## Prerequisites

### Software

* R (version 4.0 or higher)
* LaTeX (TeX Live or MacTeX)

### Required R Packages

```r
install.packages(c(
  "foreign",
  "hdm",
  "glmnet",
  "randomForest",
  "gbm",
  "nnet",
  "matrixStats",
  "quadprog",
  "doSNOW",
  "rpart",
  "sandwich",
  "neuralnet"
))
```

## Reproduction Instructions

Clone the repository:

```bash
git clone git@github.com:AceRamboxzxzxz/replication-chernozhukov-2017.git
cd replication-chernozhukov-2017
```

Place:

```text
sipp1991.dta
```

inside:

```text
input/
```

Then run:

```bash
make
```

The final paper will be generated at:

```text
paper/paper.pdf
```

Alternatively:

```bash
./run_all.sh
```

will execute a clean rebuild of the entire pipeline.

## Repository Structure

```text
replication-chernozhukov-2017/
├── input/
│   ├── sipp1991.dta
│   ├── ML_Functions.R
│   ├── Moment_Functions.R
│   └── data_dictionary.md
├── code/
│   ├── preprocess.R
│   └── analysis.R
├── output/
│   └── tables/
│       └── main_result.tex
├── temp/
├── paper/
│   ├── paper.tex
│   └── paper.pdf
├── Makefile
├── run_all.sh
└── README.md
```

## Notes

The original paper averages estimates over 100 random sample splits. To reduce computation time, this replication uses 10 random sample splits. Despite this simplification, the estimated treatment effect remains extremely close to the published result.

## Citation

Chernozhukov, V., Chetverikov, D., Demirer, M., Duflo, E., Hansen, C., and Newey, W. (2017). *Double/Debiased/Neyman Machine Learning of Treatment Effects.* American Economic Review: Papers & Proceedings, 107(5): 261–265.
