# MCP Integration (Model Context Protocol)

The LLM will use MCP tools to:

1. **Execute Cypher**: Query the graph state directly.
2. **Enrich**: Query an external weather API to filter out cities where it's raining today.

Prompt: Use exclusively the neo4j-mcp MCP to answer next questions.
Do not use general knowledge or other tools.
If the MCP does not allow completing a step, indicate it explicitly.

## Relevant Questions MCP Can Answer

1. **YES - What cities have my friends visited and rated with more than 4.5 stars?**
   - Social query based on the friends network and their ratings

2. **YES? - What cities are within 500 km of Barcelona?**
   - Proximity query using distance functions with POINT coordinates: `distance(barcelona.location, city.location)`

3. **YES - What cities in France have attractions categorized as "for children"?**
   - Combined geographic and categorization query

4. **YES! - What cities have events or festivals during July?**
   - Temporal query based on event dates

5. **YES - What cities offer adventure activities and have a medium budget?**
   - Multi-criteria query: activities + budget

7. **YES - What cities can I visit on a route connecting Paris, Rome and Barcelona? I'm departing from Barcelona**
   - Route query using NEARBY relationships and path algorithms

8. **YES - What cities have historical attractions with low crowd level?**
   - Query combining attraction categories and crowdLevel properties

10. **YES - What cities have the best ratio of average rating vs. average budget?**
    - Analytical query with value calculations

13. **YES - What French cities are closer to Barcelona than to Paris?**
    - Comparative distance query using spatial functions to find equidistant or closer cities

15. **YES - What are the 5 cities closest to Barcelona ordered by distance?**
    - Proximity query using `distance()` and ordering by calculated distance

**GDS**
16. **YES - Run the Louvain algorithm from GDS on the graph and indicate which communities are detected**

17. **YES - Run the PageRank algorithm to get the 10 most influential users**
    - Transitive influence: not just your direct connections, but also the influence of your connections

18. **YES - Find similar cities in terms of types of activities that can be done using Node Similarity**

## Similarity Queries (Vector Search)

### City Similarity
- **City embedding**: Vector representing city characteristics
  - Based on: activities offered, attraction types, budget, climate, culture
  - Use: "Find cities similar to Paris" or "Cities with cultural profile similar to Florence"

### User Similarity
- **User embedding**: Vector representing user travel preferences
  - Based on: visit history, ratings given, travel style, budget
  - Use: "Find users with similar tastes" for collaborative recommendations

### Attraction Similarity
- **Attraction embedding**: Vector representing attraction characteristics
  - Based on: category, type, rating, crowd level, description
  - Use: "Find attractions similar to the Louvre" or "Attractions with similar profile but less crowded"

### Activity Similarity
- **Activity embedding**: Vector representing the type of experience
  - Based on: description, category, cities where it's offered
  - Use: "Find activities complementary to museums" or "Activities similar to hiking"

## Proposed Properties for Embeddings (Not yet implemented)

### For City Nodes:
- `cityEmbedding`: Embedding vector representing city characteristics
  - Generated from: name, country, activities offered, attraction types, average budget, cultural description
- `cityDescription`: Descriptive text of the city (for generating embeddings)
- `cityFeatures`: Array of key features (e.g. ["beach", "museums", "nightlife", "history"])

### For User Nodes:
- `userEmbedding`: Embedding vector representing user preferences
  - Generated from: visit history, ratings given, travel style, budget, favorite cities
- `userPreferences`: Descriptive text of preferences (for generating embeddings)
- `travelProfile`: JSON object with structured travel profile

### For Attraction Nodes:
- `attractionEmbedding`: Embedding vector representing the attraction
  - Generated from: name, category, type, description, rating, crowd level
- `attractionDescription`: Detailed descriptive text of the attraction
- `attractionTags`: Array of descriptive tags (e.g. ["historical", "art", "architecture", "family-friendly"])

### For Activity Nodes:
- `activityEmbedding`: Embedding vector representing the activity type
  - Generated from: name, type, description, cities where it's offered
- `activityDescription`: Descriptive text of the activity
- `activityCategory`: Main activity category

### For Relationships:
- `VISITED` could have: `visitContext` (descriptive text of the experience) for contextual embeddings
- `RECOMMENDED` could have: `recommendationReason` (text with recommendation reason) for semantic embeddings

## Distance and Coordinate Query Examples

```cypher
// Find cities within 500 km radius from Barcelona
MATCH (barcelona:City {cityId: 'city2'})
MATCH (other:City)
WHERE other.cityId <> 'city2' AND other.location IS NOT NULL
WITH other, distance(barcelona.location, other.location) / 1000 AS distanceKm
WHERE distanceKm <= 500
RETURN other.name, other.country, distanceKm
ORDER BY distanceKm ASC

// Calculate distance between two specific cities
MATCH (paris:City {cityId: 'city1'})
MATCH (rome:City {cityId: 'city3'})
RETURN paris.name AS fromCity, rome.name AS toCity, 
       distance(paris.location, rome.location) / 1000 AS distanceKm

// Find cities closest to a specific location (coordinates)
MATCH (c:City)
WHERE c.location IS NOT NULL
WITH c, distance(point({longitude: 2.3522, latitude: 48.8566}), c.location) / 1000 AS distanceKm
WHERE distanceKm <= 300
RETURN c.name, c.country, distanceKm
ORDER BY distanceKm ASC
LIMIT 10

// Find cities closer to Paris than to London
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

// Find nearby cities with budget filter
MATCH (barcelona:City {cityId: 'city2'})
MATCH (other:City)
WHERE other.cityId <> 'city2' 
  AND other.location IS NOT NULL
  AND other.averageBudget = 'low'
WITH other, distance(barcelona.location, other.location) / 1000 AS distanceKm
WHERE distanceKm <= 400
RETURN other.name, other.country, other.averageBudget, distanceKm
ORDER BY distanceKm ASC

// Find the 5 closest cities to a location
MATCH (origin:City {cityId: 'city1'})
MATCH (other:City)
WHERE other.cityId <> 'city1' AND other.location IS NOT NULL
WITH other, distance(origin.location, other.location) / 1000 AS distanceKm
RETURN other.name, other.country, distanceKm
ORDER BY distanceKm ASC
LIMIT 5
```

## Vector Similarity Query Examples

```cypher
// Find similar cities using embeddings
MATCH (c:City {cityId: 'city1'})
WITH c.cityEmbedding AS queryVector
MATCH (other:City)
WHERE other.cityId <> 'city1' AND other.cityEmbedding IS NOT NULL
WITH other, gds.similarity.cosine(queryVector, other.cityEmbedding) AS similarity
WHERE similarity > 0.7
RETURN other.name, similarity
ORDER BY similarity DESC
LIMIT 10

// Find users with similar preferences
MATCH (u:User {userId: 'user1'})
WITH u.userEmbedding AS queryVector
MATCH (other:User)
WHERE other.userId <> 'user1' AND other.userEmbedding IS NOT NULL
WITH other, gds.similarity.cosine(queryVector, other.userEmbedding) AS similarity
WHERE similarity > 0.75
RETURN other.name, similarity
ORDER BY similarity DESC

// Find similar attractions but less crowded
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
