
task update_demo_phone_numbers: :environment do
  Demo.where(phone_number: "").update_all(phone_number: nil)
end

# rake update_demo_phone_numbers
