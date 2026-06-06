(defmodule PROPONER-RECETAS (import PROPIEDADES-RECETAS ?ALL) (import PREGUNTAS ?ALL) (import RECETAS-COMPATIBLES ?ALL))

(defglobal PROPONER-RECETAS ?*num_recetas* = 0)

;;; Si no hubiera recetas compatibles, mostrar un mensaje
(defrule PROPONER-RECETAS::no_hay_recetas_compatibles
(not (receta_compatible ?receta))
=>
(printout t crlf "Lo siento, no hay recetas compatibles con tus preferencias en mi base de conocimiento." crlf)
)

;;; Mostrar las recetas compatibles
(defrule PROPONER-RECETAS::mostrar_recetas_compatibles1
(declare (salience -999))
=>
; Contar el numero de recetas compatibles
(foreach ?fact (find-all-facts ((?x receta_compatible)) TRUE)
  (bind ?*num_recetas* (+ ?*num_recetas* 1))
)
; Si hay más de una receta compatible, mostrar un mensaje mostrando que se van a listar las recetas compatibles, 
; para luego mostrarlas y elegir una de ellas como recomendada
(if (> ?*num_recetas* 1)
  then (progn
  (printout t crlf crlf "Las recetas compatibles son:" crlf)
  (printout t "---------------------------" crlf))
  else ; Si solo hay una receta compatible, indicar que esa es la receta recomendada
    (if (= ?*num_recetas* 1)
      then
      (printout t crlf crlf crlf "La receta que te recomiendo es:" crlf)
    )
)
)

(defrule PROPONER-RECETAS::listar_recetas_compatibles1
(declare (salience -1000))
(receta_compatible ?receta)
=>
(printout t ?receta crlf)
)

;;; Mostrar justificación si solo hay una receta compatible y mostrar información de la receta recomendada
(defrule PROPONER-RECETAS::mostrar_justificacion1_1
(declare (salience -1000))
(receta_compatible ?receta)
(receta (nombre ?receta) (ingredientes $?ingredientes) (duracion ?tiempo) (numero_personas ?personas) (dificultad ?dificultad))
=>
(if (= ?*num_recetas* 1)
  then
  (printout t crlf "Esta receta es la unica que cumple con tus preferencias:" crlf)
  (printout t "---------------------------" crlf)
  (printout t "Nombre: " ?receta crlf)
  (printout t "Ingredientes: " ?ingredientes crlf)
  (printout t "Duracion: " ?tiempo crlf)
  (printout t "Numero de personas: " ?personas crlf)
  (printout t "Dificultad: " ?dificultad crlf)
  (printout t "Tipo de plato: " )
)
)

;;; Mostrar el tipo de plato de la receta recomendada si solo hay una receta compatible
(defrule PROPONER-RECETAS::mostrar_justificacion1_2
(declare (salience -1000))
(receta_compatible ?receta)
(plato-asociado ?receta ?tipo)
=>
(if (= ?*num_recetas* 1)
  then
  (printout t "- " ?tipo " ")
)
)

(defrule PROPONER-RECETAS::mostrar_justificacion1_3
(declare (salience -1000))
=>
(if (= ?*num_recetas* 1)
  then
  ;(printout t crlf "Las propiedades de la receta son: ")
)
)

;;; Mostrar las propiedades de la receta recomendada si solo hay una receta compatible
(defrule PROPONER-RECETAS::mostrar_justificacion1_4
(declare (salience -1000))
(receta_compatible ?receta)
(propiedad_receta ?propiedad ?receta)
=>
(if (= ?*num_recetas* 1)
  then
  ;(printout t "-" ?propiedad " ")
)
)

;;; Mostrar la receta recomendada en caso de que haya más de una receta compatible
(defrule PROPONER-RECETAS::mostrar_recetas_compatibles2
(declare (salience -1001))
=>
(if (> ?*num_recetas* 1)
  then (progn
    (printout t "---------------------------" crlf)
    (printout t "De todas ellas, la receta que te recomiendo es:" crlf)
  )
)
)

;;; En mi caso, la si hay más de una receta compatible, la receta recomendada será la 
;;; que comparta más ingredientes con los ingredientes pedidos por el usuario
;;; Estableceremos variables globales para guardar el nombre de la receta con más ingredientes 
;;; compartidos y el numero de ingredientes compartidos

