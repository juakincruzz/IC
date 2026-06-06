;;; NOMBRE: JOAQUÍN CRUZ LORENZO

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ejecución modulos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule ejecutar
=>
(focus PROPONER-RECETAS)
(focus RECETAS-COMPATIBLES)
(focus PROPIEDADES-RECETAS)
(focus PREGUNTAS)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Modulo de preguntas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

(defmodule PROPIEDADES-RECETAS (export deftemplate receta propiedad_receta plato-asociado) (import PREGUNTAS deftemplate ?ALL))

(deftemplate PROPIEDADES-RECETAS::receta
(slot nombre)   ; necesario
(slot introducido_por) ; necesario
(slot numero_personas)  ; necesario
(multislot ingredientes)   ; necesario
(slot dificultad (allowed-symbols alta media baja muy_baja))  ; necesario
(slot duracion)  ; necesario
(slot enlace)  ; necesario
(multislot tipo_plato (allowed-symbols entrante primer_plato plato_principal postre desayuno_merienda acompanamiento)) ; necesario, introducido o deducido en este ejercicio
(slot coste)  ; opcional relevante
(slot tipo_copcion (allowed-symbols crudo cocido a_la_plancha frito al_horno al_vapor))   ; opcional
(multislot tipo_cocina)   ;opcional
(slot temporada)  ; opcional
;;;; Estos slot se calculan, se haria mediante un algoritmo que no vamos a implementar para este prototipo, lo usamos con la herramienta indicada y lo introducimos
(slot Calorias) ; calculado necesario
(slot Proteinas) ; calculado necesario
(slot Grasa) ; calculado necesario
(slot Carbohidratos) ; calculado necesario
(slot Fibra) ; calculado necesario
(slot Colesterol) ; calculado necesario
)

;;; Función para convertir tiempo a minutos, reemplazando la "m" por "" y convirtiendo a numero
(deffunction PROPIEDADES-RECETAS::convertir-a-minutos (?tiempo)
  (bind ?resultado (str-replace ?tiempo "m" ""))
  (return (string-to-field ?resultado))
)

;;; Guardar todas las recetas en la base de hechos
(defrule PROPIEDADES-RECETAS::carga_recetas
(declare (salience 1000))
=>
(load-facts "recetas.txt")
)

;;; Filtrar las recetas de las cuales vamos a calcular sus propiedades
(defrule PROPIEDADES-RECETAS::deducir_receta_todo
(numero-comensales ?z)
(duracion ?tiempo)
(dificultad ?dificultad)
(receta (nombre ?x) (numero_personas ?z) (duracion ?tiempo_receta) (dificultad ?dificultad))
=>
(bind ?t (convertir-a-minutos ?tiempo_receta))
(if (<= ?t ?tiempo)
  then
  (assert (es_receta ?x)))
)

;;; Si no se introduce el numero de comensales, se asume que se quiere una receta para cualquier numero de comensales
(defrule PROPIEDADES-RECETAS::deducir_receta_sin_numero_comensales
(duracion ?tiempo)
(dificultad ?dificultad)
(not (numero-comensales ?))
(receta (nombre ?x) (duracion ?tiempo_receta) (dificultad ?dificultad))
=>
(bind ?t (convertir-a-minutos ?tiempo_receta))
(if (<= ?t ?tiempo)
  then
  (assert (es_receta ?x)))
)

;;; Si no se introduce la dificultad, se asume que se quiere una receta de cualquier dificultad
(defrule PROPIEDADES-RECETAS::deducir_receta_sin_dificultad
(numero-comensales ?z)
(duracion ?tiempo)
(not (dificultad ?))
(receta (nombre ?x) (numero_personas ?z) (duracion ?tiempo_receta))
=>
(bind ?t (convertir-a-minutos ?tiempo_receta))
(if (<= ?t ?tiempo)
  then
  (assert (es_receta ?x)))
)

