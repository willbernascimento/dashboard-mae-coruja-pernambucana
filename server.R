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
      filter(nome_municipio  == input$select_cidade_infantil) %>% 
      filter(ano %in% c(input$slider_cidade_infantil[1]:input$slider_cidade_infantil[2]))
  })

output$value <- renderPrint({ input$select_cidade_infantil })
  
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
  })
  
  
output$tabela_cidade_mi = DT::renderDataTable({
    DT::datatable(plotData_tx_mi_estado() %>%
      mutate(taxa_mortalidade_infantil = round(taxa_mortalidade_infantil,2)) %>%
      rename(`Mortalidade Infantil` = taxa_mortalidade_infantil,
             `Óbitos Infantis`= obitos_infantis,
             `Município` = nome_municipio,
             Ano = ano), options = list(pageLength=24, searching=FALSE),)
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

  
## [Mortalidade Infantil] Infantil -----------

plotData_tx_mm_estado <- reactive({
    
    mortalidade_materna_municipios_pe %>%
      filter(nome_municipio  == input$select_cidade_materna) %>% 
      filter(ano %in% c(input$slider_cidade_materna[1]:input$slider_cidade_materna[2]))
  })
  
  #output$value <- renderPrint({ input$select_cidade_materna })
  
output$plot_cidade_mm <- renderPlot({
    
    ggplot(plotData_tx_mm_estado(), aes(ano, taxa_mortalidade_materna, group=1)) +
      geom_line(size=1,color='steelblue') +
      geom_point(size=1.5,color='steelblue') +
      geom_vline(xintercept = '2008', linetype='dotted') +
      theme_minimal(base_size = 14) +
      theme(axis.title.x = element_blank(),
            axis.text.x = element_text(angle = 45),
            legend.position = 'top')+
      labs(y='Mortalidade Materna por 1.000 NV')
  })

output$tabela_cidade_mm = DT::renderDataTable({
    DT::datatable(plotData_tx_mm_estado() %>%
                    mutate(taxa_mortalidade_materna = round(taxa_mortalidade_materna,2)) %>%
                    rename(`Mortalidade Materna` = taxa_mortalidade_materna,
                           `Óbitos Infantis`= obitos_maternos,
                           `Município` = nome_municipio,
                           Ano = ano), options = list(pageLength=24, searching=FALSE),)
  })
  
output$info_box_MM_cidade_ABS <- renderInfoBox({
    value = tags$p(style = "font-size: 25px;", plotData_tx_mm_estado() %>%
                     filter(ano == max(as.numeric(as.character(ano)))) %>%
                     select(obitos_maternos))
    infoBox("Óbitos maternos", value, icon = icon("book-medical"))
  })
  
output$info_box_MM_cidade_TAX <- renderInfoBox({
    value = tags$p(style = "font-size: 25px;", plotData_tx_mm_estado() %>%
                     filter(ano == max(as.numeric(as.character(ano)))) %>% # seleciona o ano mais recente (MAX)
                     select(taxa_mortalidade_materna)%>% round(.,2))
    infoBox("Taxa de mortalidade", value, icon = icon("book-medical"))
  })


## CNES [Dados de Unidades e serviços hospitalares] -------

#input$cnesNivelAtencao_checkGroup

dados_cnes_atencao_barra <- reactive({
  
  dados_long %>%
    filter(nome_municipio  == input$cnes_nome_cidade) %>% 
    filter(ano %in% input$cnes_ano) %>% 
    filter(nivel_atencao_id  %in% input$cnesNivelAtencao_checkGroup)
})

dados_cnes_atencao_linha <- reactive({
  
  dados_long %>%
    filter(nome_municipio  == input$cnes_nome_cidade) %>% 
    filter(ano %in% c(input$cnes_slider_ano[1]:input$cnes_slider_ano[2])) %>% 
    filter(nivel_atencao_id  %in% input$cnesNivelAtencao_checkGroup)
})

output$cnes_NivelAtencao_barras <- renderPlotly({
  ggplotly(
      ggplot(dados_cnes_atencao_barra(), aes(nivel_atencao2, Quantidade, fill=nivel_atencao2))+
      geom_bar(stat = 'identity')+
      theme_minimal()+
      theme(legend.position = 'top')+
      coord_flip()
  ) %>% 
    layout(
      xaxis = list(title = 'Quantidade'), 
      yaxis = list(title = ''),
      legend = list(title=list(text='Nível de atenção'),x = 100, y = 0.5))
})



output$cnes_NivelAtencao_linhas <- renderPlotly({
ggplotly(
    ggplot(dados_cnes_atencao_linha(), aes(ano, Quantidade, group=nivel_atencao2, color=nivel_atencao2))+
    geom_line(size=1)+
    geom_point()+
    theme_minimal()+
    theme(legend.position = 'top', axis.title.x = element_blank())) %>%
    layout(
    yaxis = list(title = 'Quantidade'),
    legend = list(title='',orientation="h",yanchor="bottom",y=1.02,xanchor="right",x=1))
})


dados_cnes_atencao_tabela <- reactive({
  dados_long %>%
    filter(nome_municipio  == input$cnes_nome_cidade)
})


output$cnes_tabela_servicos = DT::renderDataTable({
  DT::datatable(dados_cnes_atencao_tabela() %>% 
                  select(ano, nome_municipio, nivel_atencao2, Quantidade) %>% 
                  rename(`Ano` = ano, 
                         `Nome do Município` = nome_municipio,
                         `Nível de Atenção` = nivel_atencao2),
                options = list(pageLength=30, searching=FALSE)
                )
})



# info boxes

dados_nivel_atencao_pe <- 
  dados_long %>% 
  filter(ano == 2021) %>% 
  group_by(nivel_atencao_id) %>% 
  summarise(total = sum(Quantidade))



output$info_box_cnes_amb <- renderInfoBox({
  value = tags$p(style = "font-size: 25px;", subset(dados_nivel_atencao_pe, nivel_atencao_id  == 'Ambulatorial')$total)
  infoBox("Ambulatorial", value, icon = icon("book-medical"))
})

output$info_box_cnes_hos <- renderInfoBox({
  value = tags$p(style = "font-size: 25px;", subset(dados_nivel_atencao_pe, nivel_atencao_id  == 'Hospitalar')$total)
  infoBox("Hospitalar", value, icon = icon("book-medical"))
})

output$info_box_cnes_ger <- renderInfoBox({
  value = tags$p(style = "font-size: 25px;", subset(dados_nivel_atencao_pe, nivel_atencao_id  == 'Quantidade geral')$total)
  infoBox("Geral", value, icon = icon("book-medical"))
})



  
}
