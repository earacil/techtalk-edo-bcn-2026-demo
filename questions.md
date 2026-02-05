# Integración con MCP (Model Context Protocol)

El LLM utilizará herramientas MCP para:

1. **Ejecutar Cypher**: Consultar directamente el estado del grafo.
2. **Enriquecer**: Consultar una API de clima externa para descartar ciudades donde esté lloviendo hoy.

## Preguntas Relevantes que MCP puede Responder

1. **SI - ¿Qué ciudades han visitado mis amigos y han calificado con más de 4.5 estrellas?**
   - Consulta social basada en la red de amigos y sus ratings

2. **SI? - ¿Qué ciudades están a menos de 500 km de distancia desde Barcelona?**
   - Consulta de proximidad usando funciones de distancia con coordenadas POINT: `distance(barcelona.location, city.location)`

3. **SI - ¿Qué ciudades en Francia tienen atracciones categorizadas como "for children"?**
   - Consulta geográfica y de categorización combinada

4. **SI! - ¿Qué ciudades tienen eventos o festivales durante el mes de julio?**
   - Consulta temporal basada en fechas de eventos

5. **SI - ¿Qué ciudades ofrecen actividades de aventura y tienen un presupuesto medio?**
   - Consulta multi-criterio: actividades + presupuesto

7. **SI - ¿Qué ciudades puedo visitar en una ruta que conecte París, Roma y Barcelona? Salgo desde Barcelona**
   - Consulta de ruta usando relaciones NEARBY y algoritmos de camino

8. **SI - ¿Qué ciudades tienen atracciones históricas con nivel de aglomeración bajo?**
   - Consulta combinando categorías de atracciones y propiedades de crowdLevel

10. **SI - ¿Qué ciudades tienen el mejor ratio de rating promedio vs. presupuesto promedio?**
    - Consulta analítica con cálculos de valor

13. **SI - ¿Qué ciudades francesas están más cerca de Barcelona que de París?**
    - Consulta comparativa de distancias usando funciones espaciales para encontrar ciudades equidistantes o más cercanas

15. **SI - ¿Cuáles son las 5 ciudades más cercanas a Barcelona ordenadas por distancia?**
    - Consulta de proximidad usando `distance()` y ordenamiento por distancia calculada

**GDS**
16. **SI - Ejecuta el algoritmo de luvain de gds sobre el grafo e indica cuales son las comunidades que se detectan**

17. **SI - Ejecuta el algoritmo PageRank para obtener los 10 usuarios más influyentes**
    - Influencia transitiva: no solo tus conexiones directas, sino también la influencia de tus conexiones

18. **SI - busca ciudades similares en cuanto a tipos de actividad que se pueden hacer usando Node Similarity**

## Consultas por Similaridad (Vector Search)

### Similaridad de Ciudades
- **Embedding de ciudad**: Vector que representa características de la ciudad
  - Basado en: actividades ofrecidas, tipo de atracciones, presupuesto, clima, cultura
  - Uso: "Encuentra ciudades similares a París" o "Ciudades con perfil cultural similar a Florencia"

### Similaridad de Usuarios
- **Embedding de usuario**: Vector que representa preferencias de viaje del usuario
  - Basado en: historial de visitas, ratings dados, estilo de viaje, presupuesto
  - Uso: "Encuentra usuarios con gustos similares" para recomendaciones colaborativas

### Similaridad de Atracciones
- **Embedding de atracción**: Vector que representa características de la atracción
  - Basado en: categoría, tipo, rating, nivel de aglomeración, descripción
  - Uso: "Encuentra atracciones similares al Louvre" o "Atracciones con perfil similar pero menos concurridas"

### Similaridad de Actividades
- **Embedding de actividad**: Vector que representa el tipo de experiencia
  - Basado en: descripción, categoría, ciudades donde se ofrece
  - Uso: "Encuentra actividades complementarias a museos" o "Actividades similares a senderismo"

## Propiedades Propuestas para Embeddings (No implementadas aún)

### Para Nodos City:
- `cityEmbedding`: Vector de embeddings que representa características de la ciudad
  - Generado a partir de: nombre, país, actividades ofrecidas, tipos de atracciones, presupuesto promedio, descripción cultural
- `cityDescription`: Texto descriptivo de la ciudad (para generar embeddings)
- `cityFeatures`: Array de características clave (ej: ["beach", "museums", "nightlife", "history"])

### Para Nodos User:
- `userEmbedding`: Vector de embeddings que representa preferencias del usuario
  - Generado a partir de: historial de visitas, ratings dados, estilo de viaje, presupuesto, ciudades favoritas
- `userPreferences`: Texto descriptivo de preferencias (para generar embeddings)
- `travelProfile`: Objeto JSON con perfil de viaje estructurado

### Para Nodos Attraction:
- `attractionEmbedding`: Vector de embeddings que representa la atracción
  - Generado a partir de: nombre, categoría, tipo, descripción, rating, nivel de aglomeración