;;; Si no se introduce ni el numero de comensales, ni la dificultad, se asume que se quiere una receta de cualquier 
;;; dificultad y para cualquier numero de comensales
(defrule PROPIEDADES-RECETAS::deducir_receta_sin_numero_comensales_ni_dificultad
(duracion ?tiempo)
(not (numero-comensales ?))
(not (dificultad ?))
(receta (nombre ?x) (duracion ?tiempo_receta))
=>
(bind ?t (convertir-a-minutos ?tiempo_receta))
(if (<= ?t ?tiempo)
  then
  (assert (es_receta ?x)))
)

; Obtener la receta de la que se quiere obtener informacion
(defrule PROPIEDADES-RECETAS::preguntar_receta
(es_receta ?x)
=>
(assert (nom_receta_normal ?x))
)

;;;;; EJERCICIO PARTE 1: Añadir reglas para deducir cual o cuales son los ingredientes relevantes de una receta

;;; Lista de ingredientes que suelen ser relevantes en las recetas
(deffacts PROPIEDADES-RECETAS::ingredientes_relevantes
(es_ingrediente carne)
(es_ingrediente pescado)
(es_ingrediente marisco)
(es_ingrediente molusco)
(es_ingrediente arroz)
(es_ingrediente pasta)
(es_ingrediente patata)
(es_ingrediente papas)
(es_ingrediente lentejas)
(es_ingrediente garbanzos)
(es_ingrediente huevo)
(es_ingrediente leche)
(es_ingrediente chocolate)
(es_ingrediente azucar)
(es_ingrediente ajo)
(es_ingrediente cebolla)
(es_ingrediente tomate)
(es_ingrediente galletas)
(es_ingrediente harina)
(es_ingrediente avena)
(es_ingrediente pan)
(es_ingrediente queso)
(es_ingrediente nata)
(es_ingrediente verduras)
)

;;; Lista de tipos de alimentos a partir de la lista de ingredientes relevantes
(deffacts PROPIEDADES-RECETAS::tipos_alimentos
(es_un_tipo_de pollo carne)
(es_un_tipo_de pechuga_de_pollo carne)
(es_un_tipo_de ternera carne)
(es_un_tipo_de cerdo carne)
(es_un_tipo_de cordero carne)
(es_un_tipo_de pavo carne)
(es_un_tipo_de conejo carne)
(es_un_tipo_de pato carne)
(es_un_tipo_de jamon carne)
(es_un_tipo_de bacon carne)
(es_un_tipo_de chorizo carne)
(es_un_tipo_de salchicha carne)
(es_un_tipo_de hamburguesa carne)
(es_un_tipo_de salami carne)
(es_un_tipo_de morcilla carne)
(es_un_tipo_de butifarra carne)
(es_un_tipo_de chuleta carne)
(es_un_tipo_de filete carne)
(es_un_tipo_de solomillo carne)
(es_un_tipo_de panceta carne)
(es_un_tipo_de costilla carne)
(es_un_tipo_de lomo carne)
(es_un_tipo_de albondigas carne)
(es_un_tipo_de empanada carne)
(es_un_tipo_de kebab carne)
(es_un_tipo_de escalope carne)
(es_un_tipo_de nuggets carne)
(es_un_tipo_de salmon pescado)
(es_un_tipo_de merluza pescado)
(es_un_tipo_de bacalao pescado)
(es_un_tipo_de lubina pescado)
(es_un_tipo_de atún pescado)
(es_un_tipo_de sardina pescado)
(es_un_tipo_de langostino marisco)
(es_un_tipo_de gamba marisco)
(es_un_tipo_de sepia marisco)
(es_un_tipo_de calamar marisco)
(es_un_tipo_de cangrejo marisco)
(es_un_tipo_de mejillon molusco)
(es_un_tipo_de almeja molusco)
(es_un_tipo_de pulpo molusco)
(es_un_tipo_de ostra molusco)
(es_un_tipo_de espaguetis pasta)
(es_un_tipo_de macarrones pasta)
(es_un_tipo_de tallarines pasta)
(es_un_tipo_de fideos pasta)
)

