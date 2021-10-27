class AddStatusToApplicationPets < ActiveRecord::Migration[6.1]
  def change
    add_column :pet_application_pets, :status, :string
  end
end
