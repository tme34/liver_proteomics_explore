# Olink Liver Proteomics Explorer: UK Biobank Analysis

<p align="center">
  <img src="https://img.shields.io/badge/R-Shiny-blue?logo=r" alt="R Shiny">
  <img src="https://img.shields.io/badge/Data-UK%20Biobank-red" alt="UKBB">
  <img src="https://img.shields.io/badge/Expression-GTEx%20%26%20scRNA--seq-yellow" alt="Expression Data">
  <img src="https://img.shields.io/badge/Field-Proteomics%20%26%20Genetics-green" alt="Proteomics">
</p>

## 📋 Overview
This **R Shiny** application is an interactive exploratory platform designed to analyze the intersection of **~3,000 Olink protein measurements** and **liver-related clinical endpoints** within the UK Biobank (UKBB).

The application allows researchers to move beyond simple observational associations by incorporating genetic variants and **multiscale transcriptomic filters**. This enables a **triangulation** approach to identify proteins that are biologically localized to the liver and potentially causal in disease progression.



---

## 🧪 Key Features

### 🧫 Multiscale Biological Filtering (New)
To ensure biological relevance, the app allows users to filter proteins based on their expression profiles across different scales:

* **GTEx Bulk RNA-seq Integration:** Filter for **Liver-Specific** proteins. This ensures that the proteins being analyzed are predominantly expressed in liver tissue, reducing systemic noise.
* **Single-Cell RNA-seq Mapping:** Filter proteins by their highest-expressing cell type (e.g., Hepatocytes, Stellate Cells, Kupffer Cells). This helps pinpoint which specific cell niche is driving the proteomic signal observed in the blood.

### 🧬 Genetic Triangulation
The app integrates genotype data for key genetic instruments for liver fat:
* **PNPLA3** (rs738409), **TM6SF2** (rs58542926), and **HSD17B13** (rs72613567).
* **$\beta$-$\beta$ Plot Mode:** Compare observational protein-trait effects against genetic-protein effects to assess causality.



### 📊 Exploratory Analytics
* **Volcano Plots:** Rapidly visualize high-impact proteins for endpoints like **PDFF**, **HCC**, and **Cirrhosis**.
* **Interactive Tables:** Search and filter pre-computed regression statistics for all 3,000 proteins.

---

## 📈 Clinical Endpoints & Data Sources
* **Imaging:** MRI-derived PDFF (Proton Density Fat Fraction).
* **Clinical:** ICD-10 coded Cirrhosis and Hepatocellular Carcinoma (HCC).
* **Proteomics:** Olink Explore 3072 panel (UKBB).
* **Tissue Expression:** GTEx (v8) bulk RNA-seq and independent liver scRNA-seq datasets.

---

## 📂 File Structure
* `app.R`: Core Shiny application code.
* `/data/`: Pre-computed regression results, GTEx specificity indices, and scRNA-seq cell-type mappings.
* `/www/`: UI assets and custom styling.

---

## 🚀 Getting Started

### Prerequisites
```r
install.packages(c("shiny", "tidyverse", "plotly", "DT", "data.table"))
