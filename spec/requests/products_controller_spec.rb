require 'rails_helper'

# --- helper  --> this should be moved into its own module
def create_jwt_token(user)
  exp = Time.now.to_i + 2 # 2 minutes
  payload = {
    exp: exp,
    user_id: user.id,
    role: user.role
  }

  JWT.encode payload, ENV['API_SECRET_KEY'], 'HS256'
end  



RSpec.describe "ProductsControllers", type: :request do
  fixtures :all # note: probably factories are a better choice

  let(:buyer) { users(:buyerOne) }
  let(:seller) { users(:buyerOne) }
  let(:product) { products(:one) }
  let(:product2) { products(:two) }

  describe "GET /products" do
    it "returns successful status code" do
      get '/products', as: :json, headers: { "HTTP_AUTHORIZATION" => "Bearer " + create_jwt_token(buyer) }

      expect(response).to have_http_status(:success)
    end

  end


end

