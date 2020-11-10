class  Merchant::DiscountsController < Merchant::BaseController
  def new
  end

  def create
    merchant = current_user.merchant
    discount = merchant.discounts.new(discount_params)
    if discount.save
      redirect_to "/merchant"
    else
      flash[:error] = discount.errors.full_messages.uniq
      render :new
    end
  end

  def edit
    @discount = Discount.find(params[:id])
  end

  def update
    @discount = Discount.find(params[:id])
    if @discount.update(discount_params)
      redirect_to "/merchant"
    else
      flash[:error] = @discount.errors.full_messages.uniq
      render :edit
    end
  end

  def destroy
    discount = Discount.find(params[:id])
    discount.destroy
    redirect_to '/merchant'
  end

  private
  def discount_params
    params.permit(:discount, :quantity)
  end
end
