# Desigualdades Sociales en Andalucía

Aplicación web interactiva (Shiny) para visualizar datos socioeconómicos y de renta de los hogares en Andalucía a nivel de sección censal (2015-2022). Incluye un Asistente Inteligente impulsado por IA que permite hacer preguntas sobre los datos en lenguaje natural, garantizando la máxima privacidad, ya que se ejecuta íntegramente de forma local.

**Autores:** Miguel Angel Luque Fernández, Gustavo Rivas Gervilla, Mario Rivera Izquierdo, Miguel Angel Montero Alonso y Juan Manuel Melchor Rodríguez (Doctores/Profesores de la UGR)

**Acceso en línea:** Puedes explorar la aplicación directamente en la web sin necesidad de instalación a través de [Shinyapps.io](https://watzile.shinyapps.io/RENTA/).

**Cita y Referencia (DOI):** Podrás encontrar y citar el repositorio y los datos en Zenodo a través del siguiente enlace: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21237758.svg)](https://doi.org/10.5281/zenodo.21237758)

---

## Cómo ejecutar la aplicación en tu propio ordenador

### 1. Requisitos Previos (R y RStudio)
Necesitas tener instalados **R** y **RStudio** en tu equipo. Además, la primera vez que abras el proyecto, asegúrate de instalar las librerías necesarias ejecutando el siguiente código en la consola de RStudio:
```R
install.packages(c("shiny", "bslib", "leaflet", "dplyr", "sf", "stringr", "htmltools", "ellmer"))
```
*(Nota: la librería `querychat` puede requerir instalación desde GitHub si no se encuentra en CRAN).*

### 2. Configurar el Asistente Inteligente (Ollama)
Esta aplicación utiliza **Ollama** para que la inteligencia artificial procese tus preguntas de manera 100% local, sin enviar tus datos a la nube (garantizando tu privacidad).

Sigue estos pasos para configurarlo:
1. **Descarga e instala Ollama**: Ve a [https://ollama.com](https://ollama.com) y descarga el instalador para tu sistema operativo (Windows, Mac o Linux).
2. **Descarga el modelo de lenguaje**: Abre tu terminal (en Mac/Linux) o símbolo del sistema/PowerShell (en Windows) y ejecuta el siguiente comando para descargar el modelo necesario:
   ```bash
   ollama pull llama3.2
   ```
   *(Este proceso puede tardar unos minutos dependiendo de tu conexión a internet).*
3. **Mantén Ollama abierto**: Asegúrate de que la aplicación de Ollama se está ejecutando en segundo plano (verás el icono de una llama en tu barra de tareas o barra superior).

### 3. Ejecutar la Aplicación
1. Abre el archivo `app.R` en RStudio.
2. Haz clic en el botón **"Run App"** (situado en la parte superior del panel de código).
3. ¡Listo! Ya puedes explorar los mapas sociodemográficos y hacerle preguntas al asistente inteligente en la pestaña "Asistente IA".

### 4. Licencia

Este proyecto está bajo la Licencia MIT. Esto significa que es un software de código abierto que permite la libre utilización, modificación, copia y distribución del código.
Enfoque Educativo y de Investigación

Hacemos especial énfasis en su uso con fines educativos, académicos y de investigación. Animamos a estudiantes, profesores e investigadores a utilizar esta herramienta para la formación en análisis socioeconómico, visualización de datos espaciales con R Shiny y el desarrollo de tecnologías de IA locales aplicadas a las ciencias sociales. Si utilizas este proyecto en tu investigación o material docente, te agradecemos que cites adecuadamente a los autores a través del enlace de Zenodo provisto anteriormente.

### 5. Financiación y Agradecimientos

<img src="https://www.ugr.es/sites/default/files/2021-10/UGR-Marca-Horizontal-Color.png" alt="Logo Universidad de Granada" width="300"/>

Este proyecto ha sido financiado por la **Universidad de Granada** en el marco del **Plan Propio de Investigación y Transferencia 2025**, específicamente bajo el **[Programa 21: Programa de Estimulación de la Investigación](https://investigacion.ugr.es/plan-propio/informacion/programas/p21)**.

