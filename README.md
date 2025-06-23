# HealthTech-CRM-Sales-Dashboard
Data similar to Salesforce CRM formats is generated in Python, cleaned and prepared using PostgreSQL, and visualized in Tableau as interactive CRM sales dashboards.

Tools: Python, PostgreSQL, Tableau

# Business Questions

# Dataset Description

All data in this dataset is fictional and does not represent any real persons, institutions, events, or similar entities.

The dataset contains the following tables:

`accounts`: account_id, name, type, region, annual_revenue, created_date 
`activities`: activity_id, opp_id, type, rep_id timestamp, duration_min
`contacts`: contact_id, name, title, email, account_id
`leads`: lead_id, created_date, lead_source, status, rep_id, converted_account_id
`opportunities`: opp_id, account_id, product, stage, amount, created_date, close_date, status, probability
`sales_reps`: rep_id, name, region, hire_date, quota

Note:
The tables intentionally contain dirty data, which has been cleaned using pgAdmin and PostgreSQL. Out of the six tables, only two contain clean data: the `contacts` and `sales_reps` tables.

# Data Cleaning and Preparation with PostgreSQL
## Data Cleaning
## Creating Views

# Tableau Data Modeling

# Tableau Dashboard Report Previews

![A  Accounts](https://github.com/user-attachments/assets/3e81c6c9-e74c-4b07-8d93-bfe39d4e1b2c)
![B  Activity and Engagement](https://github.com/user-attachments/assets/4282041a-35e1-4065-bfa1-f1518a07a373)
![C  Opportunitiy and Sales Performance](https://github.com/user-attachments/assets/fdc4a47c-a3df-4051-b8f5-0fd580d46e8f)

# Further Remarks
The dashboards can be customized according to client or management preferences, taking into account different business questions or particular problem statements they wish to address.
