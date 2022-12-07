SELECT
    *
FROM
    locations;

SELECT
    *
FROM
    departments;

SELECT
    *
FROM
    jobs;

SELECT
    *
FROM
    employees;

SELECT
    *
FROM
    job_history;

SELECT
    *
FROM
    regions;

SELECT
    *
FROM
    countries;

SELECT
    *
FROM
    non_functional_locations;

/********************************************** Sub-Query **********************************************/

--Listing out only the departments where we have employees
--To do this we can use a sub-query. Sub-query is also called as inner query or nested query. It is basically a sql query inside another query

SELECT
    *
FROM
    departments
WHERE
    department_id IN (
        SELECT
            department_id
        FROM
            employees
    );

--The above query shows that we have 11 departments where we have employees. Execution of this query is as follows:
--In the backend the query inside the bracket will be executed and the result of the same will be kept in the result table.
--Next this result will be matched with the department_ids from the department table using the IN clause. Hence, the result.
--Same query using the join functionality and distinct clause is shown below:

SELECT DISTINCT
    departments.department_id,
    departments.department_name
FROM
         employees
    JOIN departments ON employees.department_id = departments.department_id;

--If we're not interested in the details from employee table, then we should go for sub-query option, or else we need to go ahead with join
--option.

--Similarly we can apply sub-query on the below sql query
-- Find employee details who belongs to marketing department and has salary less then or equal to 6000.
SELECT
    *
FROM
    departments
WHERE
    department_name = 'Marketing';

SELECT
    *
FROM
    employees
WHERE
        department_id = 20
    AND salary <= 6000;

--Sub-query for the above one
SELECT
    *
FROM
    employees
WHERE
        department_id = (
            SELECT
                department_id
            FROM
                departments
            WHERE
                department_name = 'Marketing'
        )
    AND salary <= 6000;

--Now, we use '=' operator in the above query because the obtained result from the query inside the brackets is single row. If we use the '=' operator in the first query of this
--sheet then we will get an error saying that 'single-row subquery returns more than one row'. We can use IN operator in the above query, but it is bit costlier so we use '='.

/********************************************** In-line view **********************************************/

SELECT
    employees.employee_id,
    employees.first_name,
    dept_city.department_name,
    dept_city.city
FROM
    employees
    LEFT JOIN (
        SELECT
            departments.department_id,
            departments.department_name,
            locations.city
        FROM
                 departments
            JOIN locations ON departments.location_id = locations.location_id
                              AND city IN ( 'Roma', 'Venice', 'Southlake' )
    ) dept_city ON employees.department_id = dept_city.department_id;

--The above query will give us null values for department_name and city column if any of these is null. This is what was required in from the query
--The query return inside the bracket in the from clause is called as inline query
--The same thing was not possible if we just use joins.

/********************************************** Aggregate Functions **********************************************/

--Few of the aggregate functions used on daily basis are max, min, avg, count, sum

--Finding the employee with the maximum salary
SELECT
    MAX(salary) AS max_salary
FROM
    employees;

--Max salary with employee details using sub-query and aggregation 
SELECT
    *
FROM
    employees
WHERE
    salary = (
        SELECT
            MAX(salary) AS max_salary
        FROM
            employees
    );

--Min salary with employee details using sub-query and aggregation 
SELECT
    *
FROM
    employees
WHERE
    salary = (
        SELECT
            MIN(salary) AS min_salary
        FROM
            employees
    );

--Total salary firm is providing to the employees
SELECT
    SUM(salary) AS total_salary
FROM
    employees;

--Total number of employees working in the firm
SELECT
    COUNT(*)
FROM
    employees;

--Average salary of the employees
SELECT
    round(AVG(salary), 2) AS average_salary
FROM
    employees;

--Displaying all employees getting more salary than average
SELECT
    *
FROM
    employees
WHERE
    salary > (
        SELECT
            round(AVG(salary), 2) AS average_salary
        FROM
            employees
    )
ORDER BY
    salary DESC;

