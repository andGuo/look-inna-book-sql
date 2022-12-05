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

RETURN QUERY (SELECT isbn, title, msrp, num_pages, img_url, publisher_id, instock_quantity FROM books);

END;
$$;