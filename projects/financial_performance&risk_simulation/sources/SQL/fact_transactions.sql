--- fact_transactions
CREATE TABLE `sbfd-project.sbfd_dataset.fact_transactions` (
transaction_ID STRING,
/* transaction_ID : transaction_id IN checking_account_main, 
checking_account_secondary, credit_card_account, 
CONCAT(transaction_id,"_",employee_id) for Payroll*/

date DATE,
/* date : date IN checking_account_main, 
credit_card_account, checking_account_secondary*/

cash STRING,
/* cash : "OUT" if type = "Debit" in checking_account_main, 
"IN" if type = "Credit" in checking_account_main, 
"OUT" in credit_card_account, 
"NEUTRE" if category = "Transfer" in checking_account_secondary, 
"OUT" if category = "Payroll" in checking_account_secondary */

category STRING,
/* category : category IN checking_account_main, 
credit_card_account, checking_account_secondary */

description STRING,
/* description : description IN checking_account_main, 
checking_account_secondary, vendor IN credit_card_account */

amount numeric,
/* amount : amount IN checking_account_main, 
credit_card_account, 
checking_account_secondary(transfert), amount from gusto_payroll */

balance numeric,
/* balance : balance IN checking_account_main, 
credit_card_account, checking_account_secondary */

account STRING
/* account : "checking_account_main", 
"credit_card_account", "checking_account_secondary" */
);

ALTER TABLE `sbfd-project.sbfd_dataset.fact_transactions`
ADD PRIMARY KEY (transaction_ID) NOT ENFORCED;


--- INSERT 
-- `sbfd-project.sbfd_dataset.fact_transactions`
INSERT INTO `sbfd-project.sbfd_dataset.fact_transactions`
SELECT 
transaction_id as transaction_ID,
date as date,
CASE
  WHEN (type = "Debit") THEN "OUT"
  WHEN (type = "Credit") THEN "IN"
END as cash,
category as category,
description as description,
amount as amount,
balance as balance,
"checking_account_main" as account
from `sbfd-project.raw_data.checking_account_main`

-------- `sbfd-project.raw_data.credit_card_account`
/* SET BALANCE TO 0 BECAUSE THE BALANCE IN CREDIT_CARD_ACCOUNT IS NOT RELEVANT FOR THE ANALYSIS 
OF THE TRANSACTIONS 
AND SET "Credit" type Transactions to "REFUND CC" and NOT TO "IN" */

INSERT INTO `sbfd-project.sbfd_dataset.fact_transactions`
SELECT 
transaction_id as transaction_ID,
date as date,
CASE
  WHEN (type = "Debit") THEN "OUT"
  WHEN (type = "Credit") THEN "REFUND CC"
END as cash,
category as category,
vendor as description,
amount as amount,
0 as balance,
"credit_card_account" as account
from `sbfd-project.raw_data.credit_card_account`

-------- `sbfd-project.raw_data.checking_account_secondary/ Transfert`
/* SET BALANCE TO 0 BECAUSE THE BALANCE IN CHECKING_ACCOUNT_SECONDARY
IS DUE TO THE TRANSFERT FROM CHECKING_ACCOUNT_MAIN TO CHECKING_ACCOUNT_SECONDARY*/

INSERT INTO `sbfd-project.sbfd_dataset.fact_transactions`
SELECT 
transaction_id as transaction_ID,
date as date,
"NEUTRE" as cash,
category as category,
description as description,
amount as amount,
0 as balance,
"checking_account_secondary" as account
from `sbfd-project.raw_data.checking_account_secondary`
WHERE category = "Transfer"

-------- `sbfd-project.raw_data.checking_account_secondary/ Payroll`
/* SET BALANCE TO 0 BECAUSE THE BALANCE IN CHECKING_ACCOUNT_SECONDARY
IS DUE TO THE TRANSFERT FROM CHECKING_ACCOUNT_MAIN TO CHECKING_ACCOUNT_SECONDARY
SO THE BALANCE IN CHECKING_ACCOUNT_SECONDARY IS NOT RELEVANT FOR PAYROLL TRANSACTIONS */

INSERT INTO `sbfd-project.sbfd_dataset.fact_transactions`
SELECT 
CONCAT(transaction_id,"_",employee_id) as transaction_ID,
secondary.date as date,
"OUT" as cash,
category as category,
description as description,
payroll.amount as amount,
0 as balance,
"checking_account_secondary" as account
from `sbfd-project.raw_data.checking_account_secondary` as secondary
JOIN `sbfd-project.raw_data.gusto_payroll` as payroll
ON payroll.pay_date=secondary.date
WHERE secondary.category = "Payroll"