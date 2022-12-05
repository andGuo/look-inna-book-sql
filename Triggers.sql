-- inserts a ROW INTO public.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY definer SET search_path = PUBLIC
AS $$
BEGIN
  INSERT INTO public.profiles (profile_id, first_name, last_name)
  VALUES (new.id, NULL, NULL);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
-- TRIGGER the FUNCTION every TIME a user IS created
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Cart Stuff
CREATE OR REPLACE FUNCTION public.create_cart()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.carts(profile_id) VALUES (NEW.profile_id);
END;
$$;

DROP TRIGGER IF EXISTS on_profile_created ON public.profiles;
CREATE TRIGGER on_profile_created
    AFTER INSERT ON public.profiles
    REFERENCING NEW TABLE AS new_profiles
    FOR EACH ROW EXECUTE PROCEDURE public.create_cart();
     

CREATE OR REPLACE FUNCTION public.update_carts()


CREATE TRIGGER on_cart_book_added
    AFTER INSERT OR UPDATE OR DELETE ON public.cart_books
    FOR EACH ROW EXECUTE PROCEDURE public.update_carts


  -- Set up Book Image Storage:
  