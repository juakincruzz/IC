(defmodule RECETAS-COMPATIBLES (import PROPIEDADES-RECETAS ?ALL) (import PREGUNTAS ?ALL) 
                                (export deftemplate receta_compatible alimentos_compatibles))

;; Definir una función para comprobar si una palabra esta dentro de otra
;; Sustituye la subcadena por "" en la cadena y si el resultado es distinto de la cadena original,
;; entonces la subcadena esta dentro de la cadena
(deffunction RECETAS-COMPATIBLES::palabra-esta-dentro (?subcadena ?cadena)
;(if (not(stringp ?subcadena))
;  then (return FALSE))
(if (or(<= (str-length ?subcadena) 2) (numberp ?subcadena) (numberp ?cadena))
  then (return FALSE))
(bind ?reemplazo (str-replace ?cadena ?subcadena ""))
(if (neq ?reemplazo ?cadena)
  then (return TRUE)
  else (return FALSE))
)

;; Definir una función para dividir un string en palabras individuales
(deffunction RECETAS-COMPATIBLES::dividir-string (?cadena)
(if (stringp ?cadena)
  then
  (bind ?palabras (explode$ ?cadena))
  else
  (bind ?palabras (create$ ?cadena))
)
(return ?palabras)
)

;; Definir una función para dividir una palabra en subpalabras
(deffunction RECETAS-COMPATIBLES::dividir-palabra (?palabra)
(bind ?palabra-separada (str-replace ?palabra "_" " "))
(bind ?palabras (dividir-string ?palabra-separada))
(return ?palabras)
)

;; Definir una función que te indique si una palabra esta dentro de una lista de palabras 
;; Se usara la función palabra-esta-dentro
;; Devuelve una lista "resultado" con las palabras que estan dentro de la lista que se pasa como argumento
(deffunction RECETAS-COMPATIBLES::palabra-esta-dentro-lista (?palabr ?lista)
(bind ?resultado (create$))
(bind ?palabra (str-cat ?palabr))
(loop-for-count (?i (length$ ?lista))
  (bind ?x (nth$ ?i ?lista))
  ; Dividimos la palabras por si la palabra es compuesta
  (bind ?palabras (dividir-palabra ?palabra))
  ; Comprobamos si la palabra esta dentro de la lista de palabras
  (loop-for-count (?j (length$ ?palabras))
    (bind ?y (nth$ ?j ?palabras))
    (if (palabra-esta-dentro ?y ?x)
      ; Añadimos la palabra a la lista de resultados en la ultima posición
      then (bind ?resultado (insert$ ?resultado (+ (length$ ?resultado) 1) ?x)))
  )
)
(return $?resultado)
)

;;; Regla para deducir las posibles recetas compatibles para luego filtrarlas
;(defrule RECETAS-COMPATIBLES::deducir_posibles_recetas_compatibles
;(propiedad_receta ? ?receta)
;=>
;(assert (posible_receta_compatible ?receta))
;)

(defrule RECETAS-COMPATIBLES::filtrar_recetas
(tipo-comida ?tipo)
(propiedad_receta ?tipo ?receta)
=>
(assert (posible_receta_compatible ?receta))
)

;;; Filtrar las recetas segun el tipo de plato
(defrule RECETAS-COMPATIBLES::filtrar_recetas_tipo_plato
(para-cuando ?tipo)
(plato-asociado ?receta ?tipo)
=>
(assert (posible_receta_compatible ?receta))
)

;;; Filtrar las recetas segun las propiedades indicadas por el usuario
(defrule RECETAS-COMPATIBLES::filtrar_recetas1
(tipo-comida ?tipo)
(not(propiedad_receta ?tipo ?receta))
?borrar <- (posible_receta_compatible ?receta)
=>
(retract ?borrar)
)

(defrule RECETAS-COMPATIBLES::filtrar_recetas2
(tipo-comida ?tipo) ; Que entre solo si existe alguna propiedad indicada por el usuario
(propiedad_receta ?propiedad ?receta)
(not(tipo-comida ?propiedad))
?borrar <- (posible_receta_compatible ?receta)
=>
(retract ?borrar)
)

(defrule RECETAS-COMPATIBLES::filtrar_recetas_tipo_plato1
(para-cuando ?x) ;;; Que entre solo si el usuario ha indicado algun tipo
(plato-asociado ?receta ?tipo)
(not (para-cuando ?tipo))
?borrar <- (posible_receta_compatible ?receta)
=>
(retract ?borrar)
)

