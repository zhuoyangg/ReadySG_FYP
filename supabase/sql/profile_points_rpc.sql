create or replace function public.increment_profile_points(
  target_user_id uuid,
  points_delta integer
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  updated_total integer;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if auth.uid() <> target_user_id then
    raise exception 'Not authorized to update this profile';
  end if;

  update public.profiles
  set total_points = coalesce(total_points, 0) + coalesce(points_delta, 0)
  where id = target_user_id
  returning total_points into updated_total;

  if updated_total is null then
    raise exception 'Profile not found for %', target_user_id;
  end if;

  return updated_total;
end;
$$;

grant execute on function public.increment_profile_points(uuid, integer) to authenticated;
