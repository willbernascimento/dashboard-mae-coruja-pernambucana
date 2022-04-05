library(shiny)
library(shinyWidgets)
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
    menuItem('Indicadores', tabName = 'indicadores', icon = icon('fa-solid fa-file-medical'),
             menuItem('CNES', tabName = 'cnes', icon = icon('fa-solid fa-hospital'))#,
             #menuItem('etc',tabName = 'etc',icon = icon('fa-solid fa-hospital'))#,
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
              fluidRow(column(12, box(width = 12,
                title = 'Números mais recentes', status = "primary",solidHeader = TRUE,
                infoBoxOutput("info_box_MI_cidade_ABS"),
                infoBoxOutput("info_box_MI_cidade_TAX"),
                height = 150
              ))),
              column(12,
                     fluidRow(
                       column(width = 6,
                              fluidRow(box(width = 12, title = "Filtro por cidade e ano", solidHeader = TRUE, status = "primary", 
                                           selectInput("select_cidade_infantil", label = NULL, 
                                                       choices = unique(mortalidade_infantil_municipios_pe$nome_municipio), 
                                                       selected = 'Araripina'),
                                           sliderInput("slider_cidade_infantil", "Selecione o ano:", 1996, 2019, value = c(1999, 2015))),
                                       box(width = 12, plotOutput("plot_cidade_mi", height="488px", brush = "plot_brush"), 
                                           title = "Mortalidade Infantil", solidHeader = TRUE, status = "primary")
                                       ),
                              
                       ),
                       column(width = 6,
                              box(width = NULL,  title = "Mortalidade Infantil - Dados", solidHeader = TRUE, status = "primary",
                                  div(DT::dataTableOutput("tabela_cidade_mi"), style = "font-size:99%"))
                       )
                     )
              )
            )
    ),
    
    tabItem(tabName = 'materna',
            # fluidRow(
            #    box(title="Ops, essa página ainda está em desenvolvimento!", status = "danger",solidHeader = TRUE,
            #   div(class=" panel panel-default",
            #      img(src='development.png', class="img-responsive")
            #   ))
            # )
            
            
            fluidRow(
              fluidRow(column(12, box(width = 12,
                                      title = 'Números mais recentes', status = "primary",solidHeader = TRUE,
                                      infoBoxOutput("info_box_MM_cidade_ABS"),
                                      infoBoxOutput("info_box_MM_cidade_TAX"),
                                      height = 150
              ))),
              column(12,
                     fluidRow(
                       column(width = 6,
                              fluidRow(box(width = 12, title = "Filtro por cidade e ano", solidHeader = TRUE, status = "primary", 
                                           selectInput("select_cidade_materna", label = NULL, choices = unique(mortalidade_materna_municipios_pe$nome_municipio), 
                                                       selected = 'Araripina'),
                                           sliderInput("slider_cidade_materna", "Selecione o ano:", 1996, 2019, value = c(1999, 2015))),
                                       box(width = 12, plotOutput("plot_cidade_mm", height="488px", brush = "plot_brush"), 
                                           title = "Mortalidade Materna", solidHeader = TRUE, status = "primary")
                              ),
                              
                       ),
                       column(width = 6,
                              box(width = NULL,  title = "Mortalidade Materna - Dados", solidHeader = TRUE, status = "primary",
                                  div(DT::dataTableOutput("tabela_cidade_mm"), style = "font-size:99%"))
                       )
                     )
              )
            )
    ),
## --------------------------------    
    ## Tab de indicadores ##

tabItem(tabName = 'cnes',

        fluidRow(
          fluidRow(column(12, box(width = 12,
                                  title = 'Números de estabelecimentos CNES em Pernambuco, 2021', status = "primary",solidHeader = TRUE,
                                  infoBoxOutput("info_box_cnes_amb"),
                                  infoBoxOutput("info_box_cnes_hos"),
                                  infoBoxOutput("info_box_cnes_ger"),
                                  height = 150
          ))),
          column(12,
                 fluidRow(
                   column(width = 6,
                          fluidRow(box(width = 12, title = "Filtros", solidHeader = TRUE, status = "primary", 
                                       selectInput("cnes_nome_cidade", label = NULL, choices = toupper(unique(dados_long$nome_municipio)),selected = 'ARARIPINA'),
                                       checkboxGroupInput("cnesNivelAtencao_checkGroup", label = h3("Nível de atenção"), choices = list("Ambulatorial" = "Ambulatorial", "Hospitalar" = "Hospitalar"),
                                                          selected = "Ambulatorial", inline = TRUE)
                                       ),
                                   box(width = 12, 
                                       sliderTextInput("cnes_ano","Selecione o ano",choices =  sort(unique(dados_long$ano))),
                                       plotlyOutput("cnes_NivelAtencao_barras", height="488px"), 
                                       title = "Estabelecimentos por nível de atenção", solidHeader = TRUE, status = "primary"),
                                   box(width = 12,
                                       sliderInput("cnes_slider_ano", "Selecione o ano:", 2005, 2021, value = c(2010, 2020)),
                                       plotlyOutput("cnes_NivelAtencao_linhas", height="488px"), 
                                       title = "Estabelecimentos por nível de atenção no tempo", solidHeader = TRUE, status = "primary")
                                   
                          ),
                          
                   ),
                   column(width = 6,
                          box(width = NULL,  title = "Estabelecimentos por nível de atenção - Dados", solidHeader = TRUE, status = "primary",
                              div(DT::dataTableOutput("cnes_tabela_servicos"), style = "font-size:99%"))
                   )
                 )
          )
        )
),
    
    
## --------------------------------    
    tabItem(tabName = 'sobre', fluidRow(box(width = 12, status = 'info', htmlTemplate('about_page.html')))
    )
    
    
    )# fecha tabItems
  
  
  )# fecha body

dashboardPage(header, sidebar, body)
