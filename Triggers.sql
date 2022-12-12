-- inserts a ROW INTO public.users
CREATE
OR REPLACE FUNCTION public.handle_new_user() RETURNS TRIGGER LANGUAGE plpgsql SECURITY definer
SET
  search_path = PUBLIC AS $$ BEGIN
INSERT INTO
  public.profiles (profile_id, first_name, last_name)
VALUES
  (new.id, NULL, NULL);

RETURN NEW;

END;

$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- TRIGGER the FUNCTION every TIME a user IS created
CREATE TRIGGER on_auth_user_created
AFTER
INSERT
  ON auth.users FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

CREATE
OR REPLACE FUNCTION public.update_accounts_payable() RETURNS TRIGGER LANGUAGE plpgsql AS 
$$ BEGIN

UPDATE
  publisher_payment
SET
  accounts_payable = pub_commission
FROM
  (
    SELECT
      publisher_id,
      SUM(quantity * price) as total_sales,
      SUM(price * quantity * pub_percentage) as pub_commission
    FROM
      order_books
    GROUP BY
      publisher_id

) as ord
WHERE
  publisher_payment.publisher_id = ord.publisher_id;

RETURN NEW;

END;

$$;

DROP TRIGGER IF EXISTS on_order_books_created ON public.order_books;

CREATE TRIGGER on_order_books_created
AFTER
INSERT
  ON public.order_books EXECUTE PROCEDURE public.update_accounts_payable();

CREATE
OR REPLACE FUNCTION public.book_previous_month_sales(isbn_ text) RETURNS int LANGUAGE plpgsql AS $$ BEGIN RETURN SUM(order_books.quantity)
FROM
  order_books
  JOIN orders on order_books.order_id = orders.order_id
WHERE
  order_books.isbn = isbn_
  AND orders.order_date > ('now' :: timestamp - '1 month' :: interval);

END;

$$;

CREATE
OR REPLACE FUNCTION public.restock_books() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN
UPDATE
  books
SET
  instock_quantity = instock_quantity + book_previous_month_sales(isbn)
WHERE
  instock_quantity < 10;

RETURN NEW;

END;

$$;

DROP TRIGGER IF EXISTS on_book_purchase ON public.books;

CREATE TRIGGER on_book_purchase
AFTER
UPDATE
  ON public.books WHEN (pg_trigger_depth() < 1) EXECUTE PROCEDURE public.restock_books();