- `attractionDescription`: Texto descriptivo detallado de la atracción
- `attractionTags`: Array de tags descriptivos (ej: ["historical", "art", "architecture", "family-friendly"])

### Para Nodos Activity:
- `activityEmbedding`: Vector de embeddings que representa el tipo de actividad
  - Generado a partir de: nombre, tipo, descripción, ciudades donde se ofrece
- `activityDescription`: Texto descriptivo de la actividad
- `activityCategory`: Categoría principal de la actividad

### Para Relaciones:
- `VISITED` podría tener: `visitContext` (texto descriptivo de la experiencia) para generar embeddings contextuales
- `RECOMMENDED` podría tener: `recommendationReason` (texto con motivo de la recomendación) para embeddings semánticos

## Ejemplos de Consultas de Distancia y Coordenadas

```cypher
// Encontrar ciudades dentro de un radio de 500 km desde Barcelona
MATCH (barcelona:City {cityId: 'city2'})
MATCH (other:City)
WHERE other.cityId <> 'city2' AND other.location IS NOT NULL
WITH other, distance(barcelona.location, other.location) / 1000 AS distanceKm
WHERE distanceKm <= 500
RETURN other.name, other.country, distanceKm
ORDER BY distanceKm ASC

// Calcular distancia entre dos ciudades específicas
MATCH (paris:City {cityId: 'city1'})
MATCH (rome:City {cityId: 'city3'})
RETURN paris.name AS fromCity, rome.name AS toCity, 
       distance(paris.location, rome.location) / 1000 AS distanceKm

// Encontrar ciudades más cercanas a una ubicación específica (coordenadas)
MATCH (c:City)
WHERE c.location IS NOT NULL
WITH c, distance(point({longitude: 2.3522, latitude: 48.8566}), c.location) / 1000 AS distanceKm
WHERE distanceKm <= 300
RETURN c.name, c.country, distanceKm
ORDER BY distanceKm ASC
LIMIT 10

// Encontrar ciudades más cercanas a París que a Londres
MATCH (paris:City {cityId: 'city1'})
MATCH (london:City {cityId: 'city8'})
MATCH (other:City)
WHERE other.cityId <> 'city1' AND other.cityId <> 'city8' AND other.location IS NOT NULL
WITH other, 
     distance(paris.location, other.location) / 1000 AS distanceFromParis,
     distance(london.location, other.location) / 1000 AS distanceFromLondon
WHERE distanceFromParis < distanceFromLondon
RETURN other.name, distanceFromParis, distanceFromLondon
ORDER BY distanceFromParis ASC

// Encontrar ciudades cercanas con filtro de presupuesto
MATCH (barcelona:City {cityId: 'city2'})
MATCH (other:City)
WHERE other.cityId <> 'city2' 
  AND other.location IS NOT NULL
  AND other.averageBudget = 'low'
WITH other, distance(barcelona.location, other.location) / 1000 AS distanceKm
WHERE distanceKm <= 400
RETURN other.name, other.country, other.averageBudget, distanceKm
ORDER BY distanceKm ASC

// Encontrar las 5 ciudades más cercanas a una ubicación
MATCH (origin:City {cityId: 'city1'})
MATCH (other:City)
WHERE other.cityId <> 'city1' AND other.location IS NOT NULL
WITH other, distance(origin.location, other.location) / 1000 AS distanceKm
RETURN other.name, other.country, distanceKm
ORDER BY distanceKm ASC
LIMIT 5
```

## Ejemplos de Consultas de Similaridad Vectorial

```cypher
// Encontrar ciudades similares usando embeddings
MATCH (c:City {cityId: 'city1'})
WITH c.cityEmbedding AS queryVector
MATCH (other:City)
WHERE other.cityId <> 'city1' AND other.cityEmbedding IS NOT NULL
WITH other, gds.similarity.cosine(queryVector, other.cityEmbedding) AS similarity
WHERE similarity > 0.7
RETURN other.name, similarity
ORDER BY similarity DESC
LIMIT 10

// Encontrar usuarios con preferencias similares
MATCH (u:User {userId: 'user1'})
WITH u.userEmbedding AS queryVector
MATCH (other:User)
WHERE other.userId <> 'user1' AND other.userEmbedding IS NOT NULL
WITH other, gds.similarity.cosine(queryVector, other.userEmbedding) AS similarity
WHERE similarity > 0.75
RETURN other.name, similarity
ORDER BY similarity DESC

// Encontrar atracciones similares pero menos concurridas
MATCH (a:Attraction {attractionId: 'attr1'})
WITH a.attractionEmbedding AS queryVector
MATCH (other:Attraction)
WHERE other.attractionId <> 'attr1' 
  AND other.attractionEmbedding IS NOT NULL
  AND other.crowdLevel IN ['low', 'medium']
WITH other, gds.similarity.cosine(queryVector, other.attractionEmbedding) AS similarity
WHERE similarity > 0.65
RETURN other.name, other.crowdLevel, similarity
ORDER BY similarity DESC
LIMIT 15
```
