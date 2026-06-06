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
