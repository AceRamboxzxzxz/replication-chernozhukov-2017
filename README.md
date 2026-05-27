# Replication: Chernozhukov et al. (2017)

Replication of **Table 1, Panel B (Partially Linear Model, 2-fold cross-fitting), Ensemble column** from:

> Chernozhukov, V., Chetverikov, D., Demirer, M., Duflo, E., Hansen, C., and Newey, W. (2017). "Double/Debiased/Neyman Machine Learning of Treatment Effects." *American Economic Review: Papers & Proceedings*, 107(5): 261-265.

## Result

| | Mean ATE | Std. Error |
|---|---|---|
| Paper reports (Ensemble) | $9,043 | 1,432 |
| This replication | $9,158 | 1,428 |
| Difference | $115 (1.3%) | |

## Data

Data source: [OpenICPSR](https://www.openicpsr.org/openicpsr/project/113505/version/V1/view)

Download `sipp1991.dta` and place it in `input/`. The file is the 1991 Survey of Income and Program Participation (SIPP), 9,915 observations.

## Prerequisites

- R (>= 4.0)
- R packages: `foreign`, `hdm`, `glmnet`, `randomForest`, `gbm`, `nnet`, `matrixStats`, `quadprog`, `doSNOW`, `rpart`, `sandwich`, `neuralnet`
- LaTeX (TeX Live or MacTeX)

Install R packages with:
```r
install.packages(c('hdm','glmnet','randomForest','gbm','nnet',
                   'matrixStats','quadprog','doSNOW','rpart',
                   'sandwich','neuralnet'))
```

## Reproduction

```bash
git clone git@github.com:AceRamboxzxzxz/replication-chernozhukov-2017.git
cd replication-chernozhukov-2017
# Place sipp1991.dta in input/ (see Data section above)
make
```

The final paper will be at `paper/paper.pdf`.

## Repository Structure
replication-chernozhukov-2017/
├── input/          # Raw data and original helper functions (read-only)
├── code/
│   ├── preprocess.R    # Cleans raw data → temp/clean_data.csv
│   └── analysis.R      # Runs Double ML → output/tables/main_result.tex
├── output/tables/  # LaTeX table fragment (tracked in Git)
├── temp/           # Intermediate files (gitignored)
├── paper/          # paper.tex and compiled paper.pdf
├── Makefile        # Full pipeline DAG
└── run_all.sh      # Convenience wrapper: make clean && make
