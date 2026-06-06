;;; AUTOR: JOAQUIN CRUZ LORENZO ;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;   RAZONAMIENTO BAYESIANO   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;  EJEMPLO DE SISTEMA CON DOS VARIABLES QUE INFLUYEN Y DOS EFECTOS;;;;;
;;;;;;;;;;;;;;;;;;; Copywright: Juan Luis Castro Peña ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(deffacts relaciones_causa_efecto
(influye zona_origen COVID19)  ; zona de origen influye en la probabilidad de COVID19
(influye vacuna COVID19)       ; vacuna influye en la probabilidad de COVID19
(efecto tos COVID19)           ; tos es un efecto o síntoma común de COVID19
(efecto fiebre COVID19)        ; fiebre es un efecto o síntoma común de COVID19
(efecto test_resultado COVID19)        ; test_resultado es un efecto de COVID19
)

(deffacts probabilidad_variables_que_influyen
(prob zona_origen alto_riesgo 0.15)
(prob zona_origen medio_riesgo 0.45)
(prob zona_origen bajo_riesgo 0.4)
(prob vacuna si 0.72)
(prob vacuna no 0.28)
)

(deffacts distribucion_segun_valores_variables_que_influyen

(probcond2 COVID19 SI zona_origen alto_riesgo vacuna si 0.012) ; Vacunado en zona de alto riesgo
(probcond2 COVID19 SI zona_origen alto_riesgo vacuna no 0.055) ; No vacunado en zona de alto riesgo
(probcond2 COVID19 SI zona_origen medio_riesgo vacuna si 0.006) ; Vacunado en zona de medio riesgo
(probcond2 COVID19 SI zona_origen medio_riesgo vacuna no 0.028) ; No vacunado en zona de medio riesgo
(probcond2 COVID19 SI zona_origen bajo_riesgo vacuna si 0.002) ; Vacunado en zona de bajo riesgo
(probcond2 COVID19 SI zona_origen bajo_riesgo vacuna no 0.012) ; No vacunado en zona de bajo riesgo
)

(deffacts probabilidad_efectos
(probcond tos si COVID19 SI 0.72) ; 72% de los que tienen COVID19 tienen tos
(probcond tos si COVID19 NO 0.12) ; 12% de los que no tienen COVID19 tienen tos

(probcond fiebre alta COVID19 SI 0.47) ; 47% de los que tienen COVID19 tienen fiebre alta
(probcond fiebre alta COVID19 NO 0.015) ;  1.5% de los que no tienen COVID19 tienen fiebre alta
(probcond fiebre moderada COVID19 SI 0.38) ; 38% de los que tienen COVID19 tienen fiebre moderada
(probcond fiebre moderada COVID19 NO 0.065) ; 6.5% de los que no tienen COVID19 tienen fiebre moderada
(probcond fiebre baja COVID19 SI 0.12) ; 12% de los que tienen COVID19 tienen fiebre baja
(probcond fiebre baja COVID19 NO 0.28) ; 28% de los que no tienen COVID19 tienen fiebre baja


;(probcond test_resultado positivo COVID19 SI 0.78) ;Sensibilidad del test: 78%
;(probcond test_resultado positivo COVID19 NO 0.12) ; Falsos positivos: 12%     
;(probcond test_resultado negativo COVID19 SI 0.22) ; Falsos negativos: 22%        
;(probcond test_resultado negativo COVID19 NO 0.88) ; Especifidad: 88%

; EJEMPLO 4 SOLICITADO POR LA PROFESORA
(probcond test_resultado positivo COVID19 SI 0.9)  ; P(Test positivo/covid) = 0.9 (EXACTO del enunciado)
(probcond test_resultado positivo COVID19 NO 0.01) ; P(Test positivo/no covid) = 1 - 0.99 = 0.01
(probcond test_resultado negativo COVID19 SI 0.1)  ; P(Test negativo/covid) = 1 - 0.9 = 0.1        
(probcond test_resultado negativo COVID19 NO 0.99) ; P(Test negativo/no covid) = 0.99 (EXACTO del enunciado)
)

; Inicializamos valores para calculos a partir de probcond2
(deffacts inicializacion_probabilidades
(probconj2 COVID19 SI zona_origen alto_riesgo 0)
(probconj2 COVID19 SI zona_origen medio_riesgo 0)
(probconj2 COVID19 SI zona_origen bajo_riesgo 0)
(probconj2 COVID19 SI vacuna si 0)
(probconj2 COVID19 SI vacuna no 0)
(prob COVID19 SI 0)
)

(defrule inicio
=>
(printout t "Este es un sistema para decidir si usted padece COVID19" crlf)
(assert (informar datos))
(printout t crlf crlf "DATOS: Los datos estadísticos de que dispongo son:" crlf)
)

