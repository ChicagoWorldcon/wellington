select u.email, cc.last_name, r.created_at, o.active_from, o.active_to, m.can_attend
from public.users u
join public.claims c
on c.user_id = u.id
join public.chicago_contacts cc
on c.id = cc.claim_id
join public.reservations r
on c.reservation_id = r.id
join public.orders o
on o.reservation_id = r.id
join public.memberships m
on o.membership_id = m.id
where m.can_attend = true
and now() > o.active_from
and (now() < o.active_to or o.active_to is null);
