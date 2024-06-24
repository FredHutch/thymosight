#renv::init()
#renv::status()
#renv::snapshot()
#renv::restore()

#if (!require("pacman")) install.packages("pacman")
#pacman::p_load(anndata, ggplot2, hrbrthemes, reticulate, shiny, shinydashboard)
#anndata::install_anndata()

# loading of necessary libraries
library(feather)
library(anndata)
library(dichromat)
library(dplyr)
library(scattermore)
library(DT)
library(ggplot2)
library(ggpubr)
library(shiny)
library(shinycssloaders)
library(shinydashboard)
library(shinyWidgets)
library(reticulate)
library(tibble)
library(viridis)
library(hrbrthemes)
library(Matrix)
library(sccore)
library(RColorBrewer)
require(pals)

hrbrthemes::import_roboto_condensed()

if (Sys.info()["sysname"] == "Linux" && !interactive()) {
  Sys.setenv(RETICULATE_PYTHON="/usr/local/bin/python3.8")
  use_python("/usr/local/bin/python3.8")  
} else {
  Sys.setenv(RETICULATE_PYTHON=".venv/bin/python")

}
sc <- import("scanpy")

setAs("dgRMatrix", to = "dgCMatrix", function(from){
  as(as(from, "CsparseMatrix"), "dgCMatrix")
})

user_defined_palette =  c('#3283FE', '#16FF32', '#F6222E',  '#FEAF16', '#BDCDFF', '#3B00FB', '#1CFFCE', '#C075A6', '#F8A19F', '#B5EFB5', '#FBE426', '#C4451C', '#2ED9FF', '#c1c119', '#8b0000', '#FE00FA', '#1CBE4F', '#1C8356', '#0e452b', '#AA0DFE', '#B5EFB5', '#325A9B', '#90AD1C')
thymosight_cd45neg_TOTAL_mouse <- anndata::read_h5ad(paste0('data/mouse/thymosight_cd45neg_TOTAL_mouse.h5ad'))

thymosight_cd45neg_TOTAL_human <- anndata::read_h5ad(paste0('data/human/thymosight_cd45neg_TOTAL_human.h5ad'))

public_signatures <- readxl::read_excel("data/public_signatures.xlsx", sheet='Sheet2')
public_signatures_metadata <- readxl::read_excel("data/public_signatures.xlsx", sheet='Sheet3')

# if (!requireNamespace("remotes", quietly = TRUE)) {install.packages("remotes")}

addResourcePath("/assets", file.path(getwd(), "www"))

