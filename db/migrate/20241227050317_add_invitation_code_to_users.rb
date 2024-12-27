class AddInvitationCodeToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :invitation_code, :string
  end
end
