CREATE
OR REPLACE FUNCTION create_publisher(
    name text,
    email text,
    address text,
    country text,
    city text,
    state text,
    zip_code text,
    transit_num int,
    institution_num int,
    account_num bigint,
    phoneNumbers text [],
    apartment_suite text DEFAULT null,
    publisher_id uuid DEFAULT uuid_generate_v4()
) RETURNS void LANGUAGE plpgsql AS $$ 

BEGIN
INSERT INTO
    publishers (publisher_id, name, email)
VALUES
    (publisher_id, name, email);

INSERT INTO
    publisher_phones (publisher_id, number)
SELECT
    publisher_id, num
FROM
    unnest(phoneNumbers) AS num;

INSERT INTO
    publisher_payment (
        publisher_id,
        transit_num,
        institution_num,
        account_num,
        accounts_payable
    )
VALUES
    (
        publisher_id,
        transit_num,
        institution_num,
        account_num,
        0
    );

INSERT INTO
    publisher_address (
        publisher_id,
        address,
        apartment_suite,
        country,
        city,
        state,
        zip_code
    )
VALUES
    (
        publisher_id,
        address,
        apartment_suite,
        country,
        city,
        state,
        zip_code
    );

END;

$$;


CREATE
OR REPLACE FUNCTION create_author(
    first_name text,
    middle_name text,
    last_name text,
    author_id uuid DEFAULT uuid_generate_v4()
) RETURNS void LANGUAGE plpgsql AS $$ 

BEGIN
INSERT INTO
    authors (author_id, first_name, middle_name, last_name)
VALUES
    (author_id, first_name, middle_name, last_name);

END;

$$;

CREATE
OR REPLACE FUNCTION create_book(
    isbn text,
    title text,
    msrp decimal,
    num_pages int,
    pub_percentage decimal,
    publisher_id uuid,
    authors uuid[],
    genres text[],
    instock_quantity int DEFAULT 0,
    img_url text DEFAULT NULL
) RETURNS void LANGUAGE plpgsql AS $$ 

BEGIN
INSERT INTO
    books (isbn, title, msrp, instock_quantity, num_pages, pub_percentage, img_url, publisher_id)
VALUES
    (isbn, title, msrp, instock_quantity, num_pages, pub_percentage, img_url, publisher_id);

INSERT INTO
    authored (isbn, author_id)
SELECT
    isbn, author
FROM
    unnest(authors) AS author;

INSERT INTO
    book_genres (isbn, genre_id)
SELECT
    isbn, genre
FROM
    unnest(genres) AS genre;

END;

$$;

CREATE
OR REPLACE FUNCTION is_owner(
    pid uuid
) RETURNS boolean LANGUAGE plpgsql AS $$ 

BEGIN

RETURN EXISTS (SELECT * FROM profile_roles JOIN roles USING (role_id) WHERE pid = profile_id AND role_name = 'owner'); 

END;
$$;

CREATE
OR REPLACE FUNCTION add_to_cart(
    isbn_ text,
    quantity int,
    pid uuid
) RETURNS void LANGUAGE plpgsql AS $$ 

BEGIN
INSERT INTO
    cart_books (profile_id, isbn, quantity)
VALUES
    (pid, isbn_, quantity)
ON CONFLICT (profile_id, isbn)
DO UPDATE SET quantity = EXCLUDED.quantity;

END;

$$;

CREATE
OR REPLACE FUNCTION remove_book(isbn_ text) RETURNS TABLE (
    isbn text,
    title text,
    msrp decimal(19, 4),
    instock_quantity int,
    num_pages int,
    img_url text,
    publisher_id uuid
) LANGUAGE plpgsql AS $$ BEGIN

DELETE FROM authored WHERE authored.isbn = isbn_;
DELETE FROM cart_books WHERE cart_books.isbn = isbn_;
DELETE FROM book_genres WHERE book_genres.isbn = isbn_;
DELETE FROM books WHERE books.isbn = isbn_;

RETURN QUERY (SELECT books.isbn, books.title, books.msrp, books.instock_quantity, books.num_pages, books.img_url, books.publisher_id FROM books);

END;
$$;

CREATE
OR REPLACE FUNCTION get_profile_cart(uid uuid) RETURNS TABLE (
    isbn text,
    purchase_quantity int,
    title text,
    msrp decimal(19, 4),
    instock_quantity int,
    img_url text
) LANGUAGE plpgsql AS $$ BEGIN

RETURN QUERY (
    SELECT
        books.isbn,
        t.quantity,
        books.title,
        books.msrp,
        books.instock_quantity,
        books.img_url
    FROM
        (
            SELECT
                *
            FROM
                cart_books
            WHERE
                uid = profile_id
        ) as t
        JOIN books ON t.isbn = books.isbn
);

END;
$$;

