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
    account_num int,
    phoneNumbers text [],
    apartment_suite text DEFAULT null
) RETURNS void LANGUAGE plpgsql AS $$ 

DECLARE pub_id uuid;

BEGIN
INSERT INTO
    publishers (name, email)
VALUES
    (name, email) RETURNING publisher_id INTO pub_id;

INSERT INTO
    publisher_phones (publisher_id, number)
SELECT
    *
FROM
    pub_id
    CROSS JOIN unnest(phoneNumbers);

INSERT INTO
    payment_info (
        publisher_id,
        transit_num,
        institution_num,
        account_num,
        accounts_payable
    )
VALUES
    (
        (
            SELECT
                publisher_id
            FROM
                pub_id
        ),
        transit_num,
        institution_num,
        account_num,
        0
    );

END;

$$;