class PetApplicationPet < ApplicationRecord
  belongs_to :pet_application
  belongs_to :pet

  def self.find_app(app_id, pet_id)
    where(pet_application_id: app_id, pet_id: pet_id)
  end
end