--Find max salary of IT department for the employees hired after 29 November 1990
SELECT
    MAX(salary) AS "MAX_SALARY_IN_IT",
    COUNT(*)    AS "NUMBER_OF_EMPLOYEES_IN_IT"
FROM
    employees
WHERE
        department_id = (
            SELECT
                department_id
            FROM
                departments
            WHERE
                department_name = 'IT'
        )
    AND hire_date > TO_DATE('29-NOV-1990', 'dd-MM-yyyy');

--Find min salary of FINANCE department for the employees hired after 29 November 1990
SELECT
    MIN(salary) AS "MIN_SALARY_IN_FINANCE",
    COUNT(*)    AS "NUMBER_OF_EMPLOYEES_IN_FINANCE"
FROM
    employees
WHERE
        department_id = (
            SELECT
                department_id
            FROM
                departments
            WHERE
                department_name = 'Finance'
        )
    AND hire_date > TO_DATE('29-NOV-1990', 'dd-MM-yyyy');

--Finding the average salary of HR department
SELECT
    round(AVG(salary), 2) AS "AVG_SALARY_IN_HR",
    COUNT(*)              AS "NUMBER_OF_EMPLOYEES_IN_HR"
FROM
    employees
WHERE
    department_id = (
        SELECT
            department_id
        FROM
            departments
        WHERE
            department_name = 'Human Resources'
    );
                        

/********************************************** Combine Different Aggregated Results in 1 row **********************************************/

--To combine the results of different aggregate queries we can use UNION ALL operator with the aliases for each query as shown below:
--This will not combine the results in a single row
SELECT
    'max_salary',
    MAX(salary) AS "MAX_SALARY_IN_IT",
    COUNT(*)    AS "NUMBER_OF_EMPLOYEES_IN_IT"
FROM
    employees
WHERE
        department_id = (
            SELECT
                department_id
            FROM
                departments
            WHERE
                department_name = 'IT'
        )
    AND hire_date > TO_DATE('29-NOV-1990', 'dd-MM-yyyy')
UNION ALL
SELECT
    'min_salary',
    MIN(salary) AS "MIN_SALARY_IN_FINANCE",
    COUNT(*)    AS "NUMBER_OF_EMPLOYEES_IN_FINANCE"
FROM
    employees
WHERE
        department_id = (
            SELECT
                department_id
            FROM
                departments
            WHERE
                department_name = 'Finance'
        )
    AND hire_date > TO_DATE('29-NOV-1990', 'dd-MM-yyyy');

--Combining the aggregation results in a single row using max, union all, and inline query
SELECT
    MAX(max_salary_in_it),
    MAX(number_of_employees_in_it),
    MAX(min_salary_in_finance),
    MAX(number_of_employees_in_finance)
FROM
    (
        SELECT
            MAX(salary) AS "MAX_SALARY_IN_IT",
            COUNT(*)    AS "NUMBER_OF_EMPLOYEES_IN_IT",
            NULL        AS min_salary_in_finance,
            NULL        AS number_of_employees_in_finance
        FROM
            employees
        WHERE
                department_id = (
                    SELECT
                        department_id
                    FROM
                        departments
                    WHERE
                        department_name = 'IT'
                )
            AND hire_date > TO_DATE('29-NOV-1990', 'dd-MM-yyyy')
        UNION ALL
        SELECT
            NULL        AS max_salary_in_it,
            NULL        AS number_of_employees_in_it,
            MIN(salary) AS "MIN_SALARY_IN_FINANCE",
            COUNT(*)    AS "NUMBER_OF_EMPLOYEES_IN_FINANCE"
        FROM
            employees
        WHERE
                department_id = (
                    SELECT
                        department_id
                    FROM
                        departments
                    WHERE
                        department_name = 'Finance'
                )
            AND hire_date > TO_DATE('29-NOV-1990', 'dd-MM-yyyy')
    ) t;

