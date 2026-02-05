# Travel Recommendations Graph — Demo Guide

Step-by-step guide for the Neo4j Travel Recommendations demo. The graph models users, cities, attractions, events, and activities to support social, personalized, and location-based travel recommendations.

---

## Step 1: Load Data via Import in Aura

**Objective:** Import the travel recommendations graph into Neo4j AuraDB.

- Import Model to **Neo4j Aura Import** SHOW
- Use **Neo4j Aura Import** to load the CSV files from the `/data` folder.

---

## Step 2: Query in Neo4j Browser

**Objective:** Explore the graph and run Cypher queries in Neo4j Browser.

- Use **Neo4j Browser** (or Aura Query) to run Cypher queries.
- Add location

---

## Step 3: Dashboards

**Objective:** Visualize and explore the graph with Neo4j Dashboards.

- Open **Neo4j Dashboards**.

---

## Step 4: Bloom

**Objective:** Visualize and explore the graph with Neo4j Bloom.

- Open **Neo4j Explore** .

---

## Step 5: Python Vector Search (GraphRAG)

**Objective:** Add semantic search using embeddings and vector similarity.

- Use **Python** with the Neo4j driver to:
  - Generate embeddings for cities, users, or attractions (e.g. via OpenAI or similar).
  - Store embeddings as node properties.
  - Run vector similarity queries (e.g. cosine similarity) to find similar cities or users.
- Demonstrate **GraphRAG**-style flows: combine graph traversal with vector search for richer recommendations.
- Example: “Find cities similar to Paris” or “Find users with similar travel preferences.”

---

## Step 6: Aura Agents

**Objective:** Show how an AI agent can reason over the graph with Aura Agents.

- Use an **LLM agent** (e.g. LangChain, LlamaIndex) with Neo4j as a tool.
- The agent should:
  - Receive natural language questions.
  - Generate and execute Cypher queries.
  - Interpret results and return recommendations.
- Demonstrate multi-step reasoning (e.g. “Find cities my friends liked that I haven’t visited”).

---

## Step 7: MCP Neo4j from Cursor

**Objective:** Query the graph directly from Cursor via MCP (Model Context Protocol).

- Configure the **Neo4j MCP server** in Cursor.
- Ask questions in natural language from Cursor; the LLM uses MCP tools to run Cypher on the graph.
- Example questions:
  - “What cities have my friends visited and rated above 4.5 stars?”
  - “Which cities in France have attractions for children?”
  - “What cities have events in July?”
- Show how MCP enables graph-aware AI assistance without leaving the IDE.

---

## Quick Reference

| Step | Tool / Component | Main Outcome |
|------|------------------|--------------|
| 1 | Aura Import | Graph loaded from CSV |
| 2 | Cypher / Browser | Data validated |
| 3 | Neo4j Browser | Interactive Cypher exploration |
| 4 | Bloom | Visual graph exploration |
| 5 | Python + Vector Search | Semantic similarity (GraphRAG) |
| 6 | LLM Agent | Natural language → Cypher → answers |
| 7 | MCP + Cursor | Graph queries from the IDE |
