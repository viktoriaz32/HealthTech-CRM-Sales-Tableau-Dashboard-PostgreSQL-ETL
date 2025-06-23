# CRM Data Generation with Faker & Pandas
# Simulates 6 CRM tables (4 dirty, 2 clean) for 2023-2024

import pandas as pd
import numpy as np
from faker import Faker
import random

fake = Faker()

# Set seed for reproducibility
Faker.seed(42)
random.seed(42)
np.random.seed(42)

# --- Parameters ---
N_ACCOUNTS = 200
N_CONTACTS = 300
N_LEADS = 2000
N_OPPS = 800
N_ACTIVITIES = 10000
N_SALES_REPS = 26

regions = ['Northeast', 'Midwest', 'South', 'West']
account_types = ['Clinic', 'Hospital', 'Health System']
products = ['OmniRecord', 'OmniTelemed', 'OmniCare', 'OmniAnalytics']
stages = ['Prospecting', 'Qualification', 'Proposal', 'Negotiation', 'Closed Won', 'Closed Lost']
lead_sources = ['Webinar', 'Conference', 'Website', 'Referral', 'Email']
activity_types = ['Call', 'E-Mail', 'Meeting', 'Demo']

# Helper for random 2023-2024 dates
def random_date_2023_2024():
    return fake.date_between_dates(
        date_start=pd.to_datetime('2023-01-01'),
        date_end=pd.to_datetime('2024-12-31')
    )

# ---------------------------------------
# 1. Generate Clean Sales Reps Table
# ---------------------------------------
sales_reps = []
for i in range(1, N_SALES_REPS + 1):
    rep_id = f"R{str(i).zfill(3)}"
    sales_reps.append({
        'rep_id': rep_id,
        'name': fake.name(),
        'region': random.choice(regions),
        'hire_date': fake.date_between(start_date='-10y', end_date='-1y'),  # Hired before 2023 for realism
        'quota': random.randint(500_000, 5_000_000)
    })
df_sales_reps = pd.DataFrame(sales_reps)

# ---------------------------------------
# 2. Generate Clean Contacts Table
# ---------------------------------------
contacts = []
for i in range(1, N_CONTACTS + 1):
    contact_id = f"C{str(i).zfill(4)}"
    contacts.append({
        'contact_id': contact_id,
        'name': fake.name(),
        'title': random.choice(['CTO', 'CIO', 'VP Clinical Systems', 'COO']),
        'email': fake.email(),
        'account_id': f"A{str(random.randint(1, N_ACCOUNTS)).zfill(4)}"
    })
df_contacts = pd.DataFrame(contacts)

# ---------------------------------------
# 3. Generate Dirty Accounts Table
# ---------------------------------------
accounts = []
for i in range(1, N_ACCOUNTS + 1):
    account_id = f"A{str(i).zfill(4)}"
    # Dirty: Some names will have extra spaces, some regions missing, some revenue as string
    name = fake.company() + (' Health' if random.random() < 0.8 else '')
    if random.random() < 0.1:
        name = " " + name + " "
    region = random.choice(regions) if random.random() > 0.05 else None
    account_type = random.choice(account_types)
    revenue = random.choice([
        round(random.uniform(1e6, 5e8), 2),
        str(round(random.uniform(1e6, 5e8), 2)) if random.random() < 0.2 else None
    ])
    created_date = random_date_2023_2024()
    accounts.append({
        'account_id': account_id,
        'name': name,
        'type': account_type,
        'region': region,
        'annual_revenue': revenue,
        'created_date': created_date
    })
df_accounts = pd.DataFrame(accounts)

# ---------------------------------------
# 4. Generate Dirty Leads Table
# ---------------------------------------
leads = []
for i in range(1, N_LEADS + 1):
    lead_id = f"L{str(i).zfill(5)}"
    created_date = random_date_2023_2024()
    lead_source = random.choice(lead_sources)
    # Dirty: some sources missing, some status case mismatched, some converted account ids invalid
    status = random.choice(['Open', 'Disqualified', 'Qualified', 'disqualified', 'qualified'])
    rep_id = random.choice(df_sales_reps['rep_id'])
    converted_account_id = f"A{str(random.randint(1, N_ACCOUNTS)).zfill(4)}" if random.random() < 0.15 else np.nan
    if random.random() < 0.1:
        converted_account_id = "unknown"
    leads.append({
        'lead_id': lead_id,
        'created_date': created_date,
        'lead_source': lead_source,
        'status': status,
        'rep_id': rep_id,
        'converted_account_id': converted_account_id
    })
df_leads = pd.DataFrame(leads)

# ---------------------------------------
# 5. Generate Dirty Opportunities Table
# ---------------------------------------
opps = []
for i in range(1, N_OPPS + 1):
    opp_id = f"O{str(i).zfill(5)}"
    account_id = f"A{str(random.randint(1, N_ACCOUNTS)).zfill(4)}"
    product = random.choice(products)
    stage = random.choice(stages)
    amount = round(random.uniform(50_000, 5_000_000), 2)
    if random.random() < 0.12:  # Dirty: some amounts as string, some missing
        amount = str(amount) if random.random() < 0.5 else None
    created_date = random_date_2023_2024()
    close_date = random_date_2023_2024() if random.random() < 0.6 else None
    status = random.choice(['Open', 'Closed', 'open', 'closed'])
    probability = random.choice([10, 30, 50, 70, 90, None])
    opps.append({
        'opp_id': opp_id,
        'account_id': account_id,
        'product': product,
        'stage': stage,
        'amount': amount,
        'created_date': created_date,
        'close_date': close_date,
        'status': status,
        'probability': probability
    })
df_opps = pd.DataFrame(opps)

# ---------------------------------------
# 6. Generate Dirty Activities Table
# ---------------------------------------
activities = []
for i in range(1, N_ACTIVITIES + 1):
    activity_id = f"ACT{str(i).zfill(5)}"
    opp_id = f"O{str(random.randint(1, N_OPPS)).zfill(5)}"
    type_ = random.choice(activity_types)
    rep_id = random.choice(df_sales_reps['rep_id'])
    timestamp = random_date_2023_2024()
    duration_min = random.choice([15, 30, 45, None])
    # Dirty: some durations missing, some types with case error
    if random.random() < 0.07:
        type_ = type_.lower()
    activities.append({
        'activity_id': activity_id,
        'opp_id': opp_id,
        'type': type_,
        'rep_id': rep_id,
        'timestamp': timestamp,
        'duration_min': duration_min
    })
df_activities = pd.DataFrame(activities)

# ---------------------------------------
# Save to CSV
# ---------------------------------------
df_accounts.to_csv('accounts.csv', index=False)
df_contacts.to_csv('contacts.csv', index=False)
df_leads.to_csv('leads.csv', index=False)
df_opps.to_csv('opportunities.csv', index=False)
df_activities.to_csv('activities.csv', index=False)
df_sales_reps.to_csv('sales_reps.csv', index=False)
