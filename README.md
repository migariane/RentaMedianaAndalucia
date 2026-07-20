# Desigualdades Sociales en Andalucía

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21237758.svg)](https://doi.org/10.5281/zenodo.21237758)
![R Shiny](https://img.shields.io/badge/Shiny-1.9.1-blue?logo=r)
![License](https://img.shields.io/badge/license-MIT-green)

<p align="center">
  <img src="www/logo_ugr.png" alt="Universidad de Granada" height="80">
</p>

Aplicación web interactiva (Shiny) para visualizar datos socioeconómicos, demográficos y de esperanza de vida en Andalucía a nivel de sección censal (2015–2022). Incluye estimaciones de esperanza de vida por provincia y sexo, descomposición por causas de mortalidad, brechas de desigualdad (P90/P10, Q1 vs Q5) y un Asistente Inteligente impulsado por IA para consultas en lenguaje natural.

**Autores:** Miguel Ángel Luque-Fernández, Paloma Massó Guijarro, Gustavo Rivas Gervilla, Maja Nikšić, Mario Rivera Izquierdo, Miguel Ángel Montero Alonso y Juan Manuel Melchor Rodríguez (Doctores de la UGR)

**Web:** [migariane.github.io](https://migariane.github.io)

**Shiny App:** [watzile.shinyapps.io/RENTA/](https://watzile.shinyapps.io/RENTA/)

---

## Funcionalidades

- **Mapa interactivo:** 12 indicadores socioeconómicos y de esperanza de vida por sección censal (2015–2022)
- **Asistente IA:** consultas en lenguaje natural mediante Ollama (local) o API externa (OpenAI, Gemini)
- **Series temporales:** evolución anual de renta, brechas y esperanza de vida por provincia
- **Relaciones:** correlación renta–esperanza de vida con clustering y GAM
- **Causas de mortalidad:** descomposición de ganancias en esperanza de vida por 10 grupos de causas

## Cómo citar

Si utilizas esta aplicación en una publicación, por favor cítala como:

> Luque-Fernández MA, Massó Guijarro P, Rivas Gervilla G, Nikšić M, Rivera Izquierdo M, Montero Alonso MÁ, Melchor Rodríguez JM. RENTASALUD: A Web-Based Interactive Atlas of Social Inequalities and Life Expectancy in Andalusia (Southern Spain). University of Granada; 2025. DOI: [10.5281/zenodo.21237758](https://doi.org/10.5281/zenodo.21237758)

## Fuentes de datos

| Indicador | Fuente |
|-----------|--------|
| Renta y demografía | INE — Atlas de Distribución de Renta de los Hogares (2015–2022) |
| Esperanza de Vida | BDLPA — Base de Datos Longitudinal de Población de Andalucía (IECA–UGR, cohorte 2011, seguimiento hasta 2023) |

## Instalación y ejecución local

### 1. Requisitos
```r
install.packages(c("shiny", "bslib", "leaflet", "dplyr", "sf", "stringr",
                   "htmltools", "plotly", "ellmer"))
```

### 2. Configurar Asistente IA (opcional)
```bash
ollama pull llama3.2
```

### 3. Ejecutar
Abrir `app.R` en RStudio y hacer clic en **Run App**.

## Autores y financiación

**Autores (UGR):** Miguel Ángel Luque-Fernández, Paloma Massó Guijarro, Gustavo Rivas Gervilla, Mario Rivera Izquierdo, Miguel Ángel Montero Alonso y Juan Manuel Melchor Rodríguez

**Colaboración internacional:** Maja Nikšić (Centre for Health Services Studies, University of Kent)

**Financiación:** Plan Propio de Investigación y Transferencia de la Universidad de Granada. 2025. Programa 21. Programa de estimulación a la investigación.

## Licencia

MIT License. Copyright (c) 2025 Universidad de Granada.
