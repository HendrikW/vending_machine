# frozen_string_literal: true

# UsersController class
class UsersController < ApplicationController
  wrap_parameters false
  before_action :require_login, except: %i[create login]
  before_action :user_is_buyer, except: %i[create login update delete]

  # @request_body The user to be created [!Hash{username: String, password: String, password_confirmation: String, role: String}]
  # @request_body_example Create a "seller" type user [Hash] {"username": "seller1", "password": "test-test1", "password_confirmation": "test-test1", "role": "seller"}
  # @request_body_example Create a "buyer" type user [Hash] {"username": "buyer1", "password": "test-test1", "password_confirmation": "test-test1", "role": "buyer"}
  # @response Requested User(200) [Hash{username: string, role: string, deposit: integer }]
  # @response_example Requested User(200) [{username: "seller1", role: "seller", deposit: 0 }]
  # @response Bad Request(400) [Hash{message: string, errors: Array<String> }]
  # @response_example Bad Request(400) [{message: "errors during user creation", errors: ["user already exists"] }]
  def create
    begin
      user = User.new(user_params)
    rescue ArgumentError
      render json: { message: 'role does not exist' }, status: :bad_request
      return
    end

    if user.save
      render json: user
    else
      render json: { message: 'errors during user creation', errors: user.errors }, status: :bad_request
    end
  end

  def update
    if current_user.authenticate(user_params[:password])
      if current_user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
        render json: current_user
      else
        render json: { message: 'errors during update', errors: current_user.errors }, status: :bad_request
      end
    else
      render json: { message:  'incorrect password' }, status: :unauthorized
    end
  end

  def delete
    if current_user.authenticate(user_params[:password])
      current_user.destroy!
      render json: { message: 'success' }
    else
      render json: { message: 'incorrect password' }, status: :unauthorized
    end
  end

  # generates JWT token (valid for 20 minutes)
  def login
    user = User.find_by('lower(username) = ?', user_params[:username].downcase)
    if user&.authenticate(user_params[:password])
      render json: { token: jwt_token(user), user_id: user.id }, status: :created
    else
      render json: { message:  'incorrect username or password'  }, status: :unauthorized
    end
  end

  # Deposit a coin (must be 5, 10, 20, 50 or 100)
  def deposit
    if current_user.deposit_coin!(params[:coin])
      render  json: { message: 'success', deposit: current_user.deposit }, status: :ok
    else
      render  json: { message: 'not a valid coin value' }, status: :bad_request
    end
  end

  def reset
    leftover_change = current_user.available_change
    current_user.update!({ deposit: 0 })
    render json: { available_change: leftover_change }, status: :ok
  end

  private

  def user_params
    params.permit(:username, :password, :password_confirmation, :role)
  end
end