;; Definir una función para comprobar si una palabra esta dentro de otra
;; Sustituye la subcadena por "" en la cadena y si el resultado es distinto de la cadena original,
;; entonces la subcadena esta dentro de la cadena
(deffunction PROPIEDADES-RECETAS::palabra-esta-dentro (?subcadena ?cadena)
(if (not(stringp ?subcadena))
  then (return FALSE))
(if (or(<= (str-length ?subcadena) 2) (numberp ?subcadena) (numberp ?cadena))
  then (return FALSE))
(bind ?reemplazo (str-replace ?cadena ?subcadena ""))
(if (neq ?reemplazo ?cadena)
  then (return TRUE)
  else (return FALSE))
)


;; Definir una función para dividir un string en palabras individuales
(deffunction PROPIEDADES-RECETAS::dividir-string (?cadena)
(bind ?palabras (explode$ ?cadena))
(return ?palabras))

;; Definir una función para dividir una palabra en subpalabras
(deffunction PROPIEDADES-RECETAS::dividir-palabra (?palabra)
(bind ?palabra-separada (str-replace ?palabra "_" " "))
(bind ?palabras (dividir-string ?palabra-separada))
(return ?palabras)
)

;; Definir una función que te indique si una palabra esta dentro de una lista de palabras 
;; Se usara la función palabra-esta-dentro
;; Devuelve una lista "resultado" con las palabras que estan dentro de la lista que se pasa como argumento
(deffunction PROPIEDADES-RECETAS::palabra-esta-dentro-lista (?palabr ?lista)
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

;;; Pasamos el nombre de la receta a minusculas para poder comparar con los ingredientes relevantes
(defrule PROPIEDADES-RECETAS::pasar_minusculas
(nom_receta_normal ?x)
=>
(assert (nom_receta (lowcase ?x)))
)

;;; Regla para deducir los ingredientes relevantes de una receta a partir de su nombre
;;; En este caso, comprueba si cada palabra del nombre de la receta esta dentro del nombre de los ingredientes relevantes
(defrule PROPIEDADES-RECETAS::deducir_ingredientes_relevantes_nombre_compuesto1
(nom_receta_normal ?a)
(nom_receta ?x)
(receta (nombre ?a) (ingredientes $?ingredientes))
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
    (loop-for-count (?j (length$ ?resultado))
      (bind ?z (nth$ ?j ?resultado))
      (assert (propiedad_receta ingrediente_relevante ?a ?z))
    )
  )
)
)

;;; Regla para deducir los ingredientes relevantes de una receta a partir de su nombre
;;; En este caso, hacemos lo contrario, comprobamos si el nombre de los ingredientes esta dentro del nombre de la receta
(defrule PROPIEDADES-RECETAS::deducir_ingredientes_relevantes_nombre_compuesto2
(nom_receta_normal ?a)
(nom_receta ?x)
(receta (nombre ?a) (ingredientes $?ingredientes))
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
    (assert (propiedad_receta ingrediente_relevante ?a ?y))
  )
)
)

;;; Regla para deducir los ingredientes relevantes de una receta a partir de sus ingredientes haciendo uso de es_ingrediente
(defrule PROPIEDADES-RECETAS::deducir_ingredientes_relevantes_grupo
(nom_receta_normal ?a)
(nom_receta ?x)
(receta (nombre ?a) (ingredientes $?ingredientes))
(es_ingrediente ?y)
=>
; Comprobamos si alguno de los ingredientes de es_ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado (palabra-esta-dentro-lista ?y ?ingredientes))
; Si la longitud de la lista resultado es mayor que 0, entonces el ingrediente esta dentro de la lista de ingredientes
(if (> (length$ ?resultado) 0)
  then
  ; Añadimos los ingredientes de la lista resultado a la lista de ingredientes relevantes
  (loop-for-count (?j (length$ ?resultado))
    (bind ?z (nth$ ?j ?resultado))
    (assert (propiedad_receta ingrediente_relevante ?a ?z))
  )
)
)