--Example 2 of combining the aggregated results in one row
SELECT
    MAX(total_number_of_employees) AS total_number_of_employees,
    MAX(sum_of_salaries)           AS sum_of_salaries,
    MAX(max_salary_of_it)          AS max_salary_of_it,
    MAX(number_of_emp_in_it)       AS number_of_emp_in_it,
    MAX(min_salary_of_finance)     AS min_salary_of_finance,
    MAX(number_of_emp_in_finance)  AS number_of_emp_in_finance,
    MAX(avg_salary_of_hr)          AS avg_salary_of_hr,
    MAX(number_of_emp_in_hr)       AS number_of_emp_in_hr
FROM
    (
        SELECT
            SUM(salary) AS "SUM_OF_SALARIES",
            NULL        AS total_number_of_employees,
            NULL        AS max_salary_of_it,
            NULL        AS number_of_emp_in_it,
            NULL        AS min_salary_of_finance,
            NULL        AS number_of_emp_in_finance,
            NULL        AS avg_salary_of_hr,
            NULL        AS number_of_emp_in_hr
        FROM
            employees
        UNION ALL
        SELECT
            NULL,
            COUNT(*) "TOTAL_NUMBER_OF_EMPLOYEES",
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL
        FROM
            employees
        UNION ALL
        SELECT
            NULL,
            NULL,
            MAX(salary) AS "MAX_SALARY_OF_IT",
            COUNT(*)    AS "NUMBER_OF_EMP_IN_IT",
            NULL,
            NULL,
            NULL,
            NULL
        FROM
            employees
        WHERE
                department_id = (
                    SELECT
                        department_id
                    FROM
                        departments
                    WHERE
                        department_name = 'IT'
                )
            AND hire_date > TO_DATE('29-NOV-1990', 'dd-MM-yyyy')
        UNION ALL
        SELECT
            NULL,
            NULL,
            NULL,
            NULL,
            MIN(salary) AS "MIN_SALARY_OF_FINANCE",
            COUNT(*)    AS "NUMBER_OF_EMP_IN_FINANCE",
            NULL,
            NULL
        FROM
            employees
        WHERE
                department_id = (
                    SELECT
                        department_id
                    FROM
                        departments
                    WHERE
                        department_name = 'Finance'
                )
            AND hire_date > TO_DATE('29-NOV-1990', 'dd-MM-yyyy')
        UNION ALL
        SELECT
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            round(AVG(salary), 2) AS "AVG_SALARY_OF_HR",
            COUNT(*)              AS "NUMBER_OF_EMP_IN_HR"
        FROM
            employees
        WHERE
                department_id = (
                    SELECT
                        department_id
                    FROM
                        departments
                    WHERE
                        department_name = 'Human Resources'
                )
            AND hire_date > TO_DATE('29-NOV-1990', 'dd-MM-yyyy')
    ) t;
  

/********************************************** Data Analysis using Group by clause **********************************************/

--Fetching the maximum salary of each department
--We know that if we write an aggregate function in the select query we cannot fetch any other column, but we can fetch the one that is in group by clause
SELECT
    departments.department_name,
    MAX(salary) AS max_salary
FROM
         employees
    JOIN departments ON employees.department_id = departments.department_id
WHERE
    employees.department_id IS NOT NULL
GROUP BY
    departments.department_name;

--Department wise number of employees
SELECT
    departments.department_name,
    COUNT(*) AS num_of_employees
FROM
         employees
    JOIN departments ON employees.department_id = departments.department_id
WHERE
    employees.department_id IS NOT NULL
GROUP BY
    departments.department_name;

--Department wise max, min, and avg salary and number of employees
SELECT
    departments.department_name,
    COUNT(*)              AS num_of_employees,
    MAX(salary)           AS max_salary,
    MIN(salary)           AS min_salary,
    round(AVG(salary), 2) AS avg_salary
FROM
         employees
    JOIN departments ON employees.department_id = departments.department_id
WHERE
    employees.department_id IS NOT NULL
GROUP BY
    departments.department_name;

--Getting number of departments based on location
SELECT
    locations.city AS location,
    COUNT(*)       AS num_of_departnents
FROM
         departments
    JOIN locations ON departments.location_id = locations.location_id
GROUP BY
    locations.city;

