-- WINDOW FUNCTIONS --
SELECT *
FROM employee;

-- 1.
select e.*, max(salary) over() as max_salary
from employee e; -- will retreive max salary along with all the other fields

-- select max salary from each department and show it in a different field

select concat(first_name,' ',last_name) as name, sex, salary, 
branch_name, max(salary) over(partition by branch_name) as max_salary
from employee e
join branch b on b.branch_id=e.branch_id;

-- row_number

select *, row_number() over() as ranks
from employee;

-- now ranking for different departments

select *, row_number() over(partition by branch_id) as ranks
from employee;

-- application -->
-- fetch the details of last two employees from each department ; Assumption -> lower emp_id means the employee is not new in the department

select * from (select *, row_number() over(partition by branch_id order by emp_id desc) as emp_seq
from employee) new_emp
where emp_seq in (1,2) ;


insert into employee values(110,'Allu','Arjun',date('1999-03-09'),'M',69000,104,2);

-- fetch the top 3 employees from each department earning the max salary
-- using rank() window function
select * from (select *, rank() over(partition by branch_id order by salary desc) as emp_sal_order
 from employee) emp_sal_data
 where emp_sal_order < 4;
 
 -- now, for the same query we will use dense_rank
 select *, dense_rank() over(partition by branch_id order by salary desc) as emp_sal_order
 from employee;
 
 -- the key difference between rank() and dense_rank() is that when there are two or more same ranks, the rank() would skip the value for every duplicate value it finds and will report to the last rank, eg-> 1,2,2,4 but in dense_rank() it would be -> 1,2,2,3
 
 -- lead() and lag() window functions
 -- write a query to display if the current employee's salary is greater, equal or lower than the previous employee
 
 select emp_id, salary, prev_sal, case 
 when prev_sal>salary then 'lower'
 when prev_sal<salary then 'higher'
 when prev_sal is NULL then 'No prev record'
 else 'equal'
 end as sal_distribution
 from (select e.*, lag(salary) over() as prev_sal
 from employee e) emp_sal;
 ;
 
 -- lag(arg1,arg2,arg3) arg1-> the column name you wanna check , arg_2-> which previous value you wanna check,arg3->default value
 
 select *, lag(salary,2,0) over() as prev_sal
 from employee ;
 
 -- similarly lead()
  select *, lead(salary,1,0) over() as prev_sal
 from employee 