;;; AUTOR: JOAQUIN CRUZ LORENZO ;;;

;;;;;;;;;;;;;;;;;;Representación ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (ave ?x) representa “?x es un ave ”
; (animal ?x) representa “?x es un animal”
; (vuela ?x si|no seguro|por_defecto) representa
; “?x vuela si|no con esa certeza”


;;;;;;;;;;;;;;;;;;Hechos ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Las aves y los mamíferos son animales
;Los gorriones, las palomas, las águilas y los pingüinos son aves
;La vaca, los perros y los caballos son mamíferos
;Los pingüinos no vuelan
(deffacts datos
(ave gorrion) (ave paloma) (ave aguila) (ave pinguino)
(mamifero vaca) (mamifero perro) (mamifero caballo)
(vuela pinguino no seguro) )


;;;;;;;;;;;;;;;;;;Reglas seguras ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Las aves son animales
(defrule aves_son_animales
(ave ?x)
=>
(assert (animal ?x))
(bind ?expl (str-cat "sabemos que un " ?x " es un animal porque las aves son un tipo de animal"))
(assert (explicacion animal ?x ?expl)) )
; añadimos un hecho que contiene la explicación de la deducción

; Los mamiferos son animales (A3)
(defrule mamiferos_son_animales
(mamifero ?x)
=>
(assert (animal ?x))
(bind ?expl (str-cat "sabemos que un " ?x " es un animal porque los mamiferos son un tipo de animal"))
(assert (explicacion animal ?x ?expl)) )
; añadimos un hecho que contiene la explicación de la deducción


;;;;;;;;;;;;;;;;;;Reglas por defecto ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Casi todos las aves vuela --> puedo asumir por defecto que las aves vuelan
; Asumimos por defecto
(defrule ave_vuela_por_defecto
(declare (salience -1)) ; para disminuir probabilidad de añadir erróneamente
(ave ?x)
=>
(assert (vuela ?x si por_defecto))
(bind ?expl (str-cat "asumo que un " ?x " vuela, porque casi todas las aves vuelan"))
(assert (explicacion vuela ?x ?expl))
)

; Retractamos cuando hay algo en contra
(defrule retracta_vuela_por_defecto
(declare (salience 1)) ; para retractar antes de inferir cosas erroneamente
?f<- (vuela ?x ?r por_defecto)
(vuela ?x ?s seguro)
=>
(retract ?f)
(bind ?expl (str-cat "retractamos que un " ?x " " ?r " vuela por defecto, porque sabemos seguro que " ?x " " ?s " vuela"))
(assert (explicacion retracta_vuela ?x ?expl)) )
;;; COMETARIO: esta regla también elimina los por defecto cuando ya esta seguro 

;;; La mayor parte de los animales no vuelan --> puede interesarme asumir por defecto
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;que un animal no va a volar
(defrule mayor_parte_animales_no_vuelan
(declare (salience -2)) ;;;; es mas arriesgado, mejor después de otros razonamientos
(animal ?x)
(not (vuela ?x ? ?))
=>
(assert (vuela ?x no por_defecto))
(bind ?expl (str-cat "asumo que " ?x " no vuela, porque la mayor parte de los animales no vuelan"))
(assert (explicacion vuela ?x ?expl)) )


;;;;;;;;;;;;;;;;;;Ejercicio ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Inicializar consulta
(defrule iniciar_consulta
=>
(printout t "=== Sistema de consulta sobre animales voladores ===" crlf)
(printout t "De que animal quieres saber si vuela? ")
(bind ?animal (read))
(assert (consulta ?animal))
)

; Verificar si el animal ya está en la base de conocimiento
(defrule animal_conocido
(declare (salience 10))
(consulta ?x)
(or (ave ?x) (mamifero ?x))
=>
(assert (animal_procesado ?x))
(printout t "Animal encontrado en la base de conocimiento." crlf)
)

