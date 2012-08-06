class BulkLoader
  DEFAULT_COLUMN_SCHEMA = [
    :name,
    :email,
    :claim_code,
    [:sms_slug, {do_after_save: true}]
  ]

  def initialize(demo, user_data, characteristic_data, column_schema = DEFAULT_COLUMN_SCHEMA)
    @demo = demo
    @user_data = user_data
    @characteristic_data = characteristic_data
    @column_schema = column_schema
    @columns_on_create, @columns_after_create = divide_column_schema(column_schema)
  end

  def bulk_load!
    successful_creations = 0
    errored_users = []

    CSV.parse(@user_data).each do |row|
      user = build_user_from_row(row)
      if user.persisted?
        successful_creations += 1
      else
        errored_users << user 
      end
    end

    [successful_creations, errored_users]
  end

  protected

  def extra_column_characteristics
    return @extra_column_characteristics if @extra_column_characteristics

    @extra_column_characteristics = {}
    @characteristic_data.each do |column_index, characteristic_id|
      next unless characteristic_id.present?
      @extra_column_characteristics[column_index.to_i] = Characteristic.find(characteristic_id)
    end
    @extra_column_characteristics
  end

  def add_characteristics_from_extra_columns(user, row)
    return true if row.length <= @column_schema.length

    extra_column_characteristics.each do |column_index, characteristic|
      next unless row[column_index].present?

      if characteristic.value_allowed?(row[column_index])
        user.characteristics ||= {}
        user.characteristics[characteristic.id] = row[column_index]
      else
        # Can't do this with user.errors.add since it seems to ignore the
        # error on characteristics on save or valid?.
        user.errors.add(:characteristics, "bad value for #{characteristic.name}: #{row[column_index]}")
        return false
      end
    end

    true
  end

  def extract_user_data_from_row(row, columns)
    pairs = columns.map do |index, field_name|
      [field_name, row[index]]
    end

    Hash[pairs]
  end

  def build_user_from_row(row)
    on_create_attributes = extract_user_data_from_row(row, @columns_on_create)
    user = @demo.users.build(on_create_attributes)

    if add_characteristics_from_extra_columns(user, row) && user.save
      after_create_attributes = extract_user_data_from_row(row, @columns_after_create)
      user.update_attributes(after_create_attributes)
    end

    user
  end

  def divide_column_schema(column_schema)
    columns_on_create = {}
    columns_after_create = {}

    column_schema.each_with_index do |schema_field, i|
      if schema_field.kind_of?(Enumerable) 
        if schema_field.last[:do_after_save]
          columns_after_create[i] = schema_field[0]
        else
          columns_on_create[i] = schema_field[0]
        end
      else
        columns_on_create[i] = schema_field
      end
    end

    [columns_on_create, columns_after_create]
  end
end
