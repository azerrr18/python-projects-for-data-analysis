select *
from branches;

select min(rating) from orders;

--1. Filial üzrə ümumi satış və orta sifariş dəyəri
select b.branch_name,avg(od.total_price) as ortalama_deyer,count(od.quantity) as toplam_satis
from branches b
join orders o on b.branch_id = o.branch_id
join order_details od on o.order_id = od.order_id
group by b.branch_name;

--2. Menyu kateqoriyası üzrə satış və popularlıq
select m.category,sum(od.total_price) as toplam_gelir,count(od.quantity) as toplam_satis
from menu_items m
join order_details od on m.item_id = od.item_id
group by m.category
order by toplam_gelir desc;

--3. Saat üzrə sifariş trafik analizi (peak hours)
select count(order_id) as toplam_sifaris,order_hour
from orders
group by order_hour
order by toplam_sifaris desc;

--4. Müştəri loyalty tier üzrə orta xərcləmə
select c.loyalty_tier,sum(od.total_price) as toplam_gelir
from customers c
join orders o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
group by c.loyalty_tier
order by toplam_gelir desc;

--5 Top 10 ən çox satılan yemək
select m.item_name,sum(od.quantity) as toplam_satis
from menu_items m 
join order_details od on m.item_id = od.item_id
group by m.item_name
order by toplam_satis desc
fetch first 10 rows only;


--6 Filial üzrə satışların sayı
select *
from (
  select m.category, b.branch_name
  from menu_items m
  join order_details od on m.item_id = od.item_id
  join orders o on od.order_id = o.order_id
  join branches b on o.branch_id = b.branch_id
)
pivot (
  count(*) for branch_name in (
    'Lezzetli Fountain Square' as TORQOVU,
    'Lezzetli Ganclik'         as GENCLIK,
    'Lezzetli 28 Mall'         as "28_MAL",
    'Lezzetli Port Baku'       as "PORT_BAKU",
    'Lezzetli Deniz Mall'      as "DENIZ_MALL",
    'Lezzetli Ganja Mall'      as "GANJA_MALL",
    'Lezzetli Sumqayit'        as SUMQAYIT,
    'Lezzetli Lankaran'        as LANKARAN
  )
);


--6.1 filial üzrə satışların həcmi
select *
from (
  select m.category, b.branch_name,od.total_price
  from menu_items m
  join order_details od on m.item_id = od.item_id
  join orders o on od.order_id = o.order_id
  join branches b on o.branch_id = b.branch_id
)
pivot (
  sum(total_price) for branch_name in (
    'Lezzetli Fountain Square' as TORQOVU,
    'Lezzetli Ganclik'         as GENCLIK,
    'Lezzetli 28 Mall'         as "28_MAL",
    'Lezzetli Port Baku'       as "PORT_BAKU",
    'Lezzetli Deniz Mall'      as "DENIZ_MALL",
    'Lezzetli Ganja Mall'      as "GANJA_MALL",
    'Lezzetli Sumqayit'        as SUMQAYIT,
    'Lezzetli Lankaran'        as LANKARAN
  )
);


--7  Order type müqayisəsi
select o.order_type,count(o.order_id) as total_orders, 
sum(d.total_price) as amount
from orders o
join ORDER_DETAILS d on o.ORDER_ID = d.ORDER_ID
group by o.ORDER_TYPE
order by total_orders desc;

--8  Müştəri rating analizi 
select o.rating as average_rating, b.branch_name,
case 
    when o.rating between 1 and 2.5 then 'Bad Performance'
    when o.rating between 2.5 and 4 then 'Average Performance'
    when o.rating > 4 then 'High Performance'
    end as rating_compare
from orders o
join branches b on o.branch_id = b.BRANCH_ID;

--9  Hər filialda ən çox satılan yemək 
select m.item_name,b.branch_name,count(d.order_id) as total_orders,
dense_rank() over (PARTITION by m.item_name order by count(d.order_id)) as rank_val
from menu_items m
join order_details d on m.item_id = d.item_id
join orders o on d.order_id = o.order_id
join branches b on o.branch_id = b.branch_id
group by b.branch_name,m.item_name;

--10  Aylıq gəlir trendi 
select to_char(o.order_date,'MM') as month_date
,sum (d.total_price)
from orders o
join ORDER_DETAILS d on o.order_id = d.order_id
group by to_char(o.order_date,'MM');

--10.1  
select to_char(o.order_date,'MM') as month_date,
sum (d.total_price) over (PARTITION by to_char(o.ORDER_DATE,'MM') order by to_char(o.order_date,'MM') ) as sum_total
from orders o
join ORDER_DETAILS d on o.order_id = d.order_id
order by month_date;

--11  Menyu profit margin analizi
select round(cost-price/price*100,0) as margin,
case 
    when round(cost-price/price*100,0) < 20 then 'Bad Margin'
    when round(cost-price/price*100,0) BETWEEN 20 and 50 then 'Average Margin'
    else 'Good Margin'
    end as margin_rating
from menu_items;  

--12  Həftəsonu vs həftəiçi satış müqayisəsi
select sum(d.total_price)as total,
case 
    when to_char(o.order_date,'DD') < 6 then 'Hefte Ici'
    else 'Hefte sonu'
    end as day_category
from ORDER_DETAILS d
join orders o on d.order_id = o.ORDER_ID
group by
case 
    when to_char(o.order_date,'DD') < 6 then 'Hefte Ici'
    else 'Hefte sonu' 
    end
