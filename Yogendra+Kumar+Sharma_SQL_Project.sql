/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

## Answer 1.
SELECT
    CUSTOMER_ID,
    CONCAT(
        CASE
            WHEN GENDER = 'M' THEN 'Mr'
            WHEN GENDER = 'F' THEN 'Ms'
            ELSE ''
        END,
        ' ',
        UPPER(FIRST_NAME),
        ' ',
        UPPER(LAST_NAME)
    ) AS CUSTOMER_NAME,
    CUSTOMER_EMAIL,
    YEAR(CUSTOMER_CREATION_DATE) AS CUSTOMER_CREATION_YEAR,
    CASE
        WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'A'
        WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 THEN 'B'
        WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2011 THEN 'C'
    END AS CUSTOMER_CATEGORY
FROM
    ONLINE_CUSTOMER;


/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/
## Answer 2.
SELECT
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    p.PRODUCT_PRICE,
    (p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) AS INVENTORY_VALUE,
    CASE
        WHEN p.PRODUCT_PRICE > 20000 THEN (p.PRODUCT_PRICE * 0.8) -- 20% discount
        WHEN p.PRODUCT_PRICE > 10000 THEN (p.PRODUCT_PRICE * 0.85) -- 15% discount
        ELSE (p.PRODUCT_PRICE * 0.9) -- 10% discount
    END AS NEW_PRICE
FROM
    PRODUCT p
LEFT JOIN
    ORDER_ITEMS oi
ON
    p.PRODUCT_ID = oi.PRODUCT_ID
WHERE
    oi.PRODUCT_ID IS NULL
ORDER BY
    INVENTORY_VALUE DESC;


/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

## Answer 3.
SELECT
    pc.PRODUCT_CLASS_CODE,
    pc.PRODUCT_CLASS_DESC,
    COUNT(p.PRODUCT_ID) AS COUNT_PRODUCT_TYPES,
    SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) AS INVENTORY_VALUE
FROM
    PRODUCT_CLASS pc
JOIN
    PRODUCT p
ON
    pc.PRODUCT_CLASS_CODE = p.PRODUCT_CLASS_CODE
GROUP BY
    pc.PRODUCT_CLASS_CODE, pc.PRODUCT_CLASS_DESC
HAVING
    SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) > 100000
ORDER BY
    INVENTORY_VALUE DESC;


/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
 
## Answer 4.
SELECT
    oc.CUSTOMER_ID,
    CONCAT(oc.FIRST_NAME, ' ', oc.LAST_NAME) AS FULL_NAME,
    oc.CUSTOMER_EMAIL,
    a.CUSTOMER_PHONE,
    a.COUNTRY
FROM
    ONLINE_CUSTOMER oc
INNER JOIN
    ADDRESS a
ON
    oc.CUSTOMER_ID = a.CUSTOMER_ID
WHERE
    oc.CUSTOMER_ID NOT IN (
        SELECT DISTINCT oh.CUSTOMER_ID
        FROM OREDER_HEADER oh
        WHERE oh.ORDER_STATUS = 'Cancelled'
    )
AND
    oc.CUSTOMER_ID IN (
        SELECT DISTINCT oh.CUSTOMER_ID
        FROM OREDER_HEADER oh
    )
LIMIT 1;


/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

## Answer 5.  
SELECT
    s.SHIPPER_NAME,
    a.CITY AS CATERING_CITY,
    COUNT(DISTINCT oc.CUSTOMER_ID) AS NUM_CUSTOMERS,
    COUNT(oh.ORDER_ID) AS NUM_CONSIGNMENTS_DELIVERED
FROM
    SHIPPER s
JOIN
    ORDER_HEADER oh
ON
    s.SHIPPER_ID = oh.SHIPPER_ID
JOIN
    ONLINE_CUSTOMER oc
ON
    oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN
    ADDRESS a
ON
    oc.CUSTOMER_ID = a.CUSTOMER_ID
WHERE
    s.SHIPPER_NAME = 'DHL'
GROUP BY
    s.SHIPPER_NAME, a.CITY
HAVING
    COUNT(DISTINCT oc.CUSTOMER_ID) > 0
ORDER BY
    CATERING_CITY;


/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

