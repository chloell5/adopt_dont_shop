require 'rails_helper'

RSpec.describe 'pet application show' do
  context 'basic information' do
    it 'shows the applicant details' do
      app = PetApplication.create!(name: 'Liam', street: '155 Main Street', city: 'Phoenix', state: 'AZ', zip: 85_222)

      visit "/applications/#{app.id}"

      expect(page).to have_content(app.name)
      expect(page).to have_content(app.street)
      expect(page).to have_content(app.city)
      expect(page).to have_content(app.state)
      expect(page).to have_content(app.zip)
    end

    it 'shows application status' do
      app = PetApplication.create!(name: 'Liam', street: '155 Main Street', city: 'Phoenix', state: 'AZ', zip: 85_222)

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

  context 'search bar' do
    before(:each) do
      @app = PetApplication.create!(name: 'Liam', street: '155 Main Street', city: 'Phoenix', state: 'AZ', zip: 85_222)
    end
    it 'has search functions if app is not submitted' do
      visit "/applications/#{@app.id}"

      within('main') { expect(find('form')).to have_content('Search') }
    end
  end

  context 'search functionality' do
    before(:each) do
      @app = PetApplication.create!(name: 'Liam', street: '155 Main Street', city: 'Phoenix', state: 'AZ', zip: 85_222)
      @shelter = Shelter.create(name: 'Mystery Building', city: 'Irvine CA', foster_program: false, rank: 9)
      @pet = Pet.create(name: 'Scrappy', age: 1, breed: 'Great Dane', adoptable: true, shelter_id: @shelter.id)
    end

    it 'searches for pet by exact name' do
      visit "/applications/#{@app.id}"

      fill_in 'Pet Name Search', with: 'Scrappy'
      click_on 'Search Pets'

      expect(page).to have_content(@pet.name)
      expect(page).to have_content(@pet.age)
      expect(page).to have_content(@pet.breed)
      expect(page).to have_content(@pet.adoptable)
      expect(page).to have_content(@pet.shelter.name)
    end

    it 'searches for pet by partial match' do
      visit "/applications/#{@app.id}"

      fill_in 'Pet Name Search', with: 'Scrap'
      click_on 'Search Pets'

      expect(page).to have_content(@pet.name)
      expect(page).to have_content(@pet.age)
      expect(page).to have_content(@pet.breed)
      expect(page).to have_content(@pet.adoptable)
      expect(page).to have_content(@pet.shelter.name)
    end

    it 'searches for pet without case sensitivity' do
      visit "/applications/#{@app.id}"

      fill_in 'Pet Name Search', with: 'scRaPpy'
      click_on 'Search Pets'

      expect(page).to have_content(@pet.name)
      expect(page).to have_content(@pet.age)
      expect(page).to have_content(@pet.breed)
      expect(page).to have_content(@pet.adoptable)
      expect(page).to have_content(@pet.shelter.name)
    end

    it 'adds the returned pet' do
      visit "/applications/#{@app.id}"

      fill_in 'Pet Name Search', with: 'Scrappy'
      click_on 'Search Pets'

      click_button("Adopt this Pet")
    end

    it 'submits an application' do
      visit "/applications/#{@app.id}"

      fill_in 'Pet Name Search', with: 'Scrappy'
      click_on 'Search Pets'

      click_button("Adopt this Pet")

      fill_in 'Reason', with: "<3"
      click_button("Submit Application")
      expect(current_path).to eq("/applications/#{@app.id}")
      expect(page).to have_content("Pending")
      expect(page).to have_content(@pet.name)
      expect(page).to_not have_content("Add a Pet to this Application")
      expect(page).to_not have_content("Tell us why you'd make a good owner")
      expect(page).to have_content("<3")
    end

    it 'shows no submit if there are no pets' do
      visit "/applications/#{@app.id}"
      
      expect(page).to_not have_content("Submit")
    end
  end
end
