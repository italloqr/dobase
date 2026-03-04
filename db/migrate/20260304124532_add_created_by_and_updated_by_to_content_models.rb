# frozen_string_literal: true

class AddCreatedByAndUpdatedByToContentModels < ActiveRecord::Migration[8.1]
  def change
    %w[cards columns todo_items todo_lists file_items file_folders calendar_events].each do |table|
      add_reference table, :created_by, foreign_key: { to_table: :users }, null: true
      add_reference table, :updated_by, foreign_key: { to_table: :users }, null: true
    end

    # Documents: add created_by/updated_by, migrate last_edited_by data, remove old column
    add_reference :documents, :created_by, foreign_key: { to_table: :users }, null: true
    add_reference :documents, :updated_by, foreign_key: { to_table: :users }, null: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE documents SET created_by_id = last_edited_by_id, updated_by_id = last_edited_by_id
          WHERE last_edited_by_id IS NOT NULL
        SQL
      end
    end

    remove_reference :documents, :last_edited_by, foreign_key: { to_table: :users }
  end
end
