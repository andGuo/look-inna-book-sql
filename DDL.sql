-- Andrew Guo #101194373

CREATE TABLE IF NOT EXISTS public.profiles (
    profile_id uuid PRIMARY KEY,
    first_name text NULL,
    last_name text NULL,
    FOREIGN KEY (profile_id) REFERENCES auth.users (id)
);

CREATE TABLE IF NOT EXISTS public.roles (
    role_id serial PRIMARY KEY,
    role_name text NOT NULL
);

INSERT INTO public.roles (role_name) VALUES ('owner');

CREATE TABLE IF NOT EXISTS public.profile_roles (
    profile_id uuid,
    role_id int,
    PRIMARY KEY (profile_id, role_id),
    FOREIGN KEY (profile_id) REFERENCES profiles,
    FOREIGN KEY (role_id) REFERENCES roles
);

CREATE TABLE IF NOT EXISTS public.user_address(
    profile_id uuid PRIMARY KEY,
    address text NOT NULL,
    apartment_suite text NULL,
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
    order_date timestamp NOT NULL DEFAULT NOW(),
    order_total decimal(19,4) NOT NULL,
    total_quantity int NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES profiles
);

CREATE TABLE IF NOT EXISTS public.tracking_info(
    order_id int PRIMARY KEY,
    shipping_status text NOT NULL DEFAULT 'Pending',
    creation_date timestamp NOT NULL DEFAULT NOW(),
    delivery_date timestamp DEFAULT NULL,
    delivered_date timestamp DEFAULT NULL,
    city text DEFAULT NULL,
    state text DEFAULT NULL,
    country text DEFAULT NULL,
    FOREIGN KEY (order_id) REFERENCES orders
);

CREATE TABLE IF NOT EXISTS public.shipping_address(
    order_id int PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL,
    address text NOT NULL,
    apartment_suite text NULL,
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
    apartment_suite text NULL,
    country text NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    zip_code text NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders
);

CREATE TABLE IF NOT EXISTS public.publishers(
    publisher_id uuid PRIMARY KEY default uuid_generate_v4(),
    name text NOT NULL,
    email text NOT NULL
);

CREATE TABLE IF NOT EXISTS public.publisher_phones(
    publisher_id uuid,
    number text,
    PRIMARY KEY (publisher_id, number),
    FOREIGN KEY (publisher_id) REFERENCES publishers
);

CREATE TABLE IF NOT EXISTS public.publisher_address(
    publisher_id uuid PRIMARY KEY,
    address text NOT NULL,
    apartment_suite text NULL,
    country text NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    zip_code text NOT NULL,
    FOREIGN KEY (publisher_id) REFERENCES publishers
);

CREATE TABLE IF NOT EXISTS public.publisher_payment(
    publisher_id uuid PRIMARY KEY,
    transit_num numeric(5, 0) NOT NULL,
    institution_num numeric(3, 0) NOT NULL,
    account_num numeric(12, 0) NOT NULL,
    accounts_payable decimal(19,4) NOT NULL,
    FOREIGN KEY (publisher_id) REFERENCES publishers
);

CREATE TABLE IF NOT EXISTS public.books(
    isbn text PRIMARY KEY,
    title text NOT NULL,
    msrp decimal(19,4) NOT NULL,
    instock_quantity int NOT NULL DEFAULT 0,
    num_pages int NOT NULL,
    pub_percentage decimal(6,5) NOT NULL,
    img_url text NULL,
    publisher_id uuid NOT NULL,
    FOREIGN KEY (publisher_id) REFERENCES publishers 
);

CREATE TABLE IF NOT EXISTS public.genres (
    name text PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS public.book_genres (
    isbn text,
    genre_id text,
    PRIMARY KEY (isbn, genre_id),
    FOREIGN KEY (isbn) REFERENCES books,
    FOREIGN KEY (genre_id) REFERENCES genres (name)
);

CREATE TABLE IF NOT EXISTS public.cart_books (
    profile_id uuid,
    isbn text,
    quantity int NOT NULL,
    PRIMARY KEY (profile_id, isbn),
    FOREIGN KEY (profile_id) REFERENCES profiles,
    FOREIGN KEY (isbn) REFERENCES books
);

CREATE VIEW public.carts AS
SELECT
    profile_id,
    SUM(quantity * msrp) as cart_total,
    SUM(quantity) as total_quantity
FROM
    cart_books
    JOIN books ON cart_books.isbn = books.isbn
GROUP BY
    profile_id;

CREATE TABLE IF NOT EXISTS public.order_books (
    order_id int,
    isbn text,
    title text NOT NULL,
    price decimal(19,4) NOT NULL,
    quantity int NOT NULL,
    pub_percentage decimal(6,5) NOT NULL,
    publisher_id uuid NOT NULL,
    PRIMARY KEY (order_id, isbn),
    FOREIGN KEY (order_id) REFERENCES orders,
    FOREIGN KEY (publisher_id) REFERENCES publishers 
);

CREATE TABLE IF NOT EXISTS public.authors(
    author_id uuid PRIMARY KEY default uuid_generate_v4(),
    first_name text NOT NULL,
    middle_name text NULL,
    last_name text NOT NULL
);

CREATE TABLE IF NOT EXISTS public.authored (
    author_id uuid,
    isbn text,
    PRIMARY KEY (author_id, isbn),
    FOREIGN KEY (author_id) REFERENCES authors,
    FOREIGN KEY (isbn) REFERENCES books
);