;;; Regla para deducir los ingredientes relevantes de una receta a partir de sus ingredientes haciendo uso de es_un_tipo_de
(defrule PROPIEDADES-RECETAS::deducir_ingredientes_relevantes_tipos
(nom_receta_normal ?a)
(nom_receta ?x)
(receta (nombre ?a) (ingredientes $?ingredientes))
(es_un_tipo_de ?y ?)
=>
; Comprobamos si alguno de los ingredientes de es_un_tipo_de esta dentro de la lista de ingredientes de la receta
(bind ?resultado (palabra-esta-dentro-lista ?y ?ingredientes))
; Si la longitud de la lista resultado es mayor que 0, entonces el ingrediente esta dentro de la lista de ingredientes
(if (> (length$ ?resultado) 0)
  then
  ; Añadimos los ingredientes de la lista resultado a la lista de ingredientes relevantes
  (loop-for-count (?j (length$ ?resultado))
    (bind ?z (nth$ ?j ?resultado))
    (assert (propiedad_receta ingrediente_relevante ?a ?z))
  )
)
)

;;;Añadir reglas paraa deducir el tipo de plato asociado a una receta

;;; Definir los tipos de platos a partir de la duración y los posibles ingredientes
; Primer plato o plato principal
; Considerare que primer_plato y plato_principal son lo mismo
(defrule PROPIEDADES-RECETAS::deducir_tipo_plato_primer_plato
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (numero_personas ?personas) (ingredientes $?ingredientes) (duracion ?tiempo))
(es_un_tipo_de ?tipo1 carne)
(es_un_tipo_de ?tipo2 pasta)
(es_un_tipo_de ?tipo3 marisco)
=>
(bind ?t (convertir-a-minutos ?tiempo))
; Comprobamos que la carne, pasta o marisco esten en la lista de ingredientes (y sus derivados)
(bind ?resultado1 (palabra-esta-dentro-lista carne ?ingredientes))
(bind ?resultado2 (palabra-esta-dentro-lista pasta ?ingredientes))
(bind ?resultado3 (palabra-esta-dentro-lista marisco ?ingredientes))
(bind ?resultado4 (palabra-esta-dentro-lista ?tipo1 ?ingredientes))
(bind ?resultado5 (palabra-esta-dentro-lista ?tipo2 ?ingredientes))
(bind ?resultado6 (palabra-esta-dentro-lista ?tipo3 ?ingredientes))
(bind ?resultado7 (palabra-esta-dentro-lista lentejas ?ingredientes))
; Si se encuentran y se cumple la condición de tiempo, se asocia a primer plato o plato principal
(if (and (<= ?t 90) 
    (or (> (length$ ?resultado1) 0) (> (length$ ?resultado2) 0) (> (length$ ?resultado3) 0)
    (> (length$ ?resultado4) 0) (> (length$ ?resultado5) 0) (> (length$ ?resultado6) 0)
    (> (length$ ?resultado7) 0)
    ))
    then
    (assert (plato-asociado ?nombre primer_plato))
    (assert (plato-asociado ?nombre plato_principal))
)
)

; Postre o desayuno/merienda
; Considerare que postre y desayuno/merienda son lo mismo
(defrule PROPIEDADES-RECETAS::deducir_tipo_plato_postre_desayuno_merienda
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (numero_personas ?personas) (ingredientes $?ingredientes))
=>
; Comprobamos que azucar o chocolate esten en la lista de ingredientes
(bind ?resultado1 (palabra-esta-dentro-lista azucar ?ingredientes))
(bind ?resultado2 (palabra-esta-dentro-lista chocolate ?ingredientes))
(if (or (> (length$ ?resultado1) 0) (> (length$ ?resultado2) 0))
    then
    (assert (plato-asociado ?nombre postre))
    (assert (plato-asociado ?nombre desayuno_merienda))
)
)

; Entrante o acompañamiento
; Considerare que entrante y acompañamiento son lo mismo
; En principio, si no se cumple ninguna de las otras condiciones, se asume que es entrante o acompañamiento
(defrule PROPIEDADES-RECETAS::deducir_tipo_plato_entrante
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (numero_personas ?personas) (ingredientes $?ingredientes) (duracion ?tiempo) (tipo_plato $?tipo))
;(not (plato-asociado ?nombre ?))
(not (plato-asociado ?nombre primer_plato))
(not (plato-asociado ?nombre plato_principal))
(not (plato-asociado ?nombre postre))
(not (plato-asociado ?nombre desayuno_merienda))
=>
;(if 
;(assert (plato-asociado ?nombre entrante))
;(assert (plato-asociado ?nombre acompanamiento))
;)
; Por fallo en esta funcion, asignar los tipos de plato originales
(loop-for-count (?i (length$ ?tipo))
  (bind ?t (nth$ ?i ?tipo))
  (assert (plato-asociado ?nombre ?t))
)
)