; Si el animal no está en la BC, preguntar tipo
(defrule animal_desconocido
(declare (salience 5))
(consulta ?x)
(not (ave ?x))
(not (mamifero ?x))
=>
(printout t "No conozco ese animal. ¿Es un ave o un mamifero? (ave/mamifero/otro): ")
(bind ?tipo (read))
(assert (tipo_usuario ?x ?tipo))
)

; Procesar respuesta del usuario - ave
(defrule clasificar_como_ave
(declare (salience 4))
(tipo_usuario ?x ave)
=>
(assert (ave ?x))
(assert (animal_procesado ?x))
(printout t "Registrado como ave." crlf)
)

; Procesar respuesta del usuario - mamífero
(defrule clasificar_como_mamifero
(declare (salience 4))
(tipo_usuario ?x mamifero)
=>
(assert (mamifero ?x))
(assert (animal_procesado ?x))
(printout t "Registrado como mamifero." crlf)
)

; Procesar respuesta del usuario - otro tipo
(defrule clasificar_como_otro
(declare (salience 4))
(tipo_usuario ?x ?tipo)
(test (and (neq ?tipo ave) (neq ?tipo mamifero)))
=>
(assert (animal ?x))
(assert (animal_procesado ?x))
(printout t "Registrado como otro tipo de animal." crlf)
)

; Esperar a que se procesen todas las inferencias antes de mostrar resultado
(defrule preparar_resultado
(declare (salience -40))
(consulta ?x)
(animal_procesado ?x)
=>
(assert (listo_para_mostrar ?x))
)

; Mostrar resultado para aves
(defrule mostrar_resultado_ave
(declare (salience -50))
(consulta ?x)
(listo_para_mostrar ?x)
(ave ?x)
(vuela ?x ?vuela ?certeza)
(explicacion vuela ?x ?expl)
=>
(printout t crlf "=== RESULTADO ===" crlf)
(printout t ?x " es un ave." crlf)
(printout t "¿Vuela? " ?vuela " (certeza: " ?certeza ")" crlf)
(printout t "Explicacion: " ?expl crlf)
(printout t "=================" crlf)
)

; Mostrar resultado para mamíferos
(defrule mostrar_resultado_mamifero
(declare (salience -50))
(consulta ?x)
(listo_para_mostrar ?x)
(mamifero ?x)
(vuela ?x ?vuela ?certeza)
(explicacion vuela ?x ?expl)
=>
(printout t crlf "=== RESULTADO ===" crlf)
(printout t ?x " es un mamifero." crlf)
(printout t "¿Vuela? " ?vuela " (certeza: " ?certeza ")" crlf)
(printout t "Explicacion: " ?expl crlf)
(printout t "=================" crlf)
)

; Mostrar resultado para otros animales
(defrule mostrar_resultado_otro
(declare (salience -50))
(consulta ?x)
(listo_para_mostrar ?x)
(animal ?x)
(not (ave ?x))
(not (mamifero ?x))
(vuela ?x ?vuela ?certeza)
(explicacion vuela ?x ?expl)
=>
(printout t crlf "=== RESULTADO ===" crlf)
(printout t ?x " es otro tipo de animal." crlf)
(printout t "¿Vuela? " ?vuela " (certeza: " ?certeza ")" crlf)
(printout t "Explicacion: " ?expl crlf)
(printout t "=================" crlf)
)


; Caso especial: no se puede determinar si vuela
(defrule resultado_sin_info_vuelo
(declare (salience -60))
(consulta ?x)
(listo_para_mostrar ?x)
(not (vuela ?x ? ?))
=>
(printout t crlf "=== RESULTADO ===" crlf)
(printout t "No se puede determinar si " ?x " vuela." crlf)
(printout t "Informacion insuficiente en la base de conocimiento." crlf)
(printout t "=================" crlf)
)

; Limpiar explicaciones redundantes
(defrule limpiar_explicaciones_retraccion
(declare (salience -10))
(explicacion retracta_vuela ?x ?expl)
?f <- (explicacion vuela ?x ?old_expl)
(test (neq ?expl ?old_expl))
=>
(retract ?f)
(assert (explicacion vuela ?x ?expl))
)