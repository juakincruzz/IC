(defmodule PREGUNTAS (export deftemplate ?ALL))

; Para eliminar los espacios en blanco alrededor de una cadena
(deffunction PREGUNTAS::str-trim (?str)
    (if (not (integerp ?str)) 
    then
      ;(bind ?str (str-replace "^\s+" "" ?str))
      ;(bind ?str (str-replace "\s+$" "" ?str))
    )
    ?str
)

; Para leer una cadena de entrada y convertirla en un vector de palabras
(deffunction PREGUNTAS::input-vector (?prompt)
  (printout t ?prompt crlf)
  (printout t "Respuesta: ")
  (bind ?input (readline))
  (bind ?tokens (explode$ ?input))
  (bind ?vector (create$))
  (foreach ?t ?tokens
    (bind ?token (str-trim ?t))
    (if (not (eq ?token ""))
      then
      (bind ?vector (insert$ ?vector 1 ?token))
    )
  )
  ?vector
)

(defrule PREGUNTAS::pregunta-inicial
=>
(printout t crlf crlf "Hola! Soy un sistema experto que te ayudara a encontrar la receta perfecta para ti." crlf)
(printout t "Para ello, necesito hacerte unas preguntas. Si no quieres responder a alguna, escribe '-1'" crlf crlf)
)

(defrule PREGUNTAS::preguntar-numero-comensales
=>
(printout t "Cuantas personas disfrutarian de esta maravillosa receta?" crlf) 
(printout t "Es importante saberlo para tener en cuenta las cantidades y que todo el mundo quede satisfecho." crlf)
(printout t "Respuesta: ")
(bind ?numero-comensales (read))
(if (and (not (eq ?numero-comensales -1)) (and (integerp ?numero-comensales) (> ?numero-comensales 0)))
  then
  (assert (numero-comensales ?numero-comensales)))
)

(defrule PREGUNTAS::preguntar-dificultad
=>
(printout t "Quieres enfrentarte a un nuevo reto o prefieres no complicarte la vida?" crlf)
(printout t "Comentame la dificultad que te interesa (alta, media, baja, muy_baja)" crlf)
(printout t "Respuesta: ")
(bind ?dificultad (read))
(if (and (not (eq ?dificultad -1)) (or (eq (str-compare ?dificultad "alta") 0) (eq (str-compare ?dificultad "media") 0) 
                                        (eq (str-compare ?dificultad "baja") 0) (eq (str-compare ?dificultad "muy_baja") 0)))
  then
  (assert (dificultad ?dificultad)))
)

(defrule PREGUNTAS::preguntar-duracion
=>
(printout t "Vas justo de tiempo?" crlf)
(printout t "Indicame cuanto tiempo tienes disponible para hacer la receta y te hare la recomendacion (en minutos)" crlf)
(printout t "Respuesta: ")
(bind ?duracion (read))
(if (and (not (eq ?duracion -1)) (integerp ?duracion) (> ?duracion 0))
  then
  (assert (duracion ?duracion)))
  else 
  ; 180 porque el tiempo introducido es el máximo y todas las recetas tienen un tiempo máximo de 3 horas
  ; asi que podemos tener todas las recetas posibles en cuenta
  (assert (duracion 180))
)

(defrule PREGUNTAS::preguntar-tipo-comida
=>
(bind ?tipo-comida (input-vector "Alguna preferencia alimenticia? Indicalo para que pueda ayudarte de la mejor forma posible (vegana, vegetariana, sin_gluten, picante, sin_lactosa, de_dieta)"))
(if (neq (length$ ?tipo-comida) 0)
  then
  (if (not (eq (nth$ 1 ?tipo-comida) -1))
    then
    (foreach ?tipo ?tipo-comida
      (if (or (eq (str-compare ?tipo "vegana") 0) (eq (str-compare ?tipo "vegetariana") 0) 
              (eq (str-compare ?tipo "sin_gluten") 0) (eq (str-compare ?tipo "picante") 0) 
              (eq (str-compare ?tipo "sin_lactosa") 0) (eq (str-compare ?tipo "de_dieta") 0))
        then
          (if (eq (str-compare ?tipo "vegana") 0)
            then
            (assert (tipo_comida es_vegana))
            (assert (tipo_comida es_vegetariana))
          else
           (if (eq (str-compare ?tipo "sin_gluten") 0)
            then
            (assert (tipo_comida es_sin_gluten)
            )
            else
            (if (eq (str-compare ?tipo "picante") 0)
              then
              (assert (tipo_comida es_picante))
            else
            (if (eq (str-compare ?tipo "sin_lactosa") 0)
              then
              (assert (tipo_comida es_sin_lactosa))
            else
            (if (eq (str-compare ?tipo "de_dieta") 0)
              then
              (assert (tipo_comida es_de_dieta))
            else
              (if (eq (str-compare ?tipo "vegetariana") 0)
                then
                (assert (tipo_comida es_vegetariana))
            )
            )
            )
            )
          )
        ;(assert (tipo-comida ?tipo))
        )
      )
    )
  )
)
)

(defrule PREGUNTAS::preguntar-alimentos-disponibles
=>
(bind $?alimentos (input-vector "Deseas que algun alimento este si o si en tu receta? Que alimentos tienes disponibles o puedes conseguir facilmente? (separados por espacios)"))
(if (neq (length$ ?alimentos) 0)
  then
  (if (not (eq (nth$ 1 ?alimentos) -1))
    then
    (foreach ?alimento ?alimentos
      (assert (alimento-disponible ?alimento))
    )
  )
)
)

(defrule PREGUNTAS::preguntar-para-cuando
=>
(printout t "Que tipo de comida quieres? Algo para picotear o algo que te deje satisfecho cuando mas hambre pases?" crlf)
(printout t "Indicalo para poder aconsejarte mejor (entrante, primer_plato, plato_principal, postre, desayuno_merienda, acompanamiento)" crlf)
(printout t "Respuesta: ")
(bind ?para-cuando (read))
(if (and (not (eq ?para-cuando -1))  (or (eq (str-compare ?para-cuando "entrante") 0) (eq (str-compare ?para-cuando "primer_plato") 0) 
                                  (eq (str-compare ?para-cuando "plato_principal") 0) (eq (str-compare ?para-cuando "postre") 0) 
                                (eq (str-compare ?para-cuando "desayuno_merienda") 0) (eq (str-compare ?para-cuando "acompanamiento") 0)) )
  then
  (assert (para-cuando ?para-cuando))
)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FIN Modulo de preguntas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Modulo de propiedades-recetas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
