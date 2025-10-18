
-------------------------------
/** categories table**/
-------------------------------
select category_id, category_name from categories

--first top 20 values from categories table
select top 20 category_id, category_name from categories

--display max value from category_name
select max(category_name) from categories

--display minimum value from category_name
select min(category_name) from categories

--display catgory_name column with category_id === 1
select category_name from categories where category_id =1

--display category_name from categories table where category_id greater than 1
select category_name from categories where category_id > 1

--display length of category_name
select len(category_name) from categories

--display category_name from categories table where category_id (between 1 and 10)
select category_name from categories where category_id between 1 and 10

--sort categories by category_name column alphabetically
select * from categories order by category_name asc

--sort categories by category_name descending order
select * from categories order by category_name desc

--sort categories by category_id in ascending order
select * from categories order by category_id asc

--sort categories by category_id column descending order
select * from categories order by category_id desc

--display categories table where category_name column it has pattern starts with 'a' 
select * from categories where category_name like 'a%'

--display total count of categories table
select count(*) as total_count from categories 

--display categories table where length() function of category_name column has greater than 10
select * from categories where len(category_name) > 10

--display maximum length of category_name column from categories table
select max(len(category_name)) as max_length from categories

select len(min(category_name)) from categories

select * from categories where len(category_name) > (select len(min(category_name)) from categories)


--display the length of Mobiles
select len('Mobiles') 

--select left() of Mobiles
select left('Mobiles', 3)

--select right() from Mobiles
select right('Mobiles',3)

--select substring 
select substring('Mobiles', 2,6)

--replace function
select replace('Mobiles','l','ccc')

--convert Mobiles to uppercase
select upper('Mobiles')

--convert Mobiles to lowercase
select lower('Mobiles')

--apply left trim on '  Mobiles'
select ltrim('  Mobiles')

--apply right trim on 'Mobiles   a'
select rtrim('Mobiles  a      ')

--remove space 
select trim('   Mobiles_a    ')

--concat 'Mobiles' with 12345
select concat('Mobiles', 12345)

--reverse Mobiles
select reverse('Mobiles')

--find the length() of category_name with add it with 3 and display it as new_column_length from the categories table
select len(category_name) as length from categories
select len(category_name) as length, cast (len(category_name) + 3 as int) as new_column_length from categories 

--use case to label tablet devcies and mobile devices on categories table
select category_name,
	case when category_name like 'Tabl%' then 'Tablet Devices'
		 when category_name like 'Mob%' then 'Mobile Devices'
		 else 'other'
		 end as category_type from categories


