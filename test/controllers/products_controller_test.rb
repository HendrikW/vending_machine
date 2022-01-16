require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest


  setup do
    @user    = users(:buyerOne)
    @product = products(:one)
  end    


  # --- /buy       --------------------------------------------------
  test "should complete a transaction" do
    current_deposit          = @user.deposit
    current_amount_available = @product.amount_available
    
    post "/buy", as: :json, params: { "product_id": @product.id, "amount": 2 }, headers: { "HTTP_AUTHORIZATION" => "Bearer " + create_jwt_token('buyer') }
    
    assert_response :success
    assert_equal @response.parsed_body['funds_spent'], 2 * @product.cost
    assert_equal @response.parsed_body['purchased_product'], @product.product_name
    assert_equal @response.parsed_body['availabe_change'], ["0 x 100", "1 x 50", "0 x 20", "1 x 10", "1 x 5"] # 50 + 10 + 5 = 65 left 
    
    assert_equal User.find(@user.id).deposit, current_deposit - 2 * @product.cost
    assert_equal Product.find(@product.id).amount_available, current_amount_available - 2
  end


  # --- helpers     -------------------------------------------------
  def create_jwt_token(role)
    exp = Time.now.to_i + 2 # 2 minutes
    payload = { 
      exp: exp,
      user_id: @user.id,
      role: role
    }

    JWT.encode payload, ENV['API_SECRET_KEY'], 'HS256'

  end  
end
