class UsersController < ApplicationController
    wrap_parameters false

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
            render json: { message: 'errors during user creation', errors: user.errors }, status: 400
        end

    end

    private

    def user_params
        params.permit(:username, :password, :password_confirmation, :role)
    end
end
