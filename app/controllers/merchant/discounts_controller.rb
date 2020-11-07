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

  private
  def discount_params
    params.permit(:discount, :quantity)
  end
end
