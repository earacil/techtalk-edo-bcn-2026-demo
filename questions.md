# MCP Integration (Model Context Protocol)

## Neo4j MCP utility for this demo

The Neo4j MCP (Model Context Protocol) enables the LLM to interact directly with the graph database without intermediate code. The assistant can:

- **Query the graph in real time**: Execute Cypher to explore nodes, relationships, and properties.
- **Discover the schema**: Use `get-schema` to understand the data structure before writing queries with `read-cypher` and `write-cypher`.
- **Apply graph algorithms (GDS)**: Run Louvain, PageRank, and other Graph Data Science procedures.
- **Iterate over results**: Adjust queries based on the response and refine until the desired information is obtained.

All of this is done through MCP tools that the model invokes autonomously, combining natural reasoning with direct access to Neo4j.

## Instructions for the LLM

Use the neo4j-mcp MCP exclusively to answer the following questions.
Do not use general knowledge or other tools.
If the MCP cannot complete a step, indicate it explicitly.

## Questions Agent

1. **I am Enrique Aracil. What cities have I visited?**
   - Direct query on the user's VISITED relationships

2. **Which of my friends have also visited any of those cities?**
   - Social query combining the user's visited cities with friends' visits

3. **Recommend me a romantic city with art, museums and beautiful architecture, and indicate the score**
   - Recommendation query combining city attributes and embeddings

## Questions MCP

1. **I am Enrique Aracil. What cities have my friends visited and rated with more than 4.5 stars?**
   - Social query based on the friendship network and ratings

2. **What cities are within 500 km of Barcelona?**
   - Proximity query using distance functions with POINT coordinates: `distance(barcelona.location, city.location)`

3. **What French cities are closer to Barcelona than to Paris?**
   - Comparative distance query using spatial functions to find equidistant or closer cities

4. **What cities have events or festivals during July?**
   - Temporal query based on event dates

5. **What cities have historical attractions with low crowd level?**
   - Query combining attraction categories and the crowdLevel property

### GDS

6. **Run the Louvain algorithm from GDS on the graph and indicate which communities are detected**
   - Community detection with the Louvain algorithm

7. **Run the PageRank algorithm to get the 10 most influential users**
   - Transitive influence: not just direct connections, but also the influence of your connections' connections