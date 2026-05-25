# =============================================================================
# preprocess.R
# Loads raw SIPP 1991 data, selects relevant variables, and writes a clean
# analysis-ready file to temp/
# =============================================================================

library(foreign)

# --- Paths (relative to repository root) -------------------------------------
input_path  <- "input/sipp1991.dta"
output_path <- "temp/clean_data.csv"

# --- Load --------------------------------------------------------------------
cat("Loading raw data...\n")
data <- read.dta(input_path)

# --- Select variables --------------------------------------------------------
# Outcome, treatment, and the 9 covariates used in Master.R
keep <- c("net_tfa", "e401",
          "age", "inc", "educ", "fsize", "marr",
          "twoearn", "db", "pira", "hown")

data <- data[, keep]

# --- Write to temp/ ----------------------------------------------------------
write.csv(data, output_path, row.names = FALSE)

# --- Summary -----------------------------------------------------------------
cat("\n========================================\n")
cat("Preprocessing complete\n")
cat("========================================\n")
cat(sprintf("Observations:         %d\n",   nrow(data)))
cat(sprintf("Variables kept:       %d\n",   ncol(data)))
cat(sprintf("Mean net_tfa:         $%.2f\n", mean(data$net_tfa)))
cat(sprintf("Std dev net_tfa:      $%.2f\n", sd(data$net_tfa)))
cat(sprintf("Share e401 eligible:  %.3f\n",  mean(data$e401)))
cat(sprintf("Output written to:    %s\n",    output_path))
cat("========================================\n")
