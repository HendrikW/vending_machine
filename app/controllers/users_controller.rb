class UsersController < ApplicationController
    wrap_parameters false
    before_action :require_login, except: [:create, :login]
    before_action :user_is_buyer, except: [:create, :login] # currently all routes in this controller except create, login are for buyers only

    def create
        begin
            user = User.new(user_params)
        rescue ArgumentError
            render json: { message: 'role does not exist' } # TODO: figure out what is current best practice regarding https://github.com/rails/rails/issues/13971, maybe just use simple string field instead 
            return
        end


        if user.save 
            render json: user
        else
            render json: { message: 'errors during user creation', errors: user.errors }, status: :bad_request
        end

    end

    # generates JWT token (valid for 20 minutes)
    def login
        user = User.find_by("lower(username) = ?", user_params[:username].downcase)
        if user && user.authenticate(user_params[:password])
          render json: { token: jwt_token(user), user_id: user.id }, status: :created 
        else 
          render json: { message:  "incorrect username or password"  }, status: :unprocessable_entity
        end 
    end

    def deposit 
        if current_user.deposit_coin!(params[:coin])
            render  json: { message: 'success', deposit: current_user.deposit }, status: :ok
        else
            render  json: { message: 'not a valid coin value' }, status: :bad_request
        end
    end

    def reset
        leftover_change = current_user.availabe_change
        current_user.update!({ deposit: 0 })
        render  json: { availabe_change: leftover_change }, status: :ok
    end


    private

    def user_params
        params.permit(:username, :password, :password_confirmation, :role)
    end
end
