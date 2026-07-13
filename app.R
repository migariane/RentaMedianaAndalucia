source("global.R")

#  UI 
ui <- page_navbar(
  title = tags$span(
    bsicons::bs_icon("globe-americas", size = "1.2em"),
    " Desigualdades Sociales en Andalucía"
  ),
  theme = app_theme,
  header = tags$head(tags$link(rel = "stylesheet", href = "custom.css")),
  fillable = TRUE,

  #  TAB 1: Explorar 
  nav_panel(
    title = tags$span(bsicons::bs_icon("map"), " Explorar"),
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        selectInput("prov", "Provincia:", provincias_disponibles),
        selectInput("ind", "Indicador:", indicadores_completos, selected = "Renta_Mediana_UC"),
        sliderInput("year", "Año:", min = 2015, max = 2022, value = 2022, sep = "",
                    animate = animationOptions(interval = 2500, loop = FALSE)),
        hr(),
        accordion(
          accordion_panel("Información", icon = bsicons::bs_icon("info-circle"),
            p(strong("Datos:"), "Secciones censales de Andalucía, 2015-2022."),
            p(strong("Fuente:"), "INE — Atlas de Distribución de Renta de los Hogares."),
            p(strong("Cartografía:"), "Shapefiles por año (INE)."),
            hr(),
            p(strong("Autores:"), "Miguel Ángel Luque-Fernández, Gustavo Rivas Gervilla, Mario Rivera Izquierdo, Miguel Ángel Montero Alonso y Juan Manuel Melchor Rodríguez (Doctores de la UGR)"),
            p(strong("Web:"), tags$a(href="https://migariane.github.io", target="_blank", "migariane.github.io")),
            hr(),
            div(style="text-align: center;", tags$img(src="logo_ugr.png", height="50px", style="margin-bottom: 10px;")),
            p(style="font-size: 0.85em; color: #5d6d7e;", strong("Financiación:"), "Plan Propio de Investigación y Transferencia de la Universidad de Granada. 2025. Programa 21. Programa de estimulación a la investigación.")
          ),
          accordion_panel("Ayuda", icon = bsicons::bs_icon("question-circle"),
            tags$ul(
              tags$li("Selecciona provincia e indicador para actualizar el mapa."),
              tags$li("Mueve el slider para ver la evolución temporal."),
              tags$li("Pasa el cursor sobre las secciones para ver detalles."),
              tags$li("Pulsa ▶ para animar la evolución anual.")
            )
          )
        )
      ),

      layout_columns(
        col_widths = c(3, 3, 3, 3), fill = FALSE,
        value_box("Población", textOutput("total_pob"),
                  showcase = bsicons::bs_icon("people-fill"), theme = "primary"),
        value_box("Renta Mediana", textOutput("renta_media"),
                  showcase = bsicons::bs_icon("currency-euro"), theme = "success"),
        value_box("Edad Media", textOutput("edad_prom"),
                  showcase = bsicons::bs_icon("person"), theme = "info"),
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
          div(strong("Mapa por sección censal"), " — ", textOutput("map_title", inline = TRUE))
        ),
        card_body(leafletOutput("map", height = "550px"))
      ),

      div(class = "app-footer",
        HTML("Fuente: INE &middot; Atlas de Distribución de Renta de los Hogares &middot; Secciones censales 2015-2022 <br> Autores: Miguel Ángel Luque-Fernández, Gustavo Rivas Gervilla, Mario Rivera Izquierdo, Miguel Ángel Montero Alonso y Juan Manuel Melchor Rodríguez")
      )
    )
  ),

  #  TAB 2: Series Temporales 
  nav_panel(
    title = tags$span(bsicons::bs_icon("graph-up"), " Series Temporales"),
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        selectInput("prov_ts", "Provincia:", provincias_disponibles),
        selectInput("ind_ts", "Indicador:", indicadores_ts, selected = "Renta_Mediana_UC"),
        checkboxInput("compare_and", "Comparar con media de Andalucía", value = TRUE),
        hr(),
        uiOutput("ts_summary_box"),
        hr(),
        accordion(
          accordion_panel("Información", icon = bsicons::bs_icon("info-circle"),
            p("Evolución anual 2015-2022 del indicador seleccionado, agregado por provincia
               (media simple entre secciones censales; suma en el caso de Población)."),
            p(strong("Brecha P90/P10:"), " ratio entre la renta mediana del percentil 90
               y del percentil 10 de las secciones censales del área seleccionada.")
          )
        )
      ),
      card(
        full_screen = TRUE,
        card_header(
          class = "d-flex justify-content-between align-items-center",
          div(strong("Evolución temporal (2015-2022)"), " — ", textOutput("ts_title", inline = TRUE))
        ),
        card_body(plotlyOutput("ts_plot", height = "480px"))
      ),
      card(
        card_header(strong("Datos por año")),
        card_body(tableOutput("ts_table"))
      )
    )
  ),

  # TAB 3: Informe (conclusiones y curso de acción) 
  nav_panel(
    title = tags$span(bsicons::bs_icon("file-earmark-text"), " Informe"),
    div(class = "about-section",

      h2("Resumen ejecutivo"),
      div(class = "definition-card",
        p(sprintf(
          paste0("Entre %d y %d, la renta mediana por unidad de consumo en Andalucía pasó de %s € ",
                 "a %s € (un %s%% de crecimiento). Sin embargo, la desigualdad territorial apenas se ",
                 "ha movido: la brecha P90/P10 fue de %sx en %d y de %sx en %d."),
          informe_stats$anio_ini, informe_stats$anio_fin,
          format(round(informe_stats$renta_ini), big.mark = ".", decimal.mark = ","),
          format(round(informe_stats$renta_fin), big.mark = ".", decimal.mark = ","),
          informe_stats$crecimiento_renta,
          round(informe_stats$brecha_ini, 2), informe_stats$anio_ini,
          round(informe_stats$brecha_fin, 2), informe_stats$anio_fin
        ))
      ),

      h2("Resultados principales"),
      div(class = "definition-card",
        tags$ul(
          tags$li(strong("Renta: "), sprintf(
            "crecimiento sostenido del %s%% en Andalucía (%d-%d), liderado por las provincias con mayor
             dinamismo económico; algunas zonas del interior crecen algo menos.",
            informe_stats$crecimiento_renta, informe_stats$anio_ini, informe_stats$anio_fin)),
          tags$li(strong("Desigualdad interna: "), sprintf(
            "la brecha P90/P10 se mantiene estable (%sx → %sx): el crecimiento económico no reduce
             la desigualdad territorial relativa.",
            round(informe_stats$brecha_ini, 2), round(informe_stats$brecha_fin, 2))),
          tags$li(strong("Envejecimiento: "), sprintf(
            "la edad media sube de %s a %s años y el %% de mayores de 65 pasa de %s%% a %s%%.",
            round(informe_stats$edad_ini, 1), round(informe_stats$edad_fin, 1),
            round(informe_stats$mayor65_ini, 1), round(informe_stats$mayor65_fin, 1))),
          tags$li(strong("Hogares unipersonales: "), sprintf(
            "suben de %s%% a %s%%, coherente con el envejecimiento y con posibles focos de
             vulnerabilidad social.",
            round(informe_stats$hogares_uni_ini, 1), round(informe_stats$hogares_uni_fin, 1))),
          tags$li(strong("Población extranjera: "), sprintf(
            "sube de %s%% a %s%% de media, con fuerte heterogeneidad provincial.",
            round(informe_stats$extranjera_ini, 1), round(informe_stats$extranjera_fin, 1)))
        )
      ),

      h2("Extremos territoriales"),
      div(class = "definition-card",
        p(sprintf(
          paste0("En %d, la sección con mayor renta mediana es %s (%s, %s €), mientras que la de menor ",
                 "renta es %s (%s, %s €) — una diferencia de más de %sx entre ambas."),
          informe_stats$anio_fin,
          informe_stats$sec_max$Municipio, informe_stats$sec_max$Provincia,
          format(round(informe_stats$sec_max$Renta_Mediana_UC), big.mark = ".", decimal.mark = ","),
          informe_stats$sec_min$Municipio, informe_stats$sec_min$Provincia,
          format(round(informe_stats$sec_min$Renta_Mediana_UC), big.mark = ".", decimal.mark = ","),
          round(informe_stats$sec_max$Renta_Mediana_UC / informe_stats$sec_min$Renta_Mediana_UC, 1)
        ))
      ),

      h2("Conclusiones"),
      div(class = "definition-card",
        p("Andalucía mejora en términos absolutos de renta, pero no reduce su desigualdad territorial
           relativa: el crecimiento económico no se traduce en convergencia entre secciones censales.
           A esto se suma un envejecimiento estructural y una fragmentación de los hogares que,
           combinados con la desigualdad de renta, dibujan focos de vulnerabilidad muy localizados
           que un mapa provincial agregado no captaría — de ahí el valor de trabajar a nivel de
           sección censal, como permite esta aplicación.")
      ),

      h2("Curso de acción sugerido"),
      div(class = "definition-card",
        p(strong("Para explotar mejor los resultados de la app:")),
        tags$ol(
          tags$li("Automatizar un ranking de \u201csecciones cr\u00edticas\u201d cruzando renta baja +
                    brecha alta + % hogares unipersonales alto."),
          tags$li("Complementar el ratio P90/P10 con un \u00edndice de Gini o Theil por secci\u00f3n,
                    m\u00e1s robusto y est\u00e1ndar en la literatura de desigualdad territorial."),
          tags$li("Cruzar renta por secci\u00f3n censal con indicadores de salud mediante m\u00e9todos
                    causales (TMLE / g-computation) para estudiar gradientes sociales en salud a
                    nivel fino.")
        ),
        p(strong("Para uso divulgativo/institucional:")),
        tags$ol(
          tags$li("Generar autom\u00e1ticamente un informe PDF/Word anual con `generate_narrative()`
                    y los datos m\u00e1s recientes."),
          tags$li("Usar el asistente de IA (querychat) como canal para consultas ad-hoc de
                    responsables municipales sobre sus secciones.")
        )
      ),

      p(style = "font-size:0.85em; color:#7f8c8d; margin-top:1.5rem;",
        sprintf(
          "Informe generado autom\u00e1ticamente a partir de %s secciones censales (INE, Atlas de
           Distribuci\u00f3n de Renta de los Hogares, %d-%d).",
          format(informe_stats$n_secciones_fin, big.mark = "."),
          informe_stats$anio_ini, informe_stats$anio_fin
        ))
    )
  ),

  #  TAB 4: Asistente IA 
  nav_panel(
    title = tags$span(bsicons::bs_icon("robot"), " Asistente IA"),
    uiOutput("chat_panel")
  ),

  # TAB 5: Metodología 
  nav_panel(
    title = tags$span(bsicons::bs_icon("book"), " Metodología"),
    div(class = "about-section",
      h2("Renta Mediana por Unidad de Consumo"),
      div(class = "definition-card",
        p("Según el INE, es la renta mediana por unidad de consumo de los hogares,
           calculada dividiendo los ingresos totales del hogar entre las unidades de consumo."),
        p(strong("Escala OCDE modificada:")),
        tags$ul(
          tags$li(strong("1,0"), " — primer adulto del hogar"),
          tags$li(strong("0,5"), " — cada adulto adicional (≥14 años)"),
          tags$li(strong("0,3"), " — cada menor de 14 años")
        ),
        p("Permite comparar la capacidad económica de hogares con distinto tamaño y composición.")
      ),

      h2("Indicadores demográficos"),
      div(class = "definition-card",
        tags$ul(
          tags$li(strong("Edad Media:"), " media de la edad de todos los residentes."),
          tags$li(strong("% Menores / Mayores:"), " proporción de población menor de 18 o mayor de 65."),
          tags$li(strong("Hogares unipersonales:"), " porcentaje de hogares con un solo residente."),
          tags$li(strong("Población extranjera:"), " porcentaje de residentes sin nacionalidad española.")
        )
      ),

      h2("Brecha de desigualdad"),
      div(class = "definition-card",
        p("El ratio P90/P10 compara la renta mediana del percentil 90 con la del percentil 10.
           Valores más altos indican mayor desigualdad territorial dentro de la zona seleccionada.")
      ),

      h2("Fuente de datos"),
      div(class = "definition-card",
        p("Instituto Nacional de Estadística (INE)."),
        p(tags$a(href = "https://www.ine.es/dyngs/INEbase/es/operacion.htm?c=Estadistica_C&cid=1254736177088&menu=ultiDatos&idp=1254735976608",
                 target = "_blank", "Atlas de Distribución de Renta de los Hogares (ADRH)"))
      ),

      h2("Autoría y Financiación"),
      div(class = "definition-card",
        p(strong("Autores:"), " Miguel Ángel Luque-Fernández, Gustavo Rivas Gervilla, Mario Rivera Izquierdo, Miguel Ángel Montero Alonso y Juan Manuel Melchor Rodríguez (Doctores de la UGR)"),
        p(strong("Página Web (MALF):"), tags$a(href="https://migariane.github.io", target="_blank", "migariane.github.io")),
        hr(),
        div(style="margin-bottom: 15px;", tags$img(src="logo_ugr.png", height="60px")),
        p(strong("Agradecimientos / Financiación:"), "Plan Propio de Investigación y Transferencia de la Universidad de Granada. 2025. Programa 21. Programa de estimulación a la investigación.")
      )
    )
  )
)

# SERVER 
server <- function(input, output, session) {

  # Map loading
  mapa_shp <- reactive({
    req(input$prov, input$year)
    archivo <- paste0("SHP_opt/seccionado_", input$year, ".rds")
    if (!file.exists(archivo)) return(NULL)

    m <- readRDS(archivo)
    if (input$prov == "Toda Andalucía") {
      m
    } else {
      cod <- datos %>% filter(Provincia == input$prov) %>% slice(1) %>% pull(id) %>% substr(1, 2)
      m %>% filter(CPRO == cod)
    }
  })

  mapa_final <- reactive({
    req(mapa_shp())
    left_join(mapa_shp(), datos %>% filter(año == input$year), by = c("CUSEC" = "id"))
  })

  datos_filtrados <- reactive({
    req(input$prov, input$year)
    if (input$prov == "Toda Andalucía") {
      datos %>% filter(año == input$year)
    } else {
      datos %>% filter(Provincia == input$prov, año == input$year)
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
    paste0(round(edad, 1), " años")
  })

  output$brecha <- renderText({
    df <- datos_filtrados()
    if (nrow(df) < 10) return("—")
    q1 <- quantile(df$Renta_Mediana_UC, 0.1, na.rm = TRUE)
    q9 <- quantile(df$Renta_Mediana_UC, 0.9, na.rm = TRUE)
    if (is.na(q1) || q1 == 0) return("—")
    paste0(round(q9 / q1, 1), "x")
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

  # ── Series Temporales ──
  ts_series <- reactive({
    req(input$prov_ts, input$ind_ts)
    calc_ts(datos, input$prov_ts, input$ind_ts)
  })

  ts_series_and <- reactive({
    req(input$ind_ts)
    calc_ts(datos, "Toda Andalucía", input$ind_ts)
  })

  output$ts_title <- renderText({
    req(input$prov_ts, input$ind_ts)
    nombre_ind <- names(indicadores_ts)[indicadores_ts == input$ind_ts]
    paste0(input$prov_ts, " — ", nombre_ind)
  })

  output$ts_plot <- renderPlotly({
    req(ts_series())
    serie <- ts_series()
    nombre_ind <- names(indicadores_ts)[indicadores_ts == input$ind_ts]

    p <- plot_ly() %>%
      add_trace(
        data = serie, x = ~año, y = ~valor, type = "scatter", mode = "lines+markers",
        name = input$prov_ts,
        line = list(color = "#1a5276", width = 3),
        marker = list(color = "#1a5276", size = 7)
      )

    if (isTRUE(input$compare_and) && input$prov_ts != "Toda Andalucía") {
      serie_and <- ts_series_and()
      p <- p %>% add_trace(
        data = serie_and, x = ~año, y = ~valor, type = "scatter", mode = "lines",
        name = "Toda Andalucía",
        line = list(color = "#5d6d7e", width = 2, dash = "dash")
      )
    }

    p %>% layout(
      xaxis = list(title = "Año", dtick = 1),
      yaxis = list(title = nombre_ind),
      hovermode = "x unified",
      legend = list(orientation = "h", y = -0.2),
      font = list(family = "Inter, sans-serif"),
      margin = list(t = 20)
    )
  })

  output$ts_table <- renderTable({
    req(ts_series())
    serie <- ts_series()
    ind <- input$ind_ts
    serie %>%
      mutate(Valor = sapply(valor, function(v) {
        if (ind == "brecha") {
          if (is.na(v)) "—" else paste0(round(v, 2), "x")
        } else {
          format_value(v, ind)
        }
      })) %>%
      select(Año = año, Valor)
  }, striped = TRUE, bordered = TRUE, hover = TRUE, width = "100%")

  output$ts_summary_box <- renderUI({
    serie <- ts_series()
    if (nrow(serie) < 2) return(NULL)
    v_ini <- serie$valor[serie$año == min(serie$año)]
    v_fin <- serie$valor[serie$año == max(serie$año)]
    if (is.na(v_ini) || is.na(v_fin) || v_ini == 0) return(NULL)

    cambio <- round((v_fin - v_ini) / v_ini * 100, 1)
    color <- if (cambio >= 0) "#1e8449" else "#c0392b"
    icono <- if (cambio >= 0) "arrow-up-circle-fill" else "arrow-down-circle-fill"

    div(style = paste0("padding:12px; background:#f4f6f7; border-radius:10px; border-left:4px solid ", color, ";"),
      div(style = "font-size:0.85em; color:#5d6d7e;",
          paste0("Cambio ", min(serie$año), " \u2192 ", max(serie$año))),
      div(style = paste0("font-size:1.4em; font-weight:800; color:", color, ";"),
          bsicons::bs_icon(icono), paste0(" ", ifelse(cambio >= 0, "+", ""), cambio, "%"))
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
          "¡Hola! Soy tu asistente de datos sobre desigualdades sociales en Andalucía.",
          "Puedo analizar renta, demografía y población por sección censal (2015-2022).",
          "¿Qué quieres explorar?"
        )
      )
      output$chat_panel <- renderUI({
        div(style = "max-width:900px; margin:1.5rem auto; padding:0 1rem;",
          h3(bsicons::bs_icon("robot"), " Asistente IA",
             style = "color:#1a5276; font-weight:800; margin-bottom:1rem;"),
          p("Pregunta en lenguaje natural sobre los datos de renta, población y demografía.",
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
    
    h4("Opción 1: Uso Local (Ollama - Gratuito)"),
    div(class = "setup-step", span(class = "step-number", "1"), span("Instala Ollama desde ", tags$a(href = "https://ollama.com", target = "_blank", "ollama.com"))),
    div(class = "setup-step", span(class = "step-number", "2"), span("Descarga un modelo: ", tags$code("ollama pull llama3.2"))),
    div(class = "setup-step", span(class = "step-number", "3"), span("Inicia Ollama y reinicia esta aplicación Shiny")),
    
    h4(style="margin-top: 1.5rem;", "Opción 2: Uso en la Nube (shinyapps.io)"),
    div(class = "setup-step", span(class = "step-number", "1"), span("Configura una variable de entorno en el panel de shinyapps.io")),
    div(class = "setup-step", span(class = "step-number", "2"), span("Usa ", tags$code("OPENAI_API_KEY"), " o ", tags$code("GEMINI_API_KEY"))),
    p(tags$em("Asegúrate de NO escribir nunca estas claves directamente en el código fuente (app.R o global.R)."),
      style = "margin-top:1.2rem; color:#7f8c8d; font-size:0.85rem;")
  )
}

shinyApp(ui, server)
