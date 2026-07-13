library(shiny)
library(bslib)
library(leaflet)
library(dplyr)
library(sf)
library(stringr)
library(htmltools)
library(plotly)

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

# ── Serie temporal: indicadores disponibles (incluye la brecha de desigualdad) ──
indicadores_ts <- c(indicadores_completos, "Brecha de Desigualdad (P90/P10)" = "brecha")

# Calcula la evolución anual de un indicador para una provincia (o toda Andalucía)
calc_ts <- function(df, prov, ind) {
  if (prov != "Toda Andalucía") df <- df %>% filter(Provincia == prov)

  if (ind == "brecha") {
    df %>%
      group_by(año) %>%
      summarise(
        valor = {
          q1 <- quantile(Renta_Mediana_UC, 0.1, na.rm = TRUE)
          q9 <- quantile(Renta_Mediana_UC, 0.9, na.rm = TRUE)
          if (is.na(q1) || q1 == 0) NA_real_ else as.numeric(q9 / q1)
        },
        .groups = "drop"
      )
  } else if (ind == "pob") {
    df %>%
      group_by(año) %>%
      summarise(valor = sum(pob, na.rm = TRUE), .groups = "drop")
  } else {
    df %>%
      group_by(año) %>%
      summarise(valor = mean(.data[[ind]], na.rm = TRUE), .groups = "drop")
  }
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

# ── Estadísticas precalculadas para la pestaña "Informe" ──
# Se calculan una sola vez al arrancar la app (no dependen de los inputs del usuario).
compute_informe_stats <- function(datos, anio_ini = 2015, anio_fin = 2022) {

  stat_year <- function(year, var, fun = mean) fun(datos[[var]][datos$año == year], na.rm = TRUE)

  brecha_year <- function(year) {
    d <- datos[datos$año == year, ]
    q1 <- quantile(d$Renta_Mediana_UC, 0.1, na.rm = TRUE)
    q9 <- quantile(d$Renta_Mediana_UC, 0.9, na.rm = TRUE)
    if (is.na(q1) || q1 == 0) NA_real_ else as.numeric(q9 / q1)
  }

  prov_growth <- datos %>%
    filter(año %in% c(anio_ini, anio_fin)) %>%
    group_by(Provincia, año) %>%
    summarise(renta = mean(Renta_Mediana_UC, na.rm = TRUE), .groups = "drop") %>%
    tidyr_pivot_renta() %>%
    mutate(cambio = round((renta_fin - renta_ini) / renta_ini * 100, 1)) %>%
    arrange(desc(cambio))

  d_fin <- datos[datos$año == anio_fin, ]
  sec_max <- d_fin[which.max(d_fin$Renta_Mediana_UC), c("Municipio", "Provincia", "Renta_Mediana_UC")]
  sec_min <- d_fin[which.min(d_fin$Renta_Mediana_UC), c("Municipio", "Provincia", "Renta_Mediana_UC")]

  prov_fin <- datos %>%
    filter(año == anio_fin) %>%
    group_by(Provincia) %>%
    summarise(renta = mean(Renta_Mediana_UC, na.rm = TRUE), .groups = "drop") %>%
    arrange(desc(renta))

  list(
    anio_ini = anio_ini, anio_fin = anio_fin,
    n_secciones_fin = nrow(d_fin),
    renta_ini = stat_year(anio_ini, "Renta_Mediana_UC"),
    renta_fin = stat_year(anio_fin, "Renta_Mediana_UC"),
    crecimiento_renta = round((stat_year(anio_fin, "Renta_Mediana_UC") - stat_year(anio_ini, "Renta_Mediana_UC")) /
                                 stat_year(anio_ini, "Renta_Mediana_UC") * 100, 1),
    brecha_ini = brecha_year(anio_ini),
    brecha_fin = brecha_year(anio_fin),
    edad_ini = stat_year(anio_ini, "edad_media"),
    edad_fin = stat_year(anio_fin, "edad_media"),
    mayor65_ini = stat_year(anio_ini, "mayor_65"),
    mayor65_fin = stat_year(anio_fin, "mayor_65"),
    hogares_uni_ini = stat_year(anio_ini, "hogares_uni"),
    hogares_uni_fin = stat_year(anio_fin, "hogares_uni"),
    extranjera_ini = stat_year(anio_ini, "pob_extranjera"),
    extranjera_fin = stat_year(anio_fin, "pob_extranjera"),
    prov_growth = prov_growth,
    prov_fin = prov_fin,
    sec_max = sec_max,
    sec_min = sec_min
  )
}

# Pequeño helper para no depender de tidyr::pivot_wider (solo dplyr base)
tidyr_pivot_renta <- function(df) {
  ini <- df %>% filter(año == min(año)) %>% select(Provincia, renta_ini = renta)
  fin <- df %>% filter(año == max(año)) %>% select(Provincia, renta_fin = renta)
  inner_join(ini, fin, by = "Provincia")
}

informe_stats <- compute_informe_stats(datos)
