library(readxl)
library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
source('functions.R')



arquivos = dir('dados/cnes-estabelecimentos/atendimento-prestado/')

dados <- 
  lapply(paste0('dados/cnes-estabelecimentos/atendimento-prestado/',arquivos), function(x) {
  dados <- read.csv(x,
           header = F,
           sep = ';',
           skip = 4) %>% 
    mutate(ano = str_extract(x, '\\d{4}'))
  
  dados <- dados[1:as.numeric(rownames(dados[dados$V1 == 'Total',]))-1,]
}) %>% do.call('rbind', .)

names(dados) <-
  c(
    "Munic�pio",
    "Quantidade_Geral",
    "AmbulatorialB�sica_estadual",
    "AmbulatorialB�sica_municipal",
    "AmbM�dia_complex_estadual",
    "AmbM�dia_complex_municipal",
    "AmbAlta_complex_estadual",
    "AmbAlta_complex_municipal",
    "HospM�dia_complex_estadual",
    "HospM�dia_complex_municipal",
    "HospAlta_complex_estadual",
    "HospAlta_complex_municipal",
    "ano"
  )

dados$codigo_municipio <- dtsus.extractcode(dados$Munic�pio)
dados$nome_municipio <- toupper(dtsus.extractname(dados$Munic�pio))
dados[dados == '-'] <- 0 # O DATASUS indica que - s�o 0 n�o aredondados
dados$Munic�pio <- NULL

dados[,2:11] <- sapply(dados[,2:11],as.numeric)

## 


dados_long <-
  pivot_longer(
    dados,
    cols = !c(nome_municipio, codigo_municipio, ano),
    names_to = 'nivel_atencao',
    values_to = 'Quantidade'
  )

saveRDS(dados_long, 'dados/cnes-estabelecimentos/atendimento-prestado.rds')

## criar filtro para cidade e ano
dados_long %>% 
  filter(nome_municipio == 'ARARIPINA' & ano == 2005) %>% 
  ggplot(aes(nivel_atencao, Quantidade, fill=nivel_atencao))+
  geom_bar(stat = 'identity')+
  theme_minimal()+
  theme(legend.position = 'none')+
  coord_flip()
  


## filtro para a cidade, tipo de atencao -> slide de ano
ggplotly(
dados_long %>% 
  filter(nome_municipio == 'ARARIPINA') %>% 
  ggplot(aes(ano, Quantidade, group=nivel_atencao, color=nivel_atencao))+
  geom_line(size=1)+
  geom_point()+
  theme_minimal()+
  theme(legend.position = 'top', axis.title.x = element_blank())) %>%
  layout(legend = list(
    title='',
    orientation = "h"
  )
  )
  