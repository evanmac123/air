require 'csv'

class UserCreatorFromCsv
  def initialize(demo_id, schema)
    @demo_id = demo_id
    @schema = schema
  end

  def create_user(csv_line)
    user_data = CSV.parse_line(csv_line)
    new_user_attributes = {characteristics: {}}

    @schema.zip(user_data) do |column_name, value|
      if is_characteristic?(column_name)
        add_characteristic! column_name, value, new_user_attributes
      else
        add_regular_field! column_name, value, new_user_attributes
      end
    end

    new_user_attributes[:demo_id] = @demo_id
    User.create(new_user_attributes)
  end

  protected

  def is_characteristic?(name)
    name =~ /^characteristic_\d+$/
  end

  def add_characteristic!(column_name, value, new_user_attributes)
    characteristic_id = column_name.gsub(/^characteristic_/, '').to_i

    new_user_attributes[:characteristics][characteristic_id] = value
  end

  def add_regular_field!(column_name, value, new_user_attributes)
    new_user_attributes[column_name] = value
  end
end
