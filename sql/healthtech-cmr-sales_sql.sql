/* 
I. CREATING AND LOADING TABLES
The project data consists of a total of 6 CSV files.
*/
CREATE TABLE accounts (
    account_id VARCHAR(20) PRIMARY KEY, -- or just TEXT
    name VARCHAR(255),
    type VARCHAR(100),
    region VARCHAR(100),
    annual_revenue NUMERIC,
    created_date DATE
);
CREATE TABLE contacts (
    contact_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(255),
    title VARCHAR(100),
    email VARCHAR(255),
    account_id VARCHAR(20)
);
CREATE TABLE leads (
    lead_id VARCHAR(20) PRIMARY KEY,
    created_date DATE,
    lead_source VARCHAR(100),
    status VARCHAR(50),
    rep_id VARCHAR(20),
    converted_account_id VARCHAR(20)
);
CREATE TABLE opportunities (
    opp_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20),
    product VARCHAR(100),
    stage VARCHAR(50),
    amount NUMERIC,
    created_date DATE,
    close_date DATE,
    status VARCHAR(50),
    probability NUMERIC
);
CREATE TABLE activities (
    activity_id VARCHAR(20) PRIMARY KEY,
    opp_id VARCHAR(20),
    type VARCHAR(50),
    rep_id VARCHAR(20),
    timestamp TIMESTAMP,
    duration_min INTEGER
);
CREATE TABLE sales_reps (
    rep_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100),
    region VARCHAR(50),
    hire_date DATE,
    quota NUMERIC
);

/* 
Note before next step: The files contacts.csv and sales_reps.csv have been generated as clean files. 
In the next step, accounts.csv, activities.csv, leads.csv, and opportunities.csv will be reviewed, cleaned, 
and prepared in advance of the Tableau report.
*/

/* 
II. DATA CLEANING AND PREPARATION
A. accounts.csv
B. activities.csv
C. leads.csv
D. opportunities.csv
*/

/* 
A. Data cleaning and preparation: accounts.csv
account_id column is clean (PostgreSQL does not allow importing rows with duplicate IDs since it is a primary key) 
No other errors were found.
*/

/* 
name column cleaning: remove leading, trailing spaces; remove duplicate spaces inside the name; 
capitalize words; handle empty names.
*/
UPDATE accounts
SET name = TRIM(name);
UPDATE accounts
SET name = REGEXP_REPLACE(name, '\s+', ' ', 'g');
UPDATE accounts
SET name = INITCAP(name);
UPDATE accounts
SET name = NULL
WHERE TRIM(name) = '';

/* 
type column cleaning: Seems clean at first glance. The query below reassured me.
*/
SELECT DISTINCT type FROM accounts ORDER BY type;

/* 
region column cleaning: remove leading, trailing spaces; remove duplicate spaces inside the region; 
capitalize words; handle empty region.
*/
UPDATE accounts 
SET region = TRIM(region);
UPDATE accounts 
SET region = REGEXP_REPLACE(region, '\s+', ' ', 'g');
UPDATE accounts 
SET region = INITCAP(region);
UPDATE accounts 
SET region = NULL 
WHERE TRIM(region) = '';
SELECT DISTINCT region FROM accounts ORDER BY region;

/* 
annual_revenue column cleaning: handle empty annual_revenue; set annual_revenue < 1000 to NULL for reporting purposes.
*/
UPDATE accounts 
SET annual_revenue = NULL 
WHERE TRIM(COALESCE(annual_revenue::text, '')) = '';
SELECT * FROM accounts 
WHERE annual_revenue IS NULL OR annual_revenue <= 0;
SELECT * FROM accounts WHERE annual_revenue < 1000;
UPDATE accounts 
SET annual_revenue = NULL 
WHERE annual_revenue < 1000;

/* 
created_date column cleaning: No import errors detected. Column is clean.
*/

/* 
B. Data cleaning and preparation: activities.csv

activity_id column is clean (PostgreSQL does not allow importing rows with duplicate IDs since it is a primary key)
No other errors were found.
*/

/* 
opp_id column cleaning: check for missing values; check formats; check for foreign key integrity. Column is clean.
*/

SELECT * FROM activities WHERE opp_id IS NULL OR TRIM(opp_id) = '';
SELECT DISTINCT opp_id FROM activities ORDER BY opp_id;
SELECT opp_id
FROM activities
WHERE opp_id NOT IN (SELECT opp_id FROM opportunities);

/* 
type column cleaning: check all unique values; check for missing values; remove leading, trailing spaces; 
remove duplicate spaces inside the type; capitalize words; update misspelled words such as 'Dem0', 'E-Mail', 'Meting'.
*/