(defrule RECETAS-COMPATIBLES::filtrar_recetas_tipo_plato2
(para-cuando ?tipo)
(not(plato-asociado ?receta ?tipo))
?borrar <- (posible_receta_compatible ?receta)
=>
(retract ?borrar)
)

;;; Si no se ha indicado ninguna propiedad, todas las recetas seran compatibles
(defrule RECETAS-COMPATIBLES::todas_las_recetas_compatibles_tipo
(not(tipo-comida ?))
(propiedad_receta ?propiedad ?receta)
=>
(assert (posible_receta_compatible ?receta))
)

;;; Si no se ha indicado ningun tipo de plato, todas las recetas seran compatibles
(defrule RECETAS-COMPATIBLES::todas_las_recetas_compatibles_tipo_plato
(not(para-cuando ?))
(plato-asociado ?receta ?tipo)
=>
(assert (posible_receta_compatible ?receta))
)

;;; Filtrar las recetas, quedarse con las que tengan los ingredientes indicados por el usuario

;;; Usar template para almacenar los alimentos compatibles
(deftemplate RECETAS-COMPATIBLES::alimentos_compatibles
(slot receta)
(slot alimento)
)

;;; Regla para filtrar las recetas con los ingredientes pedidos a partir de la lista de ingredientes de la receta
;;; En este caso, comprueba si cada uno de los ingredientes pedidos esta dentro de la lista de ingredientes de la receta
(defrule RECETAS-COMPATIBLES::deducir_ingredientes_relevantes_nombre_compuesto1
(posible_receta_compatible ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
(alimento-disponible ?x)
=>
(bind ?palabras (dividir-string ?x))
;; Cogemos cada palabra del nombre y vemos si viene incluida en algun ingrediente que tenga nombre compuesto
(loop-for-count (?i (length$ ?palabras))
  (bind ?y (nth$ ?i ?palabras))
  ; Comprobamos si el nombre de la receta contiene alguno de sus ingredientes
  (bind ?resultado (palabra-esta-dentro-lista ?y ?ingredientes))
  ; Si la longitud de la lista resultado es mayor que 0, entonces la palabra esta dentro de la lista de ingredientes
  (if (> (length$ ?resultado) 0)
    then
    ; Añadimos los ingredientes de la lista resultado a la lista de ingredientes relevantes
    ;(loop-for-count (?j (length$ ?resultado))
    ;  (bind ?z (nth$ ?j ?resultado))
    ;  (assert (propiedad_receta ingrediente_relevante ?a ?z))
    ;)
    (assert (alimentos_compatibles (receta ?nombre) (alimento ?y)))
    (assert (receta_compatible ?nombre))
  )
)
)

;;; Regla para filtrar las recetas con los ingredientes pedidos a partir de la lista de ingredientes de la receta
;;; En este caso, hacemos lo contrario: comprobamos si el nombre de los ingredientes esta dentro del nombre de los ingredientes pedidos
(defrule RECETAS-COMPATIBLES::deducir_ingredientes_relevantes_nombre_compuesto2
(posible_receta_compatible ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
(alimento-disponible ?x)
=>
(bind ?palabras (dividir-string ?x))
;; Cogemos cada palabra del nombre y vemos si viene incluida en algun ingrediente que tenga nombre compuesto
(loop-for-count (?i (length$ ?ingredientes))
  (bind ?y (nth$ ?i ?ingredientes))
  ; Comprobamos si el nombre de la receta contiene alguno de sus ingredientes
  (bind ?resultado (palabra-esta-dentro-lista ?y ?palabras))
  ; Si la longitud de la lista resultado es mayor que 0, entonces la palabra esta dentro de la lista de ingredientes
  (if (> (length$ ?resultado) 0)
    then
    ; Añadimos el ingrediente comprobado a la lista de ingredientes relevantes
    ;(assert (propiedad_receta ingrediente_relevante ?a ?y))
    (assert (alimentos_compatibles (receta ?nombre) (alimento ?x)))
    (assert (receta_compatible ?nombre))
  )
)
)

;;; En caso de que no se hayan indicado ingredientes, todas las recetas que cumplan con las propiedades serán compatibles
(defrule RECETAS-COMPATIBLES::todas_las_recetas_compatibles
(not (alimento-disponible ?))
(posible_receta_compatible ?nombre)
=>
(assert (receta_compatible ?nombre))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FIN Modulo de obtención de recetas compatibles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Modulo de proposición de recetas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
