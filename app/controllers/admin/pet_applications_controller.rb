class Admin::PetApplicationsController < ApplicationController

  def show
    @app = PetApplication.find(params[:id])
  end

  def update
    app = PetApplication.find(params[:id])
    app_pet = PetApplicationPet.find_app(params[:id], params[:pet_id])
    app_pet.update(status: params[:status])
    redirect_to "/admin/applications/#{app.id}"
  end
end
