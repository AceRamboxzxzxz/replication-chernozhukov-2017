# write_tables.R
# Reconstructs result matrix from last DML run and writes both LaTeX tables.

ite    <- 10
methods <- c("RLasso","Trees","Forest","Boosting","Nnet","Ensemble")

result <- matrix(c(
  7602.625, 8583.182, 8757.014, 8769.868, 8792.446, 8970.030, 9047.916,
  1729.069, 1518.227, 1426.185, 1379.392, 1434.118, 1406.966, 1380.776,
  7634.194, 8826.262, 8735.950, 8755.809, 8783.703, 9017.286, 9053.890,
  1748.541, 1395.627, 1358.152, 1344.962, 1393.085, 1315.601, 1310.609
), nrow=4, byrow=TRUE)

colnames(result) <- c(methods, "best")
rownames(result) <- c("Mean ATE", "se", "Median ATE", "se")

dir.create("output/tables", showWarnings=FALSE, recursive=TRUE)

# --- Main result table -------------------------------------------------------
ensemble_col <- which(colnames(result) == "Ensemble")
mean_ate   <- result["Mean ATE", ensemble_col]
mean_se    <- result["se",       ensemble_col]
median_ate <- result["Median ATE", ensemble_col]
median_se  <- result["se",         ensemble_col]
ci_lo      <- mean_ate - 1.96 * mean_se
ci_hi      <- mean_ate + 1.96 * mean_se

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
writeLines(tex, "output/tables/main_result.tex")
cat("main_result.tex written\n")

# --- Comparison table --------------------------------------------------------
paper_mean <- c(RLasso=7718, Trees=8745, Forest=9180, Boosting=8768, Nnet=9040, Ensemble=9043)
paper_se   <- c(RLasso=1796, Trees=1488, Forest=1526, Boosting=1451, Nnet=1494, Ensemble=1432)

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
  paste(c("Mean ATE (\\$)", sprintf("$%.0f$", result["Mean ATE", methods])), collapse=" & ") |> paste0(" \\\\"),
  paste(c("", sprintf("($%.0f$)", result["se", methods])), collapse=" & ") |> paste0(" \\\\"),
  "\\hline",
  "\\multicolumn{7}{l}{\\textit{Chernozhukov et al.\\ (2017)}} \\\\",
  paste(c("Mean ATE (\\$)", sprintf("$%.0f$", paper_mean[methods])), collapse=" & ") |> paste0(" \\\\"),
  paste(c("", sprintf("($%.0f$)", paper_se[methods])), collapse=" & ") |> paste0(" \\\\"),
  "\\hline",
  sprintf("\\multicolumn{7}{l}{\\footnotesize Note: Standard errors in parentheses. Replication based on %d sample splits, 2-fold cross-fitting.} \\\\", ite),
  "\\multicolumn{7}{l}{\\footnotesize Paper values from Table 1, Panel B of the online appendix.} \\\\",
  "\\end{tabular}",
  "\\label{tab:comparison}",
  "\\end{table}"
)
writeLines(comp_tex, "output/tables/comparison_table.tex")
cat("comparison_table.tex written\n")
