require 'rails_helper'

RSpec.describe 'admin application index page' do
  before(:each) do
    @app1 = PetApplication.create!(name: 'Liam', street: '155 Main Street', city: 'Phoenix', state: 'AZ', zip: 85_222,
                                   status: 1)
    @app2 = PetApplication.create!(name: 'Chloe', street: '123 University Dr', city: 'Tempe', state: 'AZ', zip: 85_111,
                                   status: 1)

    @shelter1 = Shelter.create!(foster_program: true, name: 'Downtown Animal Shelter', city: 'Phoenix, AZ', rank: 2)
    @shelter2 = Shelter.create!(foster_program: true, name: 'Mesa Animal Adoption Center', city: 'Mesa, AZ', rank: 1)
    @shelter3 = Shelter.create!(foster_program: false, name: 'Chandler Animal Shelter', city: 'Chandler, AZ', rank: 4)

    @pet1 = Pet.create!(adoptable: true, age: 6, breed: 'Mutt', name: 'Daisy', shelter_id: @shelter1.id)
    @pet2 = Pet.create!(adoptable: true, age: 8, breed: 'Dumpster Cat', name: 'Moxie', shelter_id: @shelter2.id)
    @pet3 = Pet.create!(adoptable: true, age: 9, breed: 'Border Collie', name: 'Gimli', shelter_id: @shelter2.id)

    PetApplicationPet.create!(pet_application: @app1, pet: @pet1)
    PetApplicationPet.create!(pet_application: @app1, pet: @pet2)
    PetApplicationPet.create!(pet_application: @app2, pet: @pet1)
    PetApplicationPet.create!(pet_application: @app2, pet: @pet2)
  end

  it 'approves a pet for adoption' do
    visit "/admin/applications/#{@app1.id}"

    expect(page).to have_content('Pending')
    within("#approval-#{@pet1.id}") do
      click_on('Approve Pet')
      expect(page).to have_current_path("/admin/applications/#{@app1.id}")
      expect(page).to_not have_content('Approve Pet')
      expect(page).to have_content('Approved')
    end
  end

  it 'rejects a pet for adoption' do
    visit "/admin/applications/#{@app1.id}"

    expect(page).to have_content('Pending')
    within("#approval-#{@pet1.id}") do
      click_on('Reject Pet')
      expect(page).to have_current_path("/admin/applications/#{@app1.id}")
      expect(page).to_not have_content('Reject Pet')
      expect(page).to have_content('Rejected')
    end
  end

  it 'approves only one pet at a time for adoption' do
    visit "/admin/applications/#{@app1.id}"

    expect(page).to have_content('Pending')
    within("#approval-#{@pet1.id}") do
      click_on('Approve Pet')
      expect(page).to have_current_path("/admin/applications/#{@app1.id}")
      expect(page).to_not have_content('Approve Pet')
      expect(page).to have_content('Approved')
    end
    within("#approval-#{@pet1.id}") do
      expect(page).to have_content('Approve Pet')
      expect(page).to_not have_content('Approved')
    end
  end

  it 'only rejects or approves pets on one application' do
    visit "/admin/applications/#{@app1.id}"

    within("#approval-#{@pet1.id}") do
      click_on('Approve Pet')
    end
    within("#approval-#{@pet2.id}") do
      click_on('Reject Pet')
    end

    visit "/admin/applications/#{@app2.id}"
    within("#approval-#{@pet1.id}") do
      expect(page).to have_content('Approve Pet')
      expect(page).to_not have_content('Approved')
    end

    within("#approval-#{@pet2.id}") do
      click_on('Reject Pet')
      expect(page).to have_content('Reject Pet')
      expect(page).to_not have_content('Rejected')
    end
  end
end
