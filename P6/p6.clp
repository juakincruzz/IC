;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; SISTEMA EXPERTO DE RECOMENDACIÓN CULINARIA CON FACTORES DE CERTEZA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; AUTORES: Joaquin Cruz Lorenzo y Jose Gomez Moreno-Torres
;;; FECHA: Junio 2025
;;;
;;; ARQUITECTURA MODULAR:
;;; • PREGUNTAS: Interfaz simplificada 
;;; • PROPIEDADES-RECETAS: Motor de inferencia nutricional 
;;; • RECETAS-COMPATIBLES: Sistema de filtrado multi-criterio
;;; • EVALUACION-CERTEZA: Algoritmo de factores de certeza y selección óptima
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Regla principal de ejecución del sistema
(defrule ejecutar
=>
(focus EVALUACION-CERTEZA)   ; Evaluación final con factores de certeza
(focus RECETAS-COMPATIBLES)  ; Filtrado de recetas según criterios
(focus PROPIEDADES-RECETAS)  ; Análisis nutricional automático
(focus PREGUNTAS)            ; Interfaz simplificada del usuario
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MÓDULO DE INTERFAZ SIMPLIFICADA 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule PREGUNTAS (export deftemplate ?ALL))

;;; Función de validación para opciones de entrada
(deffunction PREGUNTAS::validar-opcion (?valor-entrada ?opciones-validas)
  "Valida si la entrada del usuario está en la lista de opciones válidas"
  (bind ?es-opcion-valida FALSE)
  (if (neq ?valor-entrada -1)
    then
    (foreach ?opcion-disponible ?opciones-validas
      (if (eq (str-compare ?valor-entrada ?opcion-disponible) 0)
        then (bind ?es-opcion-valida TRUE)
      )
    )
  else
    (bind ?es-opcion-valida TRUE) ; -1 siempre es válido (omitir pregunta)
  )
  ?es-opcion-valida
)

;;; Mensaje de bienvenida del sistema
(defrule PREGUNTAS::pregunta-inicial
=>
(printout t crlf "================================================================" crlf)
(printout t "       SISTEMA EXPERTO DE RECOMENDACIÓN CULINARIA" crlf)
(printout t "              CON FACTORES DE CERTEZA" crlf)
(printout t "================================================================" crlf)
(printout t "Le ayudaré a encontrar la receta ideal usando análisis de certeza." crlf)
(printout t "Responda las siguientes preguntas para una recomendación óptima." crlf)
(printout t "================================================================" crlf crlf)
)

;;; PREGUNTA 1: Número de comensales
(defrule PREGUNTAS::preguntar-numero-comensales
=>
(printout t "CONFIGURACIÓN DE PORCIONES" crlf)
(printout t "===========================" crlf)
(printout t "¿Cuántas personas disfrutarán de esta maravillosa receta?" crlf) 
(printout t "Es importante saberlo para calcular cantidades adecuadas." crlf)
(printout t ">>> ")
(bind ?cantidad-comensales (read))
; Validar que la entrada sea un número entero positivo o -1 para omitir
(if (and (not (eq ?cantidad-comensales -1)) (and (integerp ?cantidad-comensales) (> ?cantidad-comensales 0)))
  then
  (assert (numero-comensales ?cantidad-comensales))
  (printout t "Perfecto! Buscaré opciones para " ?cantidad-comensales " personas." crlf)
else
  (printout t "Usando valor por defecto de 4 personas." crlf)
  (assert (numero-comensales 4))
)
(printout t crlf)
)

