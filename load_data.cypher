// Load Travel Recommendations Graph Data
// This file contains Cypher queries to load CSV data into Neo4j

// ============================================
// Step 1: Create Constraints and Indexes
// ============================================

// Create constraints for unique keys
CREATE CONSTRAINT user_id IF NOT EXISTS FOR (u:User) REQUIRE u.userId IS UNIQUE;
CREATE CONSTRAINT city_id IF NOT EXISTS FOR (c:City) REQUIRE c.cityId IS UNIQUE;
CREATE CONSTRAINT attraction_id IF NOT EXISTS FOR (a:Attraction) REQUIRE a.attractionId IS UNIQUE;
CREATE CONSTRAINT event_id IF NOT EXISTS FOR (e:Event) REQUIRE e.eventId IS UNIQUE;
CREATE CONSTRAINT activity_id IF NOT EXISTS FOR (a:Activity) REQUIRE a.activityId IS UNIQUE;

// Create indexes for common query patterns
CREATE INDEX user_email IF NOT EXISTS FOR (u:User) ON (u.email);
CREATE INDEX city_country IF NOT EXISTS FOR (c:City) ON (c.country);
CREATE INDEX attraction_category IF NOT EXISTS FOR (a:Attraction) ON (a.category);
CREATE INDEX event_type IF NOT EXISTS FOR (e:Event) ON (e.type);

// ============================================
// Step 2: Load Nodes
// ============================================

// Load Users
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/users.csv' AS row
CREATE (u:User {
  userId: row.userId,
  name: row.name,
  email: row.email,
  travelStyle: row.travelStyle,
  budgetRange: row.budgetRange
});

// Load Cities
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/cities.csv' AS row
CREATE (c:City {
  cityId: row.cityId,
  name: row.name,
  country: row.country,
  location: point({longitude: toFloat(row.longitude), latitude: toFloat(row.latitude)}),
  population: toInteger(row.population),
  averageBudget: row.averageBudget,
  cityDescription: row.cityDescription
});

// Load Attractions
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/attractions.csv' AS row
CREATE (a:Attraction {
  attractionId: row.attractionId,
  name: row.name,
  category: row.category,
  type: row.type,
  rating: toFloat(row.rating),
  crowdLevel: row.crowdLevel,
  attractionDescription: row.attractionDescription
});

// Load Events
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/events.csv' AS row
CREATE (e:Event {
  eventId: row.eventId,
  name: row.name,
  startDate: date(row.startDate),
  endDate: date(row.endDate),
  type: row.type
});

// Load Activities
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/activities.csv' AS row
CREATE (a:Activity {
  activityId: row.activityId,
  name: row.name,
  type: row.type,
  activityDescription: row.activityDescription
});

// ============================================
// Step 3: Load Relationships
// ============================================

// Create FRIENDS_WITH relationships
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/friends.csv' AS row
MATCH (u1:User {userId: row.userId1})
MATCH (u2:User {userId: row.userId2})
CREATE (u1)-[:FRIENDS_WITH]->(u2);

// Create VISITED relationships
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/visited.csv' AS row
MATCH (u:User {userId: row.userId})
MATCH (c:City {cityId: row.cityId})
CREATE (u)-[:VISITED {
  visitedDate: date(row.visitedDate),
  rating: toFloat(row.rating)
}]->(c);

// Create HAS_ATTRACTION relationships
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/city_attractions.csv' AS row
MATCH (c:City {cityId: row.cityId})
MATCH (a:Attraction {attractionId: row.attractionId})
CREATE (c)-[:HAS_ATTRACTION]->(a);

// Create HOSTS_EVENT relationships
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/city_events.csv' AS row
MATCH (c:City {cityId: row.cityId})
MATCH (e:Event {eventId: row.eventId})
CREATE (c)-[:HOSTS_EVENT]->(e);

// Create OFFERS_ACTIVITY relationships
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/city_activities.csv' AS row
MATCH (c:City {cityId: row.cityId})
MATCH (a:Activity {activityId: row.activityId})
CREATE (c)-[:OFFERS_ACTIVITY]->(a);

// Create NEARBY_TO relationships
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/nearby_cities.csv' AS row
MATCH (c1:City {cityId: row.cityId1})
MATCH (c2:City {cityId: row.cityId2})
CREATE (c1)-[:NEARBY_TO {
  distance: toFloat(row.distance),
  travelTime: toFloat(row.travelTime)
}]->(c2);

// Create RECOMMENDS relationships
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/recommendations.csv' AS row
MATCH (u:User {userId: row.userId})
MATCH (c:City {cityId: row.cityId})
CREATE (u)-[:RECOMMENDS]->(c);

// Create CATEGORIZED_AS relationships (Attraction -> Activity)
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/earacil/techtalk-edo-bcn-2026-demo/main/data/attraction_activities.csv' AS row
MATCH (a:Attraction {attractionId: row.attractionId})
MATCH (act:Activity {activityId: row.activityId})
CREATE (a)-[:CATEGORIZED_AS]->(act);

// ============================================
// Step 4: Create Similar Preferences (based on travel history)
// ============================================

// Create HAS_SIMILAR_PREFERENCES relationships based on users who visited similar cities
MATCH (u1:User)-[v1:VISITED]->(c:City)<-[v2:VISITED]-(u2:User)
WHERE abs(v1.rating - v2.rating) <= 0.25
WITH u1, u2, count(c) AS commonCities, avg(abs(v1.rating - v2.rating)) AS avgRatingDiff
WHERE commonCities >= 2 AND avgRatingDiff <= 0.25
// RETURN u1.name,u2.name, commonCities, avgRatingDiff
MERGE (u1)-[:HAS_SIMILAR_PREFERENCES]->(u2);

// ============================================
// Verification Queries
// ============================================

// Count nodes
MATCH (n)
RETURN labels(n)[0] AS label, count(n) AS count
ORDER BY label;

// Count relationships
MATCH ()-[r]->()
RETURN type(r) AS relationshipType, count(r) AS count
ORDER BY relationshipType;