;;;; MODULO INFORMAR DATOS ;;;;

(defrule mostrar_prob_simples
(declare (salience 10))
(informar datos)
(influye ?i ?X) 
(prob ?i ?v  ?p)
=>
(printout t "Probabilidad de " ?i "=" ?v " es " ?p crlf)
)

(defrule mostrar_prob_condicionales
(declare (salience 9))
(informar datos)
(efecto ?e ?X) 
(probcond ?e ?v ?X SI ?p)
=>
(printout t "Probabilidad de " ?e "=" ?v " si " ?X " es " ?p crlf)
)

(defrule mostrar_prob_condicionales_bis
(declare (salience 9))
(informar datos)
(efecto ?e ?X) 
(probcond ?e ?v ?X NO ?p)
=>
(printout t "Probabilidad de " ?e "=" ?v " si no " ?X " es " ?p crlf)
)

(defrule mostrar_prob_condicionales2
(declare (salience 8))
(informar datos)
(probcond2 ?X SI ?i1 ?v1 ?i2 ?v2 ?p)
=>
(printout t "Probabilidad de " ?X " si " ?i1 "=" ?v1 " y " ?i2 "=" ?v2 " es " ?p crlf)
)

(defrule ir_a_deducciones_simples
(informar datos)
=>
(printout t crlf crlf "DEDUCCIONES SIMPLES:" crlf)
(assert (deducciones simples))
)

;;;;;;;  MODULO DEDUCCIONES SIMPLES

(defrule calcula_condicionada_negado
(declare (salience 3))
(deducciones simples)
(probcond ?e si ?X ?v ?p)
=>
(assert (probcond ?e no ?X ?v (- 1 ?p)))
)

(defrule probconj3
(declare (salience 2))
(deducciones simples)
(probcond2 ?X SI ?c1 ?v1 ?c2 ?v2 ?pc)
(prob ?c1 ?v1 ?p1)
(prob ?c2 ?v2 ?p2)
=>
(bind ?p (* (* ?pc ?p1) ?p2))
(assert (probconj3 ?X SI ?c1 ?v1 ?c2 ?v2 ?p))
(assert (sumar probconj2 ?X SI ?c1 ?v1 ?p))
(assert (sumar probconj2 ?X SI ?c2 ?v2 ?p))
(assert (sumar prob ?X SI ?p))
)

(defrule probconj2
(declare (salience 3))
(deducciones simples)
?f <- (probconj2 ?X SI ?c ?v ?p)
?g <- (sumar probconj2 ?X SI ?c ?v ?p1)
=>
(assert (probconj2 ?X SI ?c ?v (+ ?p ?p1)))
(retract ?f ?g)
)

(defrule calcula_testeo_negado
(declare (salience 3))
(deducciones simples)
(probcond test_resultado positivo ?X ?v ?p)
=>
(assert (probcond test_resultado negativo ?X ?v (- 1 ?p)))
)

(defrule calcula_probabilidad_condicionada
(declare (salience 1))
(deducciones simples)
(probconj2 ?X SI ?c ?v ?p)
(prob ?c ?v ?pc)
=>
(assert (probcond ?X SI ?c ?v (/ ?p ?pc)))
)

(defrule calcula_probabilidad_condicionada_3var
(declare (salience 1))
(deducciones simples)
(probconj3 ?X SI ?c ?v ?p)
(prob ?c ?v ?pc)
=>
(assert (probcond ?X SI ?c ?v (/ ?p ?pc)))
)

(defrule calcula_probabilidad
(declare (salience 2))
(deducciones simples)
?f <- (prob ?X SI ?p)
?g <- (sumar prob ?X SI ?pc)
=>
(assert (prob ?X SI (+ ?p ?pc)))
(retract ?f ?g)
)

(defrule mostrar_prob_condicionales_tris
(deducciones simples)
(probcond ?X SI ?i ?v ?p)
=>
(printout t "Probabilidad de " ?X " si " ?i "=" ?v " es " ?p crlf)
)

(defrule mostrar_prob_condicionales3
(declare (salience 8))
(informar datos)
(probcond3 ?X SI ?i1 ?v1 ?i2 ?v2 ?i3 ?v3 ?p)
=>
(printout t "Probabilidad de " ?X " si " ?i1 "=" ?v1 ", " ?i2 "=" ?v2 " y " ?i3 "=" ?v3 " es " ?p crlf)
)

(defrule Informa_probabilidad_a_priori
(declare (salience -1))
(deducciones simples)
(prob ?X SI ?p)
=>
(printout t crlf crlf "--> Segun los datos estadisticos: " crlf)
(printout t crlf "A PRIORI: la probabilidad de " ?X " es: " ?p crlf)
(printout t crlf)
)

