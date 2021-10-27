require 'rails_helper'

RSpec.describe 'pet application show' do
  context 'basic information' do
    it 'shows the applicant details' do
      app = PetApplication.create!(name: 'Liam', street: '155 Main Street', city: 'Phoenix', state: 'AZ', zip: 85_222,
                                   reason: 'Pet friendly, loving home looking for a companion')

      visit "/applications/#{app.id}"

      expect(page).to have_content(app.name)
      expect(page).to have_content(app.street)
      expect(page).to have_content(app.city)
      expect(page).to have_content(app.state)
      expect(page).to have_content(app.zip)
      expect(page).to have_content(app.reason)
    end

    it 'shows application status' do
      app = PetApplication.create!(name: 'Liam', street: '155 Main Street', city: 'Phoenix', state: 'AZ', zip: 85_222,
                                   reason: 'Pet friendly, loving home looking for a companion')

      visit "/applications/#{app.id}"

      expect(page).to have_content("Application Status: #{app.status}")
    end
  end

  context 'pet information' do
    before(:each) do
      @app = PetApplication.create!(name: 'Liam', street: '155 Main Street', city: 'Phoenix', state: 'AZ', zip: 85_222,
                                    reason: 'Pet friendly, loving home looking for a companion')

      shelter = Shelter.create!(foster_program: true, name: 'Phoenix Pet Friends', city: 'Phoenix, AZ', rank: 2)

      @cat = @app.pets.create!(adoptable: true, age: 8, breed: 'Bombay', name: 'Moxie', shelter_id: shelter.id)
      @dog = @app.pets.create!(adoptable: true, age: 4, breed: 'Mutt', name: 'Daisy', shelter_id: shelter.id)
    end

    it 'shows pets tied to application' do
      visit "/applications/#{@app.id}"

      expect(page).to have_content(@cat.name)
      expect(page).to have_content(@dog.name)
    end

    it 'has links in pet names' do
      visit "/applications/#{@app.id}"

      click_on 'Moxie'

      expect(page).to have_current_path("/pets/#{@cat.id}")
    end
  end

  context 'adding pets to application' do
    before(:each) do
      @app = PetApplication.create!(name: 'Liam', street: '155 Main Street', city: 'Phoenix', state: 'AZ', zip: 85_222,
                                    reason: 'Pet friendly, loving home looking for a companion')
    end
    it 'has a search bar if app is not submitted' do
      visit "/applications/#{@app.id}"

      within('main') {expect(find('form')).to have_content('Search')}
    end

    xit 'has no search function if app is submitted' do
      #not sure this will work until I move the form to a partial
      @app.status = 1
      visit "/applications/#{@app.id}"

      expect(page).to_not have_content('Add a Pet to this Application')
    end

# ADD TESTS FOR PARTIAL MATCHES
    it 'searches for pet by name' do
      shelter = Shelter.create(name: 'Mystery Building', city: 'Irvine CA', foster_program: false, rank: 9)
      pet = Pet.create(name: 'Scrappy', age: 1, breed: 'Great Dane', adoptable: true, shelter_id: shelter.id)

      visit "/applications/#{@app.id}"

      fill_in 'Pet Name Search', with: 'Scrappy'
      click_on 'Search Pets'

      expect(page).to have_content(pet.name)
      expect(page).to have_content(pet.age)
      expect(page).to have_content(pet.breed)
      expect(page).to have_content(pet.adoptable)
      expect(page).to have_content(pet.shelter.name)
    end
  end
end
