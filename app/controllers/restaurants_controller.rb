class RestaurantsController < ApplicationController
  def new
    @restaurant = Restaurant.new
  end

  def create
    res = Restaurant.create(:name => params[:name])
    res.save
    redirect_to restaurant_path(res.name)
  end

  def destroy
    Restaurant.delete_all(:conditions => {:name => params[:id]})
    redirect_to restaurants_path
  end

  def update
   res = Restaurant.find(:all, :conditions => {:name => params[:id]}).first
   res.update_attributes(:name => params[:new_name])
   redirect_to res
  end

  def show
    @restaurant = Restaurant.find(:first, :conditions => {:name => params[:id]})
  end

  def index
    @restaurants = Restaurant.find(:all)
  end
end
