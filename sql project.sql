-- ===========================================================================================
	-- PROJECT NAME => AGGRICULTURE STORE INVENTORY MANAGEMENT SYSTEM FOR ONLINE STORE;
	-- Student Name : ANUSHKA VINAYAK CHAVAN
		

	


-- ==============================================================================================
create database project;
use project;

# ====================================== user table ===================================================
-- user table
CREATE TABLE users (
    userid CHAR(15) PRIMARY KEY,
    first_name VARCHAR(20) not null,
    last_name VARCHAR(20) not null,
    mobile_no bigint  unique check(mobile_no>1111111111 and moobile_no<9999999999),
    address VARCHAR(30) not null,
    city varchar(30) not null,
    pincode int not null
);



# ======================================caateggory table ===================================================

-- category table
CREATE TABLE category (
    categoryID CHAR(15) PRIMARY KEY,
    category_name VARCHAR(30)
);
# ====================================== product table ===================================================
-- porducts
CREATE TABLE products (
    productId CHAR(15) PRIMARY KEY,
    categoryID CHAR(15),
    product_name VARCHAR(25) NOT NULL,
    price FLOAT NOT NULL,
    compony_name VARCHAR(20),
    CONSTRAINT categoryid_product_fk FOREIGN KEY products(categoryID)
        REFERENCES category (categoryID)
        ON UPDATE CASCADE ON DELETE CASCADE
       
);

# ====================================== cart table ===================================================
-- cart table
CREATE TABLE cart (
    userid CHAR(15),
    productId CHAR(15) unique,
    qty INT NOT NULL,
    CONSTRAINT uid_Cart_fk FOREIGN KEY (userid)
        REFERENCES users (userid)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT pid_Cart_fk FOREIGN KEY (productId)
        REFERENCES products (productId)
        ON UPDATE CASCADE ON DELETE CASCADE
);

# ====================================== orders table ===================================================
-- orders details  table 
CREATE TABLE orders (
	
    orderid CHAR(35),
	userid CHAR(15),
    productId CHAR(15),
    qty INT,
    order_date DATE,
	status char(15),
    constraint composite_pk_orders primary key (orderid, productid),
    CONSTRAINT pid_oredersdetails_fk FOREIGN KEY orders(productId)
        REFERENCES products (productId)
        ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT uid_oredersdetails_fk FOREIGN KEY orders(userid)
        REFERENCES users (userid)
        ON UPDATE CASCADE ON DELETE CASCADE
	
); 

# ====================================== stock table ===================================================

CREATE TABLE stock (
    productId CHAR(15),
    qty INT,
    CONSTRAINT pid_stock_fk FOREIGN KEY (productId)
        REFERENCES products (productId)
        ON UPDATE CASCADE ON DELETE CASCADE
);
show tables from project;


# ====================================== user panal procedures ===================================================
-- ==========================add to cart
-- #### add in cart
delimiter //
create procedure addToCart(prodid char(15), userid char(15), qty1 int)
begin
	declare instock int;
    declare id char(15);
    declare check1 tinyint(1);
				
			
		set check1 =	(SELECT IF( EXISTS(
             select productid from cart where productid = prodid), 1, 0));
            
            
            select qty into instock from stock where productId = prodid; 
		

            
            if (instock>0)
            then
				if(check1=1)
				then
					update cart set qty=qty+qty1 where productId = prodid;
                    update stock set qty=qty-qty1 where productId = prodid;
				else
					insert into cart values(userid,prodid,qty1);
                  
				end if;
			end if;
end; //
delimiter ;



-- ==========================delete from cart

-- ### delete from cart 
delimiter //
create procedure deleteFromCart(prodid char(15))
begin 
	
	delete from cart where  productId = prodid ;
   
end; //
delimiter ;



-- ##checkout
delimiter //
create procedure checkout()
begin
	declare prefix char(4)  default 'oid';
	declare orderID char(35);
    declare orderdatetemp datetime;
    declare orderdate date;
    declare finished int;
    declare userid char(15);
    declare productid char(15);
    declare qty int;
	declare  c1  cursor  for select  * from cart;
    declare continue handler for not found set finished = 1;
    set orderdatetemp = sysdate();
    set orderdate = sysdate();
    set orderID = concat(prefix,orderdatetemp);
	open c1;
    
    loop_1 : loop
     fetch c1 into userid, productid, qty;
     if finished = 1
     then leave loop_1;
     end if;
     insert into orders values(orderid,userid,productid,qty,orderdate,'order_placed');
     end loop loop_1;
	close c1;
	truncate cart;

end; //
delimiter ;

-- ========== Admin panal procedures============================
-- ======stock

-- add into stock
delimiter // 
create procedure addintostock(prodid char(15),qty1 int)
begin
	declare pid char(15);
	declare check1 tinyint(1);
    
  set check1 =	(SELECT IF( EXISTS(
             select productid  from stock where productid=pid), 1, 0));
	if(check1=0)
    then
    update stock set qty= qty+qty1 where productid=prodid;
    else 
    insert into stock values(prodid, qty1);
    end if;
    end; //
delimiter ;
drop procedure addintostock;


-- ======category 

