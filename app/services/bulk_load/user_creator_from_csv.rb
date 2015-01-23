require 'csv'

class BulkLoad::UserCreatorFromCsv
  def initialize(demo_id, schema, unique_id_field)
    @demo_id = demo_id
    @demo = Demo.find(@demo_id)
    @schema = schema
    @unique_id_field = unique_id_field
    @unique_id_field_index_in_schema = @schema.find_index(@unique_id_field.to_s)
  end

  def create_user(csv_line)
    user_data = CSV.parse_line(csv_line)
    new_user_attributes = {characteristics: {}}

    @schema.zip(user_data) do |column_name, value|
      add_column! column_name, value, new_user_attributes
    end

    user = @demo.users.where(@unique_id_field => user_data[@unique_id_field_index_in_schema]).first

    if user
      # Have to ditch the board_memberships join to make this record writeable
      user = User.find(user.id)
      user.attributes = clean_attributes_for_existing_user(user, new_user_attributes)
      user.save
      user.schedule_segmentation_update(true)
    else
      user = User.create(new_user_attributes)
      user.add_board(@demo_id, true) if user.persisted?
    end

    user
  end

  protected

  def add_column!(column_name, value, new_user_attributes)
    if is_characteristic?(column_name)
      add_characteristic! column_name, value, new_user_attributes
    else
      add_regular_field! column_name, value, new_user_attributes
    end
  end

  def add_characteristic!(column_name, value, new_user_attributes)
    characteristic_id = column_name.gsub(/^characteristic_/, '').to_i

    new_user_attributes[:characteristics][characteristic_id] = value
  end

  def add_regular_field!(column_name, value, new_user_attributes)
    new_user_attributes[attribute_to_set(column_name)] = normalize_value(column_name, value)
  end

  def is_characteristic?(name)
    name =~ /^characteristic_\d+$/
  end

  def attribute_to_set(column_name)
    case column_name
    when 'location_name'
      'location_id'
    else
      column_name
    end
  end

  def normalize_value(column_name, value)
    case column_name
    when 'date_of_birth'
      Chronic.parse(value).try(:to_date)
    when 'gender'
      case value.downcase.first
      when 'm'
        'male'
      when 'f'
        'female'
      when 'o'
        'other'
      end
    when 'location_name'
      existing_or_new_location_id(value)
    else
      value
    end
  end

  def existing_or_new_location_id(location_name)
    location = Location.where(demo_id: @demo_id, name: location_name).first
    location ||= Location.create(demo_id: @demo_id, name: location_name)    
    location.id
  end

  def clean_attributes_for_existing_user(user, new_user_attributes)
    result = new_user_attributes.dup
    existing_characteristics = (user.characteristics || {})

    result[:characteristics].reverse_merge!(existing_characteristics)
    result[:characteristics].keys.each do |key|
      result[:characteristics][key] = result[:characteristics][key].to_s
    end

    if result['email'].present? && result['email'] == user.overflow_email
      result.delete('email')
    end

    result
  end
end