;;; Definir los ingredientes que no son veganos, vegetarianos, de dieta, picantes, con gluten o con lactosa

(deffacts PROPIEDADES-RECETAS::ingredientes_no_veganos
(es_no_vegano carne)
(es_no_vegano pescado)
(es_no_vegano marisco)
(es_no_vegano molusco)
(es_no_vegano huevo)
(es_no_vegano leche)
(es_no_vegano queso)
(es_no_vegano nata)
(es_no_vegano mantequilla)
(es_no_vegano miel)
(es_no_vegano gelatina)
)

(deffacts PROPIEDADES-RECETAS::ingredientes_no_vegetarianos
(es_no_vegetariano carne)
(es_no_vegetariano pescado)
(es_no_vegetariano marisco)
(es_no_vegetariano molusco)
)

(deffacts PROPIEDADES-RECETAS::ingredientes_no_dieta
(es_no_de_dieta azucar)
(es_no_de_dieta chocolate)
(es_no_de_dieta mantequilla)
(es_no_de_dieta nata)
(es_no_de_dieta queso)
)

(deffacts PROPIEDADES-RECETAS::ingredientes_picantes
(es_picante pimenton)
(es_picante guindilla)
(es_picante pimienta)
(es_picante curry)
(es_picante pimiento)
(es_picante tabasco)
(es_picante wasabi)
(es_picante jengibre)
(es_picante chili)
)

(deffacts PROPIEDADES-RECETAS::ingredientes_con_gluten
(es_con_gluten trigo)
(es_con_gluten cebada)
(es_con_gluten centeno)
(es_con_gluten avena)
(es_con_gluten espelta)
(es_con_gluten kamut)
(es_con_gluten malta)
(es_con_gluten cuscus)
(es_con_gluten pan)
(es_con_gluten pasta)
(es_con_gluten galletas)
(es_con_gluten cereales)
(es_con_gluten harina)
(es_con_gluten cerveza)
(es_con_gluten salsa_de_soja)
)

(deffacts PROPIEDADES-RECETAS::ingredientes_con_lactosa
(es_con_lactosa leche)
(es_con_lactosa nata)
(es_con_lactosa queso)
(es_con_lactosa mantequilla)
(es_con_lactosa yogur)
(es_con_lactosa helado)
(es_con_lactosa batido)
(es_con_lactosa flan)
(es_con_lactosa crema)
(es_con_lactosa bechamel)
)

;;; Primero suponemos que todas las recetas son veganas, vegetarianas, de dieta, no picantes, sin gluten y sin lactosa
;;; Cuando se demuestre lo contrario, se retractara la propiedad correspondiente
(defrule PROPIEDADES-RECETAS::suponer_todo
(nom_receta_normal ?nombre)
=>
(assert (propiedad_receta es_vegana ?nombre))
(assert (propiedad_receta es_vegetariana ?nombre))
(assert (propiedad_receta es_de_dieta ?nombre))
(assert (propiedad_receta es_sin_gluten ?nombre))
(assert (propiedad_receta es_sin_lactosa ?nombre))
)

;;; Regla para deducir si una receta es vegana
(defrule PROPIEDADES-RECETAS::deducir_vegana_grupo
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
; Hecho a retractar si el ingrediente no es vegano
?ret_vegana <- (propiedad_receta es_vegana ?nombre)
; Filtramos los ingredientes que no son veganos
(es_no_vegano ?i1)
=>
; Vemos si el ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado1 (palabra-esta-dentro-lista ?i1 ?ingredientes))
; En caso de que el ingrediente o su subtipo esten en la lista de ingredientes, la receta no es vegana
(if (> (length$ ?resultado1) 0) 
  then (retract ?ret_vegana)
)
)

