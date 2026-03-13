-- Check existing users schemas if needed
SELECT username FROM all_users;

-- Create tables in your schema (example: system or custom schema)

--------------------------------------------------
-- 1. CUSTOMERS (Using IDENTITY)
--------------------------------------------------

CREATE TABLE customers (
    customer_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone VARCHAR2(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


--------------------------------------------------
-- 2. CATEGORIES (Using IDENTITY)
--------------------------------------------------

CREATE TABLE categories (
    category_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(100) NOT NULL
);


--------------------------------------------------
-- 3. SUPPLIERS (Using IDENTITY)
--------------------------------------------------

CREATE TABLE suppliers (
    supplier_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    contact_email VARCHAR2(100)
);


--------------------------------------------------
-- 4. PRODUCTS (Using IDENTITY)
--------------------------------------------------

CREATE TABLE products (
    product_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(150) NOT NULL,
    price NUMBER(10,2) NOT NULL,
    category_id NUMBER,
    supplier_id NUMBER,

    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id),

    CONSTRAINT fk_product_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id)
);


--------------------------------------------------
-- 5. ORDERS (Using SEQUENCE + TRIGGER)
--------------------------------------------------

CREATE TABLE orders (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR2(50),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


CREATE SEQUENCE orders_seq
START WITH 1
INCREMENT BY 1
NOCACHE;


CREATE OR REPLACE TRIGGER orders_trigger
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF :NEW.order_id IS NULL THEN
        SELECT orders_seq.NEXTVAL
        INTO :NEW.order_id
        FROM dual;
    END IF;
END;
/


--------------------------------------------------
-- 6. ORDER_ITEMS (Using SEQUENCE + TRIGGER)
--------------------------------------------------

CREATE TABLE order_items (
    order_item_id NUMBER PRIMARY KEY,
    order_id NUMBER,
    product_id NUMBER,
    quantity NUMBER NOT NULL,
    price NUMBER(10,2) NOT NULL,

    CONSTRAINT fk_orderitems_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_orderitems_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);


CREATE SEQUENCE order_items_seq
START WITH 1
INCREMENT BY 1
NOCACHE;


CREATE OR REPLACE TRIGGER order_items_trigger
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    IF :NEW.order_item_id IS NULL THEN
        SELECT order_items_seq.NEXTVAL
        INTO :NEW.order_item_id
        FROM dual;
    END IF;
END;
/


--------------------------------------------------
-- 7. PAYMENTS (Using SEQUENCE + TRIGGER)
--------------------------------------------------

CREATE TABLE payments (
    payment_id NUMBER PRIMARY KEY,
    order_id NUMBER,
    payment_method VARCHAR2(50),
    payment_date DATE,
    amount NUMBER(10,2),

    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


CREATE SEQUENCE payments_seq
START WITH 1
INCREMENT BY 1
NOCACHE;


CREATE OR REPLACE TRIGGER payments_trigger
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    IF :NEW.payment_id IS NULL THEN
        SELECT payments_seq.NEXTVAL
        INTO :NEW.payment_id
        FROM dual;
    END IF;
END;
/


--------------------------------------------------
-- 8. SHIPMENTS (Using IDENTITY)
--------------------------------------------------

CREATE TABLE shipments (
    shipment_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id NUMBER,
    shipment_date DATE,
    status VARCHAR2(50),

    CONSTRAINT fk_shipment_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


--------------------------------------------------
-- 9. INVENTORY (Using IDENTITY)
--------------------------------------------------

CREATE TABLE inventory (
    inventory_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id NUMBER,
    quantity NUMBER NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);