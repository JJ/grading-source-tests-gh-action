# Plan: Validación del README.md (Objetivo 0)

Este documento describe el plan para implementar un script (diseñado para ejecutarse en una GitHub Action) que procesará el archivo `README.md` del estudiante correspondiente al **Objetivo 0**, identificará errores comunes y generará un reporte con errores fatales (kill-level) y advertencias (warnings).

## 1. Procesamiento del archivo `README.md`
El primer paso consiste en transformar el `README.md` original en un formato adecuado para el análisis léxico y semántico.

- **Extracción de texto relevante:**
  - Leer el contenido del archivo `README.md`.
  - Ignorar las secciones irrelevantes como el título del repositorio o índices, enfocándose en la sección donde se describe el problema/idea.
  - Eliminar bloques de código (```...```), enlaces markdown (`[texto](url)`), imágenes y formato (negritas, cursivas).
- **Normalización:**
  - Convertir todo el texto a minúsculas.
  - Eliminar signos de puntuación innecesarios para facilitar las expresiones regulares, pero manteniendo la estructura de las frases para detectar el contexto.
  - Tokenización básica o división en oraciones para poder referenciar las líneas en el reporte.

## 2. Detección de Errores Comunes
Se aplicarán expresiones regulares y heurísticas sobre el texto procesado basándose en los documentos de "errores comunes". Los problemas detectados se clasificarán en dos niveles:

### Errores Fatales (Kill-level errors)
Estos errores indican que el objetivo será rechazado directamente si lo lee el profesor. Causarán que la GitHub Action falle (`exit code 1`).

- **Describir una solución en lugar de un problema:**
  - Patrones a buscar: `"quiero hacer una aplicación"`, `"vamos a desarrollar una web"`, `"mi aplicación hará"`, `"el programa consistirá en"`.
  - Justificación: El objetivo pide describir un problema, no la herramienta o solución técnica.
- **Expresar el problema como un simple deseo del cliente:**
  - Patrones a buscar: `"el cliente quiere"`, `"la persona desea"`.
  - Justificación: Los deseos no expresan la raíz del problema (el "por qué" o la necesidad real).
- **Empezar la descripción definiendo vagamente el problema:**
  - Patrones a buscar: `"el problema de..."` (ej. "el problema del transporte").
  - Justificación: Indica una descripción demasiado genérica que no aterriza en un problema específico y resoluble.
- **Uso exclusivo de verbos CRUD / Ausencia de lógica de negocio real:**
  - Si se describe la lógica (aunque no se pide explícitamente en la solución en este punto, a veces los alumnos lo incluyen), el uso **exclusivo** de verbos prohibidos es fatal.
  - Patrones a buscar (prohibidos): `"buscar"`, `"dar de alta"`, `"poner en contacto"`, `"visualizar"`, `"avisar"`, `"enviar"`, `"recuperar"`, `"integrar"`, `"alertar"`, `"comunicar"`.

### Advertencias (Warnings)
Estos errores indican malas prácticas o posibles rechazos dependiendo de la severidad o revisión manual. No fallan la Action, pero advierten al estudiante.

- **Introducción de múltiples problemas:**
  - Patrones a buscar: Uso recurrente de la palabra `"además"`, `"también queremos"`.
  - Justificación: Se debe definir un solo problema con una clientela clara. Usar "además" suele introducir nuevos problemas (scope creep).
- **Falta de verbos de lógica de negocio (si corresponde):**
  - Si el texto parece describir operaciones, sugerir que se verifique la existencia de palabras clave como: `"calcular"`, `"generar"`, `"extraer"`, `"resumir"`, `"filtrar"`, `"validar"`, `"analizar"`.
- **Problema demasiado corto/vago:**
  - Heurística: Si la descripción del problema tiene menos de X palabras (por ejemplo, menos de 50 palabras).
  - Justificación: Sugiere que no se ha empatizado ni profundizado lo suficiente en el problema del cliente.

## 3. Generación del Reporte (GitHub Action)
El script recopilará todos los hallazgos y producirá un informe estructurado.

- **Formato de Salida:**
  - **Anotaciones de GitHub:** Emitir comandos de flujo de trabajo (`::error file=README.md,line=X::Mensaje` y `::warning file=README.md,line=X::Mensaje`) para que los comentarios aparezcan directamente en la pestaña "Files changed" del Pull Request.
  - **Resumen Markdown:** Escribir un resumen detallado en el `GITHUB_STEP_SUMMARY` para que el estudiante pueda leer el contexto completo en la vista del Action.
- **Mensajes Accionables:**
  - Cada error o advertencia incluirá un mensaje claro de por qué está mal, citando la regla correspondiente (ej. *"Estás describiendo una solución ('quiero hacer una app') en lugar del problema subyacente. Revisa la sección 'Sobre el contenido específico de este objetivo'"*).
