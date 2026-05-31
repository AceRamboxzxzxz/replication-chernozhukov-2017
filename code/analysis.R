library(foreign)
library(hdm)
library(randomForest)
library(nnet)
library(matrixStats)
library(quadprog)
library(doSNOW)

source(file.path(getwd(), "input/ML_Functions.R"))
source(file.path(getwd(), "input/Moment_Functions.R"))

table_path <- "output/tables/main_result.tex"

cat("Loading clean data...\n")
data <- read.dta("input/sipp1991.dta")

y  <- "net_tfa"
d  <- "e401"
x  <- "age + inc + educ + fsize + marr + twoearn + db + pira + hown"
xl <- "(poly(age, 6, raw=TRUE) + poly(inc, 8, raw=TRUE) + poly(educ, 4, raw=TRUE) + poly(fsize, 2, raw=TRUE) + marr + twoearn + db + pira + hown)^2"

Boosting  <- list(bag.fraction=.5, train.fraction=1.0, interaction.depth=2, n.trees=1000, shrinkage=.01, n.cores=1, cv.folds=5, verbose=FALSE, clas_dist='adaboost', reg_dist='gaussian')
Forest    <- list(clas_nodesize=1, reg_nodesize=5, ntree=1000, na.action=na.omit, replace=TRUE)
RLasso    <- list(penalty=list(homoscedastic=FALSE, X.dependent.lambda=FALSE, lambda.start=NULL, c=1.1), intercept=TRUE)
Nnet      <- list(size=8, maxit=1000, decay=0.01, MaxNWts=10000, trace=FALSE)
Trees     <- list(reg_method="anova", clas_method="class")

arguments <- list(Boosting=Boosting, Forest=Forest, RLasso=RLasso, Nnet=Nnet, Trees=Trees)
ensemble  <- list(methods=c("RLasso","Boosting","Forest","Nnet"))
methods   <- c("RLasso","Trees","Forest","Boosting","Nnet","Ensemble")
ite       <- 10

ncores <- min(4, parallel::detectCores() - 1)
cat(sprintf("Running Double ML: %d iterations, 2-fold, %d cores...\n", ite, ncores))

cl <- makeCluster(ncores, outfile="")
registerDoSNOW(cl)
set.seed(1211)

r <- foreach(k = 1:ite, .combine='rbind', .inorder=FALSE,
             .packages=c('MASS','randomForest','neuralnet','gbm','sandwich','hdm','nnet','rpart','glmnet')) %dopar% {
  res <- DoubleML(data, y, d, x, xl, methods=methods, nfold=2, est="plinear", arguments=arguments, ensemble=ensemble, silent=FALSE)
  data.frame(t(res[1,]), t(res[2,]))
}

stopCluster(cl)

result           <- matrix(0, 4, length(methods)+1)
colnames(result) <- c(methods, "best")
rownames(result) <- c("Mean ATE", "se", "Median ATE", "se")

result[1,] <- colMeans(r[, 1:(length(methods)+1)])
result[2,] <- sqrt(colSums(r[, (length(methods)+2):ncol(r)]^2 + (r[, 1:(length(methods)+1)] - colMeans(r[, 1:(length(methods)+1)]))^2) / ite)
result[3,] <- colQuantiles(as.matrix(r[, 1:(length(methods)+1)]), probs=0.5)
result[4,] <- colQuantiles(as.matrix(sqrt(r[, (length(methods)+2):ncol(r)]^2 + (r[, 1:(length(methods)+1)] - colQuantiles(as.matrix(r[, 1:(length(methods)+1)]), probs=0.5))^2)), probs=0.5)

cat("\nFull results table:\n")
print(result)

ensemble_col <- which(colnames(result) == "Ensemble")
mean_ate     <- result["Mean ATE",   ensemble_col]
mean_se      <- result["se",         ensemble_col]
median_ate   <- result["Median ATE", ensemble_col]
median_se    <- result["se",         ensemble_col]
ci_lo        <- mean_ate - 1.96 * mean_se
ci_hi        <- mean_ate + 1.96 * mean_se

paper_mean_ate <- 9043
paper_mean_se  <- 1432

