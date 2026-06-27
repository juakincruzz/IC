# IC - Ingeniería del Conocimiento

![CLIPS](https://img.shields.io/badge/CLIPS-Expert%20Systems-blue)
![OWL](https://img.shields.io/badge/OWL-Ontologies-orange)
![Knowledge Engineering](https://img.shields.io/badge/Knowledge%20Engineering-Reasoning-green)
![Grade](https://img.shields.io/badge/Entrega%201-9%2F10-brightgreen)
![Grade](https://img.shields.io/badge/Entrega%202-7.4%2F10-yellowgreen)

Repositorio de prácticas de la asignatura **Ingeniería del Conocimiento**.

El proyecto reúne varias prácticas centradas en **sistemas basados en conocimiento**, **sistemas expertos**, **razonamiento con reglas**, **ontologías OWL**, **factores de certeza**, **razonamiento difuso** y **razonamiento probabilístico**.

---

## Descripción

El repositorio está organizado en seis prácticas. Las tres primeras forman la **Entrega 1**, orientada principalmente a sistemas expertos en CLIPS aplicados a alimentación y recomendación de recetas. Las tres últimas forman la **Entrega 2**, donde se amplía el trabajo hacia ontologías, razonamiento no monótono, factores de certeza, lógica difusa y razonamiento bayesiano.

---

## Resultados académicos

| Entrega | Prácticas incluidas | Calificación |
|---|---|---:|
| Entrega 1 | P1, P2, P3 | 9/10 |
| Entrega 2 | P4, P5, P6 | 7,4/10 |

---

## Tecnologías utilizadas

- CLIPS
- OWL / WebProtégé
- Sistemas expertos basados en reglas
- Ontologías y representación semántica
- Factores de certeza
- Razonamiento difuso
- Razonamiento bayesiano

---

## Estructura del repositorio

```text
IC/
├── P1/
│   └── p1.clp
├── P2/
│   ├── p2.clp
│   └── recetas.txt
├── P3/
│   ├── README.txt
│   ├── main.clp
│   ├── p3.clp
│   ├── preguntas.clp
│   ├── propiedades-recetas.clp
│   ├── proponer-recetas.clp
│   ├── recetas-compatibles.clp
│   └── recetas.txt
├── P4/
│   ├── P4_IC.pdf
│   └── p4.owx
├── P5/
│   ├── act1.clp
│   ├── act2.clp
│   ├── act3.clp
│   └── act4.clp
├── P6/
│   ├── p6.clp
│   └── recetas.txt
└── README.md
```

---

## Entrega 1 - Sistemas expertos en CLIPS

**Calificación:** 9/10

### P1: Sistema de recomendación alimentaria

Sistema basado en conocimiento para recomendar la cantidad de consumo de un alimento dentro de una dieta cardiosaludable.

El sistema utiliza una base de hechos sobre la pirámide alimentaria, relaciones de subtipo entre alimentos y reglas de inferencia para clasificar alimentos y recomendar cantidades de consumo.

**Aspectos trabajados:**

- Representación de conocimiento nutricional.
- Hechos y reglas en CLIPS.
- Relaciones `es_un_tipo_de`.
- Clasificación de alimentos por niveles de la pirámide alimentaria.
- Deducción de información a partir de subtipos y composición.
- Generación de recomendaciones textuales.

### P2: Análisis de recetas

Sistema experto en CLIPS para trabajar con una base de recetas.

La práctica define una plantilla `receta` con información como nombre, ingredientes, dificultad, duración, tipo de plato, tipo de cocina, temporada y valores nutricionales. A partir de esos datos, el sistema deduce ingredientes relevantes y propiedades de las recetas.

**Aspectos trabajados:**

- Carga de hechos desde `recetas.txt`.
- Definición de `deftemplate` para representar recetas.
- Procesamiento de cadenas y nombres de ingredientes.
- Deducción de ingredientes relevantes.
- Clasificación de recetas mediante reglas.
- Uso de funciones auxiliares en CLIPS.

### P3: Sistema experto de recomendación de recetas

Sistema experto modular de recomendación culinaria.

El sistema pregunta al usuario por sus preferencias, filtra recetas compatibles y recomienda una receta final justificando la elección. Está organizado en varios módulos para separar preguntas, análisis de propiedades, compatibilidad y propuesta final.

**Módulos y archivos principales:**

| Archivo | Función |
|---|---|
| `p3.clp` | Regla principal de ejecución y carga de módulos. |
| `preguntas.clp` | Preguntas al usuario y recogida de preferencias. |
| `propiedades-recetas.clp` | Análisis de propiedades de las recetas. |
| `recetas-compatibles.clp` | Filtrado de recetas compatibles. |
| `proponer-recetas.clp` | Selección y recomendación final. |
| `recetas.txt` | Base de conocimiento con recetas. |

---

## Entrega 2 - Ontologías y razonamiento avanzado

**Calificación:** 7,4/10

### P4: Ontología OWL

Práctica de representación semántica mediante una ontología OWL.

La ontología modela entidades relacionadas con recetas, ingredientes, nutrientes, clientes, perfiles y objetivos. Incluye clases, propiedades de objeto, propiedades de datos e individuos nombrados.

**Aspectos trabajados:**

- Modelado ontológico.
- Clases e individuos.
- Propiedades de objeto.
- Propiedades de datos.
- Representación de clientes, perfiles, ingredientes y recetas.
- Uso de OWL como lenguaje de representación del conocimiento.

### P5: Razonamiento bajo incertidumbre

Conjunto de actividades en CLIPS centradas en distintos tipos de razonamiento.

| Archivo | Tema |
|---|---|
| `act1.clp` | Razonamiento por defecto y explicación de inferencias sobre animales que vuelan. |
| `act2.clp` | Factores de certeza aplicados al diagnóstico de problemas de arranque de un motor. |
| `act3.clp` | Sistema difuso para calcular dosis de medicamento según temperatura, peso y edad. |
| `act4.clp` | Razonamiento bayesiano aplicado a un ejemplo de diagnóstico de COVID-19. |

**Aspectos trabajados:**

- Reglas seguras y reglas por defecto.
- Retracción de conclusiones por defecto ante evidencia segura.
- Generación de explicaciones.
- Cálculo y combinación de factores de certeza.
- Funciones de pertenencia difusa.
- Inferencia difusa y centro de gravedad.
- Razonamiento probabilístico y bayesiano.

### P6: Sistema experto culinario con factores de certeza

Sistema experto de recomendación culinaria que incorpora factores de certeza.

La práctica retoma el dominio de recetas y añade una arquitectura modular con interfaz de preguntas, análisis nutricional, filtrado multicriterio y evaluación final con certeza.

**Módulos principales:**

- `PREGUNTAS`: interfaz simplificada con el usuario.
- `PROPIEDADES-RECETAS`: análisis nutricional automático.
- `RECETAS-COMPATIBLES`: filtrado de recetas según criterios.
- `EVALUACION-CERTEZA`: selección final usando factores de certeza.

---

## Ejecución

### CLIPS

Para ejecutar una práctica CLIPS:

```clips
(clear)
(load "p3.clp")
(reset)
(run)
```

En cada práctica se debe cargar el archivo principal correspondiente:

| Práctica | Archivo principal |
|---|---|
| P1 | `P1/p1.clp` |
| P2 | `P2/p2.clp` |
| P3 | `P3/p3.clp` |
| P5 | `P5/act1.clp`, `act2.clp`, `act3.clp` o `act4.clp` |
| P6 | `P6/p6.clp` |

### OWL

Para la práctica P4, abrir el archivo:

```text
P4/p4.owx
```

en una herramienta compatible con OWL, como **Protégé** o **WebProtégé**.

---

## Aprendizajes principales

Este repositorio demuestra el trabajo práctico con distintas técnicas de representación y razonamiento en ingeniería del conocimiento:

- Representación de conocimiento mediante hechos y reglas.
- Diseño de sistemas expertos en CLIPS.
- Modularización de sistemas basados en reglas.
- Filtrado y recomendación de recetas.
- Modelado de ontologías OWL.
- Razonamiento por defecto y explicación de inferencias.
- Factores de certeza para manejar incertidumbre.
- Razonamiento difuso aplicado a decisiones graduadas.
- Razonamiento bayesiano aplicado a diagnóstico.

---

## Autor

**Joaquín Cruz Lorenzo**  
GitHub: [@juakincruzz](https://github.com/juakincruzz)
