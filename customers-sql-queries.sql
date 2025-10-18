
-------------------------
/** customers table**/
-------------------------
--list all customers table
select * from customers

--display max customer_id
select max(customer_id) from customers

--display minimum of customer_id
select min(customer_id) from customers

--concat first-name and last_name from customers table
select concat(first_name,last_name) as full_name from customers

--concat first_name and last_name without using concat() function
select first_name + '' + last_name as full_name from customers

--substring of address
select substring('"6182 Gregory Stream',2,6)

--substring on column
select substring(address,2,8) from customers

--select substring() function from first index===2 to last_index===using length() function of the '6182 Gregory Stream'
select substring('6182 Gregory Stream',2,len('6182 Gregory Stream')) as sub_part

--select substring() function on the address coulmn with first_index as 2 and last_index is the length() function of the address coulmn  in the customers table
select substring(address,2,len(address)) as sub_part from customers

--replace the address column with implement substring() of the first_index as 2 and last_index as 6  and finally apply as '@gmail.com' to it

select replace(address, substring(address,2,6), '@gmail.com') from customers

