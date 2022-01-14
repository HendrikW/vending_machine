require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:buyerOne)
  end

  test "should not deposit for unauthenticated users" do
    
    post "/deposit", as: :json,  params: { "coin": 20 }
    
    assert_response :unauthorized
  end

  test "should not deposit for sellers" do
    post "/deposit", as: :json,  params: { "coin": 20 }, headers: { "HTTP_AUTHORIZATION" => "Bearer " + create_jwt_token('seller') }
    
    assert_response :bad_request
    assert_equal @response.parsed_body['message'], 'only buyers can do this action' 
  end

  test "should not deposit invalid coins" do
    post "/deposit", as: :json,  params: { "coin": 21 }, headers: { "HTTP_AUTHORIZATION" => "Bearer " + create_jwt_token('buyer') }
    
    assert_response :bad_request
    assert_equal @response.parsed_body['message'], 'not a valid coin value'
  end

  test "should deposit valid coins" do
    current_deposit = @user.deposit
    
    post "/deposit", as: :json, params: { "coin": 20 }, headers: { "HTTP_AUTHORIZATION" => "Bearer " + create_jwt_token('buyer') }
    
    assert_response :success
    assert_equal @response.parsed_body['message'], 'success'
    assert_equal User.find(@user.id).deposit, current_deposit + 20
  end


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