;;; Regla para deducir si una receta es vegana
(defrule PROPIEDADES-RECETAS::deducir_vegana_grupo_tipo
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
; Hecho a retractar si el ingrediente no es vegano
?ret_vegana <- (propiedad_receta es_vegana ?nombre)
; Filtramos los ingredientes que no son veganos
(es_no_vegano ?i1)
; Filtramos los subtipos de los ingredientes que no son veganos
(es_un_tipo_de ?i2 ?i1)
=>
; Vemos si el subtipo del ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado2 (palabra-esta-dentro-lista ?i2 ?ingredientes))
; En caso de que el ingrediente o su subtipo esten en la lista de ingredientes, la receta no es vegana
(if (> (length$ ?resultado2) 0)
  then (retract ?ret_vegana)
)
)

;;; Regla para deducir si una receta es vegetariana
(defrule PROPIEDADES-RECETAS::deducir_vegetariana_grupo
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
; Hecho a retractar si el ingrediente no es vegetariano
?ret_vegetariana <- (propiedad_receta es_vegetariana ?nombre)
; Filtramos los ingredientes que no son vegetarianos
(es_no_vegetariano ?i1)
=>
; Vemos si el ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado1 (palabra-esta-dentro-lista ?i1 ?ingredientes))
; En caso de que el ingrediente o su subtipo esten en la lista de ingredientes, la receta no es vegetariana
(if (> (length$ ?resultado1) 0)
  then (retract ?ret_vegetariana)
)
)

;;; Regla para deducir si una receta es vegetariana
(defrule PROPIEDADES-RECETAS::deducir_vegetariana_grupo_tipo
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
; Hecho a retractar si el ingrediente no es vegetariano
?ret_vegetariana <- (propiedad_receta es_vegetariana ?nombre)
; Filtramos los ingredientes que no son vegetarianos
(es_no_vegetariano ?i1)
; Filtramos los subtipos de los ingredientes que no son vegetarianos
(es_un_tipo_de ?i2 ?i1)
=>
; Vemos si el ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado2 (palabra-esta-dentro-lista ?i2 ?ingredientes))
; En caso de que el ingrediente o su subtipo esten en la lista de ingredientes, la receta no es vegetariana
(if (> (length$ ?resultado2) 0)
  then (retract ?ret_vegetariana)
)
)

;;; Regla para deducir si una receta es de dieta
(defrule PROPIEDADES-RECETAS::deducir_de_dieta_grupo
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
; Hecho a retractar si el ingrediente no es de dieta
?ret_dieta <- (propiedad_receta es_de_dieta ?nombre)
; Filtramos los ingredientes que no son de dieta
(es_no_de_dieta ?i1)
=>
; Vemos si el ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado1 (palabra-esta-dentro-lista ?i1 ?ingredientes))
; En caso de que el ingrediente o su subtipo esten en la lista de ingredientes, la receta no es de dieta
(if (> (length$ ?resultado1) 0)
  then (retract ?ret_dieta)
)
)

;;; Regla para deducir si una receta es de dieta
(defrule PROPIEDADES-RECETAS::deducir_de_dieta_tipo
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
; Hecho a retractar si el ingrediente no es de dieta
?ret_dieta <- (propiedad_receta es_de_dieta ?nombre)
; Filtramos los ingredientes que no son de dieta
(es_no_de_dieta ?i1)
; Filtramos los subtipos de los ingredientes que no son de dieta
(es_un_tipo_de ?i2 ?i1)
=>
; Vemos si el subtipo del ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado2 (palabra-esta-dentro-lista ?i2 ?ingredientes))
; En caso de que el ingrediente o su subtipo esten en la lista de ingredientes, la receta no es de dieta
(if (> (length$ ?resultado2) 0)
  then (retract ?ret_dieta)
)
)

;;; Regla para deducir si una receta es picante
(defrule PROPIEDADES-RECETAS::deducir_picante_grupo
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
; Filtramos los ingredientes picantes
(es_picante ?i1)
=>
; Vemos si el ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado1 (palabra-esta-dentro-lista ?i1 ?ingredientes))
; En caso de que el ingrediente o su subtipo esten en la lista de ingredientes, la receta es picante
(if (> (length$ ?resultado1) 0)
  then (assert (propiedad_receta es_picante ?nombre))
)
)

