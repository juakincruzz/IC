;;; AUTOR: JOAQUIN CRUZ LORENZO ;;;

;;;;;;;;;;;;;;;;;;Representación ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (FactorCerteza ?h si|no ?f) representa que ?h se ha deducido con factor de certeza ?f
;?h podrá_ser:
; - problema_starter
; - problema_bujias
; - problema_batería
; - motor_llega_gasolina
; (Evidencia ?e si|no) representa el hecho de si evidencia ?e se da
; ?e podrá ser:
; - hace_intentos_arrancar
; - hay_gasolina_en_deposito
; - encienden_las_luces
; - gira_motor


;;;;;;;;;;;;;;;;;;Reglas ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; convertimos cada evidencia en una afirmación sobre su factor de certeza
(defrule certeza_evidencias
  (Evidencia ?e ?r)
  =>
  (assert (FactorCerteza ?e ?r 1))
)

;;;;;;;;;;;;;;;;;;Funciones ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(deffunction encadenado (?fc_antecedente ?fc_regla)
(if (> ?fc_antecedente 0)
  then
    (bind ?rv (* ?fc_antecedente ?fc_regla))
  else
    (bind ?rv 0) )
?rv)

(deffunction combinacion (?fc1 ?fc2)
(if (and (> ?fc1 0) (> ?fc2 0) )
  then
    (bind ?rv (- (+ ?fc1 ?fc2) (* ?fc1 ?fc2) ) )
  else
    (if (and (< ?fc1 0) (< ?fc2 0) )
      then
        (bind ?rv (+ (+ ?fc1 ?fc2) (* ?fc1 ?fc2) ) )
      else
        (bind ?rv (/ (+ ?fc1 ?fc2) (- 1 (min (abs ?fc1) (abs ?fc2))) ))
    )
)
?rv)


;;;;;; Combinar misma deduccion por distintos caminos
(defrule combinar
(declare (salience 1))
?f <- (FactorCerteza ?h ?r ?fc1)
?g <- (FactorCerteza ?h ?r ?fc2)
(test (neq ?fc1 ?fc2))
=>
(retract ?f ?g)
(assert (FactorCerteza ?h ?r (combinacion ?fc1 ?fc2))) )



; Aunque en este ejemplo no se da, puede ocurrir que tengamos
; deducciones de hipótesis en positivo y negativo que hay que
; combinar para compararlas
(defrule combinar_signo
(declare (salience 2))
(FactorCerteza ?h si ?fc1)
(FactorCerteza ?h no ?fc2)
=>
(assert (Certeza ?h (- ?fc1 ?fc2))) )


;R1: SI el motor obtiene gasolina Y el motor gira ENTONCES problemas con las bujías con certeza 0,7
(defrule R1
(FactorCerteza motor_llega_gasolina si ?f1)
(FactorCerteza gira_motor si ?f2)
(test (and (> ?f1 0) (> ?f2 0)))
=>
(assert (FactorCerteza problema_bujias si (encadenado (* ?f1 ?f2) 0.7))))

;R2: SI NO gira el motor ENTONCES problema con el starter con certeza 0,8 con las bujías con certeza 0,7
(defrule R2
(FactorCerteza gira_motor no ?f1)
(test (> ?f1 0))
=>
(assert (FactorCerteza problema_starter si (encadenado ?f1 0.8))))

;R3: SI NO encienden las luces ENTONCES problemas con la bateria con certeza 0.9
(defrule R3
(FactorCerteza encienden_las_luces no ?f1)
(test (> ?f1 0))
=>
(assert (FactorCerteza problema_bateria si (encadenado ?f1 0.9))))

;R4: SI hay gasolina en el deposito ENTONCES el motor obtiene gasolina con certeza 0,9
(defrule R4
(FactorCerteza hay_gasolina_en_deposito si ?f1)
(test (> ?f1 0))
=>
(assert (FactorCerteza motor_llega_gasolina si (encadenado ?f1 0.9))))

;R5: SI hace intentos de arrancar ENTONCES problema con el starter con certeza -0,6
(defrule R5
(FactorCerteza hace_intentos_arrancar si ?f1)
(test (> ?f1 0))
=>
(assert (FactorCerteza problema_starter si (encadenado ?f1 -0.6))))

;R6: SI hace intentos de arrancar ENTONCES problema con la batería 0,5
(defrule R6
(FactorCerteza hace_intentos_arrancar si ?f1)
(test (> ?f1 0))
=>
(assert (FactorCerteza problema_bateria si (encadenado ?f1 0.5))))



;;;;;;;;;;;;;;;;;;Ejercicio ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Estado del sistema de preguntas
(deffacts inicio
(estado preguntando)
)