(defrule ir_a_red_causal_causas
(declare (salience -2))
?f <- (deducciones simples)
=>
(printout t crlf crlf "INDAGANDO: Vamos a indagar en base a esos datos" crlf)
(retract ?f)
(assert (red causal causas))
)

;;;;;; MODULO RED CAUSAL CAUSAS

(defrule inferencia0causas
(red causal causas)
(influye ?c1 ?X)
(influye ?c2 ?X)
(test (neq ?c1 ?c2))
(valor ?c1 Desconocido)
(valor ?c2 Desconocido)
(prob ?X SI ?p)
=>
(assert (prob_posteriori_causas ?X ?p))
(assert (prob_conjunta ?X ?p))
(assert (prob_conjunta_negativo ?X (- 1 ?p)))
)

(defrule inferencia1causas
(red causal causas)
(influye ?c1 ?X)
(influye ?c2 ?X)
(valor ?c1 ?v1)
(valor ?c2 Desconocido)
(probcond ?X SI ?c1 ?v1 ?p+x/c)
(prob ?c1 ?v1 ?p)
=>
(assert (prob_posteriori_causas ?X ?p+x/c))
(assert (prob_conjunta ?X (* ?p ?p+x/c)))
(assert (prob_conjunta_negativo ?X (* ?p (- 1 ?p+x/c))))
(printout t  "--> " ?c1 " influye en la probabilidad de " ?X crlf)
(printout t "--> Como " ?c1 " toma el valor " ?v1 ":" crlf)
(printout t crlf "CON ESOS FACTORES: La probabilidad de " ?X " ha cambiado a " ?p+x/c crlf)
(printout t crlf)
)

(defrule inferencia2causas
(red causal causas)
(influye ?c1 ?X)
(influye ?c2 ?X)
(test (neq ?c1 ?c2))
(valor ?c1 ?v1)
(valor ?c2 ?v2)
(probcond2 ?X SI ?c1 ?v1 ?c2 ?v2 ?p+x/c1c2)
(prob ?c1 ?v1 ?p1)
(prob ?c2 ?v2 ?p2)
=>
(assert (prob_posteriori_causas ?X ?p+x/c1c2))
(assert (prob_conjunta ?X (* ?p2 (* ?p1 ?p+x/c1c2))))
(assert (prob_conjunta_negativo ?X (* ?p2 (* ?p1 (- 1 ?p+x/c1c2)))))
(printout t  "---> " ?c1 " y " ?c2 " influyen la probabilidad de " ?X crlf)
(printout t "--->  Como " ?c1 " toma el valor " ?v1 " y " ?c2 " toma el valor " ?v2 ":" crlf)
(printout t crlf "CON ESOS FACTORES: La probabilidad de " ?X " ha cambiado a " ?p+x/c1c2 crlf)
(printout t crlf)
)

(defrule ir_a_red_causal_efectos
(declare (salience -1))
?f <- (red causal causas)
=>
(printout t crlf crlf "BUSCANDO INDICIOS" crlf)
(retract ?f)
(assert (red causal efectos))
)


  
;;;;; MODULO RED CAUSAL EFECTOS   
  
(defrule redcausal1efecto
(red causal efectos)
(efecto ?e ?X) 
(valor ?e ?v & ~Desconocido)
(probcond ?e ?v ?X SI ?pe/+x)
(probcond ?e ?v ?X NO ?pe/-x)
=>
(assert (multiplicar prob_conjunta ?pe/+x)) 
(assert (multiplicar prob_conjunta_negativo ?pe/-x)) 
(printout t "--> " ?e " es un efecto de " ?X ". Como " ?e " toma el valor " ?v ":" crlf)
(printout t "--> vamos a utilizarlo para actualizar la probabilidad de " ?X crlf)
(printout t crlf)
)

(defrule actualizar_prob_conjunta
(red causal efectos)
?f <- (prob_conjunta ?X ?p+x)
?g <- (multiplicar prob_conjunta ?pe/+x)
=>
(bind ?p+x+e (* ?pe/+x ?p+x))
(assert (prob_conjunta ?X ?p+x+e))
(retract ?f ?g) 
)

(defrule actualizar_prob_conjunta_negativa
(red causal efectos)
?f <- (prob_conjunta_negativo ?X ?p)
?g <- (multiplicar prob_conjunta_negativo ?pe)
=>
(assert (prob_conjunta_negativo ?X (* ?p ?pe)))
(retract ?f ?g) 
)

