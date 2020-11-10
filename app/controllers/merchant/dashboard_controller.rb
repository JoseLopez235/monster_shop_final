class Merchant::DashboardController < Merchant::BaseController
  def index
    current_user.reload
    @merchant = current_user.merchant
  end
end
