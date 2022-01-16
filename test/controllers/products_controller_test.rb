require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest


  setup do
    @user     = users(:buyerOne)
    @seller   = users(:sellerOne)
    @product  = products(:one)
    @product2 = products(:two)
  end    

  # --- GET /          -------------------------------------------------
  test "should list products" do

    get "/products", as: :json, headers: { "HTTP_AUTHORIZATION" => "Bearer " + create_jwt_token(@user) }
    
    assert_response :success
    # TODO: don't depend on exact order of elements in array
    assert_equal @response.parsed_body[0]["product_name"],  @product2.product_name 
    assert_equal @response.parsed_body[0]["cost"],  @product2.cost 
    assert_equal @response.parsed_body[1]["product_name"],  @product.product_name 
  end

  # --- GET /:id       -------------------------------------------------
  test "should show specific product" do

    get "/products/#{@product2.id}", as: :json, headers: { "HTTP_AUTHORIZATION" => "Bearer " + create_jwt_token(@user) }
    
    assert_response :success
    assert_equal @response.parsed_body["product_name"],  @product2.product_name 
    assert_equal @response.parsed_body["cost"],  @product2.cost 
  end

  # --- POST /         ------------------------------------------------- 
  test "should NOT create a new product as a buyer" do

    post "/products", as: :json, params: {     
      "product_name": "piano",
    }, headers: { "HTTP_AUTHORIZATION" => "Bearer " + create_jwt_token(@user) }
    
    assert_response :unauthorized
  end

  # --- POST /         ------------------------------------------------- 
  test "should create a new product" do

    post "/products", as: :json, params: {     
      "product_name": "piano123",
      "cost": 1500,
      "amount_available": 2
    }, headers: { "HTTP_AUTHORIZATION" => "Bearer " + create_jwt_token(@seller) }
    
    assert_response :success
    assert_equal @response.parsed_body["product_name"], "piano123"
    assert_equal @response.parsed_body["seller_id"], @seller.id

    assert Product.all.find {|e| e.product_name === "piano123" }
  end

  # --- PUT /:id       -------------------------------------------------
  test "should update a product" do

    put "/products/#{@product.id}", as: :json, params: {     
      "product_name": "blabla",
      "cost": 98765,
      "amount_available": 234576
    }, headers: { "HTTP_AUTHORIZATION" => "Bearer " + create_jwt_token(@seller) }
    
    assert_response :success
    assert_equal @response.parsed_body["product_name"], @product.product_name
    assert_equal @response.parsed_body["cost"], 98765
    assert_equal @response.parsed_body["amount_available"], 234576
    assert_equal @response.parsed_body["seller_id"], @seller.id

    assert_equal Product.find(@product.id).cost, 98765
    assert_equal Product.find(@product.id).amount_available, 234576
  end


  # --- DELETE /:id    -------------------------------------------------
  test "should delete a product" do

    assert_difference 'Product.count', -1 do
      delete "/products/#{@product.id}", as: :json, headers: { "HTTP_AUTHORIZATION" => "Bearer " + create_jwt_token(@seller) }
    end
    
    assert_response :success
    assert_equal @response.parsed_body["message"], "success"

    assert_not Product.find_by(id: @product.id)
  end


  # --- POST /buy     --------------------------------------------------
  test "should complete a transaction" do
    current_deposit          = @user.deposit
    current_amount_available = @product.amount_available
    
    post "/buy", as: :json, params: { "product_id": @product.id, "amount": 2 }, headers: { "HTTP_AUTHORIZATION" => "Bearer " + create_jwt_token(@user) }
    
    assert_response :success
    assert_equal @response.parsed_body['funds_spent'], 2 * @product.cost
    assert_equal @response.parsed_body['purchased_product'], @product.product_name
    assert_equal @response.parsed_body['availabe_change'], ["0 x 100", "1 x 50", "0 x 20", "1 x 10", "1 x 5"] # 50 + 10 + 5 = 65 left 
    
    assert_equal User.find(@user.id).deposit, current_deposit - 2 * @product.cost
    assert_equal Product.find(@product.id).amount_available, current_amount_available - 2
  end


  # --- helpers     ----------------------------------------------------
  def create_jwt_token(user)
    exp = Time.now.to_i + 2 # 2 minutes
    payload = { 
      exp: exp,
      user_id: user.id,
      role: user.role
    }

    JWT.encode payload, ENV['API_SECRET_KEY'], 'HS256'

  end
end