CREATE
OR REPLACE FUNCTION place_order(
    shipFname text,
    shipLname text,
    shipAddr text,
    shipCountry text,
    shipCity text,
    shipState text,
    shipZipCode text,
    shipPhoneNum text,
    billFname text,
    billLname text,
    billAddr text,
    billCountry text,
    billCity text,
    billState text,
    billZipCode text,
    uid uuid,
    shipAptSuite text DEFAULT NULL,
    billAptSuite text DEFAULT NULL
) RETURNS void LANGUAGE plpgsql AS $$ BEGIN
INSERT INTO
    orders (profile_id, order_total, total_quantity)
SELECT
    profile_id,
    cart_total,
    total_quantity
FROM
    carts
WHERE
    carts.profile_id = uid;

INSERT INTO
    tracking_info (order_id)
VALUES
    (lastval());

INSERT INTO
    shipping_address (
        order_id,
        first_name,
        last_name,
        address,
        apartment_suite,
        country,
        city,
        state,
        zip_code,
        phone_number
    )
VALUES
    (
        lastval(),
        shipFname,
        shipLname,
        shipAddr,
        shipAptSuite,
        shipCountry,
        shipCity,
        shipState,
        shipZipCode,
        shipPhoneNum
    );

INSERT INTO
    billing_address (
        order_id,
        first_name,
        last_name,
        address,
        apartment_suite,
        country,
        city,
        state,
        zip_code
    )
VALUES
    (
        lastval(),
        billFname,
        billLname,
        billAddr,
        billAptSuite,
        billCountry,
        billCity,
        billState,
        billZipCode
    );

INSERT INTO
    order_books (
        order_id,
        isbn,
        title,
        price,
        quantity,
        pub_percentage,
        publisher_id
    )
SELECT
    lastval(),
    isbn,
    title,
    msrp,
    quantity,
    pub_percentage,
    publisher_id
FROM
    cart_books NATURAL
    JOIN books
WHERE
    quantity <= instock_quantity
    AND cart_books.profile_id = uid;

UPDATE
    books
SET
    instock_quantity = instock_quantity - ord.quantity
FROM
    (
        SELECT
            isbn,
            quantity
        FROM
            cart_books NATURAL
            JOIN books
        WHERE
            quantity <= instock_quantity
            AND cart_books.profile_id = uid
    ) as ord
WHERE
    books.isbn = ord.isbn;

DELETE FROM
    cart_books
WHERE
    uid = profile_id;

END;

$$;

CREATE
OR REPLACE FUNCTION get_profile_order(order_number int) RETURNS TABLE (
    shipping_status text,
    creation_date timestamp,
    delivery_date timestamp,
    delivered_date timestamp,
    city text,
    state text,
    country text
) LANGUAGE plpgsql AS $$ BEGIN

RETURN QUERY (
    SELECT
        tracking_info.shipping_status,
        tracking_info.creation_date,
        tracking_info.delivery_date,
        tracking_info.delivered_date,
        tracking_info.city,
        tracking_info.state,
        tracking_info.country
    FROM
        tracking_info
    WHERE
        order_number = order_id
);

END;
$$;

CREATE OR REPLACE FUNCTION generate_report() RETURNS TABLE (
    total_sales decimal(19, 4),
    total_expenses decimal(19, 4)
) LANGUAGE plpgsql AS $$ BEGIN

RETURN QUERY (
    SELECT
        t1.total_sales,
        t2.publisher_payment
    FROM
        (
            SELECT
                SUM(order_total) as total_sales
            FROM
                orders
        ) as t1
        CROSS JOIN (
            SELECT
                SUM(accounts_payable) as publisher_payment
            FROM
                publisher_payment
        ) as t2
);
END;
$$;

CREATE
OR REPLACE FUNCTION gen_author_genre_sales(authors uuid [], genres text []) RETURNS decimal(19, 4) LANGUAGE plpgsql AS $$ BEGIN IF cardinality(authors) > 0
AND cardinality(genres) > 0 THEN RETURN SUM(price * quantity)
FROM
    (
        SELECT
            *
        FROM
            order_books NATURAL
            JOIN (
                SELECT
                    DISTINCT isbn
                FROM
                    authored
                WHERE
                    authored.author_id = ANY(authors)
            ) as t1
    ) as t3 NATURAL
    JOIN (
        SELECT
            *
        FROM
            order_books NATURAL
            JOIN (
                SELECT
                    DISTINCT isbn
                FROM
                    book_genres
                WHERE
                    book_genres.genre_id = ANY(genres)
            ) as t2
    ) as t4;

ELSIF cardinality(authors) > 0 THEN RETURN SUM(price * quantity)
FROM
    (
        SELECT
            *
        FROM
            order_books NATURAL
            JOIN (
                SELECT
                    DISTINCT isbn
                FROM
                    authored
                WHERE
                    authored.author_id = ANY(authors)
            ) as t1
    ) as t3;

ELSIF cardinality(genres) > 0 THEN RETURN SUM(price * quantity)
FROM
    (
        SELECT
            *
        FROM
            order_books NATURAL
            JOIN (
                SELECT
                    DISTINCT isbn
                FROM
                    book_genres
                WHERE
                    book_genres.genre_id = ANY(genres)
            ) as t2
    ) as t4;

END IF;

END;
$$;
