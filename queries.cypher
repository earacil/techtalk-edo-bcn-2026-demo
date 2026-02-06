// Find similar cities
MATCH (c:City)-[r:SIMILAR_TO]->(other:City)
WHERE elementId(c) < elementId(other)
RETURN DISTINCT(c.name) AS city1,
       other.name AS city2,
       r.similarity
ORDER BY r.similarity DESC;

// Delete relations :SIMILAR_TO
MATCH ()-[r:SIMILAR_TO]->()
DELETE r;