# LiverLink Proteomics Explorer: UK Biobank Analysis

<p align="center">
  <img src="https://img.shields.io/badge/R-Shiny-blue?logo=r" alt="R Shiny">
  <img src="https://img.shields.io/badge/Data-UK%20Biobank-red" alt="UKBB">
  <img src="https://img.shields.io/badge/Field-Proteomics%20%26%20Genetics-green" alt="Proteomics">
  <img src="https://img.shields.io/badge/Platform-Olink%20Explore-orange" alt="Olink">
</p>

## 📋 Overview
This **R Shiny** application is an interactive exploratory platform designed to analyze the intersection of **~3,000 Olink protein measurements** and **liver-related clinical endpoints** within the UK Biobank (UKBB).

The application allows researchers to move beyond simple observational associations by incorporating genetic variants (SNPs) known to be strongly associated with liver fat and steatosis. This enables a **triangulation** approach to help distinguish between proteins that are mere biomarkers of disease and those that may be on the causal pathway.



---

## 🧪 Key Features

### 📊 Exploratory Analytics
* **Volcano Plots:** Visualize the global proteomic landscape for endpoints like **PDFF** (Proton Density Fat Fraction), **HCC**, and **Cirrhosis**. Instantly identify proteins with high effect sizes ($\beta$) and statistical significance.
* **Interactive Regression Tables:** A searchable, sortable database of regression statistics for all 3,000 proteins, including effect sizes, standard errors, and p-values.
* **Custom Filtering:** Filter results by specific Olink panels or clinical subgroups.

### 🧬 Genetic Triangulation
The app integrates genotype data for key genetic "instruments" for liver fat:
* **PNPLA3** (rs738409)
* **TM6SF2** (rs58542926)
* **HSD17B13** (rs72613567)

**$\beta$-$\beta$ Plot Mode:** This feature allows users to plot the observational protein-trait effect against the genetic-protein effect. Aligning these effects provides evidence for potential causality, similar to the logic used in Mendelian Randomization.



---

## 📈 Clinical Endpoints & Variants
The app contains pre-computed associations for:
* **Imaging:** MRI-derived PDFF (Proton Density Fat Fraction).
* **Pathology:** Cirrhosis (ICD-10) and Hepatocellular Carcinoma (HCC).
* **Genetics:** Focus on variants in *PNPLA3*, *TM6SF2*, and *HSD17B13*.

---

## 📂 File Structure
* `app.R`: The core Shiny application code (UI and Server).
* `/data/`: Contains the pre-computed regression results and genetic association files.
* `/www/`: UI assets (images/custom CSS).

---

## 🚀 Getting Started

### Prerequisites
You will need **R** installed and the following libraries:
```r
install.packages(c("shiny", "tidyverse", "plotly", "DT", "data.table"))
