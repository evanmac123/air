Factory.define :demo do |factory|
  factory.company_name { "Gillette" }
end

Factory.define :player do |factory|
  factory.association(:demo)
  factory.name  { "James Earl Jones" }
  factory.email { "james@example.com" }
end

Factory.define :rule do |factory|
  factory.association(:key)
  factory.value  { "banana" }
  factory.points { 2 }
end

Factory.define :key do |factory|
  factory.name { "ate" }
end