SELECT DISTINCT type FROM activities ORDER BY type;
SELECT * FROM activities WHERE type IS NULL OR TRIM(type) = '';
UPDATE activities SET type = TRIM(type);
UPDATE activities SET type = REGEXP_REPLACE(type, '\s+', ' ', 'g')
UPDATE activities SET type = INITCAP(type);
SELECT DISTINCT type FROM activities ORDER BY type;
UPDATE activities
SET type = 'Demo'
WHERE type = 'Dem0';
UPDATE activities
SET type = 'Email'
WHERE type = 'E-Mail';
UPDATE activities
SET type = 'Meeting'
WHERE type = 'Meting';

/* 
rep_id column cleaning: In 30 cases rep_id has no value and could not be recovered from other tables and were left as NULL.
*/

/* 
timestamp column cleaning: check for missing values; check formats; check for foreign key integrity; converted column from TIMESTAMP to DATE 
since time information was missing.
*/

ALTER TABLE activities
ALTER COLUMN timestamp TYPE DATE
USING timestamp::date;

/* 
duration_min column cleaning: No import errors detected. Column is clean.
*/

SELECT DISTINCT duration_min FROM activities ORDER BY duration_min;
SELECT * FROM activities WHERE duration_min IS NULL;

/* 
C. Data cleaning and preparation: leads.csv

lead_id column is clean (PostgreSQL does not allow importing rows with duplicate lead_ids since it is a primary key, 
therefore lead_id duplicates (totally 10 times duplicates were found) had been removed before importing rows from the leads.csv file)
*/

/* 
created_date column cleaning: check for missing values; correct format.
*/
SELECT * FROM leads WHERE created_date IS NULL;

/* 
lead_source column cleaning: check for missing values (missing values were found in 100 cases);
*/
SELECT * FROM leads WHERE lead_source IS NULL;

/* 
status column cleaning: Initially 19 status variations were found.
*/
UPDATE leads SET status = TRIM(status);
UPDATE leads SET status = REGEXP_REPLACE(status, '\s+', ' ', 'g')
SELECT DISTINCT status FROM leads ORDER BY status;
UPDATE leads
SET status = 'Open'
WHERE status IN ('OPEN', 'open');
UPDATE leads
SET status = 'Converted'
WHERE status IN ('CONVERTED', 'converted');
UPDATE leads
SET status = 'Disqualified'
WHERE status IN ('DISQUALIFIED', 'disqualified');
SELECT * FROM leads WHERE status IS NULL;

/* 
rep_id column cleaning: 49 missing rep_id values in leads could not be filled from other tables. Left as NULL.
*/
SELECT * FROM leads WHERE rep_id IS NULL;
/* 
converted_account_id column cleaning: In 1352 cases lead has not been converted into an account yet. 
In 648 cases the lead has been converted into an account.
*/
SELECT COUNT(*) FROM leads WHERE converted_account_id IS NULL;
SELECT * FROM leads WHERE converted_account_id IS NOT NULL;
UPDATE leads SET converted_account_id = TRIM(converted_account_id);
UPDATE leads SET converted_account_id = REGEXP_REPLACE(converted_account_id, '\s+', ' ', 'g')

/* 
D. Data cleaning and preparation: opportunities.csv

opp_id column is clean (PostgreSQL does not allow importing rows with duplicate lead_ids since it is a primary key.
*/

SELECT * FROM opportunities WHERE account_id IS NULL;
SELECT DISTINCT product FROM opportunities ORDER BY product;
SELECT * FROM opportunities WHERE stage IS NULL;
SELECT DISTINCT stage FROM opportunities ORDER BY stage;
SELECT * FROM opportunities WHERE amount <= 0;
UPDATE opportunities
SET amount = NULL
WHERE amount < 0;
SELECT *
FROM opportunities
WHERE status = 'Open'
  AND amount = 0;
/* 
In 5 cases amount was a negative, therefore they were set to NULL. Additionally, opp_id 'O00387' and 'opp_id O00686 
have amount=0, so the values should be updated.
*/
SELECT * FROM opportunities WHERE close_date IS NOT NULL AND close_date !~ '^\d{4}-\d{2}-\d{2}$';
SELECT * FROM opportunities WHERE status='Open';
SELECT DISTINCT status FROM opportunities;
SELECT * FROM opportunities WHERE probability < 0 OR probability > 100;
UPDATE opportunities
SET status = 'Won'
WHERE stage = 'Closed Won';
UPDATE opportunities
SET status = 'Lost'
WHERE stage = 'Closed Lost';

/* 
END OF DATA CLEANING
*/