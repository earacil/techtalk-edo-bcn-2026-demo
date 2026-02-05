# Deploy: Travel Recommendations Graph 

## LLM Instructions

### Step 1: Generate the Graph Data Model
- Read `use-case.md` to understand all the use cases that need to be supported
- Use MCP tools from `neo4j-graph-data-modeling` to design and validate a graph data model
- The model should include nodes for: Users, Cities, Attractions, Events, Activities, etc.
- The model should include relationships for: friendships, visits, ratings, geographic proximity, categorizations, etc.
- Validate the complete data model using `validate_data_model`
- Generate constraint queries using `get_constraints_cypher_queries`

### Step 2: Create Dummy Data
- Generate realistic dummy data that covers all use cases:
  - Multiple users (20-30) with diverse travel preferences and friend connections
  - Multiple cities (50-100) across different countries with coordinates
  - Various attractions with different categories and ratings
  - Events and festivals with dates
  - User visit history with ratings and dates
  - Geographic relationships (distances, nearby cities)
- Ensure data diversity to support all query patterns from `use-case.md`
- Write the dummy data in .csv files on /data folder

### Step 3: Create Cypher Load CSV Queries
- Create a file with the Cypher queries to load the .csv files on `/data`