Modern Data Stack Portfolio Project: Zomato End-2-End Pipeline

Project Objective:
This project reinforces the core Modern Data Stack (MDS) engineering principles. It mimics a real-world production environment by transforming raw, multi-format source data into production-ready business intelligence assets.

Tech Stack:
1. Storage: AWS S3
2. Data Warehouse: Snowflake
3. Transformation: dbt (Data Build Tool)
4. BI Visualization: Tableau (Link: Coming Soon)

Data Architecture & Pipeline:
1. Ingestion: Semi-structured JSON datasets uploaded to AWS S3
   Link: Zomato Kaggle data (https://www.kaggle.com/datasets/shrutimehta/zomato-restaurants-data)
2. Staging: Copied data into raw Snowflake ingestion tables
3. Modeling: Structural formatting applied via Snowflake staging views
4. Transformation: dbt models built on top of staged views to generate optimized Dimension and Fact tables
5. Analytics: A scoped data extract built to feed a functional Tableau dashboard

Repository Structure:
snowflake/
dbt/
models/marts/
src/
data_ingestion/
tableau/

Analytics and Business Intelligence (BI) Layer:
The presentation layer consists of a Zomato Global Analytics dashboard powered by data extracts from Dimension and Fact tables. It focuses on Global Culinary trends.
![Dashboard Preview](tableau/Zomato_Global_Analytics_Intelligence_Modern_Data_Stack.png)

Key Visualizations & Features:
1. Global Restaurant Map: Interactive geographic map plotting restaurant locality density and distributions globally.
2. Global Cuisine Leaderboard: Ranked bar chart analyzing cuisines by their Average Customer Ratings and Average Price for Two people.
3. Dynamic Data Filters: Integrated interactive filtering for localized analysis:
     Country Name multi-select filter (e.g., India, Australia, Brazil, Canada).
     Cuisine Name multi-select filter.
     Quantitative sliders tracking Average Cost For Two and Average Total Votes.

Core Business Metrics Surfaced:
Average Cost For Two (Pricing tier analysis)
Average Customer Rating (Cuisine performance indicator)
Total Votes (Customer engagement and popularity tracking)

