class AddDependentBoardEmailContentToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :dependent_board_email_subject, :string
    add_column :demos, :dependent_board_email_body, :text
  end
end
