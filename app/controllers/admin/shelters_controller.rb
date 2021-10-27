class Admin::SheltersController < ApplicationController
  def index
    @shelters = Shelter.alphabetical_shelters
    @pending = Shelter.pending_shelters
  end
end
