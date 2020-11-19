class ReviewsController < ApplicationController
  def new
    @item = Item.find(params[:id])
  end

  def create
    @item = Item.find(params[:id])
    review = @item.reviews.new(review_params)
    if review.save
      redirect_to "/items/#{@item.id}"
    else
      generate_flash(review)
      render :new
    end
  end

  def edit
    @review = Review.find(params[:id])
  end

  def update
    @review = Review.find(params[:id])
    @review.update(review_params)
    redirect_to "/items/#{@review.item.id}"
  end

  def destroy
    review = Review.find(params[:id])
    review.destroy
    redirect_to"/items/#{review.item.id}"
  end

  private

  def review_params
    params.permit(:title, :description, :rating)
  end
end
