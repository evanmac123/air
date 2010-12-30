Factory.define :demo do |factory|
  factory.company_name { "Gillette" }
end

Factory.define :player do |factory|
  factory.name  { "James Earl Jones" }
  factory.email { "james@example.com" }
end
