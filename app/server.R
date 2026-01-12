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

# Server
server <- function(input, output, session) {
  
  #thematic::thematic_shiny()
  # Reactive value to store the clicked protein
  selected_protein <- reactiveVal(NULL)
  
  # UI Output for third exposure dropdown
  output$third_exposure_dropdown <- renderUI({
    req(input$add_exposure_button > 0)  # Show only if button clicked
    selectInput("third_exposure", "Choose an additional exposure for coloring:", choices = names(exposure_columns))
  })
  
  # Update selected_protein based on click event from scatter plot
  observeEvent(event_data("plotly_click"), {
    click_data <- event_data("plotly_click")
    if (!is.null(click_data)) {
      selected_protein(click_data$key)  # Store the clicked protein name
      print(paste("Selected protein:", click_data$key))  # Verify selection
    }
  })
  
  # Render the Beta vs Beta plot
  output$beta_vs_beta_plot <- renderPlotly({
    
    plot_data <- selected_data()
    plot_data_filtered <- plot_data %>% as.data.frame %>%
      filter(is_checked & primary_significant & 
               (if (input$hide_non_significant_secondary) secondary_significant else TRUE))
    # Assuming 'data' contains the two effect columns: 'primary_effect' and 'secondary_effect'
    
    # Fit a linear model to calculate R-squared
    if (nrow(plot_data_filtered)>1){
      good<-TRUE
      fit <- lm(strat_effect ~ effect, data = plot_data_filtered)
      r_squared <- summary(fit)$r.squared
    } else {
      good<-FALSE
    }
    
    y_label <- split_label(paste("-log10(p-value):", input$third_exposure))
    # Step 2: Get the maximum x and y values for placing the R^2 annotation in the upper right
    min_x <- min(plot_data$effect, na.rm = TRUE)
    max_y <- max(plot_data$strat_effect, na.rm = TRUE)
    
    # Check if third exposure is selected
    if (!is.null(input$third_exposure)) {
      third_pval <- exposure_columns[[input$third_exposure]]$pval
      plot_data <- plot_data %>%
        mutate(
          third_pval_col = -log10(.data[[third_pval]])
        )
    }
    b_b <- ggplot(plot_data) +
      geom_point(data= filter(plot_data, !is_checked),
                 aes(x = effect, y = strat_effect, text = hover_text, key = protein_name, alpha=transparency),
                 color = "grey")+
      geom_point(data=filter(plot_data, is_checked),
                 aes(x = effect, y = strat_effect, color =  if (!is.null(input$third_exposure)) third_pval_col, 
                     alpha = transparency, text = hover_text, key=protein_name),
                 shape=16)+
      geom_vline(xintercept = 0, color = "black", linetype = "dashed") +  # Vertical line at x=0
      geom_hline(yintercept = 0, color = "black", linetype = "dashed") +  # Horizontal line at y=0
      geom_smooth(data=plot_data_filtered,
                  aes(x = effect, y = strat_effect), method = "lm", color = "red", se = FALSE) +  # Regression line
      annotate("text", x = min_x * 1.1, y = max_y * 0.99, label = ifelse(good==TRUE,paste0("R² = ", round(r_squared, 3)),"Sample Size too low"), 
               hjust = 1.1, vjust = 1.1, size = 5, color = "red") +  # R-squared annotation
      scale_color_gradient(low="blue",high="red",na.value="grey") +
      scale_alpha_identity() +
      labs(
        x = paste("Effect Size for", input$regression_type),
        y = paste("Effect Size for", input$stratify_type),
        color = if (!is.null(input$third_exposure)) y_label else "No additional coloring"
      ) +
      theme_minimal()
    ggplotly(b_b, tooltip = "text") %>%
      layout(hoverlabel = list(align = "left", font = list(size = 10)))
  })
  
  # Helper function to split text into lines if it exceeds a character limit
  split_label <- function(text, max_length = 20) {
    words <- unlist(strsplit(text, " ")) # Split text by spaces
    current_line <- ""
    lines <- c()
    
    for (word in words) {
      # Add the word to the current line if it doesn't exceed the max length
      if (nchar(current_line) + nchar(word) + 1 <= max_length) {
        current_line <- paste(current_line, word)
      } else {
        # Otherwise, add the current line to lines, and start a new line
        lines <- c(lines, current_line)
        current_line <- word
      }
    }
    # Add the last line if there's any remaining text
    lines <- c(lines, current_line)
    # Join lines with newline characters
    paste(lines, collapse = "\n")
  }
  # Plot with updated transparency based on search term
  output$scatter_plot <- renderPlotly({
    plot_data <- selected_data()
    y_label <- split_label(paste("-log10(p-value):", input$stratify_type))
    p <- ggplot(plot_data) +
      geom_point(
        data = filter(plot_data, !is_checked),
        aes(x = effect, y = neg_log_pval, text = hover_text, key = protein_name, alpha= transparency),
        color = "grey"
      ) +
      geom_point(
        data = filter(plot_data, is_checked),
        aes(x = effect, y = neg_log_pval, color = strat_neg_log_pval, 
            alpha = transparency, text = hover_text, key=protein_name),
        shape = 16
      ) +
      scale_color_gradient(low = "blue", high = "red", na.value = "grey") +
      scale_alpha_identity() +
      labs(
        x = "Effect Size",
        y = "-log10(p-value)",
        color = y_label
      ) +
      theme_minimal()
    
    ggplotly(p, tooltip = "text") %>%
      layout(hoverlabel = list(align = "left", font = list(size = 10)))
  })
  # Render the bar plot for cell type expression
  output$cell_type_barplot <- renderPlotly({
    req(input$show_expression_data)   # Only render if checkbox is checked
    req(selected_protein())             # Only render if a protein is selected
    
    # Get the selected protein name
    protein <- selected_protein()
    print(paste("Rendering bar plot for:", protein))  # Debug statement
    
    # Check if protein data is available
    if (!is.null(protein) && protein %in% colnames(cell_type_data)) {
      # Prepare data for the bar chart
      
      bar_data <- data.frame(
        CellType = cell_type_data$celltype,
        Expression = cell_type_data[[protein]]
      )
      # Render the bar chart
      plot_ly(
        data = bar_data,
        x = ~CellType,
        y = ~Expression,
        type = "bar",
        marker = list(color = "steelblue", line = list(color = "black", width = 1))
      ) %>%
        layout(
          title = paste("Expression Levels of", protein),
          xaxis = list(title = "Cell Type", font=list(size=25)),
          yaxis = list(title = "Expression Level"),
          margin = list(b = 100)  # Add margin for x-axis labels if rotated
        )
    } else {
      # Display message if protein data is unavailable
      plot_ly() %>%
        layout(
          title = "Information not available",
          xaxis = list(visible = FALSE),
          yaxis = list(visible = FALSE)
        )
    }
  })
  
  # JavaScript to capture the search term from the DT search box and send it to Shiny
  output$protein_table <- renderDT({
    datatable(
      selected_data() %>%
        filter(if (input$protein_search != "") grepl(input$protein_search, protein_name, ignore.case = TRUE) else TRUE) %>%
        dplyr::select(
          protein_name,
          round_effect,
          round_pval,
          round_strat_effect,
          round_strat_pval,
          Expression_Category,
          level,
          Liver
        ) %>%
        arrange(round_pval, round_strat_pval),
      options = list(
        pageLength = 10,
        autoWidth = FALSE,
        columnsDefs = list(list(width = '400px', targets = '_all')),
        searching = FALSE
      ),
      colnames = c(
        "Protein Name",
        paste(input$regression_type, "effect", sep=" "),
        paste(input$regression_type, "p-value", sep=" "),
        paste(input$stratify_type, "effect", sep=" "),
        paste(input$stratify_type, "p-value", sep=" "),
        "Expression Category",
        "Expression Level",
        "Liver (TPM)"
      ),
      rownames = FALSE
    )
  })
  
  # Update the checkbox label dynamically
  observe({
    updateCheckboxInput(
      session,
      "hide_non_significant_secondary",
      label = paste("Hide Non-Significant Proteins of", input$stratify_type)
    )
  })
  output$main_panel_title <- renderText({
    paste("Protein Association with", input$regression_type, "Stratified by", input$stratify_type, "Significance")
  })
  
  # Calculate the Bonferroni-adjusted 
  adjusted_threshold <- reactive({
    threshold <- input$pvalue_threshold
    if (input$apply_bonferroni) {
      threshold / nrow(protein_data)  # Bonferroni correction
    } else {
      threshold
    }
  })
  
  # Reactive expression to filter data based on selected regression type
  selected_data <- reactive({
    req(input$regression_type, input$stratify_type)
    if (input$inverse_rn) {
      chosen_data<-protein_data_inv
    } else {
      chosen_data<-protein_data
      #      chosen_data$mri_p<-protein_data_inv$mri_p
      #      chosen_data$ct_p<-protein_data_inv$ct_p
      #      chosen_data$p.value_hcc<-protein_data_inv$p.value_hcc
      #      chosen_data$p.value_cirr<-protein_data_inv$p.value_cirr
      #      chosen_data$p.value_pnpla3<-protein_data_inv$p.value_pnpla3
      #      chosen_data$p.value_tm6sf2<-protein_data_inv$p.value_tm6sf2
      #      chosen_data$p.value_hsd17b13<-protein_data_inv$p.value_hsd17b13
      #      chosen_data$p.value_bmi<-protein_data_inv$p.value_bmi
      #      chosen_data$p.value_alc<-protein_data_inv$p.value_alc
    }
    
    primary_effect <- exposure_columns[[input$regression_type]]$effect
    primary_pval <- exposure_columns[[input$regression_type]]$pval
    
    secondary_effect <- exposure_columns[[input$stratify_type]]$effect
    secondary_pval <- exposure_columns[[input$stratify_type]]$pval
    
    
    all_categories_selected<-length(c(input$expression_category,"Not available")) == length(unique(protein_data$Expression_Category))
    all_levels_selected<-length(c(input$expression_level, "Not available")) == length(unique(protein_data$level))
    all_enriched_selected<-length(c(input$cell_expression,NA)) == length(unique(protein_data$enriched))
    
    chosen_data %>%
      mutate(
        effect = .data[[primary_effect]],
        round_effect = round(.data[[primary_effect]], 4),
        pval = .data[[primary_pval]],
        round_pval = as.numeric(format(signif(.data[[primary_pval]], digits = 4), nsmall = 4)),
        strat_effect = .data[[secondary_effect]],
        round_strat_effect = round(.data[[secondary_effect]], 4),
        strat_pval = .data[[secondary_pval]],
        round_strat_pval = as.numeric(format(signif(.data[[secondary_pval]], digits = 4), nsmall = 4)),
        neg_log_pval = -log10(pval),
        strat_neg_log_pval = -log10(strat_pval),
        primary_significant = neg_log_pval >= -log10(adjusted_threshold()),
        secondary_significant = strat_neg_log_pval >= -log10(adjusted_threshold()),
        is_checked = (all_categories_selected | Expression_Category %in% input$expression_category) &
          (all_levels_selected | level %in% input$expression_level) &
          (all_enriched_selected | enriched %in% input$cell_expression),
        transparency = case_when(
          !primary_significant ~ 0.03,
          input$hide_non_significant_secondary & !secondary_significant ~ 0.03,
          input$protein_search != "" & !grepl(input$protein_search, protein_name, ignore.case = TRUE) ~ 0.03,
          TRUE ~ 1
        ),
        hover_text = paste(
          "Protein:", protein_name,
          "<br>", input$regression_type, "-log10(p-value):", round(neg_log_pval, 2),
          "<br>", input$stratify_type, "-log10(p-value):", round(strat_neg_log_pval, 2),
          "<br>Specificity:", Expression_Category,
          "<br>Expression Level:", level,
          "<br>Liver Expression (TPM):", round(Liver, 2),
          "<br>Description:", ifelse(nchar(gene_description) > 350,
                                     paste0(substr(gene_description, 1, 350), "..."),
                                     gene_description)
        )
      )
  })
  dl_data<-reactive({ 
    selected_data() %>%
      select(.,c("protein_name","effect","pval","strat_effect","strat_pval","Expression_Category","level","Liver"))
  })
  output$downloadData <- downloadHandler(
    
    filename = function() {
      paste("proteomics_sumstats_", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(dl_data(), file, row.names = FALSE, quote=FALSE)
    }
  )
  
}