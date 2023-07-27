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

adata_TOTAL_meta <- arrow::read_feather('data/thymus CD45- TOTAL meta.txt')
adata_TOTAL_meta_tr <- t(adata_TOTAL_meta[,1:length(adata_TOTAL_meta)-1])
adata_TOTAL_meta <- as.data.frame(adata_TOTAL_meta_tr)
colnames(adata_TOTAL_meta) <- c("tissue", "sorted_cell", "cell_type_subset", "stage", "age", "gender", "genotype", "strain", "treatment", "DOI", "dataset")


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
            menuItem("The thymus gland", tabName = "theThymusGland", badgeLabel = "OVERVIEW", badgeColor = "black"),
            menuItem("Database", tabName = "database",  selected = TRUE, icon=icon("database")),# ),
            menuItem("Data browser", tabName = "dataBrowser", icon=icon("coffee")))),
        dashboardBody(tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "/assets/custom.css")),
          tabItems(
            tabItem(tabName="theThymusGland",	titlePanel("Overview and graphical abstract"),
              fluidPage(
                fluidRow(column(11, h2(""), tags$div(class="header", checked=NA, align="justify", tags$p("A diverse T cell repertoire is an important branch of adaptive immunity which is required to adequately mount response to pathogens, maintain immunosurveillance of cancer, and tissue health. T cell development is orchestrated in the thymus. Thymic functionality and, thus, thymopoiesis declines in a process termed age-related involution. Thymic output can also be transiently impaired due to acute injury. Yet, the thymus has a remarkable capacity for endogenous repair. Here we interrogated on a single-cell level the complex stromal network of thymic epithelial, endothelial and mesenchymal cells providing the microenvironment for T cell development. We encountered a previously underappreciated heterogeneity in cellular subpopulations. Aging induced compositional changes in the thymic stroma, including the emergence of new subpopulations. We demonstrate that epithelium, endothelium, and mesenchyme are differently impacted by hallmarks of aging. Age-dependent stromal compositional and subset-specific transcriptional changes contributed to attenuated regenerative response with aging. This data set will serve as a resource that can shed light on the involuted thymus status quo and how aging impacts organ function and tissue regeneration.", style = "font-size:13pt")))),
                tags$br(),
                fluidRow(column(1),
                  column(5, tags$img(src = "/assets/mouse-thymus-sketch.jpg", width = "350px")),
                  column(5, tags$img(src = "/assets/human-thymus-sketch.jpg", width = "400px"))))),
            tabItem(tabName="database",	titlePanel("Thymus single cell database"),
              fluidPage(
                tags$style("@import url(https://use.fontawesome.com/releases/v6.2.0/css/all.css);"),
                tags$style('.container-fluid { background-color: #FFFFFF;}'),
                tags$style(".small-box.bg-light-blue { background-color: #ff616d !important; color: #FFFFFF !important;}"),
                tags$br(),
                fluidRow(
                  valueBoxOutput("nsubsetsBox",  width = 2),
                  valueBoxOutput("nagesBox",  width = 2),
                  valueBoxOutput("ngenotypeBox",  width = 2),
                  valueBoxOutput("nstrainBox",  width = 2),
                  valueBoxOutput("ntreatmentBox", width = 2),
                  valueBoxOutput("ncellsBox",  width = 2)),
                tags$hr(),
                tags$br(),
                fluidPage(
                      fluidRow(column(12, 
                        tags$style("@import url(https://use.fontawesome.com/releases/v6.2.0/css/all.css);"),
                        dropdownButton(
                          selectInput(inputId = 'varColor',
                                      label = '',
                                      choices = colnames(adata_TOTAL_meta),
                                      selected = 'publication'),
                          circle = TRUE, status = "danger",
                          icon = icon("paint-roller"),width = "250px",
                          tooltip = tooltipOptions(title = "Click to change coloured variable [subset, age, treatment, genotype...]")
                        ),
                        tags$br(),
                        plotOutput("barplot"))),
                      fluidRow(column(5), 
                        column(2,
                          pickerInput(inputId = 'xaxis',
                            label = '',
                            choices = colnames(adata_TOTAL_meta),
                            selected = 'cell_type_subset',
                            options = list(`style` = "btn-danger")))
                      ),
                  ),
                  tags$hr(),
                  tags$br(),
                  fluidRow(DTOutput('tbl_db')))
            ),         
            tabItem(tabName="dataBrowser",	titlePanel("Explore the single cell thymus atlas"),
              fluidPage(
                tags$style('.container-fluid { background-color: #FFFFFF;}'),
                tags$style("@import url(https://use.fontawesome.com/releases/v6.2.0/css/all.css);"),
                tags$br(),
                sidebarLayout(
                  sidebarPanel(width = 4, h3("Datasets"),
                    pickerInput("dataset", "Choose dataset(s)", choices = list.files("data/", pattern = '.h5ad')), 
                    tags$hr(),
                    h3("Graphs"),
                    prettyRadioButtons(
                      inputId = "annotation", label = "", choices = c( "metadata", "gene", "signature"),
                      inline = TRUE, status = "danger", fill = TRUE),
                    conditionalPanel(
                      condition = "input.annotation == 'metadata'",
                        selectizeInput('groupingInput', label = 'Choose annotation :', choices = NULL,
                        multiple = F, options = list(create = TRUE))),
                    conditionalPanel(
                      condition = "input.annotation == 'gene'",
                      selectizeInput('geneInput', label = 'Choose gene :', choices = NULL, 
                      multiple = F, options = list(create = TRUE))),
                    conditionalPanel(
                      condition = "input.annotation == 'signature'",
                      pickerInput(inputId = "signature", label = "Choose signature :", 
                      choices = colnames(public_signatures),
                      choicesOpt = list(subtext = paste(public_signatures_metadata$author, "", sep = "")))),
                    tags$br(),
                    actionBttn(inputId = "update_browser", label = "Launch", style = "pill", color = "danger"),
                  ),
                  mainPanel(width = 8,
                    dropdownButton(
                      radioGroupButtons(inputId = "cellSize", label = "Adjust cell size", selected = 1,
                        choices = c(1,2,3,4,5), justified = TRUE),
                        circle = TRUE, status = "danger", icon = icon("paint-roller"), width = "250px",
                        tooltip = tooltipOptions(title = "Click to change size of points on graph")),           
                  tags$br(),
                  fluidRow(column(12,plotOutput("umap") %>% withSpinner(color="#FF465D")))),
                  position='right'
                ),
                fluidRow(column=12, DTOutput('tbl_br'))
              )
            )
          )
        )
      )