# Shiny app: ui component
ui <- dashboardPage(skin="black",
        dashboardHeader(title=tags$div(tags$h3(HTML(paste(tags$span(style="color: #222d32 ", "Thymo"), tags$span(style="color: #FF465D", "Sight"), sep = ""))))),
        dashboardSidebar(
          tags$script('document.title = "ThymoSight";', language="javascript"),
          sidebarMenu(
            menuItem("The thymus gland", tabName = "theThymusGland"),
            menuItem(" ThymoSight", tabName = "database", badgeLabel = "AN OVERVIEW", badgeColor = "black", selected = TRUE, icon=icon("database")),# ),
            menuItem("Explore the data", tabName = "dataBrowser", icon=icon("coffee")))),
        dashboardBody(tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "/assets/custom.css")),
          tabItems(
            tabItem(tabName="theThymusGland",	titlePanel("Summary"),
              fluidPage(
                fluidRow(column(11, h2(""), tags$div(class="header", checked=NA, align="justify", tags$p("The thymus is essential for establishing adaptive immunity yet undergoes age-related involution that leads to compromised immune responsiveness. The thymus is also extremely sensitive to acute insult and although capable of regeneration, this capacity declines with age for unknown reasons. We applied single-cell and spatial transcriptomics, lineage-tracing and advanced imaging to define age-related changes in non-hematopoietic stromal cells and discovered the emergence of two atypical thymic epithelial cell (TEC) states. These age-associated (aa)TECs formed high-density peri-medullary epithelial clusters that were devoid of thymocytes; an accretion of non-productive thymic tissue that worsened with age, exhibited features of epithelial-to-mesenchymal transition (EMT), and was associated with downregulation of FOXN1. Interaction analysis revealed that the emergence of aaTEC drew tonic signals from other functional TEC populations at baseline acting as a sink for TEC growth factors. Following acute injury, aaTEC expanded substantially, further perturbing trophic regeneration pathways and correlating with defective repair of the involuted thymus. These findings therefore define a unique feature of thymic involution linked to immune aging and could have implications for developing immune boosting therapies in older individuals.", style = "font-size:13pt")))),
                tags$br(),
                fluidRow(column(1),
                  column(5, tags$img(src = "/assets/mouse-thymus-sketch.jpg", width = "350px")),
                  column(5, tags$img(src = "/assets/human-thymus-sketch.jpg", width = "400px"))))),
            tabItem(tabName="database",	titlePanel("Single cell sequencing dataset collection of the mouse and human thymus"),
              fluidPage(
                tags$style("@import url(https://use.fontawesome.com/releases/v6.2.0/css/all.css);"),
                tags$style('.container-fluid { background-color: #FFFFFF;}'),
                tags$style(".small-box.bg-light-blue { background-color: #ff616d !important; color: #FFFFFF !important;}"),
                tags$br(),
                tags$br(),
                fluidPage(
                  fluidRow(
                    column(5, h3("ThymoSight all mouse", align='center'), tags$img(src = "/assets/thymosight_cd45neg_TOTAL_mouse_publication.png", width = "450px")),
                    column(1),
                    column(5,  h3("ThymoSight all human",  align='center'), tags$img(src = "/assets/thymosight_cd45neg_TOTAL_human_publication.png", width = "450px"))),
                  fluidRow(column(11, h2(""), tags$div(class="header", checked=NA, align="justify", tags$p("For a detailed description of the publicly available single cell sequencing datasets included in ThymoSight go to www.thymosight.github.com. For the data preprocessing steps and integration analyis see the Jupyter notebook here.", style = "font-size:11pt")))),
                  tags$br(),
                  tags$br(),
                  
                  # tabset panel for MOUSE metadata
                  tabsetPanel(
                    tabPanel("Mouse",
                      tags$br(),
                      valueBoxOutput("nsubsetsBox-mouse",  width = 2),
                      valueBoxOutput("nagesBox-mouse",  width = 2),
                      valueBoxOutput("ngenotypeBox-mouse",  width = 2),
                      valueBoxOutput("nsortedcellBox-mouse",  width = 2),
                      valueBoxOutput("ntreatmentBox-mouse", width = 2),
                      valueBoxOutput("ncellsBox-mouse",  width = 2),
                      fluidRow(column(12, tags$style("@import url(https://use.fontawesome.com/releases/v6.2.0/css/all.css);"),
                        dropdownButton(
                          selectInput(inputId = 'barplot-c-mouse',
                                      label = 'Annotate by',
                                      choices = colnames(thymosight_cd45neg_TOTAL_mouse$obs),
                                      selected = 'dataset'),
                                      circle = FALSE, status = "danger",
                                      icon = icon("paint-roller"),width = "250px",
                                      tooltip = tooltipOptions(title = "Click to change coloured variable [subset, age, treatment, genotype...]")
                          )
                        )
                      ),
                      
                      fluidRow(
                        column(12, h3("Number of single cells per selected annotation (x-axis)", align='center'), 
                          plotOutput("barplot-mouse"))),
                      
                      fluidRow(
                        column(5), 
                        column(2,
                          pickerInput(inputId = 'barplot-x-mouse',
                                      label = '',
                                      choices = colnames(thymosight_cd45neg_TOTAL_mouse$obs),
                                      selected = 'cell_type_subset',
                                      options = list(`style` = "btn-danger")))
                      ),
                      tags$hr(),
                      tags$br(),
                      fluidRow(
                        column(12, h3("Overview table with per cell annotation", align='center'), 
                          DTOutput('tbl_db_mouse'))
                        )
                    ),
                    
                    # tabset panel for HUMAN metadata
                    tabPanel("Human",tags$br(),
                      valueBoxOutput("nsubsetsBox-human",  width = 2),
                      valueBoxOutput("nagesBox-human",  width = 2),
                      valueBoxOutput("ngenotypeBox-human",  width = 2),
                      valueBoxOutput("nsortedcellBox-human",  width = 2),
                      valueBoxOutput("ntreatmentBox-human", width = 2),
                      valueBoxOutput("ncellsBox-human",  width = 2),
                      fluidRow(
                        column(12,  
                          tags$style("@import url(https://use.fontawesome.com/releases/v6.2.0/css/all.css);"),
                          dropdownButton(
                            selectInput(inputId = 'barplot-c-human',
                                        label = 'Annotate by',
                                        choices = colnames(thymosight_cd45neg_TOTAL_human$obs),
                                        selected = 'dataset'),
                                        circle = FALSE, status = "danger",
                                        icon = icon("paint-roller"),width = "250px",
                                        tooltip = tooltipOptions(title = "Click to change coloured variable [subset, age, treatment, genotype...]")
                          )
                        )
                      ),
                      fluidRow(
                        column(12, h3("Number of single cells per selected annotation (x-axis)", align='center'), 
                          plotOutput("barplot-human"))),
                      fluidRow(
                        column(5), 
                        column(2,
                          pickerInput(inputId = 'barplot-x-human',
                            label = '',
                            choices = colnames(thymosight_cd45neg_TOTAL_human$obs),
                            selected = 'cell_type_subset',
                            options = list(`style` = "btn-danger")))
                      ),
                      tags$hr(),
                      tags$br(),
                      fluidRow(
                        column(12, h3("Overview table with per cell annotation", align='center'), 
                          DTOutput('tbl_db_human'))))
                  )
                )
              )
            ), 
            
            tabItem(tabName="dataBrowser",	titlePanel("Explore the web-based ThymoSight interface"),
              fluidPage(
                tags$style('.container-fluid { background-color: #FFFFFF;}'),
                tags$style("@import url(https://use.fontawesome.com/releases/v6.2.0/css/all.css);"),
                tags$br(),
                
                tabsetPanel(
                tabPanel("Mouse",tags$br(),
              
                fluidRow(
                  column(12, pickerInput("dataset_mouse", "Choose dataset(s)", multiple=FALSE, selected = 'thymosight_cd45neg_TOTAL_mouse.h5ad', choices = list.files("data/mouse/", pattern = '.h5ad')))
                  ),
                fluidRow(
                  column(3, h3('Available metadata'),
                    radioButtons( inputId = 'annotation_mouse',
                                  label = 'Annotate by:',
                                  choices = colnames(thymosight_cd45neg_TOTAL_mouse$obs),
                                  selected = 'tissue')),
                  column(9, plotOutput("umap_mouse") %>% withSpinner(color="#FF465D"))
                ),
                  
                fluidRow(
                  column(3,
                    tags$br(),
                    tags$br(),
                    h3("Check expression of your favourite genes"),
                    selectizeInput('geneInput_mouse', 
                                        label = 'Choose gene :', 
                                        choices = NULL,
                                        multiple = T, options = list(create = TRUE))),
                  column(9, plotOutput("dotplot_mouse") %>% withSpinner(color="#FF465D"))
                )
              ),

              tabPanel("Human",tags$br(),
                fluidRow(
                  column(12, pickerInput("dataset_human", "Choose dataset(s)", multiple=FALSE, selected = 'thymosight_cd45neg_TOTAL_human.h5ad', choices = list.files("data/human/", pattern = '.h5ad')))
                ),
                fluidRow(
                  column(3, 
                    h3('Available metadata'),
                    radioButtons( inputId = 'annotation_human',
                                  label = 'Annotate by:',
                                  choices = colnames(thymosight_cd45neg_TOTAL_human$obs),
                                  selected = 'tissue')),
                  column(9, plotOutput("umap_human") %>% withSpinner(color="#FF465D"))
                ),
                fluidRow(
                  column(3, 
                    tags$br(),
                    tags$br(),
                    h3("Check expression of your favourite genes"),
                    selectizeInput('geneInput_human', 
                                        label = 'Choose gene :', 
                                        choices = NULL,
                                        multiple = T, options = list(create = TRUE))),
                  column(9, plotOutput("dotplot_human") %>% withSpinner(color="#FF465D"))
                )

              )
            )
          )
        )
      )
    )
  )

