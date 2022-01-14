class ProductsController < ApplicationController
  before_action :require_login
  before_action :user_is_seller, except: [:show] # buyers can only look, not modify products

  def show
    if product = Product.find_by_id(params[:id])
      render json: product
    else
      render json: { message: 'not found'}, status: :not_found
    end
  end

  def create
    product = Product.new(product_params)
    product.seller = current_user
    
    if product.save
      render json: product
    else
      render json: { message: 'errors during product creation', errors: product.errors }, status: :bad_request
    end
  rescue ActiveRecord::RecordNotFound
      render json: { message: 'not found'}, status: :not_found
  end

  def update
    product = Product.find_by!(id: params[:id], seller: current_user)
    # for now, only allow updating cost and amount available
    product.cost = params[:cost]
    product.amount_available = params[:amount_available]

    if product.save
      render json: product
    else
      render json: { message: 'errors during product update', errors: product.errors }, status: :bad_request
    end
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'not found'}, status: :not_found
  end

  def destroy
    product = Product.find_by!(id: params[:id], seller: current_user)
    product.destroy
    render json: { message: 'success'}, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'not found'}, status: :not_found
  end


  private

  def product_params
      params.permit(:product_name, :cost, :amount_available)
  end
end
