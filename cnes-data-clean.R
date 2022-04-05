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
           header = F,fileEncoding = 'Latin1',
           sep = ';',
           skip = 4) %>% 
    mutate(ano = str_extract(x, '\\d{4}'))
  
  dados <- dados[1:as.numeric(rownames(dados[dados$V1 == 'Total',]))-1,]
}) %>% do.call('rbind', .)

names(dados) <-
  c(
    "Município",
    "Quantidade_Geral",
    "AmbulatorialBásica_estadual",
    "AmbulatorialBásica_municipal",
    "AmbMédia_complex_estadual",
    "AmbMédia_complex_municipal",
    "AmbAlta_complex_estadual",
    "AmbAlta_complex_municipal",
    "HospMédia_complex_estadual",
    "HospMédia_complex_municipal",
    "HospAlta_complex_estadual",
    "HospAlta_complex_municipal",
    "ano"
  )

dados$codigo_municipio <- dtsus.extractcode(dados$Município)
dados$nome_municipio <- toupper(dtsus.extractname(dados$Município))
dados[dados == '-'] <- 0 # O DATASUS indica que - s?o 0 n?o aredondados
dados$Município <- NULL

dados[,2:11] <- sapply(dados[,2:11],as.numeric)

## 


dados_long <-
  pivot_longer(
    dados,
    cols = !c(nome_municipio, codigo_municipio, ano),
    names_to = 'nivel_atencao',
    values_to = 'Quantidade'
  )


dados_long <- 
  dados_long %>%
  mutate(nivel_atencao2 = case_when(
    nivel_atencao == 'AmbAlta_complex_estadual' ~ 'Amb. Alta complexidade estadual',
    nivel_atencao == 'AmbAlta_complex_municipal' ~ 'Amb. Alta complexidade municipal',
    nivel_atencao == 'AmbMédia_complex_estadual' ~ 'Amb. Média complexidade estadual',
    nivel_atencao == 'AmbMédia_complex_municipal' ~'Amb. Média complexidade municipal' ,
    nivel_atencao == 'AmbulatorialBásica_estadual' ~ 'Amb. Básica estadual',
    nivel_atencao == 'AmbulatorialBásica_municipal' ~ 'Amb. Básica municipal',
    nivel_atencao == 'HospAlta_complex_estadual' ~ 'Hosp. Alta complexidade estadual',
    nivel_atencao == 'HospAlta_complex_municipal' ~ 'Hosp. Alta complexidade municipal',
    nivel_atencao == 'HospMédia_complex_estadual' ~ 'Hosp. Média complexidade estadual',
    nivel_atencao == 'HospMédia_complex_municipal' ~ 'Hosp Média complexidade municipal',
    nivel_atencao == 'Quantidade_Geral' ~ 'Quantidade geral', TRUE ~ 'ERRO'
  )) %>% 
  mutate(
    nivel_atencao_id = ifelse(grepl(pattern = 'Amb.',x = nivel_atencao2) == TRUE, 'Ambulatorial', ifelse(grepl(pattern = 'Hosp.',x = nivel_atencao2) == TRUE, 'Hospitalar',nivel_atencao2 ))
  )


saveRDS(dados_long, 'dados/cnes-estabelecimentos/atendimento-prestado.rds')





## graficos ------------

dados_long <- readRDS('dados/cnes-estabelecimentos/atendimento-prestado.rds')

dados_nivel_atencao_pe <- 
dados_long %>% 
  filter(ano == 2021) %>% 
  group_by(nivel_atencao_id) %>% 
  summarise(total = sum(Quantidade))
