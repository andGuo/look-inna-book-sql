-- Andrew Guo #101194373

--Reset stuff w this:
-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;
-- GRANT ALL ON SCHEMA public TO aguo;
-- GRANT ALL ON SCHEMA public TO root;
-- GRANT ALL ON SCHEMA public TO postgres;
-- GRANT ALL ON SCHEMA public TO public;

CREATE TABLE IF NOT EXISTS public.profiles (
    profile_id uuid PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL,
    create_date date NOT NULL,
    last_sign_in date NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES auth.users (id)
);

CREATE TABLE IF NOT EXISTS public.roles (
    role_id serial PRIMARY KEY,
    role_name text NOT NULL
);

CREATE TABLE IF NOT EXISTS public.profile_roles (
    profile_id uuid,
    role_id int,
    PRIMARY KEY (profile_id, role_id),
    FOREIGN KEY (profile_id) REFERENCES profiles,
    FOREIGN KEY (role_id) REFERENCES roles
);

CREATE TABLE IF NOT EXISTS public.user_address(
    profile_id uuid PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL,
    address text NOT NULL,
    apartment_suite NULL,
    country text NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    zip_code text NOT NULL,
    phone_number text NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES profiles
);

CREATE TABLE IF NOT EXISTS public.orders(
    order_id serial PRIMARY KEY,
    profile_id uuid NOT NULL,
    order_date date NOT NULL,
    order_total decimal(19,4) NOT NULL,
    total_quantity int(11) unsigned NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES profiles
);

CREATE TABLE IF NOT EXISTS public.shipping_address(
    order_id int PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL,
    address text NOT NULL,
    apartment_suite NULL,
    country text NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    zip_code text NOT NULL,
    phone_number text NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders
);

CREATE TABLE IF NOT EXISTS public.billing_address(
    order_id int PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL,
    address text NOT NULL,
    apartment_suite NULL,
    country text NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    zip_code text NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders
);

CREATE TABLE IF NOT EXISTS public.carts(
    profile_id uuid PRIMARY KEY,
    cart_total decimal(19,4) NOT NULL,
    total_quantity int(11) unsigned NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES profiles
);

CREATE TABLE IF NOT EXISTS public.publishers(
    publisher_id uuid PRIMARY KEY,
    name text NOT NULL,
    email text NOT NULL,
    phone_number text NOT NULL 
);

CREATE TABLE IF NOT EXISTS public.publisher_address(
    publisher_id uuid PRIMARY KEY,
    address text NOT NULL,
    apartment_suite NULL,
    country text NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    zip_code text NOT NULL,
    phone_number text NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders
);

CREATE TABLE IF NOT EXISTS public.books(
    isbn text PRIMARY KEY,
    name text NOT NULL,
    msrp decimal(19,4) NOT NULL,
    num_pages int NOT NULL,
    pub_percentage decimal(3,10) NOT NULL,
    img_url text NULL,
    publisher_id uuid NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES publishers 
);





ALTER TABLE
    EMPLOYEE
ADD
    CONSTRAINT fk_employee_depart FOREIGN KEY (dno) REFERENCES DEPARTMENT;