cat("\n========================================\n")
cat("Replication Result\n")
cat("========================================\n")
cat(sprintf("Paper reports (Ensemble): ATE = $%.0f (s.e. %.0f)\n", paper_mean_ate, paper_mean_se))
cat(sprintf("We obtain (Ensemble):     ATE = $%.2f (s.e. %.2f)\n", mean_ate, mean_se))
cat(sprintf("Difference:               $%.2f\n", mean_ate - paper_mean_ate))
cat(sprintf("95%% CI:                  [$%.2f, $%.2f]\n", ci_lo, ci_hi))
cat("========================================\n")

dir.create("output/tables", showWarnings=FALSE, recursive=TRUE)

tex <- c(
  "\\begin{table}[h]",
  "\\centering",
  "\\caption{Replication of Table 1, Panel B (Partially Linear Model, 2-fold) from Chernozhukov et al. (2017)}",
  "\\begin{tabular}{lcc}",
  "\\hline",
  " & This Replication & Paper (Ensemble) \\\\",
  "\\hline",
  sprintf("Mean ATE (\\$) & $%.2f$ & $9{,}043$ \\\\", mean_ate),
  sprintf("Std.\\ Error & $%.2f$ & $1{,}432$ \\\\", mean_se),
  sprintf("95\\%% CI & [$%.2f$,\\; $%.2f$] & --- \\\\", ci_lo, ci_hi),
  sprintf("Median ATE (\\$) & $%.2f$ & $9{,}061$ \\\\", median_ate),
  sprintf("Median SE & $%.2f$ & $1{,}343$ \\\\", median_se),
  "\\hline",
  sprintf("\\multicolumn{3}{l}{\\footnotesize Note: Based on %d sample splits, 2-fold cross-fitting.} \\\\", ite),
  "\\multicolumn{3}{l}{\\footnotesize Paper values from Table 1, Panel B, Ensemble column.} \\\\",
  "\\end{tabular}",
  "\\label{tab:main}",
  "\\end{table}"
)

writeLines(tex, table_path)
cat(sprintf("\nLaTeX table written to: %s\n", table_path))

# --- Write comparison table across all methods -------------------------------
paper_mean <- c(RLasso=7718, Trees=8745, Forest=9180, Boosting=8768, Nnet=9040, Ensemble=9043)
paper_se   <- c(RLasso=1796, Trees=1488, Forest=1526, Boosting=1451, Nnet=1494, Ensemble=1432)

method_labels <- c("RLasso", "Trees", "Forest", "Boosting", "Nnet", "Ensemble")

comp_tex <- c(
  "\\begin{table}[h]",
  "\\centering",
  "\\small",
  "\\caption{Replication vs.\\ Paper: Table 1, Panel B (Partially Linear Model, 2-fold)}",
  "\\begin{tabular}{lcccccc}",
  "\\hline",
  " & RLasso & Reg.\\ Tree & Random Forest & Boosting & Neural Net & Ensemble \\\\",
  "\\hline",
  "\\multicolumn{7}{l}{\\textit{This Replication}} \\\\",
  paste("Mean ATE (\\$)",
        paste(sprintf("$%.0f$", result["Mean ATE", method_labels]), collapse=" & "),
        sep=" & ") |> paste0(" \\\\"),
  paste("",
        paste(sprintf("($%.0f$)", result["se", method_labels]), collapse=" & "),
        sep=" & ") |> paste0(" \\\\"),
  "\\hline",
  "\\multicolumn{7}{l}{\\textit{Chernozhukov et al.\\ (2017)}} \\\\",
  paste("Mean ATE (\\$)",
        paste(sprintf("$%.0f$", paper_mean[method_labels]), collapse=" & "),
        sep=" & ") |> paste0(" \\\\"),
  paste("",
        paste(sprintf("($%.0f$)", paper_se[method_labels]), collapse=" & "),
        sep=" & ") |> paste0(" \\\\"),
  "\\hline",
  sprintf("\\multicolumn{7}{l}{\\footnotesize Note: Standard errors in parentheses. Replication based on %d sample splits, 2-fold cross-fitting.} \\\\", ite),
  "\\multicolumn{7}{l}{\\footnotesize Paper values from Table 1, Panel B of the online appendix.} \\\\",
  "\\end{tabular}",
  "\\label{tab:comparison}",
  "\\end{table}"
)

writeLines(comp_tex, "output/tables/comparison_table.tex")
cat("Comparison table written to: output/tables/comparison_table.tex\n")

# Save result matrix for later use
saveRDS(result, "temp/result_matrix.rds")
