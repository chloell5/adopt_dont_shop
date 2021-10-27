class PetApplicationPetsController < ApplicationController
  def create
    pet = Pet.find(params[:pet_id])
    app = PetApplication.find(params[:id])
    @app_pet = PetApplicationPet.create!(pet_id: pet.id, pet_application_id: app.id)
    redirect_to "/applications/#{app.id}"
  end
end