(defrule prob_posteriori
(declare (salience -1))
(red causal efectos)
(prob_conjunta ?X ?p+x)
(prob_conjunta_negativo ?X ?p-x)
=>
(bind ?pc (+ ?p+x ?p-x))
(bind ?p (/ ?p+x ?pc))
(assert (prob_posteriori ?X ?p))
(printout t "FINALMENTE: Por el teorema de bayes a probabilidad de " ?X " ha cambiado a " ?p crlf)
(printout t crlf)
)

  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;   PARA PROBARLO  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  Normalmente los valores de las variables que influyen se deducen a partir
;;;  de datos a mas bajo nivel (por ejemplo a partir del pais se deduce la zona
;;;  de riesgo, o a traves del grupo sangíneo se deduce la vacuna
;;;  Los síntomas o efectos a veces se deducen y otras veces son introducidos por
;;;  el usuario
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(defrule preguntar_zona_origen
(red causal causas)
=>
(printout t "Escribe una opcion: La zona de origen es de riesgo (1=alto 2=medio 3=bajo 4=Desconocido): " )
(bind ?respuesta (read))
(if (= ?respuesta 1) then (assert (valor zona_origen alto_riesgo))
  else (if (= ?respuesta 2) then (assert (valor zona_origen medio_riesgo))
    else (if (= ?respuesta 3) then (assert (valor zona_origen bajo_riesgo))
	 else (assert (valor zona_origen Desconocido)))))
(printout t crlf)	 
)

(defrule preguntar_vacuna
(red causal causas)
=>
(printout t "Escribe una opcion: Esta vacunado? (1=si 2=no 3=Desconocido): " )
(bind ?respuesta (read))
(if (= ?respuesta 1) then (assert (valor vacuna si))        
  else (if (= ?respuesta 2) then (assert (valor vacuna no))
     else (assert (valor vacuna Desconocido))))
(printout t crlf)
)

(defrule preguntar_fiebre
(red causal efectos)
=>
(printout t "Escribe una opcion: Ha tenido fiebre (1=alta 2=moderada 3=baja 4=Desconocido): " )
(bind ?respuesta (read))
(if (= ?respuesta 1) then (assert (valor fiebre alta))
  else (if (= ?respuesta 2) then (assert (valor fiebre moderada))
    else (if (= ?respuesta 3) then (assert (valor fiebre baja))
     else (assert (valor fiebre Desconocido)))))
(printout t crlf)
)

(defrule preguntar_tos
(red causal efectos)
=>
(printout t "Escribe una opcion: Ha tenido tos? (1=si 2=no 3=Desconocido): " )
(bind ?respuesta (read))
(if (= ?respuesta 1) then (assert (valor tos si))
  else (if (= ?respuesta 2) then (assert (valor tos no))
     else (assert (valor tos Desconocido))))
(printout t crlf)
)

(defrule preguntar_test_resultado
(red causal efectos)
=>
(printout t "¿Se ha realizado alguna prueba diagnostica (PCR, antígenos, etc.)?" crlf)
(printout t "1 = Si, y el resultado fue POSITIVO" crlf)
(printout t "2 = Si, y el resultado fue NEGATIVO" crlf)
(printout t "3 = No me he hecho ninguna prueba / Desconocido" crlf)
(printout t "Escribe tu opcion (1-3): ")
(bind ?respuesta (read))
(if (= ?respuesta 1) then (assert (valor test_resultado positivo))
  else (if (= ?respuesta 2) then (assert (valor test_resultado negativo))
     else (assert (valor test_resultado Desconocido))))
(printout t crlf)
)

(defrule diagnostico_final
(declare (salience -3))
(prob_posteriori COVID19 ?p)
=>
(printout t "========================================" crlf)
(printout t "DIAGNOSTICO FINAL DE COVID-19:" crlf)
(printout t "Probabilidad calculada: " (round (* ?p 100)) "%" crlf)
(if (>= ?p 0.7) then
    (printout t "RESULTADO: ALTO riesgo de COVID-19" crlf)
    (printout t "RECOMENDACION: Contacte inmediatamente con servicios medicos" crlf)
  else (if (>= ?p 0.3) then
    (printout t "RESULTADO: MODERADO riesgo de COVID-19" crlf)
    (printout t "RECOMENDACION: Realice una prueba diagnostica" crlf)
  else (if (>= ?p 0.1) then
    (printout t "RESULTADO: BAJO riesgo de COVID-19" crlf)
    (printout t "RECOMENDACION: Mantenga medidas preventivas" crlf)
  else
    (printout t "RESULTADO: MUY BAJO riesgo de COVID-19" crlf)
    (printout t "RECOMENDACION: Medidas preventivas habituales" crlf)
  )
))
(printout t "========================================" crlf)
)