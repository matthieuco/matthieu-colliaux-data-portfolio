# Data Quality Audit – Case study : SME Retail (Café/Bakery, Vancouver)

## Imports
import os
import pandas as pd
import subprocess

pd.set_option("display.max_columns", None)

# GET Workspace's PATH And current repository
def get_repo_root():
    try:
        root = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        root = os.getcwd()
    return root

print("Workspace CWD:", os.getcwd())
print("Repo root:", get_repo_root())
print("Script directory:", os.path.dirname(os.path.abspath(__file__)))
project_path =get_repo_root()+"/projects/financial_performance&risk_simulation/"
raw_datasources_path = project_path+"sources/raw_data/"

## 1. Data Scope Sources & audit methodologic

"""
Tables analyzed :
- checking_account_main
- checking_account_secondary
- credit_card_account
- gusto_payroll


Dimensions analyzed :
- Comliance/Complétude: Valeurs nulles / manquantes
- Unicity/Unicité :	Clés primaires
- Coherent/Cohérence	: Intra & inter-tables
- Business check/Validité métier :	Règles Risk
- Traceability /Traçabilité : Dates, historisation
- Outliers /Anomalies
"""

## 2. Load Data

checking_account_main = pd.read_csv(raw_datasources_path+"checking_account_main.csv")
checking_account_secondary = pd.read_csv(raw_datasources_path+"checking_account_secondary.csv")
credit_card_account = pd.read_csv(raw_datasources_path+"credit_card_account.csv")
gusto_payroll = pd.read_csv(raw_datasources_path+"gusto_payroll.csv")


## 3. Data Profiling (vue d'ensemble)

"""
Objectives :
- To understand data volumes
- To identify data types
- To detect the first alert signals
"""

# Conversion csv to dataframe
def profile_table(df, name):
    return pd.DataFrame({
        "table": name,
        "rows": len(df),
        "columns": df.shape[1],
        "memory_MB": round(df.memory_usage(deep=True).sum() / 1e6, 2)
    }, index=[0])

pd.concat([
    profile_table(checking_account_main, "checking_account_main"),
    profile_table(checking_account_secondary, "checking_account_secondary"),
    profile_table(credit_card_account, "credit_card_account"),
    profile_table(gusto_payroll, "gusto_payroll"),
])

 # Header preview


print("checking_account_main : \n",checking_account_main.head(5))
print("checking_account_secondary : \n",checking_account_secondary.head(5))
print("credit_card_account : \n",credit_card_account.head(5))
print("gusto_payroll : \n",gusto_payroll.head(5))


####4 Audit per table
### 4.1 checking_account_main
## A. Unicity

print("---------------- 4 .Audit per table --------------\n")
print("-------- --------- 4.1 TABLE : checking_account_main \n")
print("checking_account_main : \n",checking_account_main.head(5))
print("------- 4.1.A Unicity \n")

"""
Objectives :
- To evaluate the uniqueness of business keys and the impact of duplicates on indicators.
"""
print("checking_account_main:", checking_account_main.describe())
print("checking_account_main unicity on transaction_id:", checking_account_main['transaction_id'].duplicated().mean())

## B.Completeness Analysis
print("------- 4.1.B Completeness Analysis \n")
print("Completeness rate per column in checking_account_main table:")
print(checking_account_main.isnull().mean().sort_values(ascending=False))

## C.Business Validity Checks
print("------- 4.1.C Business Validity Checks \n")

"""
Objectives :
- To identify impossible or inconsistent values from a business perspective.
"""

# checking_account_main amount > balance
checking_account_main_amount_balance = checking_account_main[
    (checking_account_main['amount'] > checking_account_main['balance'])]
    
print("Number of checking_account_main with amount > balance:", len(checking_account_main_amount_balance))

# checking_account_main negative balance
checking_account_main_negativeB = checking_account_main[
    (checking_account_main['balance'] < 0)]
    
print("Number of checking_account_main with negative balance:", len(checking_account_main))

## D.Outliers Detection
print("------- 4.1.D Outliers Detection \n")
"""
Objectives :
Identify extreme values that may impact analysis.
"""
 # Outliers in amount and balance
