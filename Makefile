.PHONY: all clean

all: paper/paper.pdf

# Preprocessing
temp/clean_data.csv: input/sipp1991.dta code/preprocess.R
	Rscript code/preprocess.R

# Analysis
output/tables/main_result.tex: temp/clean_data.csv code/analysis.R input/ML_Functions.R input/Moment_Functions.R
	Rscript code/analysis.R

# Paper
paper/paper.pdf: paper/paper.tex output/tables/main_result.tex
	cd paper && pdflatex paper.tex && pdflatex paper.tex

clean:
	rm -f temp/*.csv output/tables/*.tex paper/paper.pdf paper/paper.aux paper/paper.log paper/paper.out