# Shiny app: server component
server <- function(input, output, session) {
  # options(shiny.maxRequestSize=30*1024^2)
  adata_TOTAL_obs_tmp = adata_TOTAL_meta
  
  output$tbl_db = renderDT(
    tibble(adata_TOTAL_obs_tmp)[,c(11, 1:10)], filter='top', options = list(lengthChange = FALSE)
  )
  
  tbl_db_filtered <- reactive({
    req(input$tbl_db_rows_all)
    tibble(adata_TOTAL_obs_tmp)[,c(11, 1:10)][input$tbl_db_rows_all, ]  
  })
  output$nsubsetsBox <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_filtered()$cell_type_subset))), "subsets",  
      icon = icon('shapes', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  output$nagesBox <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_filtered()$age))), "ages", 
      icon = icon('people-group', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$ngenotypeBox <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_filtered()$genotype))), "genotypes", 
      icon = icon('circle-radiation', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$nstrainBox <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_filtered()$strain))), "strains", 
      icon = icon('circle-radiation', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$ntreatmentBox <- renderValueBox({
    valueBox(
      nrow(unique(tibble(tbl_db_filtered()$treatment))), "treatments", 
      icon = icon('circle-radiation', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$ncellsBox <- renderValueBox({
    valueBox(
      nrow(tibble(tbl_db_filtered())), "cells", 
      icon = icon('viruses', class = NULL, lib = "font-awesome"), color = "light-blue")
  })
  
  output$barplot <- renderPlot({
    summary <- tbl_db_filtered() %>% group_by(.data[[input$xaxis]], .data[[input$varColor]]) %>% summarise(n_cells = length(.data[[input$varColor]]))
    ggplot(summary, aes(fill=.data[[input$varColor]], y=n_cells, x=.data[[input$xaxis]])) +
      geom_bar( colour='black', position="stack", stat="identity") + 
      scale_fill_manual(values = as.vector(polychrome(n=36))) +
      ylab("Number of cells\n") +  xlab("") + theme_pubr() +
      theme(axis.text.x = element_text(angle = 90, hjust=1, size = 15),
            axis.text.y = element_text(size = 15), legend.title = element_text(size = 15),
            legend.text = element_text(size = 15), axis.title = element_text(size = 19))
  })
  
  
  observeEvent(input$dataset,{
    adata <- anndata::read_h5ad(paste0('data/', input$dataset))
    output$tbl_br = renderDT(
      tibble(adata$obs)[,c(1:10)], filter='top', options = list(lengthChange = FALSE)
    )
    
    tbl_br_filtered <- reactive({
      req(input$tbl_br_rows_all)
      adata$obs[input$tbl_br_rows_all,]
    })
    
    updateSelectizeInput(session, 'groupingInput', choices = colnames(tbl_br_filtered()), server = TRUE)
    updateSelectizeInput(session, 'geneInput', choices = rownames(adata$var), server = TRUE)
    
    observeEvent(input$update_browser,{
      
      if (input$annotation == 'metadata'){
        output$umap <- renderPlot({
          ggplot(as.data.frame(adata[rownames(tbl_br_filtered())]$obsm$X_umap), aes(x = adata[rownames(tbl_br_filtered())]$obsm$X_umap[,1], y = adata[rownames(tbl_br_filtered())]$obsm$X_umap[,2], colour = adata[rownames(tbl_br_filtered())]$obs[[input$groupingInput]])) +
            geom_scattermore(pointsize = input$cellSize) + theme_pubr() + xlab("UMAP1") + ylab("UMAP2") + theme(legend.position = "right", legend.title = element_text(size = 17), legend.text = element_text(size = 15)) +
            scale_color_manual("", values = as.vector(polychrome(n=36)))
        })
      }
      else if (input$annotation == 'gene'){
        output$umap <- renderPlot({
          if (is.null(input$geneInput)) return()
          ggplot(as.data.frame(adata[rownames(tbl_br_filtered())]$obsm$X_umap), aes(x = adata[rownames(tbl_br_filtered())]$obsm$X_umap[,1], y = adata[rownames(tbl_br_filtered())]$obsm$X_umap[,2], colour = adata[rownames(tbl_br_filtered())]$X[, input$geneInput])) + 
            geom_scattermore(pointsize = input$cellSize) + theme_classic2() + scale_color_gradientn("", colours = rev(brewer.pal(11, "Spectral"))) + xlab("UMAP1") + ylab("UMAP2")
        })
      }
      else if (input$annotation == 'signature'){
        sc$tl$score_genes(adata, public_signatures[[input$signature]][!is.na(public_signatures[[input$signature]])], score_name=input$signature, use_raw=F)
        output$umap <- renderPlot({
          ggplot(as.data.frame(adata[rownames(tbl_br_filtered())]$obsm$X_umap), aes(x = adata[rownames(tbl_br_filtered())]$obsm$X_umap[,1], y = adata[rownames(tbl_br_filtered())]$obsm$X_umap[,2], colour = adata[rownames(tbl_br_filtered())]$obs[[input$signature]])) + 
            geom_scattermore(pointsize = input$cellSize) + theme_classic2() + scale_color_gradientn("", colours = rev(brewer.pal(11, "Spectral"))) + xlab("UMAP1") + ylab("UMAP2")
        })
      }
      
    })
    
    
    
  })
  
  
  
    
    
}

options <- list()
if (!interactive()) {
  options$port = 3838
  options$launch.browser = FALSE
  options$host = "0.0.0.0"
  
}


shinyApp(ui, server, options = options)