print("outliers :\n",checking_account_main[['amount', 'balance']].describe())  

### 4.2 checking_account_secondary
## A. Unicity

print("-------- --------- 4.2 TABLE : checking_account_secondary \n")
print("checking_account_secondary : \n",checking_account_secondary.head(5))
print("------- 4.2.A Unicity \n")

print("checking_account_secondary:", checking_account_secondary.describe())
print("checking_account_secondary unicity on transaction_id:", checking_account_secondary['transaction_id'].duplicated().mean())

## B.Completeness Analysis
print("------- 4.2.B Completeness Analysis \n")
print("Completeness rate per column in checking_account_secondary table:")
print(checking_account_secondary.isnull().mean().sort_values(ascending=False))

## C.Business Validity Checks
print("------- 4.2.C Business Validity Checks \n")

# checking_account_secondary amount > balance
checking_account_secondary_amount_balance = checking_account_secondary[
    (checking_account_secondary['amount'] > checking_account_secondary['balance'])]
    
print("Number of checking_account_secondary with amount > balance:", len(checking_account_secondary_amount_balance))

# checking_account_secondary negative balance
checking_account_secondary_negativeB = checking_account_secondary[
    (checking_account_secondary['balance'] < 0)]
    
print("Number of checking_account_secondary with negative balance:", len(checking_account_secondary_negativeB))
## D.Outliers Detection
print("------- 4.2.D Outliers Detection \n")

 # Outliers in amount and balance
print("outliers :\n",checking_account_secondary[['amount', 'balance']].describe())  

### 4.3 credit_card_account
## A. Unicity

print("-------- --------- 4.3 TABLE : credit_card_account \n")
print("credit_card_account : \n",credit_card_account.head(5))
print("------- 4.3.A Unicity \n")


print("credit_card_account:", credit_card_account.describe())
print("credit_card_account unicity on transaction_id:", credit_card_account['transaction_id'].duplicated().mean())

## B.Completeness Analysis
print("------- 4.3.B Completeness Analysis \n")
print("Completeness rate per column in credit_card_account table:")
print(credit_card_account.isnull().mean().sort_values(ascending=False))

## C.Business Validity Checks
print("------- 4.3.C Business Validity Checks \n")
# credit_card_account amount > balance
credit_card_account_amount_balance = credit_card_account[
    (credit_card_account['amount'] > credit_card_account['balance'])]
    
print("Number of credit_card_account with amount > balance:", len(credit_card_account_amount_balance))

# credit_card_account negative balance
credit_card_account_negativeB = credit_card_account[
    (credit_card_account['balance'] < 0)]
    
print("Number of credit_card_account with negative balance:", len(credit_card_account_negativeB))
## D.Outliers Detection
print("------- 4.3.D Outliers Detection \n")
 # Outliers in amount and balance
print("outliers :\n",credit_card_account[['amount', 'balance']].describe())  

### 4.4 gusto_payroll
## A. Unicity

print("-------- --------- 4.4 TABLE : gusto_payroll \n")
print("gusto_payroll : \n",gusto_payroll.head(5))
print("------- 4.4.A Unicity \n")


print("gusto_payroll: \n", gusto_payroll.describe())
print("gusto_payroll unicity on employee_id:", gusto_payroll['employee_id'].duplicated().mean())

## B.Completeness Analysis
print("------- 4.4.B Completeness Analysis \n")
print("Completeness rate per column in gusto_payroll table:")
print(gusto_payroll.isnull().mean().sort_values(ascending=False))

## C.Business Validity Checks
print("------- 4.4.C Business Validity Checks \n")

# gusto_payroll negative amount
gusto_payroll_negativeA = gusto_payroll[
    (gusto_payroll['amount'] <= 0)]
    
print("Number of gusto_payroll with null or negative amount:", len(gusto_payroll_negativeA))
  
## D.Outliers Detection
print("------- 4.4.D Outliers Detection \n")
 # Outliers in amount and balance
print("outliers :\n",gusto_payroll['amount'].describe())