; Preguntar evidencias de forma secuencial
(defrule pregunta_hace_intentos_arrancar
(declare (salience 100))
(estado preguntando)
(not (Evidencia hace_intentos_arrancar ?))
=>
(printout t "=== SISTEMA DE DIAGNOSTICO DE COCHE ===" crlf)
(printout t "Hace intentos de arrancar? (si/no): ")
(bind ?r (read))
(while (and (neq ?r si) (neq ?r no))
  (printout t "Por favor, responda 'si' o 'no': ")
  (bind ?r (read)))
(assert (Evidencia hace_intentos_arrancar ?r))
)

(defrule pregunta_hay_gasolina_en_deposito
(declare (salience 99))
(estado preguntando)
(Evidencia hace_intentos_arrancar ?)
(not (Evidencia hay_gasolina_en_deposito ?))
=>
(printout t "Hay gasolina en el deposito? (si/no): ")
(bind ?r (read))
(while (and (neq ?r si) (neq ?r no))
  (printout t "Por favor, responda 'si' o 'no': ")
  (bind ?r (read)))
(assert (Evidencia hay_gasolina_en_deposito ?r))
)

(defrule pregunta_encienden_las_luces
(declare (salience 98))
(estado preguntando)
(Evidencia hace_intentos_arrancar ?)
(Evidencia hay_gasolina_en_deposito ?)
(not (Evidencia encienden_las_luces ?))
=>
(printout t "Encienden las luces? (si/no): ")
(bind ?r (read))
(while (and (neq ?r si) (neq ?r no))
  (printout t "Por favor, responda 'si' o 'no': ")
  (bind ?r (read)))
(assert (Evidencia encienden_las_luces ?r))
)

(defrule pregunta_gira_motor
(declare (salience 97))
(estado preguntando)
(Evidencia hace_intentos_arrancar ?)
(Evidencia hay_gasolina_en_deposito ?)
(Evidencia encienden_las_luces ?)
(not (Evidencia gira_motor ?))
=>
(printout t "El motor gira? (si/no): ")
(bind ?r (read))
(while (and (neq ?r si) (neq ?r no))
  (printout t "Por favor, responda 'si' o 'no': ")
  (bind ?r (read)))
(assert (Evidencia gira_motor ?r))
)

; Cambiar estado cuando todas las preguntas están respondidas
(defrule terminar_preguntas
(declare (salience 96))
?e <- (estado preguntando)
(Evidencia hace_intentos_arrancar ?)
(Evidencia hay_gasolina_en_deposito ?)
(Evidencia encienden_las_luces ?)
(Evidencia gira_motor ?)
=>
(retract ?e)
(assert (estado procesando))
(printout t crlf "Procesando informacion..." crlf)
)

; Eliminar factores de certeza de evidencias para quedarse solo con los deducidos
(defrule eliminar_factores_evidencia
(declare (salience -1))
(estado procesando)
(Evidencia ?h ?)
?f <- (FactorCerteza ?h ? ?)
=>
(retract ?f)
)

; Inicializar búsqueda de la mejor hipótesis
(defrule inicializar_busqueda
(declare (salience -2))
(estado procesando)
=>
(assert (mejor_hipotesis ninguna 0))
)

; Encontrar la hipótesis con mayor factor de certeza
(defrule encontrar_mejor_hipotesis
(declare (salience -3))
(estado procesando)
(FactorCerteza ?h si ?fc)
(test (or (eq ?h problema_starter) (eq ?h problema_bujias) (eq ?h problema_bateria)))
?f <- (mejor_hipotesis ? ?fc_actual)
(test (> ?fc ?fc_actual))
=>
(retract ?f)
(assert (mejor_hipotesis ?h ?fc))
)

; Mostrar resultado final
(defrule mostrar_diagnostico
(declare (salience -10))
(estado procesando)
(mejor_hipotesis ?h ?fc)
(test (> ?fc 0))
=>
(printout t crlf "=== RESULTADO DEL DIAGNOSTICO ===" crlf)
(printout t "Problema identificado: " ?h crlf)
(printout t "Factor de certeza: " (round (* ?fc 100)) "%" crlf)
(printout t "Explicacion: Este es el problema con mayor certeza segun las evidencias proporcionadas." crlf)
(printout t "=============================" crlf)
)

; Caso cuando no se puede determinar el problema
(defrule sin_diagnostico
(declare (salience -10))
(estado procesando)
(mejor_hipotesis ninguna 0)
=>
(printout t crlf "=== RESULTADO DEL DIAGNOSTICO ===" crlf)
(printout t "No se pudo determinar un problema con certeza suficiente." crlf)
(printout t "Se necesita mas informacion para realizar un diagnostico." crlf)
(printout t "=============================" crlf)
)

; Mostrar todos los factores de certeza para debug (opcional)
(defrule mostrar_factores_debug
(declare (salience -5))
(estado procesando)
(FactorCerteza ?h si ?fc)
(test (or (eq ?h problema_starter) (eq ?h problema_bujias) (eq ?h problema_bateria)))
(test (> ?fc 0.1))
=>
(printout t "Factor de certeza para " ?h ": " (round (* ?fc 100)) "%" crlf)
)