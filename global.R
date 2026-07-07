library(shiny)
library(bslib)
library(leaflet)
library(dplyr)
library(sf)
library(stringr)
library(htmltools)

ai_packages_ok <- tryCatch({
  library(querychat)
  library(ellmer)
  TRUE
}, error = function(e) FALSE)

load("datos_rentapop_long.RData")
datos$id <- str_pad(as.character(datos$id), width = 10, side = "left", pad = "0")

datos <- datos %>%
  group_by(año) %>%
  mutate(Renta_Quintil = ntile(Renta_Mediana_UC, 5)) %>%
  ungroup() %>%
  mutate(pob_extranjera = 100 - pob_esp)

provincias_disponibles <- c("Toda Andalucía", sort(unique(datos$Provincia)))

indicadores_completos <- c(
  "Renta Mediana (€)" = "Renta_Mediana_UC",
  "Edad Media" = "edad_media",
  "Población Total" = "pob",
  "% Menores de 18 años" = "menor_18",
  "% Mayores de 65 años" = "mayor_65",
  "Tamaño Medio del Hogar" = "tam_hogar",
  "% Hogares Unipersonales" = "hogares_uni",
  "% Población Española" = "pob_esp",
  "% Población Extranjera" = "pob_extranjera",
  "Quintil de Renta" = "Renta_Quintil"
)

codigos_andalucia <- c("04", "11", "14", "18", "21", "23", "29", "41")

ollama_running <- tryCatch({
  con <- url("http://localhost:11434/api/tags", open = "rb")
  close(con)
  TRUE
}, error = function(e) FALSE)

openai_api_ok <- Sys.getenv("OPENAI_API_KEY") != ""
gemini_api_ok <- Sys.getenv("GEMINI_API_KEY") != ""

app_theme <- bs_theme(
  version = 5, preset = "shiny",
  primary = "#1a5276", secondary = "#5d6d7e",
  success = "#1e8449", info = "#2874a6",
  warning = "#d4ac0d", danger = "#c0392b",
  base_font = font_google("Inter"),
  heading_font = font_google("Outfit")
)

format_value <- function(valor, indicador) {
  if (is.na(valor)) return("Sin datos")
  switch(indicador,
    "Renta_Mediana_UC" = paste0(format(round(valor), big.mark = ".", decimal.mark = ","), " €"),
    "pob" = format(round(valor), big.mark = ".", decimal.mark = ","),
    "menor_18" = , "mayor_65" = , "hogares_uni" = ,
    "pob_esp" = , "pob_extranjera" = paste0(round(valor, 1), "%"),
    "Renta_Quintil" = paste0("Q", round(valor)),
    "edad_media" = paste0(round(valor, 1), " años"),
    "tam_hogar" = round(valor, 2),
    round(valor, 2)
  )
}

get_palette <- function(ind) {
  switch(ind,
    "Renta_Mediana_UC" = , "Renta_Quintil" = "RdYlGn",
    "menor_18" = , "pob_extranjera" = "YlOrRd",
    "mayor_65" = , "edad_media" = "PuBuGn",
    "pob" = "YlGnBu",
    "Spectral"
  )
}

build_tooltip <- function(res, val, nombre_ind, indicador) {
  vals <- sapply(seq_along(val), function(i) format_value(val[i], indicador))
  sprintf(
    "<div style='font-family:Inter,sans-serif;font-size:13px;min-width:190px;'>
     <div style='font-weight:700;color:#1a5276;border-bottom:2px solid #e8f4f8;padding-bottom:4px;margin-bottom:5px;'>%s</div>
     <div style='color:#5d6d7e;'>Sección: %s</div>
     <div style='margin-top:6px;padding:6px 8px;background:linear-gradient(135deg,#e8f8f5,#d5f5e3);border-radius:6px;'>
       <span style='font-weight:600;color:#1a5276;'>%s:</span><br/>
       <span style='font-size:15px;font-weight:800;color:#148f77;'>%s</span>
     </div></div>",
    ifelse(is.na(res$Municipio), "Desconocido", res$Municipio),
    res$CUSEC, nombre_ind, vals
  ) |> lapply(HTML)
}

generate_narrative <- function(df, prov, year, datos_all) {
  if (nrow(df) == 0) return("")
  
  renta <- mean(df$Renta_Mediana_UC, na.rm = TRUE)
  edad <- mean(df$edad_media, na.rm = TRUE)
  mayores <- mean(df$mayor_65, na.rm = TRUE)
  extranjera <- mean(100 - df$pob_esp, na.rm = TRUE)
  hogares_u <- mean(df$hogares_uni, na.rm = TRUE)
  
  renta_and <- mean(datos_all$Renta_Mediana_UC[datos_all$año == year], na.rm = TRUE)
  
  parts <- c()
  
  if (!is.na(renta) && !is.na(renta_and) && renta_and > 0) {
    diff <- round((renta - renta_and) / renta_and * 100, 1)
    rfmt <- format(round(renta), big.mark = ".", decimal.mark = ",")
    if (abs(diff) < 3) {
      parts <- c(parts, paste0("La renta mediana (", rfmt, " €) se sitúa en torno a la media andaluza."))
    } else if (diff > 0) {
      parts <- c(parts, paste0("La renta mediana (", rfmt, " €) supera la media andaluza en un ", abs(diff), "%."))
    } else {
      parts <- c(parts, paste0("La renta mediana (", rfmt, " €) queda un ", abs(diff), "% por debajo de la media andaluza."))
    }
  }
  
  if (!is.na(mayores) && mayores > 25)
    parts <- c(parts, paste0("Población envejecida: ", round(mayores, 1), "% mayores de 65."))
  if (!is.na(mayores) && mayores < 15)
    parts <- c(parts, paste0("Zona joven: solo ", round(mayores, 1), "% mayores de 65."))
  if (!is.na(extranjera) && extranjera > 15)
    parts <- c(parts, paste0("Alta diversidad: ", round(extranjera, 1), "% población extranjera."))
  if (!is.na(hogares_u) && hogares_u > 35)
    parts <- c(parts, paste0(round(hogares_u, 1), "% hogares unipersonales — posible vulnerabilidad social."))
  
  # Inequality gap
  df_q <- datos_all[datos_all$año == year, ]
  if (prov != "Toda Andalucía") df_q <- df_q[df_q$Provincia == prov, ]
  q1 <- quantile(df_q$Renta_Mediana_UC, 0.1, na.rm = TRUE)
  q9 <- quantile(df_q$Renta_Mediana_UC, 0.9, na.rm = TRUE)
  if (!is.na(q1) && q1 > 0) {
    ratio <- round(q9 / q1, 1)
    parts <- c(parts, paste0("Brecha P90/P10: ", ratio, "x entre las secciones más y menos favorecidas."))
  }
  
  paste(parts, collapse = " ")
}
