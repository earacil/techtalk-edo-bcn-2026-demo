// =============================================================================
// QUERIES.cypher - Neo4j Cypher queries for the travel/cities graph demo
// =============================================================================

// -----------------------------------------------------------------------------
// SIMILARITY & GRAPH ALGORITHMS
// -----------------------------------------------------------------------------

// Find similar cities based on pre-computed SIMILAR_TO relationships
MATCH (c:City)-[r:SIMILAR_TO]->(other:City)
WHERE elementId(c) < elementId(other)
RETURN DISTINCT(c.name) AS city1,
       other.name AS city2,
       r.similarity
ORDER BY r.similarity DESC;

// Delete all SIMILAR_TO relationships (cleanup before recomputing)
MATCH ()-[r:SIMILAR_TO]->()
DELETE r;

// -----------------------------------------------------------------------------
// SPATIAL QUERIES (distance, proximity)
// -----------------------------------------------------------------------------

// Find cities within 500 km radius from Barcelona
MATCH (barcelona:City {cityId: 'city2'})
MATCH (other:City)
WHERE other.cityId <> 'city2' AND other.location IS NOT NULL
WITH other, point.distance(barcelona.location, other.location) / 1000 AS distanceKm
WHERE distanceKm <= 500
RETURN other.name, other.country, distanceKm
ORDER BY distanceKm ASC;

// Calculate distance between two specific cities
MATCH (paris:City {cityId: 'city1'})
MATCH (rome:City {cityId: 'city3'})
RETURN paris.name AS fromCity,
       rome.name AS toCity,
       point.distance(paris.location, rome.location) / 1000 AS distanceKm;

// Find cities closest to a specific location (coordinates)
MATCH (c:City)
WHERE c.location IS NOT NULL
WITH c, point.distance(point({longitude: 2.3522, latitude: 48.8566}), c.location) / 1000 AS distanceKm
WHERE distanceKm <= 300
RETURN c.name, c.country, distanceKm
ORDER BY distanceKm ASC
LIMIT 10;

// Find cities closer to Paris than to London (comparative distance)
MATCH (paris:City {cityId: 'city1'})
MATCH (london:City {cityId: 'city8'})
MATCH (other:City)
WHERE other.cityId <> 'city1'
  AND other.cityId <> 'city8'
  AND other.location IS NOT NULL
WITH other,
     point.distance(paris.location, other.location) / 1000 AS distanceFromParis,
     point.distance(london.location, other.location) / 1000 AS distanceFromLondon
WHERE distanceFromParis < distanceFromLondon
RETURN other.name, distanceFromParis, distanceFromLondon
ORDER BY distanceFromParis ASC;

// Find nearby cities with budget filter (low budget within 400 km)
MATCH (barcelona:City {cityId: 'city2'})
MATCH (other:City)
WHERE other.cityId <> 'city2'
  AND other.location IS NOT NULL
  AND other.averageBudget = 'low'
WITH other, point.distance(barcelona.location, other.location) / 1000 AS distanceKm
WHERE distanceKm <= 400
RETURN other.name, other.country, other.averageBudget, distanceKm
ORDER BY distanceKm ASC;

// Find the 5 closest cities to a given origin city
MATCH (origin:City {cityId: 'city1'})
MATCH (other:City)
WHERE other.cityId <> 'city1' AND other.location IS NOT NULL
WITH other, point.distance(origin.location, other.location) / 1000 AS distanceKm
RETURN other.name, other.country, distanceKm
ORDER BY distanceKm ASC
LIMIT 5;

// -----------------------------------------------------------------------------
// SOCIAL & USER-BASED QUERIES
// -----------------------------------------------------------------------------

// Cities visited by a user's friends with high ratings (> 4.5 stars)
// Example: Enrique Aracil's friends and their top-rated cities
MATCH (me:User {userId: 'user25'})-[:FRIENDS_WITH]-(friend:User)
MATCH (friend)-[v:VISITED]->(city:City)
WHERE v.rating > 4.5
RETURN DISTINCT city.name AS city,
       friend.name AS visitedBy,
       v.rating
ORDER BY v.rating DESC;

// Cities with the most visitors (popularity ranking)
MATCH (u:User)-[v:VISITED]->(c:City)
RETURN c.name AS city,
       c.country,
       count(u) AS visitorCount,
       avg(v.rating) AS avgRating
ORDER BY visitorCount DESC
LIMIT 10;

// Cities with users who have visited (list cities and their visitors)
MATCH (u:User)-[v:VISITED]->(c:City)
RETURN c.name AS city,
       collect(u.name) AS visitors,
       count(u) AS visitorCount
ORDER BY visitorCount DESC;

// Top-rated cities by average visitor rating (min 2 reviews)
MATCH (u:User)-[v:VISITED]->(c:City)
WITH c, avg(v.rating) AS avgRating, count(v) AS reviewCount
WHERE reviewCount >= 2
RETURN c.name AS city,
       c.country,
       round(avgRating * 10) / 10 AS avgRating,
       reviewCount
ORDER BY avgRating DESC
LIMIT 10;

// -----------------------------------------------------------------------------
// TEMPORAL QUERIES (events, festivals)
// -----------------------------------------------------------------------------

// Cities with events or festivals during July
MATCH (c:City)-[:HOSTS_EVENT]->(e:Event)
WHERE (e.startDate >= date('2024-07-01') AND e.startDate <= date('2024-07-31'))
   OR (e.endDate >= date('2024-07-01') AND e.endDate <= date('2024-07-31'))
   OR (e.startDate <= date('2024-07-01') AND e.endDate >= date('2024-07-31'))
RETURN DISTINCT c.name AS city,
       c.country,
       collect(e.name) AS events
ORDER BY c.name;

// -----------------------------------------------------------------------------
// ATTRACTION-BASED QUERIES
// -----------------------------------------------------------------------------

// Cities with historical/cultural attractions (museum, landmark) and low crowd level
MATCH (c:City)-[:HAS_ATTRACTION]->(a:Attraction)
WHERE a.category IN ['museum', 'landmark']
  AND a.crowdLevel = 'low'
RETURN DISTINCT c.name AS city,
       c.country,
       collect(a.name) AS lowCrowdAttractions
ORDER BY size(collect(a.name)) DESC;

// Cities recommended by users
MATCH (u:User)-[:RECOMMENDED]->(c:City)
RETURN c.name AS city,
       c.country,
       collect(u.name) AS recommendedBy
ORDER BY size(collect(u.name)) DESC;