--Getting number of employees working under particular manager
SELECT
    m.first_name
    || ' '
    || m.last_name AS manager_name,
    COUNT(*)       AS num_of_employees
FROM
         employees e
    JOIN employees m ON e.manager_id = m.employee_id
GROUP BY
    m.first_name
    || ' '
    || m.last_name;
/********************************************** Filter & Organized Aggregate Data **********************************************/

--Finding the number of employees of each departments who have resigned
--We can order our data using order by clause
--To filter the data we can use the query as inline view, or having clause

--Inline view (not efficient)
SELECT
    *
FROM
    (
        SELECT
            job_history.department_id,
            departments.department_name,
            COUNT(*) AS num_0f_employees_resigned
        FROM
                 job_history
            JOIN departments ON job_history.department_id = departments.department_id
        GROUP BY
            job_history.department_id,
            departments.department_name
        ORDER BY
            num_0f_employees_resigned DESC
    ) t
WHERE
    num_0f_employees_resigned > 1;

--Having clause (can only be used with aggregate functions)
SELECT
    job_history.department_id,
    departments.department_name,
    COUNT(*) AS num_0f_employees_resigned
FROM
         job_history
    JOIN departments ON job_history.department_id = departments.department_id
GROUP BY
    job_history.department_id,
    departments.department_name
HAVING
    COUNT(*) > 1
ORDER BY
    num_0f_employees_resigned DESC;

--Getting max salary for each department greater than 15000
SELECT
    departments.department_name,
    MAX(salary) AS max_salary
FROM
         employees
    JOIN departments ON employees.department_id = departments.department_id
WHERE
    employees.department_id IS NOT NULL
GROUP BY
    departments.department_name
HAVING
    MAX(salary) > 10000
ORDER BY
    max_salary DESC;

/********************************************** Department level details using aggregate functions and inline views **********************************************/

SELECT
    departments.department_id,
    departments.department_name,
    employees.first_name
    || ' '
    || employees.last_name AS manager_name,
    locations.city,
    max_salary,
    min_salary,
    avg_salary,
    num_of_employees,
    total_salary,
    num_of_employees_resigned
FROM
    departments
    LEFT JOIN employees ON departments.manager_id = employees.employee_id
    LEFT JOIN locations ON locations.location_id = departments.location_id
    LEFT JOIN (
        SELECT
            department_id,
            MAX(salary)           AS max_salary,
            MIN(salary)           AS min_salary,
            round(AVG(salary), 2) AS avg_salary,
            COUNT(*)              AS num_of_employees,
            SUM(salary)           AS total_salary
        FROM
            employees
        GROUP BY
            department_id
    ) department_salary_detail ON departments.department_id = department_salary_detail.department_id
    LEFT JOIN (
        SELECT
            department_id,
            COUNT(*) AS num_of_employees_resigned
        FROM
            job_history
        GROUP BY
            department_id
    ) emp_resigned_details ON departments.department_id = emp_resigned_details.department_id
ORDER BY
    departments.department_id;

/********************************************** Data Analysis using sub-query and Exists clause **********************************************/

--Exists clause is based on true or false. If true (1) then it will show the data, or else it will not show the data
--Instead of giving 1 we can also select particular columns from the table
--When the results of the sub-query is very large at that time EXISTS clause is much faster than the IN clause.
--Because IN-clause internally compares the query values and replace it will result set, whereas EXISTS clause matches simultaneously while running the query
--IN clause cannot compare anything with null vaues, but exists clause compares it with null

--This query will give us all the department information if there are employees presnet in that department
SELECT
    *
FROM
    departments
WHERE
    EXISTS (
        SELECT
            1
        FROM
            employees
        WHERE
            employees.department_id = departments.department_id
    );

--This below query shows 1 line in the result
SELECT
    *
FROM
    employees
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            departments
        WHERE
            departments.department_id = employees.department_id
    );
    
--if we use NOT IN clause for the same query, the it will not show any result.
SELECT
    *
FROM
    employees
WHERE
    employees.department_id NOT IN (
        SELECT
            departments.department_id
        FROM
            departments
    );
