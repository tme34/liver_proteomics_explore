library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)
library(DT)

# Sample data (for illustration purposes)
protein_data <- read.csv("proteomics_mri_ct1_dataset.csv")
exposure_columns <- list(
  "PDFF (MRI Scan)" = list(effect = "mri_beta", pval = "mri_p", se="mri_se"),
  "Liver iron corrected T1" = list(effect = "ct1_beta", pval = "ct_p", se="ct_se"),
  "Hepatocellular Carcinoma (HCC)" = list(effect = "estimate_hcc", pval = "p.value_hcc", se="se_hcc"),
  "Cirrhosis" = list(effect = "estimate_cirr", pval = "p.value_cirr", se = "se_cirr"),
  "BMI" = list(effect= "estimate_bmi", pval = "p.value_bmi", se = ""),
  "Alcohol" = list(effect= "estimate_alc", pval = "p.value_alc", se = ""),
  "PNPLA3 (rs738409)" = list(effect = "estimate_pnpla3", pval = "p.value_pnpla3", se="se_pnpla3"),
  "TM6SF2 (rs58542926)" = list(effect = "estimate_tm6sf2", pval = "p.value_tm6sf2", se="se_tm6sf2"),
  "HSD17B13 (rs72613567)" = list(effect = "estimate_hsd17b13", pval = "p.value_hsd17b13", se="se_hsd17b13")
)

protein_data_inv <-read.csv("proteomics_mri_ct1_dataset_inv.csv")

cell_type_data<-read.csv("average_protein_measurements_by_cell_type.csv")

# UI
ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "sandstone"),
  titlePanel("Olink Protein Regression Analysis"),
  sidebarLayout(
    sidebarPanel(width=3,
                 selectInput(
                   inputId = "regression_type",
                   label = "Choose a Variable (exposure)",
                   choices = names(exposure_columns)
                 ),
                 selectInput(
                   inputId = "stratify_type",
                   label = "Stratify by Secondary Regression Type",
                   choices = names(exposure_columns)
                 ),
                 sliderInput(
                   inputId = "pvalue_threshold",
                   label = "Set Significance Threshold (-log10 p-value)",
                   min = 0.001, max = 0.1, value = 0.05
                 ),
                 checkboxInput(
                   inputId = "apply_bonferroni",
                   label = "Apply Bonferroni Correction",
                   value = FALSE
                 ),
                 checkboxInput(
                   inputId = "hide_non_significant_secondary",
                   label = "Hide Non-Significant Proteins of Secondary Exposure",
                   value = FALSE
                 ),
                 
                 # Toggle buttons for Expression category and Level
                 checkboxGroupInput(
                   inputId = "expression_category",
                   label = "Filter by Expression Specificity",
                   choices = c("Broadly expressed", "Not expressed in liver", "Semi-specific", "Specific to liver"),
                   selected = c("Broadly expressed", "Not expressed in liver", "Semi-specific", "Specific to liver")
                 ),
                 checkboxGroupInput(
                   inputId = "expression_level",
                   label = "Filter by Hepatic Expression Level",
                   choices = c("high", "medium-high", "medium-low", "low", "not expressed"),
                   selected = c("high", "medium-high", "medium-low", "low", "not expressed")
                 ),
                 checkboxGroupInput(
                   inputId = "cell_expression",
                   label = "Filter by Cellular Expression",
                   choices = c("Hepatocyte-enriched", "Cholangiocyte-enriched", "Stellate cells-enriched", "EC-enriched", "Immune-enriched"),
                   selected = c("Hepatocyte-enriched", "Cholangiocyte-enriched", "Stellate cells-enriched", "EC-enriched", "Immune-enriched")
                 ),
                 textInput(
                   inputId = "protein_search",
                   label = "Search for Protein",
                   placeholder = "Enter protein name"
                 ),
                 # New toggle button for showing/hiding the bar chart
                 checkboxInput("show_expression_data", "Show Single Cell Expression Data", value = FALSE
                 ),
                 checkboxInput(
                   inputId = "inverse_rn",
                   label = "Inverse Rank Normalize exposure effects",
                   value = FALSE
                 ),
    ),
    
    mainPanel(width=9,
              h3(textOutput("main_panel_title")),
              tabsetPanel(
                id = "plot_tabs",
                tabPanel("Effect vs. p-value Plot",
                         div(
                           plotlyOutput("scatter_plot", height = "700px"),  # Increase height here
                           style = "width: 100%; height: 700px; padding: 10px;
                           margin-bottom: 20px;
                           border-color: rgba(223, 215, 202, 0.75); " # Add custom CSS for full width
                         ),
                         # Conditional bar chart output
                         br()
                ),
                tabPanel("Beta vs. Beta Plot",
                         div(
                           plotlyOutput("beta_vs_beta_plot", height = "700px"),  # Increase height here
                           style = "width: 100%; height: 700px; padding: 10px; 
                            margin-bottom: 20px;
                            border-color: rgba(223, 215, 202, 0.75); " # Add custom CSS for full width
                         ),
                         # "Add Exposure" button and conditional dropdown for third exposure
                         conditionalPanel(
                           condition = "input.plot_tabs == 'Beta vs. Beta Plot'",
                           actionButton("add_exposure_button", "Add Exposure"),
                           uiOutput("third_exposure_dropdown"),
                         ),
                         br()
                )),
              conditionalPanel(
                condition = "input.show_expression_data == true",
                plotlyOutput("cell_type_barplot", height = "500px")
              ),
              div(
                DTOutput("protein_table"),
                style="border: solid 2px black;
               padding: 15px 15px 15px 15px;
               border-radius: 5px;
               box-shadow: inline 2px 2px 4px black;
               background-color: rgba(0, 0, 0, 0.03);
               border-color: rgba(223, 215, 202, 0.75);"
              ),
              div(
                downloadButton("downloadData", "Download")
              )
    )
  ),
  hr(),
  tags$footer(
    tags$div(
      style = "width: 100%; display: flex; justify-content: space-between; align-items: center;",
      
      # Left-aligned text
      tags$span(
        HTML("Developed by Tim Møller Eyrich & <a href=\"https://scholar.google.com/citations?user=mtgbiKoAAAAJ&hl=da&oi=ao/\" target=\"_blank\">Stefan Stender</a>.")
      ),
      
      # Right-aligned text
      tags$span(
        HTML("Site built with <a href=\"https://shiny.posit.co/\" target=\"_blank\">Shiny</a> 1.9.1")
      )
    )
  ),
  br()
)