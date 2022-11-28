-- inserts a ROW INTO public.users
CREATE FUNCTION public.handle_new_user()
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

-- TRIGGER the FUNCTION every TIME a user IS created
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

  -- Set up Book Image Storage:
  