library(shiny)
library(shinydashboard)
library(shinyalert)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(DT)
source('data-setting.R')

header <- dashboardHeader(title = 'Dashboard PMCP')

sidebar <- dashboardSidebar(
  sidebarMenu(
    id = 'sidebarmenu',
    menuItem('O Cenário', tabName = 'cenario', icon = icon('fas fa-chart-line')),
    menuItem('Mortalidade', tabName = 'mortalidade', icon = icon('fas fa-chart-line'),
      menuItem('Infantil', tabName = 'infantil', icon = icon('baby')),
      menuItem('Materna',tabName = 'materna',icon = icon('female'))#,
      # menuItem('c',
      #          tabName = 'c',
      #          icon = icon('fas fa-chart-line'))
    ),
    menuItem('Sobre', tabName = 'sobre', icon = icon('address-card'))
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(
      tabName = "cenario",
        fluidRow(
          box(title = 'Números para 2019', status = "primary",solidHeader = TRUE, infoBoxOutput("info_box1",width = 4),
              infoBoxOutput("info_box2",width = 4),
         infoBoxOutput("info_box3",width = 4),
              infoBoxOutput("info_box4",width = 4), width = 12)
        ), # fecha fluid
        
        fluidRow(box(title = 'Mortalidade materna', status = "primary",solidHeader = TRUE, plotOutput('plot1')), 
                 box(title = 'Mortalidade infantil', status = "primary",solidHeader = TRUE, plotOutput('plot2'))),
      
      fluidRow(box(sliderInput("slider_plot1", "Selecione o ano:", 1996, 2019, value = c(2005, 2015))), 
               box(sliderInput("slider_plot2", "Selecione o ano:", 1996, 2019, value = c(2005, 2015))))
      
      
      ), # tabitem
    
    tabItem(tabName = 'infantil',
      fluidRow(
      box(
      # Copy the line below to make a select box 
       title = "Selecione a cidade", status = "primary",solidHeader = TRUE, 
       selectInput("select_cidade_infantil", label = NULL, choices = unique(mortalidade_infantil_municipios_pe$nome_municipio), selected = 'Araripina'),
       height = 150
    ), 

    
    box(
      title = 'Números para 2019', status = "primary",solidHeader = TRUE, 
      infoBoxOutput("info_box_MI_cidade"),
      infoBoxOutput("info_box_MI_cidade_ABS"),
      infoBoxOutput("info_box_MI_cidade_TAX"),
      height = 150
    )
    
    
    ),
      fluidRow(box(title = 'Mortalidade infantil', status = "primary",solidHeader = TRUE, plotOutput('plot_cidade_mi')),
               box(title = 'Mortalidade infantil - Dados', status = "primary",solidHeader = TRUE,  div(DT::dataTableOutput("tabela_cidade_mi"), style = "font-size:99%")       ))
    ),
    
    tabItem(tabName = 'materna',
            fluidRow(
               box(title="Ops, essa página ainda está em desenvolvimento!", status = "danger",solidHeader = TRUE,
              div(class=" panel panel-default",
                 img(src='development.png', class="img-responsive")
              ))
            )
    ),
    
    tabItem(tabName = 'sobre', fluidRow(box(width = 12, status = 'info', htmlTemplate('about_page.html')))
    )
    
    
    )# fecha tabItems
  
  
  )# fecha body

dashboardPage(header, sidebar, body)
