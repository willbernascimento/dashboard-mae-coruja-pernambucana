#source('data-setting.R')



server <- function(input, output) {
  
  plotData_tx_mm <- reactive({
    
    dt_mort_uf_br %>% 
      filter(sigla_uf %in% c('PE', 'BR')) %>% 
      filter(ano %in% c(input$slider_plot1[1]:input$slider_plot1[2]))
  })
  
  plotData_tx_mi <- reactive({
    
    dt_mort_uf_br %>% 
      filter(sigla_uf %in% c('PE', 'BR')) %>% 
      filter(ano %in% c(input$slider_plot2[1]:input$slider_plot2[2]))
  })
  
  
  output$info_box1 <- renderInfoBox({
    value = tags$p(style = "font-size: 25px;", info_box1_value)
    infoBox("Óbitos maternos BR", value, icon = icon("book-medical"),width = 4)
  })
  
  output$info_box2 <- renderInfoBox({
    value = tags$p(style = "font-size: 25px;", info_box2_value)
    infoBox("Óbitos maternos PE", value, icon = icon("book-medical"),width = 4)
  })
  
  
  output$info_box3 <- renderInfoBox({
    value = tags$p(style = "font-size: 25px;", info_box3_value)
    infoBox("Óbitos infantis BR", value, icon = icon("book-medical"),width = 4)
  })
  

  output$info_box4 <- renderInfoBox({
    value = tags$p(style = "font-size: 25px;", info_box4_value)
    infoBox("Óbitos infantis PE", value, icon = icon("book-medical"),width = 4)
  })
  
  
  histdata <- rnorm(500)
  
  output$plot1 <- renderPlot({
    
    ggplot(plotData_tx_mm(), aes(ano, tx_mm, group=sigla_uf, color=sigla_uf)) +
      geom_line() + 
      geom_point() + 
      geom_vline(xintercept = '2008', linetype='dotted') +
      theme_minimal(base_size = 11) + 
      theme(axis.title.x = element_blank(),
            axis.text.x = element_text(angle = 45),
            legend.position = 'top')+
      labs(y='RMM por 100.000NV', color='Localização')
    
    
    #hist(histdata)
  })
  
  output$plot2 <- renderPlot({
    
    ggplot(plotData_tx_mi(), aes(ano, tx_mi, group=sigla_uf, color=sigla_uf)) +
      geom_line() + 
      geom_point() + 
      geom_vline(xintercept = '2008', linetype='dotted') +
      theme_minimal(base_size = 11) + 
      theme(axis.title.x = element_blank(),
            axis.text.x = element_text(angle = 45),
            legend.position = 'top')+
      labs(y='Mortalidade infantil por 1.000 NV', color='Localização')
    
    
    #hist(histdata)
  })
  
  output$plot3 <- renderPlot({
    hist(histdata)
  })
  
  output$plot4 <- renderPlot({
    hist(histdata)
  })

  
  ## [Mortalidade Infantil] Infantil -----------
  
  
  plotData_tx_mi_estado <- reactive({
    
    mortalidade_infantil_municipios_pe %>% 
      filter(nome_municipio  == input$select_cidade_infantil)
  })
  
  #output$value <- renderPrint({ input$select_cidade_infantil })
  output$plot_cidade_mi <- renderPlot({
    
    ggplot(plotData_tx_mi_estado(), aes(ano, taxa_mortalidade_infantil, group=1)) +
      geom_line(size=1,color='steelblue') + 
      geom_point(size=1.5,color='steelblue') + 
      geom_vline(xintercept = '2008', linetype='dotted') +
      theme_minimal(base_size = 14) + 
      theme(axis.title.x = element_blank(),
            axis.text.x = element_text(angle = 45),
            legend.position = 'top')+
      labs(y='Mortalidade infantil por 1.000 NV')
    
    
    #hist(histdata)
  })
  
  output$tabela_cidade_mi = DT::renderDataTable({
    DT::datatable(plotData_tx_mi_estado() %>% 
      mutate(taxa_mortalidade_infantil = round(taxa_mortalidade_infantil,2)) %>% 
      rename(`Mortalidade Infantil` = taxa_mortalidade_infantil, 
             `Óbitos Infantis`= obitos_infantis, 
             `Município` = nome_municipio,
             Ano = ano), options = list(pageLength=8, searching=FALSE),)
  })
  
  output$info_box_MI_cidade_ABS <- renderInfoBox({
    value = tags$p(style = "font-size: 25px;", plotData_tx_mi_estado() %>% 
                     filter(ano == max(as.numeric(as.character(ano)))) %>% 
                     select(obitos_infantis))
    infoBox("Óbitos infantis", value, icon = icon("book-medical"))
  })
  
  output$info_box_MI_cidade_TAX <- renderInfoBox({
    value = tags$p(style = "font-size: 25px;", plotData_tx_mi_estado() %>% 
                     filter(ano == max(as.numeric(as.character(ano)))) %>% 
                     select(taxa_mortalidade_infantil)%>% round(.,2)) 
    infoBox("Taxa de mortalidade", value, icon = icon("book-medical"))
  })
  
  
}
