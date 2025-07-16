# HealthTech-CRM-Sales-Dashboard-PostgreSQL-ETL
Data similar to Salesforce CRM formats is generated in Python, cleaned and prepared using PostgreSQL, and visualized in Tableau as interactive CRM sales dashboards.

Tools: Python, PostgreSQL, Tableau

Links: 

[Dataset](data)

[Python data generation script](python/generate_crm_data.py)

[Database SQL script](sql/healthtech-cmr-sales_sql.sql)

[Tableau Public visualization](https://public.tableau.com/app/profile/viktoria.zetko/viz/Healthcare-CRM-Sales/A_Accounts)

# Business Questions

The business questions were asked by the managers and decision-makers of the fictional HealthTech company for the years 2023 and 2024.

## Accounts Dashboard

* How many accounts are we managing, and how much are they worth?
* How are accounts and sales distributed across regions?
* Which account types or segments drive the most revenue?
* Who are our top-performing accounts?

## Activity and Engagement Dashboard

* How engaged are our sales teams and accounts?
* What types of activities are performed most frequently?
* How does engagement and activity trend over time?
* How are activities distributed by sales stage?
* Which sales reps are most active and effective?
  
## Opportunity and Sales Performance Dashboard

* What is the size and status of our current sales pipeline?
* How is our sales performance trending over time?
* Which products are selling the most?
* What is our win rate versus lost opportunities?
* Where are opportunities concentrated by account?
* How is the pipeline distributed by sales stage and conversion rates?
  
# Dataset Description

Note: All data in this dataset is fictional and does not represent any real persons, institutions, events, or similar entities.

The dataset contains the following tables:

`accounts`: account_id, name, type, region, annual_revenue, created_date

`activities`: activity_id, opp_id, type, rep_id timestamp, duration_min

`contacts`: contact_id, name, title, email, account_id

`leads`: lead_id, created_date, lead_source, status, rep_id, converted_account_id

`opportunities`: opp_id, account_id, product, stage, amount, created_date, close_date, status, probability

`sales_reps`: rep_id, name, region, hire_date, quota

Note:
The tables intentionally contain dirty data, which has been cleaned using pgAdmin and PostgreSQL. Out of the six tables, only two contain clean data from the Python generation stage: the `contacts` and `sales_reps` tables.

# Data Cleaning and Preparation with PostgreSQL
## Data Cleaning
Data cleaning was performed using standard techniques such as identifying and correcting errors, removing duplicates, and standardizing value formats. The data cleaning was performed in pgAdmin using PostgreSQL. The complete script can be viewed here: [Database SQL script](sql/healthtech-cmr-sales_sql.sql)

## Creating Views
The robust volume of data made it impossible to merge all the tables -Tableau can handle a maximum of 1 million rows- therefore three views were created in pgAdmin.
### Accounts view

<pre> ```CREATE OR REPLACE VIEW public.accounts_view
 AS
 SELECT acc.account_id,
    acc.name,
    acc.type,
    acc.region,
    acc.annual_revenue,
    count(DISTINCT o.opp_id) AS num_opportunities,
    sum(o.amount) AS total_sales
   FROM accounts acc
     LEFT JOIN opportunities o ON o.account_id::text = acc.account_id::text
  GROUP BY acc.account_id, acc.name, acc.type, acc.region, acc.annual_revenue;

ALTER TABLE public.accounts_view
    OWNER TO postgres; ```</pre>

### Activity view

<pre> ```CREATE OR REPLACE VIEW public.activity_view
 AS
 SELECT a.activity_id,
    a.type AS activity_type,
    a."timestamp" AS activity_timestamp,
    a.duration_min,
    o.opp_id,
    o.amount,
    o.stage,
    sr.name AS rep_name
   FROM activities a
     LEFT JOIN opportunities o ON a.opp_id::text = o.opp_id::text
     LEFT JOIN sales_reps sr ON a.rep_id::text = sr.rep_id::text;

ALTER TABLE public.activity_view
    OWNER TO postgres;```</pre>
### Opportunity view

<pre> ```CREATE OR REPLACE VIEW public.opportunity_view
 AS
 SELECT o.opp_id,
    o.account_id,
    o.product,
    o.stage,
    o.amount,
    o.created_date,
    o.close_date,
    o.status,
    o.probability,
    acc.name AS account_name,
    acc.region,
    acc.annual_revenue
   FROM opportunities o
     LEFT JOIN accounts acc ON o.account_id::text = acc.account_id::text;

ALTER TABLE public.opportunity_view
    OWNER TO postgres;```</pre>

# Tableau Data Modeling

![datamodeling](https://github.com/user-attachments/assets/ed0e04fb-bce5-4662-8da1-cb26e9202458)



# Tableau Dashboard Report Previews

![A  Accounts](https://github.com/user-attachments/assets/3e81c6c9-e74c-4b07-8d93-bfe39d4e1b2c)
![B  Activity and Engagement](https://github.com/user-attachments/assets/4282041a-35e1-4065-bfa1-f1518a07a373)
![C  Opportunitiy and Sales Performance](https://github.com/user-attachments/assets/fdc4a47c-a3df-4051-b8f5-0fd580d46e8f)

# Further Remarks
The dashboards can be customized according to client or management preferences, taking into account different business questions or particular problem statements they wish to address.
