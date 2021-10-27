require 'rails_helper'

RSpec.describe 'admin shelter index page' do
  before(:each) do
    @app1 = PetApplication.create!(name: 'Liam', street: '155 Main Street', city: 'Phoenix', state: 'AZ', zip: 85_222, status: 0)
    @app2 = PetApplication.create!(name: 'Chloe', street: '123 University Dr', city: 'Tempe', state: 'AZ', zip: 85_111, status: 1)

    @shelter1 = Shelter.create!(foster_program: true, name: 'Downtown Animal Shelter', city: 'Phoenix, AZ', rank: 2)
    @shelter2 = Shelter.create!(foster_program: true, name: 'Mesa Animal Adoption Center', city: 'Mesa, AZ', rank: 1)
    @shelter3 = Shelter.create!(foster_program: false, name: 'Chandler Animal Shelter', city: 'Chandler, AZ', rank: 4)

    @pet1 = Pet.create!(adoptable: true, age: 6, breed: 'Mutt', name: 'Daisy', shelter_id: @shelter1.id)
    @pet2 = Pet.create!(adoptable: true, age: 8, breed: 'Dumpster Cat', name: 'Moxie', shelter_id: @shelter2.id)

    PetApplicationPet.create!(pet_application: @app1, pet: @pet1)
    PetApplicationPet.create!(pet_application: @app2, pet: @pet2)
  end

  it 'displays shelters in reverse alphabetical order' do
    visit '/admin/shelters'

    expect(@shelter3.name).to appear_before(@shelter1.name)
    expect(@shelter1.name).to appear_before(@shelter2.name)
  end

  it 'shows shelters with pending applications' do
    visit '/admin/shelters'

    expect(page).to have_content("Shelters with Pending Applications")

    within("#pending") do
      expect(page).to have_content(@shelter2.name)
      expect(page).to_not have_content(@shelter1.name)
      expect(page).to_not have_content(@shelter3.name)
    end
  end
end
