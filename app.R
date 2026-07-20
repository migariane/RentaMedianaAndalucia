source("global.R")

# ── UI ──
ui <- page_navbar(
  title = tags$span(
    bsicons::bs_icon("people", size = "1.2em"),
    " Desigualdades Sociales en Andalucía"
  ),
  theme = app_theme,
  header = tags$head(tags$link(rel = "stylesheet", href = "custom.css")),
  fillable = TRUE,

  # ── TAB 1: Explorar ──
  nav_panel(
    title = tags$span(bsicons::bs_icon("map"), " Explorar"),
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        selectInput("prov", "Provincia:", provincias_disponibles),
        selectInput("ind", "Indicador:", indicadores_completos, selected = "Renta_Mediana_UC"),
        sliderInput("year", "Año:", min = 2015, max = 2022, value = 2022, sep = "",
                    animate = animationOptions(interval = 2500, loop = FALSE)),
        hr(),
        accordion(
          accordion_panel("Información", icon = bsicons::bs_icon("info-circle"),
            p(strong("Datos:"), "Secciones censales de Andalucía, 2015-2022."),
            p(strong("Fuente Renta y Demografía:"), "INE — Atlas de Distribución de Renta de los Hogares."),
            p(strong("Fuente Esperanza de Vida:"), "BDLPA — Base de Datos Longitudinal de Población de Andalucía (Estadísticas Longitudinales de Supervivencia y Longevidad, cohorte censal 2011, seguimiento hasta 2023). Instituto de Estadística y Cartografía de Andalucía (IECA) y Universidad de Granada."),
            p(strong("Cartografía:"), "Shapefiles por año (INE)."),
            hr(),
            p(strong("Autores:"), "Miguel Ángel Luque-Fernández, Paloma Massó Guijarro, Gustavo Rivas Gervilla, Mario Rivera Izquierdo, Miguel Ángel Montero Alonso y Juan Manuel Melchor Rodríguez (Doctores de la UGR) — ",
              tags$a(href="https://migariane.github.io", target="_blank", "migariane.github.io")),
            hr(),
            div(style="text-align: center;", tags$img(src="logo_ugr.png", height="50px", style="margin-bottom: 10px;")),
            p(style="font-size: 0.85em; color: #5d6d7e;", strong("Financiación:"), "Plan Propio de Investigación y Transferencia de la Universidad de Granada. 2025. Programa 21. Programa de estimulación a la investigación.")
          ),
          accordion_panel("Ayuda", icon = bsicons::bs_icon("question-circle"),
            tags$ul(
              tags$li("Selecciona provincia e indicador para actualizar el mapa."),
              tags$li("Mueve el slider para ver la evolución temporal."),
              tags$li("Pasa el cursor sobre las secciones para ver detalles."),
              tags$li("Pulsa ▶ para animar la evolución anual."),
              tags$li("La pestaña 'Relaciones' explora la correlación entre renta y esperanza de vida."),
              tags$li("La pestaña 'Series Temporales' muestra la evolución anual de un indicador para una sección censal concreta.")
            )
          )
        )
      ),

      layout_columns(
        col_widths = c(2, 2, 2, 3, 3), fill = FALSE,
        value_box("Población", textOutput("total_pob"),
                  showcase = bsicons::bs_icon("people-fill"), theme = "primary"),
        value_box("Renta Mediana", textOutput("renta_media"),
                  showcase = bsicons::bs_icon("currency-euro"), theme = "success"),
        value_box("Edad Media", textOutput("edad_prom"),
                  showcase = bsicons::bs_icon("person"), theme = "info"),
        value_box("Esperanza Vida", textOutput("ev_prom"),
                  showcase = bsicons::bs_icon("heart-pulse"), theme = "danger"),
        value_box("Brecha P90/P10", textOutput("brecha"),
                  showcase = bsicons::bs_icon("arrow-left-right"), theme = "warning")
      ),

      div(class = "narrative-card",
        div(class = "narrative-title",
          tags$span(class = "narrative-icon", bsicons::bs_icon("chat-quote")),
          "Contexto social"
        ),
        div(class = "narrative-text", textOutput("narrativa"))
      ),

      card(
        full_screen = TRUE,
        card_header(
          class = "d-flex justify-content-between align-items-center",
          div(strong("Mapa por sección censal"), " — ", textOutput("map_title", inline = TRUE))
        ),
        card_body(leafletOutput("map", height = "550px"))
      ),

      div(class = "app-footer",
        HTML("Fuente: INE &middot; Atlas de Distribución de Renta de los Hogares &middot; BDLPA (IECA-UGR) &middot; Secciones censales 2015-2022 <br> Autores: Miguel Ángel Luque-Fernández, Paloma Massó Guijarro, Gustavo Rivas Gervilla, Mario Rivera Izquierdo, Miguel Ángel Montero Alonso y Juan Manuel Melchor Rodríguez")
      )
    )
  ),

  # ── TAB 2: Asistente IA ──
  nav_panel(
    title = tags$span(bsicons::bs_icon("robot"), " Asistente IA"),
    uiOutput("chat_panel")
  ),

  # ── TAB 3: Series Temporales ──
  nav_panel(
    title = tags$span(bsicons::bs_icon("graph-up"), " Series Temporales"),
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        selectInput("ts_prov", "Provincia:", choices = provincias_disponibles, selected = "Granada"),
        selectInput("ts_ind", "Indicador:",
          choices = c(
            "Renta Mediana (€)" = "Renta_Mediana_UC",
            "Brecha P90/P10" = "brecha_p90p10",
            "Brecha Q1 vs Q5" = "brecha_q1_q5",
            "Renta media Q1 (más pobre)" = "q1_renta",
            "Renta media Q5 (más rico)" = "q5_renta",
            "Edad Media" = "edad_media",
            "Población Total" = "pob",
            "% Menores de 18 años" = "menor_18",
            "% Mayores de 65 años" = "mayor_65",
            "Tamaño Medio del Hogar" = "tam_hogar",
            "% Hogares Unipersonales" = "hogares_uni",
            "% Población Española" = "pob_esp",
            "% Población Extranjera" = "pob_extranjera",
            "Esperanza Vida (Hombres)" = "EV_Hombres",
            "Esperanza Vida (Mujeres)" = "EV_Mujeres",
            "Esperanza Vida (Media)" = "EV_Media"
          ),
          selected = "Renta_Mediana_UC"),
        hr(),
        p(strong("Estadísticos descriptivos"), style = "color:#1a5276; font-weight:600;"),
        div(style = "background:#eaf2f8; border-radius:8px; padding:12px; margin-top:6px;",
          textOutput("ts_stats")
        ),
        hr(),
        p(style = "font-size:0.85em; color:#5d6d7e;",
          "Evolución temporal del indicador seleccionado a nivel de provincia (2015–2022)."),
        p(style = "font-size:0.85em; color:#5d6d7e;",
          "La EV no varía anualmente porque se calcula sobre todo el período de seguimiento de la BDLPA (2011–2023).")
      ),
      card(
        full_screen = TRUE,
        card_header(
          class = "d-flex justify-content-between align-items-center",
          div(strong("Evolución temporal por provincia"), " — ", textOutput("ts_title", inline = TRUE))
        ),
        card_body(plotlyOutput("ts_plot", height = "500px"))
      )
    )
  ),

  # ── TAB 4: Relaciones ──
  nav_panel(
    title = tags$span(bsicons::bs_icon("graph-up"), " Relaciones"),
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        selectInput("prov_rel", "Provincia (resaltar):",
                    choices = c("Ninguna", sort(unique(renta_provincia$Provincia))),
                    selected = "Ninguna"),
        hr(),
        p(strong("Correlación Renta vs Esperanza de Vida"),
          style = "color:#1a5276; font-weight:600;"),
        div(class = "correlation-card",
          style = "background:#eaf2f8; border-radius:8px; padding:12px; margin-top:6px;",
          textOutput("correlacion_text")
        ),
        hr(),
        p(style = "font-size:0.85em; color:#5d6d7e;",
          "Cada punto representa una provincia andaluza. La línea muestra la tendencia lineal (mínimos cuadrados).")
      ),
      layout_columns(
        col_widths = c(6, 6),
        card(
          full_screen = TRUE,
          card_header(
            class = "d-flex justify-content-between align-items-center",
            div(strong("Renta media vs Esperanza de Vida por provincia"))
          ),
          card_body(plotlyOutput("renta_ev_scatter", height = "450px"))
        ),
        card(
          full_screen = TRUE,
          card_header(
            class = "d-flex justify-content-between align-items-center",
            div(strong("Esperanza de Vida por provincia y sexo"))
          ),
          card_body(plotlyOutput("ev_provincia_sexo_bars", height = "450px"))
        )
      )
    )
  ),

  # ── TAB 4: Causas de Mortalidad ──
  nav_panel(
    title = tags$span(bsicons::bs_icon("heart-pulse"), " Causas Mortalidad"),
    layout_sidebar(
      sidebar = sidebar(
        width = 280,
        radioButtons("causa_sexo", "Sexo:",
                     choices = c("Hombres" = "Hombres", "Mujeres" = "Mujeres"),
                     selected = "Hombres", inline = TRUE),
        hr(),
        p(strong("Esperanza de Vida al nacer observada:"),
          style = "color:#1a5276; font-weight:600;"),
        div(class = "ev-observada-card",
          style = "background:#eaf2f8; border-radius:8px; padding:12px; text-align:center;",
          h2(textOutput("ev_observada_valor"), style = "color:#1a5276; margin:0;"),
          p(textOutput("ev_observada_sexo"), style = "color:#5d6d7e; margin:2px 0 0 0;")
        ),
        hr(),
        p(style = "font-size:0.85em; color:#5d6d7e;",
          "Las tablas de vida se construyen con el método de Chiang (1968) aplicado a la BDLPA (cohorte censal 2011, seguimiento 2011-2023, ~637.000 personas)."),
        p(style = "font-size:0.85em; color:#5d6d7e;",
          "La 'ganancia' representa los años que ganaría la esperanza de vida al nacer si esa causa de muerte se eliminara por completo.")
      ),
      navset_card_underline(
        title = "Análisis de mortalidad por causas",

        nav_panel("Ganancia por causa",
          layout_columns(
            col_widths = c(7, 5),
            card(
              full_screen = TRUE,
              card_header("Años ganados al eliminar cada causa"),
              card_body(plotlyOutput("causas_ganancia_plot", height = "450px"))
            ),
            card(
              full_screen = TRUE,
              card_header("Tabla de ganancias"),
              card_body(DT::dataTableOutput("causas_tabla", height = "450px"))
            )
          )
        ),

        nav_panel("EV por banda de edad",
          layout_columns(
            col_widths = c(12),
            card(
              full_screen = TRUE,
              card_header("Esperanza de Vida por banda de edad"),
              card_body(plotlyOutput("causas_ev_bandas", height = "450px"))
            )
          )
        )
      )
    )
  ),

  # ── TAB 5: Metodología ──
  nav_panel(
    title = tags$span(bsicons::bs_icon("book"), " Metodología"),
    div(class = "about-section",
      h2("Renta Mediana por Unidad de Consumo"),
      div(class = "definition-card",
        p("Según el INE, es la renta mediana por unidad de consumo de los hogares,
           calculada dividiendo los ingresos totales del hogar entre las unidades de consumo."),
        p(strong("Escala OCDE modificada:")),
        tags$ul(
          tags$li(strong("1,0"), " — primer adulto del hogar"),
          tags$li(strong("0,5"), " — cada adulto adicional (≥14 años)"),
          tags$li(strong("0,3"), " — cada menor de 14 años")
        ),
        p("Permite comparar la capacidad económica de hogares con distinto tamaño y composición.")
      ),

      h2("Indicadores demográficos"),
      div(class = "definition-card",
        tags$ul(
          tags$li(strong("Edad Media:"), " media de la edad de todos los residentes."),
          tags$li(strong("% Menores / Mayores:"), " proporción de población menor de 18 o mayor de 65."),
          tags$li(strong("Hogares unipersonales:"), " porcentaje de hogares con un solo residente."),
          tags$li(strong("Población extranjera:"), " porcentaje de residentes sin nacionalidad española.")
        )
      ),

      h2("Brecha de desigualdad"),
      div(class = "definition-card",
        p("El ratio P90/P10 compara la renta mediana del percentil 90 con la del percentil 10.
           Valores más altos indican mayor desigualdad territorial dentro de la zona seleccionada.")
      ),

      h2("Esperanza de Vida"),
      div(class = "definition-card",
        p("Número medio de años que le quedaría por vivir a una persona recién nacida si las tasas de mortalidad observadas durante el período de seguimiento (2011-2023) se mantuvieran constantes."),
        p("Se calcula mediante tablas de vida (método de Chiang, 1968) a partir de los microdatos de la BDLPA (Muestra del Censo de 2011, ~637.000 personas con seguimiento hasta 2023)."),
        p(strong("Desagregación geográfica:"), " Los valores están calculados a nivel de provincia, no de sección censal. Todas las secciones dentro de una provincia reciben el mismo valor porque el ID de persona en la BDLPA es un número secuencial de 6 dígitos que no contiene información geográfica más allá de la provincia."),
        p("Ver el pipeline ", tags$code("pipeline_esperanza_vida_por_causa.R"), " para más detalles metodológicos.")
      ),

      h2("Fuente de datos"),
      div(class = "definition-card",
        p("Instituto Nacional de Estadística (INE)."),
        p(tags$a(href = "https://www.ine.es/dyngs/INEbase/es/operacion.htm?c=Estadistica_C&cid=1254736177088&menu=ultiDatos&idp=1254735976608",
                 target = "_blank", "Atlas de Distribución de Renta de los Hogares (ADRH)")),
        p("BDLPA — Base de Datos Longitudinal de Población de Andalucía (Estadísticas Longitudinales de Supervivencia y Longevidad en Andalucía, cohorte censal 2011, seguimiento hasta 2023). Instituto de Estadística y Cartografía de Andalucía (IECA) y Universidad de Granada.")
      ),

      h2("Autoría y Financiación"),
      div(class = "definition-card",
        p(strong("Autores:"), " Miguel Ángel Luque-Fernández, Paloma Massó Guijarro, Gustavo Rivas Gervilla, Mario Rivera Izquierdo, Miguel Ángel Montero Alonso y Juan Manuel Melchor Rodríguez (Doctores de la UGR) — ",
          tags$a(href="https://migariane.github.io", target="_blank", "migariane.github.io")),
        hr(),
        div(style="margin-bottom: 15px;", tags$img(src="logo_ugr.png", height="60px")),
        p(strong("Agradecimientos / Financiación:"), "Plan Propio de Investigación y Transferencia de la Universidad de Granada. 2025. Programa 21. Programa de estimulación a la investigación.")
      )
    )
  )
)

# ── SERVER ──
server <- function(input, output, session) {

  # Diccionario de nombres para indicadores de series temporales
  ts_ind_names <- c(
    "Renta_Mediana_UC" = "Renta Mediana",
    "brecha_p90p10" = "Brecha P90/P10",
    "brecha_q1_q5" = "Brecha Q1 vs Q5",
    "q1_renta" = "Renta media Q1",
    "q5_renta" = "Renta media Q5",
    "edad_media" = "Edad Media",
    "pob" = "Población Total",
    "menor_18" = "% Menores 18",
    "mayor_65" = "% Mayores 65",
    "tam_hogar" = "Tamaño Hogar",
    "hogares_uni" = "% Hogares Unip.",
    "pob_esp" = "% Población Española",
    "pob_extranjera" = "% Población Extranjera",
    "EV_Hombres" = "EV Hombres",
    "EV_Mujeres" = "EV Mujeres",
    "EV_Media" = "EV Media"
  )

  # Map loading
  mapa_shp <- reactive({
    req(input$prov, input$year)
    archivo <- paste0("SHP_opt/seccionado_", input$year, ".rds")
    if (!file.exists(archivo)) return(NULL)

    m <- readRDS(archivo)
    if (input$prov == "Toda Andalucía") {
      m
    } else {
      cod <- datos %>% filter(Provincia == input$prov) %>% slice(1) %>% pull(id) %>% substr(1, 2)
      m %>% filter(CPRO == cod)
    }
  })

  mapa_final <- reactive({
    req(mapa_shp())
    left_join(mapa_shp(), datos %>% filter(año == input$year), by = c("CUSEC" = "id"))
  })

  datos_filtrados <- reactive({
    req(input$prov, input$year)
    if (input$prov == "Toda Andalucía") {
      datos %>% filter(año == input$year)
    } else {
      datos %>% filter(Provincia == input$prov, año == input$year)
    }
  })

  # Value boxes
  output$total_pob <- renderText({
    df <- datos_filtrados()
    if (nrow(df) == 0) return("N/A")
    format(sum(df$pob, na.rm = TRUE), big.mark = ".", decimal.mark = ",")
  })

  output$renta_media <- renderText({
    df <- datos_filtrados()
    media <- mean(df$Renta_Mediana_UC, na.rm = TRUE)
    if (is.na(media)) return("—")
    paste0(format(round(media), big.mark = ".", decimal.mark = ","), " €")
  })

  output$edad_prom <- renderText({
    df <- datos_filtrados()
    edad <- mean(df$edad_media, na.rm = TRUE)
    if (is.na(edad)) return("—")
    paste0(round(edad, 1), " años")
  })

  output$ev_prom <- renderText({
    df <- datos_filtrados()
    ev <- mean(df$EV_Media, na.rm = TRUE)
    if (is.na(ev)) return("—")
    paste0(round(ev, 1), " años")
  })

  output$brecha <- renderText({
    df <- datos_filtrados()
    if (nrow(df) < 10) return("—")
    q1 <- quantile(df$Renta_Mediana_UC, 0.1, na.rm = TRUE)
    q9 <- quantile(df$Renta_Mediana_UC, 0.9, na.rm = TRUE)
    if (is.na(q1) || q1 == 0) return("—")
    paste0(round(q9 / q1, 1), "x")
  })

  # ── Series Temporales: datos agregados por provincia ──
  ts_data <- reactive({
    req(input$ts_prov)

    df <- if (input$ts_prov == "Toda Andalucía") datos else datos %>% filter(Provincia == input$ts_prov)
    años_unicos <- sort(unique(df$año))

    result_list <- lapply(años_unicos, function(ann) {
      sub <- df %>% filter(año == ann)

      # Medias de indicadores
      medias <- c(
        Renta_Mediana_UC = mean(sub$Renta_Mediana_UC, na.rm = TRUE),
        edad_media = mean(sub$edad_media, na.rm = TRUE),
        pob = mean(sub$pob, na.rm = TRUE),
        menor_18 = mean(sub$menor_18, na.rm = TRUE),
        mayor_65 = mean(sub$mayor_65, na.rm = TRUE),
        tam_hogar = mean(sub$tam_hogar, na.rm = TRUE),
        hogares_uni = mean(sub$hogares_uni, na.rm = TRUE),
        pob_esp = mean(sub$pob_esp, na.rm = TRUE),
        pob_extranjera = mean(sub$pob_extranjera, na.rm = TRUE),
        EV_Hombres = mean(sub$EV_Hombres, na.rm = TRUE),
        EV_Mujeres = mean(sub$EV_Mujeres, na.rm = TRUE),
        EV_Media = mean(sub$EV_Media, na.rm = TRUE)
      )

      # Brecha P90/P10
      q1p <- quantile(sub$Renta_Mediana_UC, 0.1, na.rm = TRUE)
      q9p <- quantile(sub$Renta_Mediana_UC, 0.9, na.rm = TRUE)
      brecha_p90 <- if (is.na(q1p) || q1p == 0) NA_real_ else round(q9p / q1p, 2)

      # Quintiles Q1 y Q5
      q_renta <- ntile(sub$Renta_Mediana_UC, 5)
      q1_renta_val <- mean(sub$Renta_Mediana_UC[q_renta == 1], na.rm = TRUE)
      q5_renta_val <- mean(sub$Renta_Mediana_UC[q_renta == 5], na.rm = TRUE)

      data.frame(
        año = ann,
        t(medias),
        brecha_p90p10 = brecha_p90,
        q1_renta = q1_renta_val,
        q5_renta = q5_renta_val,
        brecha_q1_q5 = round(q5_renta_val / q1_renta_val, 2),
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
    })

    do.call(rbind, result_list)
  })

  # ── Series Temporales: título ──
  output$ts_title <- renderText({
    ind_name <- ts_ind_names[input$ts_ind]
    if (is.na(ind_name)) ind_name <- input$ts_ind
    paste0(input$ts_prov, " — ", ind_name)
  })

  # ── Series Temporales: gráfico de evolución ──
  output$ts_plot <- renderPlotly({
    req(ts_data(), input$ts_ind)
    df <- ts_data()
    val <- df[[input$ts_ind]]
    ind_name <- ts_ind_names[input$ts_ind]
    if (is.na(ind_name)) ind_name <- input$ts_ind

    if (all(is.na(val))) {
      return(plot_ly() %>% layout(title = "Sin datos disponibles"))
    }

    hover_text <- sapply(seq_len(nrow(df)), function(i) {
      v <- df[[input$ts_ind]][i]
      if (is.na(v)) return(paste0(df$año[i], ": Sin datos"))
      paste0(df$año[i], ": ", format_value(v, input$ts_ind))
    })

    plot_ly(df,
      x = ~año, y = ~val,
      type = "scatter", mode = "lines+markers",
      line = list(color = "#1a5276", width = 3),
      marker = list(color = "#1a5276", size = 10,
                    line = list(color = "#ffffff", width = 2)),
      text = hover_text,
      hovertemplate = "%{text}<extra></extra>",
      showlegend = FALSE
    ) %>%
      layout(
        xaxis = list(title = "Año", dtick = 1, gridcolor = "#e8e8e8"),
        yaxis = list(title = ind_name, gridcolor = "#e8e8e8"),
        plot_bgcolor = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 60, r = 20, t = 10, b = 50),
        hovermode = "x"
      )
  })

  # ── Series Temporales: estadísticos ──
  output$ts_stats <- renderText({
    req(ts_data(), input$ts_ind)
    df <- ts_data()
    val <- df[[input$ts_ind]]
    val <- val[!is.na(val)]

    if (length(val) == 0) return("Sin datos disponibles")
    if (length(val) < 2) {
      return(paste0("Valor (", df$año[1], "): ", format_value(val[1], input$ts_ind)))
    }

    cambio <- val[length(val)] - val[1]
    cambio_pct <- round(cambio / val[1] * 100, 1)

    paste0(
      "Media: ", format_value(mean(val), input$ts_ind), "\n",
      "Mín: ", format_value(min(val), input$ts_ind), " (", df$año[which.min(val)], ")\n",
      "Máx: ", format_value(max(val), input$ts_ind), " (", df$año[which.max(val)], ")\n",
      "Cambio ", df$año[1], "–", df$año[length(val)], ": ",
      ifelse(cambio >= 0, "+", ""), format_value(abs(cambio), input$ts_ind),
      " (", ifelse(cambio_pct >= 0, "+", ""), cambio_pct, "%)"
    )
  })

  # ── Renta vs EV scatter plot (con recta de regresión) ──
  output$renta_ev_scatter <- renderPlotly({
    df <- renta_provincia
    prov_sel <- input$prov_rel

    # Regresión lineal
    lm_fit <- lm(EV_Media ~ Renta_Media, data = df)
    r2 <- summary(lm_fit)$r.squared
    coefs <- coef(lm_fit)

    # Línea de regresión
    x_range <- seq(min(df$Renta_Media, na.rm = TRUE),
                   max(df$Renta_Media, na.rm = TRUE), length.out = 100)
    y_pred <- coefs[1] + coefs[2] * x_range

    # Colores: resaltar provincia seleccionada
    df$color <- ifelse(df$Provincia == prov_sel, "#e74c3c", "#1a5276")
    df$size <- ifelse(df$Provincia == prov_sel, 20, 14)
    df$alpha <- ifelse(df$Provincia == prov_sel, 1, 0.7)

    p <- plot_ly() %>%
      add_trace(
        x = ~x_range, y = ~y_pred,
        type = "scatter", mode = "lines",
        line = list(color = "rgba(231, 76, 60, 0.5)", width = 2, dash = "dash"),
        name = paste0("Tendencia lineal (R² = ", round(r2, 3), ")"),
        hovertemplate = paste0("Recta de regresión<extra></extra>")
      ) %>%
      add_trace(
        data = df,
        x = ~Renta_Media, y = ~EV_Media,
        type = "scatter", mode = "markers+text",
        text = ~Provincia,
        textposition = "top center",
        textfont = list(size = 10, color = ~color),
        marker = list(
          size = ~size,
          color = ~color,
          opacity = ~alpha,
          line = list(color = "#ffffff", width = 2)
        ),
        hovertemplate = paste0(
          "<b>%{text}</b><br>",
          "Renta media: %{x:,.0f} €<br>",
          "EV media: %{y:.1f} años<extra></extra>"
        ),
        showlegend = FALSE
      ) %>%
      layout(
        xaxis = list(title = "Renta mediana (€)", gridcolor = "#e8e8e8"),
        yaxis = list(title = "Esperanza de vida (años)", gridcolor = "#e8e8e8"),
        plot_bgcolor = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 50, r = 20, t = 10, b = 50),
        hovermode = "closest"
      )
    p
  })

  # ── EV por provincia y sexo (barras agrupadas) ──
  output$ev_provincia_sexo_bars <- renderPlotly({
    df <- datos %>%
      filter(año == 2022) %>%
      select(Provincia, EV_Hombres, EV_Mujeres) %>%
      distinct() %>%
      tidyr::pivot_longer(cols = c(EV_Hombres, EV_Mujeres),
                           names_to = "Sexo", values_to = "EV") %>%
      mutate(Sexo = recode(Sexo,
                           EV_Hombres = "Hombres",
                           EV_Mujeres = "Mujeres"))

    plot_ly(df,
      x = ~Provincia, y = ~EV, color = ~Sexo,
      type = "bar",
      colors = c(Hombres = "#1a5276", Mujeres = "#e74c3c"),
      barmode = "group",
      hovertemplate = paste0(
        "<b>%{x}</b><br>",
        "%{meta}: %{y:.1f} años<extra></extra>"
      )
    ) %>%
      layout(
        xaxis = list(title = "", tickangle = -30, gridcolor = "#e8e8e8"),
        yaxis = list(title = "Esperanza de vida (años)", gridcolor = "#e8e8e8"),
        legend = list(orientation = "h", y = -0.25, x = 0.3),
        plot_bgcolor = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 50, r = 20, t = 10, b = 80)
      )
  })

  # ── Coeficiente de correlación 
  output$correlacion_text <- renderText({
    df <- renta_provincia
    r <- cor(df$Renta_Media, df$EV_Media, use = "complete.obs")
    r2 <- r^2
    paste0(
      "r = ", round(r, 4), "\n",
      "R² = ", round(r2, 4), " (", round(r2 * 100, 1), "% de la varianza explicada)\n\n",
      "Interpretación: existe una correlación ",
      ifelse(abs(r) > 0.8, "muy fuerte",
             ifelse(abs(r) > 0.6, "fuerte",
                    ifelse(abs(r) > 0.4, "moderada",
                           ifelse(abs(r) > 0.2, "débil", "muy débil")))),
      " y ", ifelse(r > 0, "positiva", "negativa"),
      " entre la renta mediana y la esperanza de vida a nivel provincial."
    )
  })

  # ── Causas Mortalidad: EV observada ──
  output$ev_observada_valor <- renderText({
    df <- if (input$causa_sexo == "Hombres") tabla_vida_hombres else tabla_vida_mujeres
    paste0(df$esperanza_vida[1], " años")
  })
  output$ev_observada_sexo <- renderText({
    paste0("EV al nacer — ", input$causa_sexo)
  })

  #  Causas Mortalidad: Ganancia por causa (barras) ──
  output$causas_ganancia_plot <- renderPlotly({
    df <- ganancia_causas %>% filter(sexo == input$causa_sexo) %>% arrange(desc(ganancia_anos))
    df$causa <- factor(df$causa, levels = df$causa[order(df$ganancia_anos)])

    plot_ly(df,
      x = ~ganancia_anos,
      y = ~causa,
      type = "bar",
      orientation = "h",
      marker = list(
        color = ~colores_causas[causa],
        line = list(color = "#ffffff", width = 1)
      ),
      hovertemplate = paste0(
        "<b>%{y}</b><br>",
        "Ganancia: %{x:.2f} años<br>",
        "EV sin causa: %{customdata:.1f} años<extra></extra>"
      ),
      customdata = ~esperanza_vida_sin_causa
    ) %>%
      layout(
        xaxis = list(title = "Años ganados", gridcolor = "#e8e8e8"),
        yaxis = list(title = "", automargin = TRUE),
        plot_bgcolor = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 200, r = 20, t = 10, b = 50)
      )
  })

  # ── Causas Mortalidad: Tabla de ganancias ──
  output$causas_tabla <- DT::renderDataTable({
    df <- ganancia_causas %>% filter(sexo == input$causa_sexo) %>%
      arrange(desc(ganancia_anos)) %>%
      select(Causa = causa,
             `EV observada` = esperanza_vida_observada,
             `EV sin causa` = esperanza_vida_sin_causa,
             `Ganancia (años)` = ganancia_anos)
    DT::datatable(df, rownames = FALSE,
      options = list(pageLength = 10, dom = "t",
                     columnDefs = list(
                       list(className = "dt-right", targets = 1:3)
                     )),
      class = "cell-border stripe hover"
    ) %>%
      DT::formatRound(columns = 2:3, digits = 2) %>%
      DT::formatRound(columns = 4, digits = 2)
  })

  # ── Causas Mortalidad: EV por banda de edad ──
  output$causas_ev_bandas <- renderPlotly({
    df <- if (input$causa_sexo == "Hombres") tabla_vida_hombres else tabla_vida_mujeres

    # Forzar orden correcto de bandas de edad (evitar orden alfabetico)
    orden_bandas <- c("0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34",
                      "35-39", "40-44", "45-49", "50-54", "55-59", "60-64",
                      "65-69", "70-74", "75-79", "80-84", "85-89", "90+")
    df$banda <- factor(df$banda, levels = orden_bandas, ordered = TRUE)

    # Causa con mayor ganancia para mostrar la línea "sin causa"
    causa_top <- ganancia_causas %>%
      filter(sexo == input$causa_sexo) %>%
      slice_max(ganancia_anos, n = 1) %>%
      pull(causa)

    plot_ly() %>%
      add_trace(
        data = df,
        x = ~banda, y = ~esperanza_vida,
        type = "scatter", mode = "lines+markers",
        name = "EV observada",
        line = list(color = "#1a5276", width = 3),
        marker = list(color = "#1a5276", size = 8),
        hovertemplate = paste0(
          "Banda: %{x}<br>",
          "EV observada: %{y:.1f} años<extra></extra>"
        )
      ) %>%
      add_trace(
        data = df,
        x = ~banda, y = ~esperanza_vida_sin_causa,
        type = "scatter", mode = "lines+markers",
        name = paste0("Sin: ", causa_top),
        line = list(color = "#e74c3c", width = 3, dash = "dash"),
        marker = list(color = "#e74c3c", size = 8),
        hovertemplate = paste0(
          "Banda: %{x}<br>",
          "EV sin ", causa_top, ": %{y:.1f} años<extra></extra>"
        )
      ) %>%
      layout(
        xaxis = list(title = "Banda de edad", tickangle = -45, gridcolor = "#e8e8e8",
                     categoryorder = "array", categoryarray = orden_bandas),
        yaxis = list(title = "Esperanza de vida (años)", gridcolor = "#e8e8e8"),
        legend = list(orientation = "h", y = -0.3, x = 0.1),
        plot_bgcolor = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 50, r = 20, t = 10, b = 100)
      )
  })

  # Narrative
  output$narrativa <- renderText({
    generate_narrative(datos_filtrados(), input$prov, input$year, datos)
  })

  output$map_title <- renderText({
    req(input$prov, input$year)
    ind_name <- names(indicadores_completos)[indicadores_completos == input$ind]
    paste0(input$prov, " — ", ind_name, " (", input$year, ")")
  })

  # Map
  output$map <- renderLeaflet({
    req(mapa_final(), input$ind)
    res <- mapa_final()
    val <- res[[input$ind]]

    paleta <- get_palette(input$ind)
    rev <- input$ind %in% c("mayor_65", "edad_media")

    pal <- colorBin(paleta, domain = val, bins = 7, na.color = "#e0e0e0", reverse = rev)
    ind_name <- names(indicadores_completos)[indicadores_completos == input$ind]
    etiquetas <- build_tooltip(res, val, ind_name, input$ind)

    leaflet(res) %>%
      addProviderTiles(providers$CartoDB.PositronNoLabels) %>%
      addProviderTiles(providers$CartoDB.PositronOnlyLabels,
                       options = providerTileOptions(zIndex = 1000)) %>%
      addPolygons(
        fillColor = ~pal(val), color = "#ffffff", weight = 0.5,
        fillOpacity = 0.85, opacity = 1, label = etiquetas,
        labelOptions = labelOptions(
          style = list("padding" = "8px 12px", "background-color" = "rgba(255,255,255,0.96)",
                       "border" = "1px solid #ccc", "border-radius" = "8px",
                       "box-shadow" = "0 3px 10px rgba(0,0,0,0.15)"),
          textsize = "13px", direction = "auto"
        ),
        highlightOptions = highlightOptions(weight = 3, color = "#e67e22",
                                            fillOpacity = 0.95, bringToFront = TRUE)
      ) %>%
      addLegend(
        pal = pal, values = val, position = "bottomright", na.label = "Sin datos",
        title = HTML(paste0("<strong>", ind_name, "</strong>")),
        opacity = 1, labFormat = labelFormat(digits = 0, big.mark = ".", between = " – ")
      )
  })

  # AI Chat (Ollama local o API en la nube)
  if (ai_packages_ok && (ollama_running || openai_api_ok || gemini_api_ok)) {
    tryCatch({
      if (openai_api_ok) {
        cliente <- chat_openai(model = "gpt-4o-mini")
      } else if (gemini_api_ok) {
        cliente <- chat_google_gemini(model = "gemini-1.5-flash")
      } else {
        cliente <- chat_ollama(model = "llama3.2")
      }
      qc <- QueryChat$new(
        datos, "datos", client = cliente,
        greeting = paste(
          "¡Hola! Soy tu asistente de datos sobre desigualdades sociales en Andalucía.",
          "Puedo analizar renta, demografía y población por sección censal (2015-2022).",
          "¿Qué quieres explorar?"
        )
      )
      output$chat_panel <- renderUI({
        div(style = "max-width:900px; margin:1.5rem auto; padding:0 1rem;",
          h3(bsicons::bs_icon("robot"), " Asistente IA",
             style = "color:#1a5276; font-weight:800; margin-bottom:1rem;"),
          p("Pregunta en lenguaje natural sobre los datos de renta, población y demografía.",
            style = "color:#7f8c8d; margin-bottom:1.5rem;"),
          qc$ui()
        )
      })
      qc$server()
    }, error = function(e) {
      output$chat_panel <- renderUI({ chat_instructions_ui() })
    })
  } else {
    output$chat_panel <- renderUI({ chat_instructions_ui() })
  }
}

