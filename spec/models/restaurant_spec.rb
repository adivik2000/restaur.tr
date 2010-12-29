require 'spec_helper'

describe Restaurant do
  describe "when no restaurants are available" do
    it "should return nil safely in find by name" do
      Restaurant.find_by_name("abc123").should be_nil
    end
  end

  describe "when many restaurants are available" do
    before do
      Restaurant.create(:name => "first")
      Restaurant.create(:name => "second")
      Restaurant.create(:name => "third")
    end

    it "should return nil for an object not present" do
      Restaurant.find_by_name("fourth").should be_nil
    end

    it "should return the desired object" do
      Restaurant.find_by_name("first").should_not be_nil
    end
  end
end
