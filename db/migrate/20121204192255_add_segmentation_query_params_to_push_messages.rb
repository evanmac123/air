class AddSegmentationQueryParamsToPushMessages < ActiveRecord::Migration
  def change
    add_column :push_messages, :respect_notification_method,  :boolean

    add_column :push_messages, :segment_query_columns,   :string
    add_column :push_messages, :segment_query_operators, :string
    add_column :push_messages, :segment_query_values,    :string
  end
end
