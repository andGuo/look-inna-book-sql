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

END;

$$;