;;; Regla para deducir si una receta es picante
(defrule PROPIEDADES-RECETAS::deducir_picante_tipo
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
; Filtramos los ingredientes picantes
(es_picante ?i1)
; Filtramos los subtipos de los ingredientes picantes
(es_un_tipo_de ?i2 ?i1)
=>
; Vemos si el subtipo del ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado2 (palabra-esta-dentro-lista ?i2 ?ingredientes))
; En caso de que el ingrediente o su subtipo esten en la lista de ingredientes, la receta es picante
(if (> (length$ ?resultado2) 0)
  then (assert (propiedad_receta es_picante ?nombre))
)
)

;;; Regla para deducir si una receta es sin gluten
(defrule PROPIEDADES-RECETAS::deducir_sin_gluten_grupo
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
; Hecho a retractar si el ingrediente contiene gluten
?ret_gluten <- (propiedad_receta es_sin_gluten ?nombre)
; Filtramos los ingredientes con gluten
(es_con_gluten ?i1)
=>
; Vemos si el ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado1 (palabra-esta-dentro-lista ?i1 ?ingredientes))
; En caso de que el ingrediente o su subtipo esten en la lista de ingredientes, la receta no es sin gluten
(if (> (length$ ?resultado1) 0)
  then (retract ?ret_gluten)
)
)

;;; Regla para deducir si una receta es sin gluten
(defrule PROPIEDADES-RECETAS::deducir_sin_gluten_tipo
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
; Hecho a retractar si el ingrediente contiene gluten
?ret_gluten <- (propiedad_receta es_sin_gluten ?nombre)
; Filtramos los ingredientes con gluten
(es_con_gluten ?i1)
; Filtramos los subtipos de los ingredientes con gluten
(es_un_tipo_de ?i2 ?i1)
=>
; Vemos si el subtipo del ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado2 (palabra-esta-dentro-lista ?i2 ?ingredientes))
; En caso de que el ingrediente o su subtipo esten en la lista de ingredientes, la receta no es sin gluten
(if (> (length$ ?resultado2) 0)
  then (retract ?ret_gluten)
)
)

;;; Regla para deducir si una receta es sin lactosa
(defrule PROPIEDADES-RECETAS::deducir_sin_lactosa_grupo
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
; Hecho a retractar si el ingrediente contiene lactosa
?ret_lactosa <- (propiedad_receta es_sin_lactosa ?nombre)
; Filtramos los ingredientes con lactosa
(es_con_lactosa ?i1)
=>
; Vemos si el ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado1 (palabra-esta-dentro-lista ?i1 ?ingredientes))
; En caso de que el ingrediente o su subtipo esten en la lista de ingredientes, la receta no es sin lactosa
(if (> (length$ ?resultado1) 0)
  then (retract ?ret_lactosa)
)
)

;;; Regla para deducir si una receta es sin lactosa
(defrule PROPIEDADES-RECETAS::deducir_sin_lactosa_tipo
(nom_receta_normal ?nombre)
(receta (nombre ?nombre) (ingredientes $?ingredientes))
; Hecho a retractar si el ingrediente contiene lactosa
?ret_lactosa <- (propiedad_receta es_sin_lactosa ?nombre)
; Filtramos los ingredientes con lactosa
(es_con_lactosa ?i1)
; Filtramos los subtipos de los ingredientes con lactosa
(es_un_tipo_de ?i2 ?i1)
=>
; Vemos si el subtipo del ingrediente esta dentro de la lista de ingredientes de la receta
(bind ?resultado2 (palabra-esta-dentro-lista ?i2 ?ingredientes))
; En caso de que el ingrediente o su subtipo esten en la lista de ingredientes, la receta no es sin lactosa
(if (> (length$ ?resultado2) 0)
  then (retract ?ret_lactosa)
)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FIN Modulo de propiedades-recetas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Modulo de obtención de recetas compatibles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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