# Shiny app: server component
server <- function(input, output, session) {
  # options(shiny.maxRequestSize=30*1024^2)
  sc <- import("scanpy")
  
  # read in MOUSE adata on the server side
  thymosight_cd45neg_TOTAL_mouse = thymosight_cd45neg_TOTAL_mouse
  thymosight_cd45neg_TOTAL_mouse_obs = thymosight_cd45neg_TOTAL_mouse$obs
  updateSelectizeInput(session, 'geneInput_mouse', choices = rownames(thymosight_cd45neg_TOTAL_mouse$var), 
                       selected = c('Epcam', 'Pdgfra', 'Pecam1', 'Nkain4', 'Acta2', 'S100b'), server = TRUE)
  
  # read in HUMAN adata on the server side
  thymosight_cd45neg_TOTAL_human = thymosight_cd45neg_TOTAL_human
  thymosight_cd45neg_TOTAL_human_obs = thymosight_cd45neg_TOTAL_human$obs
  updateSelectizeInput(session, 'geneInput_human', choices = rownames(thymosight_cd45neg_TOTAL_human$var), 
                       selected = c('EPCAM', 'PDGFRA', 'PECAM1', 'NKAIN4', 'ACTA2', 'S100B'), server = TRUE)
  
  
  # reactive database table for MOUSE data (all+filtered)
  output$tbl_db_mouse = renderDT(
    tibble(thymosight_cd45neg_TOTAL_mouse_obs)[,c(1:10)], filter='top', options = list(lengthChange = FALSE)
  )
  tbl_db_mouse_filtered <- reactive({
    req(input$tbl_db_mouse_rows_all)
    tibble(thymosight_cd45neg_TOTAL_mouse_obs)[,c(1:10)][input$tbl_db_mouse_rows_all, ]  
  })
  
  # reactive database table for HUMAN data
  output$tbl_db_human = renderDT(
    tibble(thymosight_cd45neg_TOTAL_human_obs)[,c(1:9)], filter='top', options = list(lengthChange = FALSE)
  )
  tbl_db_human_filtered <- reactive({
    req(input$tbl_db_human_rows_all)
    tibble(thymosight_cd45neg_TOTAL_human_obs)[,c(1:9)][input$tbl_db_human_rows_all, ]  
  })
  
  # value boxes for MOUSE
  output$`nsubsetsBox-mouse` <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_mouse_filtered()$cell_type_subset))), "subsets",  
      icon = icon('shapes', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  output$`nagesBox-mouse` <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_mouse_filtered()$age_range))), "age-ranges", 
      icon = icon('person-cane', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$`ngenotypeBox-mouse` <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_mouse_filtered()$genotype))), "genotypes", 
      icon = icon('mouse', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$`nsortedcellBox-mouse` <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_mouse_filtered()$sorted_cell))), "sorted-cells", 
      icon = icon('filter', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$`ntreatmentBox-mouse` <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_mouse_filtered()$treatment))), "treatments", 
      icon = icon('radiation', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$`ncellsBox-mouse` <- renderValueBox({
    valueBox(
      nrow(tibble(tbl_db_mouse_filtered())), "cells", 
      icon = icon('viruses', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  # value boxes for HUMAN
  output$`nsubsetsBox-human` <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_human_filtered()$cell_type_subset))), "subsets",  
      icon = icon('shapes', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$`nagesBox-human` <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_human_filtered()$age_range))), "age-ranges", 
      icon = icon('person-cane', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$`ngenotypeBox-human` <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_human_filtered()$gender))), "gender", 
      icon = icon('venus-mars', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$`nsortedcellBox-human` <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_human_filtered()$sorted_cell))), "sorted-cells", 
      icon = icon('filter', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$`ntreatmentBox-human` <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_human_filtered()$treatment))), "treatments", 
      icon = icon('radiation', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$`ncellsBox-human` <- renderValueBox({
    valueBox(
      nrow(tibble(tbl_db_human_filtered())), "cells", 
      icon = icon('viruses', class = NULL, lib = "font-awesome"), color = "light-blue")
  })  
  
  # barplot with MOUSE metadata
  output$`barplot-mouse` <- renderPlot({
    summary <- tbl_db_mouse_filtered() %>% group_by(.data[[input$`barplot-x-mouse`]], .data[[input$`barplot-c-mouse`]]) %>% summarise(n_cells = length(.data[[input$`barplot-c-mouse`]]))
    ggplot(summary, aes(fill=.data[[input$`barplot-c-mouse`]], y=n_cells, x=.data[[input$`barplot-x-mouse`]])) +
      geom_bar( colour='black', position="stack", stat="identity") + 
      scale_fill_manual(values = as.vector(polychrome(n=36))) +
      ylab("Number of cells\n") +  xlab("") + theme_pubr() +
      theme(axis.text.x = element_text(angle = 90, hjust=1, size = 15),
            axis.text.y = element_text(size = 15), legend.title = element_text(size = 15),
            legend.text = element_text(size = 15), axis.title = element_text(size = 19))
  })
  
  # barplot with HUMAN metadata
  output$`barplot-human` <- renderPlot({
    summary <- tbl_db_human_filtered() %>% group_by(.data[[input$`barplot-x-human`]], .data[[input$`barplot-c-human`]]) %>% summarise(n_cells = length(.data[[input$`barplot-c-human`]]))
    ggplot(summary, aes(fill=.data[[input$`barplot-c-human`]], y=n_cells, x=.data[[input$`barplot-x-human`]])) +
      geom_bar( colour='black', position="stack", stat="identity") + 
      scale_fill_manual(values = as.vector(polychrome(n=36))) +
      ylab("Number of cells\n") +  xlab("") + theme_pubr() +
      theme(axis.text.x = element_text(angle = 90, hjust=1, size = 15),
            axis.text.y = element_text(size = 15), legend.title = element_text(size = 15),
            legend.text = element_text(size = 15), axis.title = element_text(size = 19))
  })

  adata_mouse <- reactive({
    anndata::read_h5ad(paste0('data/mouse/', input$dataset_mouse))
    })
  
  observeEvent(input$annotation_mouse, { 
   # gene = input$annotation
    output$umap_mouse <- renderPlot({ 
      
    # annotation colors
    if (input$annotation_mouse == 'cell_type_subset'){
      palette = c('#f6222e', '#3283fe', 'beige', '#16ff32',  '#bdcdff', 'beige', '#aa0dfe', '#1cffce', 'grey', '#d62728',
                  '#2ED9FF', '#c1c119', '#8b0000', '#3B00FC', '#FE00FA',  '#1CBE4F', '#F8A19F', '#B5EFB5','#9195F6',   '#325A9B',
                  '#F9F07A', '#C075A6', '#7F27FF', '#FEAF16', 'black', '#BEFFF7', 'beige', '#FFA5D2', '#19c9b3', 'beige')}
    else if (input$annotation_mouse == 'sorted_cell'){
      palette = c('#16FF32', '#3283FE',  '#F6222E',  '#FEAF16', '#BDCDFF', '#3B00FB', '#1CFFCE', '#C075A6', '#F8A19F', '#B5EFB5',
                  '#FBE426', '#C4451C', '#2ED9FF', '#c1c119', '#8b0000', '#FE00FA', '#1CBE4F', '#1C8356', '#0e452b', '#AA0DFE',
                  '#B5EFB5', '#325A9B', '#90AD1C')}
    else {
      palette = user_defined_palette}
    
    # plot annotation umap
    sc$pl$umap(adata_mouse(), color=input$annotation_mouse,
               color_map='Spectral_r', 
               use_raw=FALSE,
               ncols=5,
               wspace = 0.75,
               outline_width=c(0.6, 0.05),
               size=7,
               palette=palette,
               frameon=FALSE,
               add_outline=TRUE,
               sort_order = TRUE)
  })
      
    
    adata_human <- reactive({
      anndata::read_h5ad(paste0('data/human/', input$dataset_human))
    })
    
    output$umap_human <- renderPlot({ 
      
      # annotation colors
      if (input$annotation_human == 'cell_type_subset'){
        palette = c('#f6222e', '#3283fe', 'beige', '#16ff32',  '#bdcdff', 'beige', '#aa0dfe', '#1cffce', 'grey', '#d62728',
                    '#2ED9FF', '#c1c119', '#8b0000', '#3B00FC', '#FE00FA',  '#1CBE4F', '#F8A19F', '#B5EFB5','#9195F6',   '#325A9B',
                    '#F9F07A', '#C075A6', '#7F27FF', '#FEAF16', 'black', '#BEFFF7', 'beige', '#FFA5D2', '#19c9b3', 'beige')}
      else if (input$annotation_human == 'sorted_cell'){
        palette = c('#16FF32', '#3283FE',  '#F6222E',  '#FEAF16', '#BDCDFF', '#3B00FB', '#1CFFCE', '#C075A6', '#F8A19F', '#B5EFB5',
                    '#FBE426', '#C4451C', '#2ED9FF', '#c1c119', '#8b0000', '#FE00FA', '#1CBE4F', '#1C8356', '#0e452b', '#AA0DFE',
                    '#B5EFB5', '#325A9B', '#90AD1C')}
      else {
        palette = user_defined_palette}
      
      # plot annotation umap
      sc$pl$umap(adata_human(), color=input$annotation_human,
                       color_map='Spectral_r', 
                       use_raw=FALSE,
                       ncols=5,
                       wspace = 0.75,
                       outline_width=c(0.6, 0.05),
                       size=7,
                       palette=palette,
                       frameon=FALSE,
                       add_outline=TRUE,
                       sort_order = TRUE)
    })
    
    output$dotplot_mouse <- renderPlot({
      sc$pl$dotplot(adata_mouse(), input$geneInput_mouse,
                    groupby = input$annotation_mouse,
                    cmap = 'Reds',
                    swap_axes = TRUE,
                    standard_scale='var')
      # arrange(p, ncol=1, padding=units(5, "line"), top="", bottom="", right="", left="")
    })
    
    output$dotplot_human <- renderPlot({
      sc$pl$dotplot(adata_human(), input$geneInput_human,
                   groupby = input$annotation_human,
                   cmap = 'Reds',
                   swap_axes = TRUE,
                   standard_scale='var')
    })
    
  })
}

options <- list()
if (!interactive()) {
  options$port = 3838
  options$launch.browser = FALSE
  options$host = "0.0.0.0"
  sessionInfo()  
}


shinyApp(ui, server, options = options)
