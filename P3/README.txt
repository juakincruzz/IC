
# SISTEMA EXPERTO DE RECOMENDACIÓN DE RECETAS

Este sistema experto está diseñado en CLIPS para ayudarte a encontrar la receta perfecta según tus preferencias.

## Archivos incluidos

- `p3.clp` .................. Regla principal que carga los módulos y ejecuta el sistema.
- `recetas.txt` ............. Base de conocimiento con todas las recetas.
- `main.clp` ................ Módulo principal y regla de control del sistema.
- `preguntas.clp` ........... Pregunta al usuario sus preferencias.
- `propiedades-recetas.clp` . Carga y analiza las propiedades de las recetas.
- `recetas-compatibles.clp` . Filtra recetas compatibles.
- `proponer-recetas.clp` .... Recomienda la receta final óptima.

## ¿Cómo ejecutar?

1. Abre CLIPS.
2. Ejecuta el siguiente comando para limpiar el entorno:

```
(clear)
```

3. Carga el archivo principal:

```
(load "p3.clp")
```

4. Ejecuta el sistema:

```
(reset)
(run)
```

## ¿Qué hace el sistema?

1. Solicita tus preferencias: número de personas, dificultad, tiempo, tipo de plato, preferencias alimentarias, etc.
2. Lista las recetas compatibles con esas condiciones.
3. Te recomienda una receta óptima justificando por qué.
4. Puedes consultar más recetas compatibles si lo deseas.

---

**Nota:** Si no quieres responder a alguna pregunta durante la ejecución, puedes escribir `-1` para ignorarla.

¡Disfruta cocinando!