(defglobal PROPONER-RECETAS ?*receta_recomendada* = "")
(defglobal PROPONER-RECETAS ?*num_ingredientes_compartidos* = 0)
; También un bool para indicar si hay más de una receta con el mismo numero de ingredientes compartidos
(defglobal PROPONER-RECETAS ?*empate* = FALSE)
; También guardaremos las calorias de las recetas para desempatar
(defglobal PROPONER-RECETAS ?*calorias* = 100000000)

;;; Regla para contar el numero de ingredientes compartidos entre una receta y los ingredientes pedidos
(defrule PROPONER-RECETAS::contar_ingredientes_compartidos1
(declare (salience -1002))
(alimentos_compatibles (receta ?receta))
(receta (nombre ?receta) (Calorias ?calorias1))
=>
; Contamos el numero de ingredientes compartidos
(bind ?num_apariciones 0)
(foreach ?fact (find-all-facts ((?f alimentos_compatibles)) (eq ?f:receta ?receta))
  (bind ?num_apariciones (+ ?num_apariciones 1)) 
)
(if (and (not (eq ?receta ?*receta_recomendada*)) (> ?*num_recetas* 1))
  then
  ; Si el numero de ingredientes compartidos es mayor que el numero de ingredientes compartidos de la receta recomendada
  ; o si el numero de ingredientes compartidos es igual al numero de ingredientes compartidos de la receta recomendada
  ; y hay más de una receta con el mismo numero de ingredientes compartidos
  (if (> ?num_apariciones ?*num_ingredientes_compartidos*)
    then
      (bind ?*receta_recomendada* ?receta)
      (bind ?*num_ingredientes_compartidos* ?num_apariciones)
      (bind ?*empate* FALSE)
      (bind ?*calorias* ?calorias1)
    else
      (if (eq ?num_apariciones ?*num_ingredientes_compartidos*)
        then
        (bind ?*empate* TRUE)
        ; Asignamos como receta recomendada la que tenga menos calorias
        (if (< ?calorias1 ?*calorias*)
          then
          (bind ?*receta_recomendada* ?receta)
          (bind ?*calorias* ?calorias1)
        )
      )
  )
)
)

;;; Lo mismo que lo anterior pero en caso de que no se hayan indicado ingredientes
(defrule PROPONER-RECETAS::contar_ingredientes_compartidos2
(declare (salience -1002))
(receta_compatible ?receta)
(not(alimentos_compatibles))
(receta (nombre ?receta) (Calorias ?calorias1))
=>
(bind ?*empate* TRUE)
; Asignamos como receta recomendada la que tenga menos calorias
(if (and (< ?calorias1 ?*calorias*) (not (eq ?receta ?*receta_recomendada*)) (> ?*num_recetas* 1))
  then
  (bind ?*receta_recomendada* ?receta)
  (bind ?*calorias* ?calorias1)
)
)

;;; Mostrar la receta recomendada en caso de que no haya empate
(defrule PROPONER-RECETAS::mostrar_receta_recomendada
(declare (salience -1003))
(receta_compatible ?receta)
=>
(if (not ?*empate*)
  then
  (if (eq ?receta ?*receta_recomendada*)
    then
    (printout t ?receta crlf)
    (assert (receta_recomendada ?receta))
    (printout t crlf "Recomiendo esta receta ya que es la que mas ingredientes comparte con los ingredientes que has indicado." crlf)
    (printout t "A continuacion, la informacion sobre esta:" crlf)
  )
  else
  (if (eq ?receta ?*receta_recomendada*)
    then
    (printout t ?receta crlf)
    (assert (receta_recomendada ?receta))
    (printout t crlf "De las recetas que contienen el mayor numero de ingredientes de los que has indicado, esta es la que menos calorias tiene." crlf)
    (printout t "Debido a eso, es la que he decidido recomendar. A continuacion, la informacion sobre esta:" crlf)
  )
)
)

