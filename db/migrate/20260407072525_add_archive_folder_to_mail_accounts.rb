class AddArchiveFolderToMailAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :mail_accounts, :archive_folder, :string
  end
end
