require 'spec_helper'
require 'devise/test_helpers'

describe RestaurantsController do
  render_views
  describe "when user is signed in" do
    before do
      @user = User.create(:name => "Bob Saget", :email => "bob@test.com", :password => "pword1234")
      sign_in @user
    end

    after do
      User.delete_all
    end

    describe "when starting to create a restaurant site" do
      before do
        get 'new'
      end

      it "should have a name field" do
        response.should have_selector("label", :content => "Name")
        response.should have_selector("input", :name => "restaurant[name]")
      end

      it "should have a check box" do
        response.should have_selector("input", :type => "checkbox")
      end

      it "should have an address field" do
        response.should have_selector("label", :content => "Address")
        response.should have_selector("input", :name => "restaurant[address]")
      end
    end

    describe "when submitting a new restaurant" do
      before do
        post 'create', :restaurant => { :name => "A New Restaurant", :owner => @user.id.to_s, :address => "555 W Barry" }
      end

      after do
        Restaurant.delete_all
      end

      it "should create a new restaurant when submitted" do 
        Restaurant.find(:all).count.should == 1
      end

      it "should have the owner specified" do
        puts User.find(@user.id.to_s)
        Restaurant.find_by_name("A New Restaurant").owner_name.should == "Bob Saget"
      end

      it "should show the new created restaurant after creation" do
        get 'show', :id => "A New Restaurant"
        response.should have_selector("h1", :content => "A New Restaurant")
      end

      it "should automatically redirect to the show page after creating a restaurant" do
        response.should redirect_to(restaurant_path("A New Restaurant"))
      end
    end

    describe "when viewing an existing restaurant" do
      before do
        Restaurant.create(:name => "Akbar", :owner => @user, :address => "555 W Barry")
      end

      after do
        Restaurant.delete_all
      end

      it "should be listed in the list of all restaurants" do
        get 'index'
        response.should have_selector("li", :content => "Akbar")
      end

      it "should be accessible through a direct name link" do
        get 'show', :id => "Akbar"
        response.should_not be_nil
      end

      it "should be accessible through a case insensitive name link" do
        get 'show', :id => "akbar"
        response.should_not be_nil
      end

      it "should have name on direct page" do
        get 'show', :id => "akbar"
        response.should have_selector("h1", :content => "Akbar")
      end

      it "should have owner on direct page" do
        get 'show', :id => "akbar"
        response.should have_selector("h2", :content => "Owner: Bob Saget")
      end

      it "should have owner on direct page" do
        get 'show', :id => "akbar"
        response.should have_selector("h2", :content => "Address: 555 W Barry")
      end
    end

    describe "when modifying an existing restaurant" do
      before do
        Restaurant.create(:name => "test restaurant", :address => "")
      end

      after do
        Restaurant.delete_all
      end

      it "should delete a restaurant" do
        delete :destroy, :id => "test restaurant"
        Restaurant.find_by_name("test restaurant").should be_nil
      end

      it "should update a restaurant name" do
        post 'update', :id => "test restaurant", :new_name => "new test"
        Restaurant.find_by_name("test restaurant").should be_nil
        Restaurant.find_by_name("new test").should_not be_nil
      end
    end

    describe "when a restaraunt has no owner defined" do
      before do
        rest = Restaurant.create(:name => "Panes", :address => "")
        section = rest.sections.create(:name => "Bread")
        section.menuitems.create(:name => "Cookie", :price => 1.50)
      end

      it "should show Not Claimed on the direct page" do
        get 'show', :id => "Panes"
        response.should have_selector("h2", :content => "Not Claimed")
      end

      it "should show all sections for a restaurant" do
        get 'show', :id => "Panes"
        response.should have_selector("h3", :content => "Menu")
        response.should have_selector("h4", :content => "Bread")
      end

      it "should show menu items for a restaurant" do
        get 'show', :id => "Panes"
        response.should have_selector("h5", :content => "Cookie")
      end
    end
  end

  describe "when no user is logged in" do
    describe "when starting to create a restaurant site" do
      it "should put no user as owner" do
        post 'create', :restaurant => { :name => "A New Restaurant 2", :owner => nil }
        Restaurant.find_by_name("A New Restaurant 2").owner.should be_nil
      end
    end
  end
end
