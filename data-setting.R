## ----------- Pacotes -------
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)

## ---------- [CENARIO] comparacao brasil com pernambuco ----

brasil <- readRDS(file = "dados/mortematerna/agregado_BR.rds")
regiao <- readRDS(file = "dados/mortematerna/agregado_REGIAO.rds")
estados <- readRDS(file = "dados/mortematerna/agregado_ESTADOS.rds")

br_inf <- readRDS(file = "dados/morteinfantil/agregado_BR.rds")
re_inf <- readRDS(file = "dados/morteinfantil/agregado_REGIAO.rds")
es_inf <- readRDS(file = "dados/morteinfantil/agregado_ESTADOS.rds")

es_inf <- es_inf[!is.na(es_inf$sigla_uf),]

df_mm_UFBR <- rbind(brasil, estados)

df_mi_UFBR <-  rbind(br_inf, es_inf)

dt_mort_uf_br <- merge(df_mm_UFBR, 
                       df_mi_UFBR[, -4],
                       by=c('sigla_uf',"ano" ), all.x = T)




## infobox para 2019

dt_info <- 
dt_mort_uf_br %>% 
  filter(sigla_uf %in% c('PE', 'BR') & ano == 2019) %>% 
  group_by(sigla_uf) %>% 
  summarise(
    obitos_ma = sum(total_obitos_maternos),
    obitos_inf = sum(total_obitos_infantis)
  )

info_box1_value <- dt_info[dt_info$sigla_uf=='BR',]$obitos_ma
info_box2_value <- dt_info[dt_info$sigla_uf=='PE',]$obitos_ma
info_box3_value <- dt_info[dt_info$sigla_uf=='BR',]$obitos_inf
info_box4_value <- dt_info[dt_info$sigla_uf=='PE',]$obitos_inf

## ------------ [Mortalidade Infantil - Municipios] ------------

mortalidade_infantil_municipios <- readRDS('dados/df_mortalidade_infantil_BR_MUNICIPIOS.rds')

mortalidade_infantil_municipios_pe <- 
mortalidade_infantil_municipios %>% 
  filter(sigla_uf == 'PE') %>% 
  select(ano, nome_municipio, obitos_infantis, taxa_mortalidade_infantil)




## ------------ [Mortalidade Materna - Municipios] ------------

mortalidade_materna_municipios <- readRDS('dados/df_mortalidade_materna_BR_MUNICIPIOS.rds')

mortalidade_materna_municipios_pe <- 
  mortalidade_materna_municipios %>% 
  filter(sigla_uf == 'PE') %>% 
  select(ano, nome_municipio, obitos_maternos, taxa_mortalidade_materna)
