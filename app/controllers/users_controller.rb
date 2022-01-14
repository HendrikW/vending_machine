class UsersController < ApplicationController
    wrap_parameters false
    before_action :require_login, except: [:create, :login]

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

    # generates JWT token (valid for 2 minutes)
    def login
        user = User.find_by("lower(username) = ?", user_params[:username].downcase)
        if user && user.authenticate(user_params[:password])
          render json: { token: jwt_token(user), user_id: user.id }, status: :created 
        else 
          render json: { message:  "incorrect username or password"  }, status: :unprocessable_entity
        end 
    end

    def deposit 
        unless current_user_role === "buyer"
            render json: { message: 'only buyers can do this action' }, status: :bad_request
            return
        end

        if User.find(current_user_id).deposit_coin!(params[:coin])
            render  json: { message: 'success' }, status: :ok
        else
            render  json: { message: 'not a valid coin value' }, status: :bad_request
        end
    end

    def reset
        unless current_user_role === "buyer"
            render json: { message: 'only buyers can do this action' }, status: :bad_request
            return
        end

        User.update(current_user_id, { deposit: 0 })
        render  json: { message: 'success' }, status: :ok
    end

    private

    def user_params
        params.permit(:username, :password, :password_confirmation, :role)
    end
end
