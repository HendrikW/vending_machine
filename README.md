# Vending Machine (a Rails+JWT API)

JWT auth demonstrator project. It'a a Rails API that functions as a vending machine: Different sellers can place their products inside, buyers can insert coins, buy stuff, and receive change. 

## API documentation

Find the (interactive 🙌) API documentation here: https://vending-machine-demonstrator-bf25eecc3a18.herokuapp.com/docs (very BETA!)

## Local Dev Setup

* create a `.env` file with a `API_SECRET_KEY=in-dev-environment-can-use-anything` entry for use with jwt tokens

* run `bundle install` and then `bin/rails s`

* run `rake test` to run the included tests


## Notes

* user cannot reset their password. also no e-mail confirmation. using an authentication gem like https://github.com/heartcombo/devise could be a good choice as a next step

* role-based access very simple with just enum in the database. could use a gem like https://github.com/CanCanCommunity/cancancan instead

* probably want to use serializers for json responses, or a gem like https://github.com/rails/jbuilder (instead of overriding `as_json`)
