library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)
library(readr)
library(stringr)
library(DT)

# reformat date to have four digit year, followed by month, and day, without separators

custom_date <- function() {
  today <- Sys.Date()
  return(format(today, format = "%Y%m%d"))
}

# User interface definition
# Start of 80s and end of 80s are the area of the monosome
# Max fraction lets you exclude values at the end of the curve if the profile shows instability - which often is the case

ui <- fluidPage(
  titlePanel("Interactive Polysome Profile Analyser"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("csv_file", "Upload CSV File", accept = ".csv"),
      textInput("out_dir", "Plots Output Directory", value = ""),
      numericInput("baseline", "Baseline", value = 0.16, step = 0.01),
      numericInput("start_80s", "Start of 80S", value = 1.1, step = 0.05),
      numericInput("end_80s", "End of 80S", value = 2, step = 0.05),
      numericInput("max_fraction", "Max Fraction", value = 4.5, step = 0.1),
      numericInput("ymin", "Y Axis Min", value = 0),
      numericInput("ymax", "Y Axis Max", value = 2, step = 0.2),
      selectInput("x_axis_type", "X Axis Type", choices = c("Volume", "Fraction Number"), selected = "Volume"),
      actionButton("calc_auc", "Calculate AUC"),
      actionButton("save_plot", "Save Plot as PNG"),
      downloadButton("download_data", "Download Results CSV")
    ),
    
    mainPanel(
      plotlyOutput("abs_plot", height = "450px"),
      DTOutput("result_table")
    )
  )
)

server <- function(input, output, session) {
  rv <- reactiveValues(data = NULL, results = data.frame())
  
  observeEvent(input$csv_file, {
    req(input$csv_file)
    df <- read_csv(input$csv_file$datapath, col_names = TRUE, skip = 45)
    
    total_vol <- sum(as.numeric(df$`Fraction Volume(ml)`), na.rm = TRUE)
    step <- total_vol / nrow(df)
    df$cum_vol <- seq(step, total_vol, step)
    
    df$Fraction_Number_Label <- NA
    frac_counter <- 1
    for (i in seq_len(nrow(df))) {
      if (!is.na(df$`Fraction Number`[i])) frac_counter <- frac_counter + 1
      df$Fraction_Number_Label[i] <- frac_counter
    }
    
    file_base <- tools::file_path_sans_ext(basename(input$csv_file$name))
    sample_name <- str_replace(file_base, "^([0-9]{8})_", "\\1\n") %>% str_replace_all("_", " ")
    
    df$sample <- sample_name
    rv$data <- df
  })
  
  output$abs_plot <- renderPlotly({
    req(rv$data)
    df <- rv$data
    
    p <- ggplot(df, aes(x = cum_vol, y = Absorbance)) +
      geom_line(size = 1) + theme_bw() +
      scale_y_continuous(limits = c(input$ymin, input$ymax)) +
      geom_vline(xintercept = input$start_80s, linetype = "dashed", color = "darkblue") +
      geom_vline(xintercept = input$end_80s, linetype = "dashed", color = "darkblue") +
      geom_vline(xintercept = input$max_fraction, linetype = "dashed", color = "darkred") +
      geom_hline(yintercept = input$baseline, linetype = "dashed", color = "darkgreen") +
      labs(title = unique(df$sample), x = ifelse(input$x_axis_type == "Volume", "Volume", "Fraction Number"), y = "Absorbance") +
      theme(axis.title = element_text(size = 16), plot.title = element_text(size = 18, face = "bold", hjust = 0.5, margin = margin(b = 20)))
    
    if (input$x_axis_type == "Volume") {
      p <- p + scale_x_continuous(breaks = scales::pretty_breaks(n = 10))
    } else {
      uf <- df %>% filter(!duplicated(Fraction_Number_Label)) %>% select(cum_vol, Fraction_Number_Label)
      p <- p + scale_x_continuous(breaks = uf$cum_vol, labels = uf$Fraction_Number_Label)
    }
    
    ggplotly(p) %>% layout(margin = list(t = 100))
  })
  
  observeEvent(input$calc_auc, {
    req(rv$data)
    df <- rv$data %>% mutate(corrected_absorbance = Absorbance - input$baseline)
    
    subs <- sum(df$corrected_absorbance[df$cum_vol >= input$start_80s & df$cum_vol <= input$end_80s])
    polys <- sum(df$corrected_absorbance[df$cum_vol > input$end_80s & df$cum_vol <= input$max_fraction])
    
    new_row <- data.frame(
      Sample = unique(df$sample), Baseline = input$baseline,
      Start_80S = input$start_80s, End_80S = input$end_80s,
      Max_Fraction = input$max_fraction,
      Monosomes_AUC = subs, Polysomes_AUC = polys,
      Mono_Poly_ratio = subs / polys
    )
    rv$results <- bind_rows(rv$results, new_row)
  })
  
  observeEvent(input$save_plot, {
    req(rv$data)
    req(input$out_dir)
    df <- rv$data
    
    clean_dir <- gsub("\\\\", "/", input$out_dir)
    
    file_base <- tools::file_path_sans_ext(basename(input$csv_file$name))
    suffix <- if (input$x_axis_type == "Volume") "_vol" else "_FN"
    filename <- paste0(file_base, suffix, "_", custom_date(), ".png")
    fullpath <- file.path(clean_dir, filename)
    
    p_save <- ggplot(df, aes(x = cum_vol, y = Absorbance)) +
      geom_line(size = 1) + theme_bw() +
      scale_y_continuous(limits = c(input$ymin, input$ymax)) +
      geom_vline(xintercept = input$start_80s, linetype = "dashed", color = "darkblue") +
      geom_vline(xintercept = input$end_80s, linetype = "dashed", color = "darkblue") +
      geom_vline(xintercept = input$max_fraction, linetype = "dashed", color = "darkred") +
      geom_hline(yintercept = input$baseline, linetype = "dashed", color = "darkgreen") +
      labs(title = unique(df$sample), x = ifelse(input$x_axis_type == "Volume", "Volume", "Fraction Number"), y = "Absorbance")
    if (input$x_axis_type == "Volume") {
      p_save <- p_save + scale_x_continuous(breaks = scales::pretty_breaks(n = 10))
    } else {
      uf <- df %>% filter(!duplicated(Fraction_Number_Label)) %>% select(cum_vol, Fraction_Number_Label)
      p_save <- p_save + scale_x_continuous(breaks = uf$cum_vol, labels = uf$Fraction_Number_Label)
    }
    
    ggsave(fullpath, p_save, width = 8, height = 6, dpi = 300)
    message("Plot saved to: ", fullpath)
  })
  
  output$result_table <- renderDT({
    datatable(rv$results, options = list(pageLength = 25))
  })
  
  output$download_data <- downloadHandler(
    filename = function() paste0("polysome_results_", custom_date(), ".csv"),
    content = function(file) write.csv(rv$results, file, row.names = FALSE)
  )
}

shinyApp(ui, server)
