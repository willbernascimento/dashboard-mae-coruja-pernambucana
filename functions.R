library(stringr)

dtsus.extractcode <- function(x){
  # Recebe uma coluna de codigo do data sus e retorna apenas o código
  
  cod_municipio <- stringr::str_extract(x, pattern = "\\d{6}")
  return(cod_municipio)
}

dtsus.extractname <- function(x){
  # Recebe uma coluna de codigo do data sus e retorna apenas o nome do municipio
  
  nome_municipio <- str_extract(x, "[^\\d]*$") %>% str_trim()
  return(nome_municipio)
}


dtsus.obtInf.mes <- function(ano = 2019) {
  # Baixa os obitos mensais: infantis
  
  
  ano <- as.character(ano)
  
  
  # baixa as tabelas de mortalidade por mês
  
  lista <- list()
  for (i in ano) {
    lista[[i]] <-
      datasus::sim_inf10_mun(coluna = "Mês do Óbito", periodo = i)
    
  }
  
  # alguns bancos tem uma coluna a mais. excluimos a coluna 14. O ideal seria excluir por nome.
  #
  
  nova_lista <- lapply(lista, function(x) {
    if (length(x) == 15) {
      x <- x[, -14]
    } else {
      x
    }
    
  })
  
  # junta todos os bancos de dados, cria uma coluna com os anos e remove a linha de total
  banco <- do.call("rbind", nova_lista)
  banco$ano <- str_extract(rownames(banco), "\\d{4}")
  banco <- banco[banco$Município != "TOTAL", ]
  
  return(banco)
}