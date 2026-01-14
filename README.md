OLink Liver Proteomics Explorer: UK Biobank Analysis<p align="center"><img src="https://img.shields.io/badge/R-Shiny-blue?logo=r" alt="R Shiny"><img src="https://img.shields.io/badge/Data-UK%20Biobank-red" alt="UKBB"><img src="https://img.shields.io/badge/Field-Proteomics%20%26%20Genetics-green" alt="Proteomics"></p>
🧬 Overview
This Shiny application is an exploratory platform for investigating the relationship between ~3,000 Olink protein measurements and a wide range of liver-related clinical endpoints within the UK Biobank cohort.
The app is specifically designed to facilitate "triangulation" of evidence. By integrating genetic variants known to influence liver fat (Steatosis), users can compare observational associations with genetic effects to differentiate between simple correlations and potentially causal pathways.
🧪 Key Features
1. Exploratory AnalyticsComprehensive Statistics: Access regression data for ~3,000 proteins against endpoints including PDFF (Proton Density Fat Fraction), HCC (Hepatocellular Carcinoma), and Cirrhosis.Volcano Plots: Rapidly visualize high-impact proteins by plotting effect size ($\beta$) against statistical significance ($-log10(p)$).Interactive Tables: Search and filter all regression coefficients, standard errors, and p-values in real-time.
2. Genetic Integration & TriangulationThe app incorporates genotype data for key liver-fat associated variants to assist in causal inference:
  PNPLA3 (rs738409)
  TM6SF2 (rs58542926)
  HSD17B13 (rs72613567)
$\beta$-$\beta$ Plot Function: Compare the effect of a protein on a liver trait versus the genetic effect of these variants to identify consistent signals across observational and genetic data.
📈 Analysis ModulesModuleDescriptionAssociation TableA searchable summary of all Olink protein-trait associations.Volcano PlotVisualization of the proteomic landscape for a chosen endpoint.$\beta$-$\beta$ ComparisonPlotting observational effects against genetic instruments for triangulation.Variant FilteringAnalyze how associations behave when stratified by liver-fat risk alleles.📂 Data SourcesProteomics: Olink Explore 3072 panel (UK Biobank).Imaging: MRI-derived PDFF (Proton Density Fat Fraction).Clinical: ICD-10 coded cirrhosis and HCC data.Genetics: UK Biobank genetic release (selected liver-steatosis variants).🚀 How to Run LocallyTo run this app in your local R environment:Clone the repository:Bashgit clone https://github.com/YourUsername/Liver-Proteomics-Shiny.git
Install dependencies:Rinstall.packages(c("shiny", "ggplot2", "plotly", "dplyr", "DT"))
Launch:Rshiny::runApp()
📝 About the "Triangulation" ApproachThis app enables a "Genetic vs. Observational" check. If a protein is truly on the causal path to liver disease, we expect its observational association with the trait to align with the effects predicted by genetic variants like PNPLA3. This helps researchers prioritize proteins that are more likely to be therapeutic targets rather than just biomarkers of existing damage.