;;; PREGUNTA 2: Categoría de servicio
(defrule PREGUNTAS::preguntar-categoria-servicio
=>
(printout t "CATEGORÍA DE SERVICIO" crlf)
(printout t "=====================" crlf)
(printout t "¿Qué tipo de comida desea?" crlf)
(printout t "¿Algo para picar o algo que le deje completamente satisfecho?" crlf)
(printout t "Seleccione la categoría de servicio:" crlf)
(printout t "Opciones: entrante, primer_plato, plato_principal, postre, desayuno_merienda, acompanamiento" crlf)
(printout t ">>> ")
(bind ?categoria-servicio (read))
(bind ?opciones-categoria (create$ "entrante" "primer_plato" "plato_principal" "postre" "desayuno_merienda" "acompanamiento"))
(if (validar-opcion ?categoria-servicio ?opciones-categoria)
  then
  (if (neq ?categoria-servicio -1)
    then 
    (assert (para-cuando ?categoria-servicio))
    (printout t "Excelente! Buscaré opciones de " ?categoria-servicio "." crlf)
  else
    (assert (para-cuando plato_principal))
    (printout t "Usando 'plato_principal' por defecto." crlf)
  )
else
  (assert (para-cuando plato_principal))
  (printout t "Categoría no válida. Usando 'plato_principal' por defecto." crlf)
)
(printout t crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MÓDULO DE ANÁLISIS NUTRICIONAL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule PROPIEDADES-RECETAS (export deftemplate receta propiedad_receta plato-asociado) (import PREGUNTAS deftemplate ?ALL))

;;; Template principal para recetas
(deftemplate PROPIEDADES-RECETAS::receta
(slot nombre)
(slot introducido_por)
(slot numero_personas)
(multislot ingredientes)
(slot dificultad)
(slot duracion)
(slot enlace)
(multislot tipo_plato)
(slot coste)
(slot tipo_copcion)
(multislot tipo_cocina)
(slot temporada)
(slot Calorias)
(slot Proteinas)
(slot Grasa)
(slot Carbohidratos)
(slot Fibra)
(slot Colesterol)
)

;;; Template para propiedades nutricionales
(deftemplate PROPIEDADES-RECETAS::propiedad_receta
(slot propiedad)
(slot receta)
)

;;; Template para asociaciones de platos
(deftemplate PROPIEDADES-RECETAS::plato-asociado
(slot receta)
(slot tipo)
)

;;; Función para convertir duración con formato "45m" a número
(deffunction PROPIEDADES-RECETAS::convertir-a-minutos (?cadena-tiempo)
  "Convierte strings como 30m a números enteros"
  (if (symbolp ?cadena-tiempo)
    then
    (bind ?tiempo-str (sym-cat ?cadena-tiempo))
    (if (neq (str-index "m" ?tiempo-str) FALSE)
      then
      (bind ?pos-m (str-index "m" ?tiempo-str))
      (string-to-field (sub-string 1 (- ?pos-m 1) ?tiempo-str))
    else
      (if (numberp ?cadena-tiempo) then ?cadena-tiempo else 60)
    )
  else
    (if (numberp ?cadena-tiempo) then ?cadena-tiempo else 60)
  )
)

;;; Cargar recetas desde archivo
(defrule PROPIEDADES-RECETAS::carga_recetas
(declare (salience 1000)) 
=>
(printout t "Cargando base de datos de recetas..." crlf)
(if (load-facts "recetas.txt")
  then (printout t "Recetas cargadas correctamente." crlf)
  else (printout t "Error al cargar recetas.txt" crlf)
)
(printout t crlf)
)

;;; Normalizar datos cargados
(defrule PROPIEDADES-RECETAS::normalizar_datos
(declare (salience 999))
?r <- (receta (nombre ?nom) (duracion ?dur_orig) (coste ?cost_orig) (temporada ?temp_orig))
=>
; Normalizar duración
(bind ?duracion-normalizada (convertir-a-minutos ?dur_orig))
; Normalizar coste 
(bind ?coste-normalizado 
  (if (or (eq ?cost_orig nil) (not (numberp ?cost_orig)))
    then 5 
    else ?cost_orig
  )
)
; Normalizar temporada 
(bind ?temporada-normalizada
  (if (or (eq ?temp_orig nil) (not ?temp_orig))
    then "cualquiera"
    else ?temp_orig
  )
)
(modify ?r (duracion ?duracion-normalizada) (coste ?coste-normalizado) (temporada ?temporada-normalizada))
)

;;; Detectar recetas adecuadas según criterios básicos
(defrule PROPIEDADES-RECETAS::evaluar_receta_basica
(numero-comensales ?personas-solicitadas)
(para-cuando ?categoria-solicitada)
(receta (nombre ?nombre-receta) (numero_personas ?personas-receta) (tipo_plato $?tipos-disponibles))
=>
; Verificar compatibilidad de personas (±2 de flexibilidad)
(bind ?compatible-personas 
  (and (>= ?personas-receta (- ?personas-solicitadas 2))
       (<= ?personas-receta (+ ?personas-solicitadas 2)))
)
; Verificar compatibilidad de tipo de plato
(bind ?compatible-tipo (member$ ?categoria-solicitada ?tipos-disponibles))

; Si es compatible, crear asociación de plato
(if (and ?compatible-personas ?compatible-tipo)
  then
  (assert (plato-asociado (receta ?nombre-receta) (tipo ?categoria-solicitada)))
)
)

;;; Lógica por defecto para propiedades nutricionales básicas
(defrule PROPIEDADES-RECETAS::suponer_propiedades_basicas
(receta (nombre ?nombre-receta))
=>
; Asumir propiedades básicas que se pueden refutar después
(assert (propiedad_receta (propiedad es_de_dieta) (receta ?nombre-receta)))
(assert (propiedad_receta (propiedad es_vegetariana) (receta ?nombre-receta)))
(assert (propiedad_receta (propiedad es_sin_gluten) (receta ?nombre-receta)))
)

;;; Base de conocimiento nutricional
(deffacts PROPIEDADES-RECETAS::ingredientes_especiales
(ingrediente_no_vegetariano carne)
(ingrediente_no_vegetariano pollo)
(ingrediente_no_vegetariano pescado)
(ingrediente_no_vegetariano marisco)

(ingrediente_con_gluten pan)
(ingrediente_con_gluten pasta)
(ingrediente_con_gluten harina)
(ingrediente_con_gluten galletas)

(ingrediente_alto_calorico chocolate)
(ingrediente_alto_calorico azucar)
(ingrediente_alto_calorico nata)
)

;;; Función auxiliar para verificar ingredientes
(deffunction PROPIEDADES-RECETAS::contiene-ingrediente (?buscar ?lista-ingredientes)
  "Verifica si un ingrediente está presente en la lista"
  (bind ?encontrado FALSE)
  (foreach ?ingrediente ?lista-ingredientes
    (bind ?ingrediente-str (lowcase (sym-cat ?ingrediente)))
    (bind ?buscar-str (lowcase (sym-cat ?buscar)))
    (if (neq (str-index ?buscar-str ?ingrediente-str) FALSE)
      then (bind ?encontrado TRUE)
    )
  )
  ?encontrado
)

;;; Refutar propiedades vegetarianas si contiene carne/pescado
(defrule PROPIEDADES-RECETAS::verificar_vegetariana
?prop <- (propiedad_receta (propiedad es_vegetariana) (receta ?nombre-receta))
(receta (nombre ?nombre-receta) (ingredientes $?lista-ingredientes))
(ingrediente_no_vegetariano ?ingrediente-prohibido)
=>
(if (contiene-ingrediente ?ingrediente-prohibido ?lista-ingredientes)
  then (retract ?prop)
)
)

;;; Refutar sin gluten si contiene gluten
(defrule PROPIEDADES-RECETAS::verificar_sin_gluten
?prop <- (propiedad_receta (propiedad es_sin_gluten) (receta ?nombre-receta))
(receta (nombre ?nombre-receta) (ingredientes $?lista-ingredientes))
(ingrediente_con_gluten ?ingrediente-gluten)
=>
(if (contiene-ingrediente ?ingrediente-gluten ?lista-ingredientes)
  then (retract ?prop)
)
)

;;; Detectar recetas bajas en calorías
(defrule PROPIEDADES-RECETAS::detectar_bajo_calorias
(receta (nombre ?nombre-receta) (Calorias ?contenido-calorico))
(test (< ?contenido-calorico 300))
=>
(assert (propiedad_receta (propiedad es_bajo_calorico) (receta ?nombre-receta)))
)

;;; Detectar recetas equilibradas
(defrule PROPIEDADES-RECETAS::detectar_equilibrado
(receta (nombre ?nombre-receta) (Calorias ?contenido-calorico))
(test (and (>= ?contenido-calorico 300) (<= ?contenido-calorico 600)))
=>
(assert (propiedad_receta (propiedad es_equilibrado) (receta ?nombre-receta)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MÓDULO DE FILTRADO Y COMPATIBILIDAD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule RECETAS-COMPATIBLES (import PROPIEDADES-RECETAS ?ALL) (import PREGUNTAS ?ALL) 
                                (export deftemplate receta_compatible))

;;; Template para recetas que pasan el filtro
(deftemplate RECETAS-COMPATIBLES::receta_compatible
(slot nombre)
)

;;; Filtrar recetas compatibles por criterios básicos
(defrule RECETAS-COMPATIBLES::evaluar_compatibilidad
(plato-asociado (receta ?nombre-receta) (tipo ?categoria-plato))
(para-cuando ?categoria-plato)
=>
(assert (receta_compatible (nombre ?nombre-receta)))
)

;;; Regla de respaldo si no hay criterios específicos
(defrule RECETAS-COMPATIBLES::respaldo_sin_filtros
(declare (salience -100))
(not (receta_compatible (nombre ?)))
(receta (nombre ?nombre-receta))
=>
(assert (receta_compatible (nombre ?nombre-receta)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MÓDULO DE EVALUACIÓN CON FACTORES DE CERTEZA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule EVALUACION-CERTEZA (import PROPIEDADES-RECETAS ?ALL) (import PREGUNTAS ?ALL) (import RECETAS-COMPATIBLES ?ALL))

;;; Template para factores de certeza
(deftemplate factor_certeza
(slot receta)
(slot criterio)
(slot valor)
)

;;; Template para la recomendación final
(deftemplate recomendacion_final
(slot receta)
(slot certeza_total)
)

;;; Template para control de consulta adicional
(deftemplate consulta_adicional
(slot estado (default pendiente))
)

;;; Template para receta específica solicitada
(deftemplate receta_solicitada
(slot nombre)
)

;;; Función para combinar factores de certeza (algoritmo MYCIN)
(deffunction combinar_certezas (?fc1 ?fc2)
  "Combina dos factores de certeza usando el algoritmo de MYCIN"
  (if (and (> ?fc1 0) (> ?fc2 0))
    then (- (+ ?fc1 ?fc2) (* ?fc1 ?fc2))
  else (if (and (< ?fc1 0) (< ?fc2 0))
    then (+ (+ ?fc1 ?fc2) (* ?fc1 ?fc2))
  else
    (/ (+ ?fc1 ?fc2) (- 1 (min (abs ?fc1) (abs ?fc2))))
  )
  )
)

;;; Factor de certeza 1: Exactitud en número de personas
(defrule EVALUACION-CERTEZA::calcular_factor_personas
(receta_compatible (nombre ?nombre-receta))
(numero-comensales ?personas-solicitadas)
(receta (nombre ?nombre-receta) (numero_personas ?personas-receta))
=>
(bind ?diferencia-personas (abs (- ?personas-receta ?personas-solicitadas)))
(bind ?factor-personas
  (if (= ?diferencia-personas 0)
    then 0.9    ; Certeza muy alta para coincidencia exacta
  else (if (= ?diferencia-personas 1)
    then 0.7    ; Certeza alta para diferencia de 1 persona
  else (if (= ?diferencia-personas 2)
    then 0.4    ; Certeza media para diferencia de 2 personas
  else
    0.1         ; Certeza baja para diferencias mayores
  )))
)
(assert (factor_certeza (receta ?nombre-receta) (criterio personas) (valor ?factor-personas)))
)

;;; Factor de certeza 2: Características nutricionales
(defrule EVALUACION-CERTEZA::calcular_factor_nutricional
(receta_compatible (nombre ?nombre-receta))
=>
(bind ?factor-nutricional 0.0)

; Bonificar características positivas
(do-for-all-facts ((?prop propiedad_receta)) 
  (eq ?prop:receta ?nombre-receta)
  (if (eq ?prop:propiedad es_vegetariana)
    then (bind ?factor-nutricional (+ ?factor-nutricional 0.3))
  )
  (if (eq ?prop:propiedad es_bajo_calorico)
    then (bind ?factor-nutricional (+ ?factor-nutricional 0.4))
  )
  (if (eq ?prop:propiedad es_equilibrado)
    then (bind ?factor-nutricional (+ ?factor-nutricional 0.2))
  )
  (if (eq ?prop:propiedad es_sin_gluten)
    then (bind ?factor-nutricional (+ ?factor-nutricional 0.1))
  )
)

(assert (factor_certeza (receta ?nombre-receta) (criterio nutricional) (valor ?factor-nutricional)))
)

;;; Factor de certeza 3: Eficiencia temporal y práctica
(defrule EVALUACION-CERTEZA::calcular_factor_practicidad
(receta_compatible (nombre ?nombre-receta))
(receta (nombre ?nombre-receta) (duracion ?tiempo-preparacion) (dificultad ?nivel-dificultad))
=>
; Factor basado en tiempo de preparación
(bind ?factor-tiempo
  (if (<= ?tiempo-preparacion 30)
    then 0.5    ; Muy rápido - alta certeza
  else (if (<= ?tiempo-preparacion 60)
    then 0.2    ; Tiempo moderado - certeza media
  else (if (<= ?tiempo-preparacion 90)
    then 0.0    ; Tiempo aceptable - neutro
  else
    -0.2        ; Tiempo largo - certeza negativa
  )))
)

; Factor basado en dificultad
(bind ?factor-dificultad
  (if (eq ?nivel-dificultad muy_baja)
    then 0.3
  else (if (eq ?nivel-dificultad baja)
    then 0.2
  else (if (eq ?nivel-dificultad media)
    then 0.0
  else
    -0.1        ; Alta dificultad - certeza negativa
  )))
)

; Combinar factores de practicidad
(bind ?factor-practicidad (combinar_certezas ?factor-tiempo ?factor-dificultad))
(assert (factor_certeza (receta ?nombre-receta) (criterio practicidad) (valor ?factor-practicidad)))
)

;;; Combinación de todos los factores de certeza
(defrule EVALUACION-CERTEZA::combinar_factores_totales
(declare (salience -100))
(receta_compatible (nombre ?nombre-receta))
(factor_certeza (receta ?nombre-receta) (criterio personas) (valor ?fc-personas))
(factor_certeza (receta ?nombre-receta) (criterio nutricional) (valor ?fc-nutricional))
(factor_certeza (receta ?nombre-receta) (criterio practicidad) (valor ?fc-practicidad))
=>
; Combinar progresivamente los factores
(bind ?certeza-intermedia (combinar_certezas ?fc-personas ?fc-nutricional))
(bind ?certeza-final (combinar_certezas ?certeza-intermedia ?fc-practicidad))

(assert (factor_certeza (receta ?nombre-receta) (criterio final) (valor ?certeza-final)))
)

;;; Selección de la mejor recomendación
(defrule EVALUACION-CERTEZA::seleccionar_mejor_opcion
(declare (salience -200))
=>
(bind ?mejor-receta "")
(bind ?mejor-certeza -2.0)

; Buscar la receta con mayor factor de certeza final
(do-for-all-facts ((?fc factor_certeza)) (eq ?fc:criterio final)
  (if (> ?fc:valor ?mejor-certeza)
    then
    (bind ?mejor-receta ?fc:receta)
    (bind ?mejor-certeza ?fc:valor)
  )
)

(if (neq ?mejor-receta "")
  then
  (assert (recomendacion_final (receta ?mejor-receta) (certeza_total ?mejor-certeza)))
)
)

;;; Presentación del análisis completo
(defrule EVALUACION-CERTEZA::mostrar_analisis_factores
(declare (salience -300))
=>
(printout t "================================================================" crlf)
(printout t "           ANÁLISIS CON FACTORES DE CERTEZA" crlf)
(printout t "================================================================" crlf)
(printout t "EVALUACIÓN DE TODAS LAS OPCIONES DISPONIBLES:" crlf)
(printout t "----------------------------------------------------------------" crlf)

; Mostrar análisis simplificado de cada receta candidata
(do-for-all-facts ((?rc receta_compatible)) TRUE
  (bind ?nombre-candidato ?rc:nombre)
  
  ; Buscar y mostrar solo el factor final
  (do-for-all-facts ((?fc factor_certeza)) 
    (and (eq ?fc:receta ?nombre-candidato) (eq ?fc:criterio final))
    (bind ?certeza-final (/ (round (* ?fc:valor 100)) 100))
    (printout t "- " ?nombre-candidato crlf)
    (printout t "  Factor de certeza: " ?certeza-final)
    
    ; Interpretar nivel de certeza
    (if (>= ?certeza-final 0.7)
      then (printout t " (ALTAMENTE RECOMENDADO)")
    else (if (>= ?certeza-final 0.4)
      then (printout t " (RECOMENDADO)")
    else (if (>= ?certeza-final 0.1)
      then (printout t " (ACEPTABLE)")
    else
      (printout t " (CON RESERVAS)")
    )))
    (printout t crlf crlf)
  )
)
(printout t "================================================================" crlf crlf)
)

;;; Presentación de la recomendación final con opción de consulta adicional
(defrule EVALUACION-CERTEZA::presentar_recomendacion_optima
(declare (salience -400))
(recomendacion_final (receta ?receta-ganadora) (certeza_total ?certeza-final))
(receta (nombre ?receta-ganadora) (ingredientes $?ingredientes) (duracion ?tiempo) (numero_personas ?personas) (dificultad ?dificultad))
=>
(printout t "================================================================" crlf)
(printout t "                RECOMENDACIÓN ÓPTIMA" crlf)
(printout t "================================================================" crlf)
(printout t "RECETA SELECCIONADA: " ?receta-ganadora crlf)
(bind ?certeza-porcentaje (round (* ?certeza-final 100)))
(printout t "FACTOR DE CERTEZA: " (/ (round (* ?certeza-final 100)) 100) " (" ?certeza-porcentaje "%)" crlf)
(printout t "----------------------------------------------------------------" crlf)
(printout t "DETALLES DE LA RECETA:" crlf)
(printout t "- Ingredientes: " ?ingredientes crlf)
(printout t "- Tiempo de preparación: " ?tiempo " minutos" crlf)
(printout t "- Número de personas: " ?personas crlf)
(printout t "- Dificultad: " ?dificultad crlf)

; Mostrar propiedades nutricionales
(printout t "- Propiedades: ")
(do-for-all-facts ((?prop propiedad_receta)) (eq ?prop:receta ?receta-ganadora)
  (printout t ?prop:propiedad " ")
)
(printout t crlf)

(printout t "----------------------------------------------------------------" crlf)
(printout t "JUSTIFICACIÓN DE LA SELECCIÓN:" crlf)
(printout t "Esta receta fue seleccionada mediante análisis probabilístico" crlf)
(printout t "considerando múltiples criterios de calidad y compatibilidad." crlf)

; Mostrar desglose de factores
(printout t "Factores evaluados:" crlf)
(do-for-all-facts ((?fc factor_certeza)) 
  (and (eq ?fc:receta ?receta-ganadora) (neq ?fc:criterio final))
  (printout t "- " ?fc:criterio ": " (/ (round (* ?fc:valor 100)) 100) crlf)
)

(printout t crlf "El algoritmo de factores de certeza determinó que esta" crlf)
(printout t "es la opción más adecuada para sus criterios específicos." crlf)
(printout t "================================================================" crlf crlf)

; Preguntar si desea consultar otra receta
(assert (consulta_adicional (estado pendiente)))
)

;;; Regla para preguntar si desea consultar una receta adicional
(defrule EVALUACION-CERTEZA::preguntar_consulta_adicional
(declare (salience -450))
(consulta_adicional (estado pendiente))
=>
(printout t "================================================================" crlf)
(printout t "                CONSULTA ADICIONAL" crlf)
(printout t "================================================================" crlf)
(printout t "¿Desea consultar información de una receta específica adicional?" crlf)
(printout t "Responda 'si' para consultar otra receta o 'no' para finalizar." crlf)
(printout t ">>> ")
(bind ?respuesta (read))

(if (or (eq ?respuesta si) (eq ?respuesta SI) (eq ?respuesta yes) (eq ?respuesta s))
  then
  (assert (consulta_adicional (estado aceptada)))
  (printout t crlf "Perfecto! Ahora puede consultar una receta específica." crlf)
else
  (assert (consulta_adicional (estado rechazada)))
  (printout t crlf "Entendido. Finalizando el sistema..." crlf)
)
(printout t crlf)
)

;;; Regla para solicitar el nombre de la receta específica 
(defrule EVALUACION-CERTEZA::solicitar_nombre_receta
(declare (salience -460))
(consulta_adicional (estado aceptada))
=>
(printout t "================================================================" crlf)
(printout t "               BÚSQUEDA DE RECETA ESPECÍFICA" crlf)
(printout t "================================================================" crlf)
(printout t "Escriba el nombre exacto de la receta que desea consultar:" crlf)
(printout t "Recetas recomendadas disponibles para consulta:" crlf)

; Mostrar solo las recetas que fueron evaluadas en el análisis
(bind ?contador 0)
(do-for-all-facts ((?rc receta_compatible)) TRUE
  (bind ?contador (+ ?contador 1))
  (printout t "- " ?rc:nombre crlf)
)

(if (= ?contador 0)
  then
  (printout t "No hay recetas recomendadas disponibles." crlf)
)

(printout t "----------------------------------------------------------------" crlf)
(printout t "Nombre de la receta: ")
(bind ?nombre-receta (readline))
(assert (receta_solicitada (nombre ?nombre-receta)))
(printout t crlf)
)

;;; Regla para mostrar información de la receta solicitada
(defrule EVALUACION-CERTEZA::mostrar_receta_especifica
(declare (salience -470))
(receta_solicitada (nombre ?nombre-buscado))
(receta_compatible (nombre ?nombre-buscado))
(receta (nombre ?nombre-buscado) (ingredientes $?ingredientes) (duracion ?tiempo) 
        (numero_personas ?personas) (dificultad ?dificultad) (Calorias ?calorias))
=>
(printout t "================================================================" crlf)
(printout t "              INFORMACIÓN DE RECETA ESPECÍFICA" crlf)
(printout t "================================================================" crlf)
(printout t "RECETA ENCONTRADA: " ?nombre-buscado crlf)
(printout t "----------------------------------------------------------------" crlf)
(printout t "INFORMACIÓN COMPLETA:" crlf)
(printout t "- Ingredientes: " ?ingredientes crlf)
(printout t "- Tiempo de preparación: " ?tiempo " minutos" crlf)
(printout t "- Número de personas: " ?personas crlf)
(printout t "- Dificultad: " ?dificultad crlf)
(printout t "- Calorías: " ?calorias " kcal" crlf)

; Mostrar propiedades nutricionales de esta receta
(printout t "- Propiedades nutricionales: ")
(do-for-all-facts ((?prop propiedad_receta)) (eq ?prop:receta ?nombre-buscado)
  (printout t ?prop:propiedad " ")
)
(printout t crlf)

; Mostrar factor de certeza si fue evaluada
(do-for-all-facts ((?fc factor_certeza)) 
  (and (eq ?fc:receta ?nombre-buscado) (eq ?fc:criterio final))
  (bind ?certeza-especifica (/ (round (* ?fc:valor 100)) 100))
  (printout t "- Factor de certeza para sus criterios: " ?certeza-especifica crlf)
)

(printout t "================================================================" crlf crlf)
(assert (consulta_adicional (estado completada)))
)

;;; Regla para manejar cuando la receta no se encuentra 
(defrule EVALUACION-CERTEZA::receta_no_encontrada
(declare (salience -480))
(receta_solicitada (nombre ?nombre-buscado))
(not (receta_compatible (nombre ?nombre-buscado)))
=>
(printout t "================================================================" crlf)
(printout t "                   RECETA NO ENCONTRADA" crlf)
(printout t "================================================================" crlf)
(printout t "Lo siento, '" ?nombre-buscado "' no está entre las recetas recomendadas." crlf)
(printout t "Solo puede consultar recetas que aparecieron en el análisis anterior." crlf)
(printout t "Verifique que el nombre esté escrito exactamente como aparece en la lista." crlf)
(printout t "================================================================" crlf crlf)
(assert (consulta_adicional (estado completada)))
)

;;; Mensaje de finalización cuando corresponde
(defrule EVALUACION-CERTEZA::finalizar_sistema
(declare (salience -500))
(or (consulta_adicional (estado rechazada))
    (consulta_adicional (estado completada)))
=>
(printout t "================================================================" crlf)
(printout t "            SISTEMA EXPERTO FINALIZADO" crlf)
(printout t "================================================================" crlf)
(printout t "¡Gracias por usar nuestro sistema de recomendación culinaria!" crlf)
(printout t "Esperamos que haya encontrado la información útil." crlf)
(printout t crlf "¡Buen provecho!" crlf)
(printout t "================================================================" crlf crlf)
)