-- add new categorys
desc category;
delimiter //
create procedure addCategory(catid char(15), catname varchar(30))
begin
	insert into category values(catid,catname);
end; //
delimiter ;

-- === product
-- add new products
desc products;
delimiter //
create procedure addproduct(prodid char(15), categoryid char(15), prodname varchar(25), price float, componyname varchar(20))
begin
	insert into products values(prodid, categoryid, prodname, price, componyname);
end; //
delimiter ;

-- === user
-- add new user
desc users;
delimiter //
create procedure addnewuser(uid char(15), fname varchar(20), lname varchar(20), mno bigint(20), address varchar(30), city varchar(30), pincode int(11))
begin
	insert into users values(uid, fname, lname, mno, address,city, pincode);
end; //
delimiter ;

desc orders;
-- upadate order status
delimiter //

create procedure updateorderstautus(oid char(35), stat char(15))
begin 
	update orders set status = stat where orderid = oid;
end; //
delimiter ;


######## ======================================## triggers ##=================================

######## ========== insert trigger for stock counter========

-- insert trigger
delimiter //
create trigger Stockcounter_CI
before insert
on cart for each row 
begin 
	
	update stock set qty = qty-new.qty where productid=new.productid;
end; //
delimiter ;


######## ======== delte trigger for stock counter========


-- delete trigger
delimiter //

create trigger Stockcounter_Cd
before delete 
on cart for each row 
begin 
	
	update stock set qty = qty+old.qty where productid=old.productid;
end; //
delimiter ;







-- ===========================================================
select * from stock;
call addintostock('P001',100);
select * from stock;
call addproduct('P010','CI001','WHEAT seed', 1255, 'EAGLE');
select * from products;
call addcategory('CI005', 'LIME');
select * from category;
call addnewuser('UR00012','QUEEN', 'MCQUEEN', '8806021046', 'backerstreet, LONDON','LONDON',589632 );
select * from users order by userid;
desc users;






select * from orders;
-- billing querry for detaild info
SELECT 
    orderid,
    orders.userid,
    CONCAT(first_name, ' ', last_name) 'Username',
    orders.productid,
    qty,
    qty * price 'Total amount',
    address 'Delivery Adress', 
    status 'Delivery Stauts'
FROM
    orders,
    products,
    users
WHERE
    products.productId = orders.productId
        AND orders.userid = users.userid ;

-- billing query for order amount
select orderid, sum(qty*price) 'TOTAL AMOUNT' from orders, products where orders.productId=products.productId group by orderid;

select orderid, orders.userid, concat(first_name,' ',last_name),product_name,qty*price 'amount' from orders, users, products where users.userid=orders.userid and orders.productId=products.productId; 
desc users;


-- ===================user querries===================================
call addtocart('P001','UR0002',5);
call addToCart('P004','UR0002',5);
call addToCart('P006','UR0002',5);
call deletefromcart('P001');
select * from cart;
call checkout;
select * from cart;
-- ======= dummy data insertion=========
insert into products values
('P001','CI001','2-4D',299,'WEEDMAR'),
('P002','CI001','Meera-71',149,'Excel'),
('P003','CI002','Growroot',499,'Planto'),
('P004','CI002','Sugaecane Super',799,'RCF'),
('P005','CI003','10-26-26',1350,'IFFCO'),
('P006','CI003','24-24-24-08',1750,'MAHDHAN'),
('P007','CI004','Soyafast',2500,'Eagale'),
('P008','CI004','GramSeed',499,'Indra agree');

insert into category values('CI001','Herbicide'),
('CI002','Liqude Fertilizer'),
('CI003','Solid Fertilizer'),
('CI004','Seeds and pallets');
select * from products;

-- inserting data into users
insert into users (userid, first_name, last_name, mobile_no, Address, City, Pincode) values 
('UR0001', 'Nadeen', 'Cyphus', '9960979095', '90847 Debra Point', 'Zhamao', 609747),
('UR0002', 'Reiko', 'Rowley', '8549568759', '21460 Knutson Hill', 'San Miguel de Tucumán', 502521),
 ('UR0003', 'Case', 'Sheldrake', '7387774545', '246 Portage Road', 'Ploso Wetan', 892728),
 ('UR0004', 'Sallee', 'Jockle', '8412256845', '9 Logan Junction', 'Jinping', 377446),
('UR0005', 'Waiter', 'Assandri', '7875498672', '9 Sugar Park', 'Tarata', 611697),
('UR0006', 'Christean', 'Prodrick', '8975468412', '159 Weeping Birch Park', 'Janeng', 347851),
('UR0007', 'Gardy', 'Secret', '7387449857', '68 Alpine Drive', 'Sansheng', 592922),
('UR0008', 'Frederick', 'Caccavella', '8888006547', '89796 Scoville Drive', 'Calibishie', 508998),
('UR0009', 'Loren', 'Tucsell', '9168479853', '6739 Havey Parkway', 'Hetoudian', 813365),
('UR0010', 'Danette', 'Byneth', '9745862147', '9 Stang Trail', 'Shiziqiao', 484119);

select * from users;

insert into stock values
('P001',10),
('P002',10),
('P003',10),
('P004',10),
('P005',10),
('P006',10),
('P007',10),
('P008',10);
select * from stock;

