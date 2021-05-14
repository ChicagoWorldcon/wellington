class UsersWhoCanNominateForChicago

  def call
    users_with_nominating_chicago_claims.select(:email)
  end

  private

  def current_time_stamp
    Time.now
  end

  def nominating_memberships
    Membership.where(can_nominate: true)
  end

  def active_orders
    Order.where(:active_from > current_time_stamp ).and
    (Order.where("active_to IS NULL").or(Order.where(:active_to < current_time_stamp)))
  end

  def chicago_claims
    # FIXME this query needs to be implemented
    # Claim.joins(:chicago_contact, (reservation: (active_orders nominating_memberships))) #Should join active orders.
  end

  def users_with_nominating_chicago_claims
    User.joins(chicago_claims)
  end

end