;;; Mostrar justificación si hay más de una receta compatible y mostrar información de la receta recomendada
(defrule PROPONER-RECETAS::mostrar_justificacion2_1
(declare (salience -1004))
(receta_recomendada ?receta)
(receta (nombre ?receta) (ingredientes $?ingredientes) (duracion ?tiempo) (numero_personas ?personas) (dificultad ?dificultad))
=>
(if (> ?*num_recetas* 1)
  then
  (printout t "---------------------------" crlf)
  (printout t "Nombre: " ?receta crlf)
  (printout t "Ingredientes: " ?ingredientes crlf)
  (printout t "Duracion: " ?tiempo crlf)
  (printout t "Numero de personas: " ?personas crlf)
  (printout t "Dificultad: " ?dificultad crlf)
  (printout t "Tipo de plato: " )
)
)

;;; Mostrar el tipo de plato de la receta recomendada si solo hay una receta compatible
(defrule PROPONER-RECETAS::mostrar_justificacion2_2
(declare (salience -1004))
(receta_recomendada ?receta)
(plato-asociado ?receta ?tipo)
=>
(if (> ?*num_recetas* 1)
  then
  (printout t "- " ?tipo " ")
)
)

(defrule PROPONER-RECETAS::mostrar_justificacion2_3
(declare (salience -1004))
(receta_recomendada ?receta)
=>
(if (> ?*num_recetas* 1)
  then
  ;(printout t crlf "Las propiedades de la receta son: ")
)
)

;;; Mostrar las propiedades de la receta recomendada si solo hay una receta compatible
(defrule PROPONER-RECETAS::mostrar_justificacion2_4
(declare (salience -1004))
(receta_recomendada ?receta)
(propiedad_receta ?propiedad ?receta)
=>
(if (> ?*num_recetas* 1)
  then
  ;(printout t "-" ?propiedad " ")
)
)

;;; Si quiere ver información de otra receta compatible
(defrule PROPONER-RECETAS::preguntar_ver_otra_receta
(declare (salience -1005))
=>
(if (> ?*num_recetas* 1)
  then
  (printout t crlf crlf "Quieres ver informacion de otra receta compatible? Si es asi, introduzca el nombre de la receta.")
  (printout t crlf "En caso contrario, introduzca 'no'." crlf)
  (printout t "Respuesta: ")
  (bind ?respuesta (readline))
  (if (eq ?respuesta "no")
    then (printout t crlf "Espero que disfrutes de la receta recomendada!" crlf)
    else (assert (nueva_receta ?respuesta))
  )
)
)

;;; Si quiere ver información de otra receta compatible
(defrule PROPONER-RECETAS::mostrar_justificacion3_1
(declare (salience -1006))
(nueva_receta ?receta)
(receta (nombre ?receta) (ingredientes $?ingredientes) (duracion ?tiempo) (numero_personas ?personas) (dificultad ?dificultad))
=>
(if (> ?*num_recetas* 1)
  then
  (printout t "Aqui tiene la informacion de la receta solicitada:" crlf)
  (printout t "---------------------------" crlf)
  (printout t "Nombre: " ?receta crlf)
  (printout t "Ingredientes: " ?ingredientes crlf)
  (printout t "Duracion: " ?tiempo crlf)
  (printout t "Numero de personas: " ?personas crlf)
  (printout t "Dificultad: " ?dificultad crlf)
  (printout t "Tipo de plato: " )
)
)

;;; Mostrar el tipo de plato de la receta recomendada si solo hay una receta compatible
(defrule PROPONER-RECETAS::mostrar_justificacion3_2
(declare (salience -1006))
(nueva_receta ?receta)
(plato-asociado ?receta ?tipo)
=>
(if (> ?*num_recetas* 1)
  then
  (printout t "- " ?tipo " ")
)
)

(defrule PROPONER-RECETAS::mostrar_justificacion3_3
(declare (salience -1006))
(nueva_receta ?receta)
=>
(if (> ?*num_recetas* 1)
  then
  ;(printout t crlf "Las propiedades de la receta son: ")
)
)

;;; Mostrar las propiedades de la receta recomendada si solo hay una receta compatible
(defrule PROPONER-RECETAS::mostrar_justificacion3_4
(declare (salience -1006))
(nueva_receta ?receta)
(propiedad_receta ?propiedad ?receta)
=>
(if (> ?*num_recetas* 1)
  then
  ;(printout t "-" ?propiedad " ")
)
)


(defrule PROPONER-RECETAS::espacios_finales
(declare (salience -1050))
=>
(printout t crlf "---------------------------" crlf)
(printout t crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FIN Modulo de proposición de recetas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;