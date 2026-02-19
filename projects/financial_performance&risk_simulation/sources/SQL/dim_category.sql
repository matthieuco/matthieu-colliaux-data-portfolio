----- dimension category 
-- category : Sales Revenue, COGS, Operating Expense, Transfer, Payroll, Payment, Other, Marketing, Supplies, Utilities
-- category_flux : revenus_recurrents, charges_variables, charges_fixes, flux_neutre 
-- type_flux : revenus, charges, neutre

CREATE TABLE `sbfd-project.sbfd_dataset.dim_category` ( 
category STRING,
category_flux STRING,
type_flux STRING
);

ALTER TABLE `sbfd-project.sbfd_dataset.dim_category` ADD PRIMARY KEY(category) 
NOT ENFORCED;


INSERT INTO `sbfd-project.sbfd_dataset.dim_category`
SELECT DISTINCT category as category, 
CASE
		WHEN (category = "Sales Revenue") THEN "revenus_recurrents"
		WHEN (category = "COGS") THEN "charges_variables"
    WHEN (category = "Operating Expense") THEN "charges_fixes"
END as category_flux,
CASE
		WHEN (category = "Sales Revenue") THEN "revenus"
		WHEN (category = "COGS" OR category = "Operating Expense") THEN "charges"
END as type_flux
FROM `sbfd-project.raw_data.checking_account_main` UNION ALL
SELECT DISTINCT category as category, 
CASE
		WHEN (category = "Transfer") THEN "flux_neutre"
		WHEN (category = "Payroll") THEN "charges_fixes"
END as category_flux,
CASE
		WHEN (category = "Transfer") THEN "neutre"
		WHEN (category = "Payroll") THEN "charges"
END as type_flux
FROM `sbfd-project.raw_data.checking_account_secondary`
UNION ALL
SELECT DISTINCT category as category,
CASE
		WHEN (category = "Payment" OR category = "Other" OR category = "Marketing" OR category = "Supplies") THEN "charges_variables"
    WHEN (category = "Utilities") THEN "charges_fixes"
END as category_flux,
"charges" as type_flux
FROM `sbfd-project.raw_data.credit_card_account`