## Answer 6.
SELECT
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    SUM(oi.PRODUCT_QUANTITY) AS QUANTITY_SOLD,
    CASE
        WHEN pc.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') THEN
            CASE
                WHEN SUM(oi.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.1 * SUM(oi.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.5 * SUM(oi.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        WHEN pc.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches') THEN
            CASE
                WHEN SUM(oi.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.2 * SUM(oi.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.6 * SUM(oi.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        ELSE
            CASE
                WHEN SUM(oi.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.3 * SUM(oi.PRODUCT_QUANTITY) THEN 'Low inventory, need to add inventory'
                WHEN p.PRODUCT_QUANTITY_AVAIL < 0.7 * SUM(oi.PRODUCT_QUANTITY) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
    END AS INVENTORY_STATUS
FROM
    PRODUCT p
JOIN
    PRODUCT_CLASS pc
ON
    p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
LEFT JOIN
    ORDER_ITEMS oi
ON
    p.PRODUCT_ID = oi.PRODUCT_ID
GROUP BY
    p.PRODUCT_ID, p.PRODUCT_DESC, p.PRODUCT_QUANTITY_AVAIL, pc.PRODUCT_CLASS_DESC
ORDER BY
    p.PRODUCT_ID;


/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

## Answer 7.
SELECT
    oi.ORDER_ID,
    SUM(p.PRODUCT_VOLUME * oi.PRODUCT_QUANTITY) AS ORDER_VOLUME
FROM
    ORDER_ITEMS oi
JOIN
    PRODUCT p
ON
    oi.PRODUCT_ID = p.PRODUCT_ID
WHERE
    oi.ORDER_ID IN (
        SELECT
            oi2.ORDER_ID
        FROM
            ORDER_ITEMS oi2
        WHERE
            oi2.CARTON_ID = 10
        GROUP BY
            oi2.ORDER_ID
        HAVING
            SUM(p.PRODUCT_VOLUME * oi2.PRODUCT_QUANTITY) <= (
                SELECT
                    CARTON_VOLUME
                FROM
                    CARTON
                WHERE
                    CARTON_ID = 10
            )
    )
GROUP BY
    oi.ORDER_ID
ORDER BY
    ORDER_VOLUME DESC
LIMIT 1;

/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

## Answer 8.
SELECT
    oc.CUSTOMER_ID,
    CONCAT(oc.FIRST_NAME, ' ', oc.LAST_NAME) AS CUSTOMER_FULL_NAME,
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY,
    SUM(oi.PRODUCT_QUANTITY * p.PRODUCT_PRICE) AS TOTAL_VALUE
FROM
    ONLINE_CUSTOMER oc
JOIN
    ORDER_HEADER oh
ON
    oc.CUSTOMER_ID = oh.CUSTOMER_ID
JOIN
    ORDER_ITEMS oi
ON
    oh.ORDER_ID = oi.ORDER_ID
JOIN
    PRODUCT p
ON
    oi.PRODUCT_ID = p.PRODUCT_ID
WHERE
    oh.PAYMENT_MODE = 'Cash'
    AND oc.LAST_NAME LIKE 'G%'
GROUP BY
    oc.CUSTOMER_ID, oc.FIRST_NAME, oc.LAST_NAME
HAVING
    SUM(oi.PRODUCT_QUANTITY) > 0
ORDER BY
    oc.CUSTOMER_ID;


/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

## Answer 9.
SELECT
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM
    PRODUCT p
JOIN
    (
        SELECT DISTINCT oh.ORDER_ID
        FROM
            ORDER_ITEMS oi1
        JOIN
            ORDER_HEADER oh
        ON
            oi1.ORDER_ID = oh.ORDER_ID
        WHERE
            oi1.PRODUCT_ID = 201
            AND oh.SHIPPING_CITY NOT IN ('Bangalore', 'New Delhi')
    ) subq
ON
    p.PRODUCT_ID = subq.ORDER_ID
JOIN
    ORDER_ITEMS oi
ON
    subq.ORDER_ID = oi.ORDER_ID
GROUP BY
    p.PRODUCT_ID, p.PRODUCT_DESC
ORDER BY
    TOTAL_QUANTITY DESC;


/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */

## Answer 10.
SELECT
    oh.ORDER_ID,
    oh.CUSTOMER_ID,
    CONCAT(oc.FIRST_NAME, ' ', oc.LAST_NAME) AS CUSTOMER_FULLNAME,
    SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM
    ORDER_HEADER oh
JOIN
    ONLINE_CUSTOMER oc
ON
    oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN
    ADDRESS a
ON
    oh.CUSTOMER_ID = a.CUSTOMER_ID
JOIN
    ORDER_ITEMS oi
ON
    oh.ORDER_ID = oi.ORDER_ID
WHERE
    oh.ORDER_ID % 2 = 0
    AND LEFT(a.PINCODE, 1) <> '5'
GROUP BY
    oh.ORDER_ID, oh.CUSTOMER_ID, oc.FIRST_NAME, oc.LAST_NAME
ORDER BY
    oh.ORDER_ID;
