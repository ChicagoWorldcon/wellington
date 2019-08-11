bid_announcement = Date.parse("2018-08-25").midday
presupport_start = bid_announcement - 2.years
vote_date = Date.parse("2020-08-01").midday

Membership.create(
  name: "bid_supporter",
  active_from: presupport_start,
  active_to: vote_date,
  description: "Bid Supporter",
  can_vote: false,
  can_attend: false,
  price_cents: 20_00,
  price_currency: "USD",
)

Membership.create(
  name: "friend_of_the_bid",
  active_from: presupport_start,
  active_to: vote_date,
  description: "Friend of the Bid",
  can_vote: false,
  can_attend: false,
  price_cents: 150_00,
  price_currency: "USD",
)

Membership.create(
  name: "star_supporter",
  active_from: presupport_start,
  active_to: vote_date,
  description: "Bid Star",
  can_vote: false,
  can_attend: false,
  price_cents: 500_00,
  price_currency: "USD",
)
