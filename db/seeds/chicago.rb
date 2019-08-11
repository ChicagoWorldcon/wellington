bid_announcement = Date.parse("2018-08-25").midday
presupport_start = bid_announcement - 2.years
vote_date = Date.parse("2020-08-01").midday

FactoryBot.create(:membership, :bid_support, active_from: presupport_start, active_to: vote_date)
FactoryBot.create(:membership, :bid_friend, active_from: presupport_start, active_to: vote_date)
FactoryBot.create(:membership, :bid_star, active_from: presupport_start, active_to: vote_date)
