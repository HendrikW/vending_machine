class ProductsController < ApplicationController
  before_action :require_login
  before_action :user_is_seller, except: [:show, :buy] # buyers can only look, not modify products
  before_action :user_is_buyer, only: [:buy]

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


  def buy
    product = Product.find(params[:product_id])

    total_cost = (product.cost * params[:amount])

    if current_user.deposit < total_cost
      render json: { message: 'not enough funds'}, status: :ok
      return
    end

    if product.amount_available < params[:amount]
      render json: { message: 'amount of this product not available'}, status: :ok
      return
    end

    # prevent lost updates using locks (with_lock also creates a transaction)
    product.with_lock do 
      product.amount_available -= params[:amount]
      product.save!
      current_user.lock! # not sure .. ActiveRecord probably already does this as part of #update!
      current_user.update!(deposit: current_user.deposit - total_cost)
    end

    render json: { funds_spent: total_cost, purchased_product: product.product_name, availabe_change: current_user.availabe_change }

  rescue ActiveRecord::RecordNotFound
    render json: { message: 'not found'}, status: :not_found
  end


  private

  def product_params
      params.permit(:product_name, :cost, :amount_available)
  end
end
