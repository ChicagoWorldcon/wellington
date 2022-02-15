namespace :reservation_price_lock do
  desc "Assign a price_lock_date to supporting membership reservations where installment plan info has been requested"
  task backdate: :environment do
    PriceLockBackDater.call
  end
end