chat_instructions_ui <- function() {
  div(class = "chat-instructions-card",
    h3(bsicons::bs_icon("robot", size = "1.5em"), " Asistente IA no configurado"),
    p("Para usar el asistente de IA necesitas configurar un modelo local (Ollama) o una API externa (para uso en la nube).",
      style = "color:#5d6d7e; margin:1rem 0;"),
    
    h4("Opción 1: Uso Local (Ollama - Gratuito)"),
    div(class = "setup-step", span(class = "step-number", "1"), span("Instala Ollama desde ", tags$a(href = "https://ollama.com", target = "_blank", "ollama.com"))),
    div(class = "setup-step", span(class = "step-number", "2"), span("Descarga un modelo: ", tags$code("ollama pull llama3.2"))),
    div(class = "setup-step", span(class = "step-number", "3"), span("Inicia Ollama y reinicia esta aplicación Shiny")),
    
    h4(style="margin-top: 1.5rem;", "Opción 2: Uso en la Nube (shinyapps.io)"),
    div(class = "setup-step", span(class = "step-number", "1"), span("Configura una variable de entorno en el panel de shinyapps.io")),
    div(class = "setup-step", span(class = "step-number", "2"), span("Usa ", tags$code("OPENAI_API_KEY"), " o ", tags$code("GEMINI_API_KEY"))),
    p(tags$em("Asegúrate de NO escribir nunca estas claves directamente en el código fuente (app.R o global.R)."),
      style = "margin-top:1.2rem; color:#7f8c8d; font-size:0.85rem;")
  )
}

shinyApp(ui, server)
