----- dimension category employee

CREATE TABLE `sbfd-project.sbfd_dataset.dim_employee` ( 
employee_id STRING,
employee_name STRING,
role STRING,
type STRING
);

INSERT INTO `sbfd-project.sbfd_dataset.dim_employee` 
SELECT DISTINCT 
employee_id as employee_id, 
employee_name as employee_name, 
role as role, 
type as type 
FROM `sbfd-project.raw_data.gusto_payroll`;