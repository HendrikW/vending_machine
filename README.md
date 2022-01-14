# README

## Bonus

* since JWT authentication is stateless the client can destroy all sessions by deleting the respective token(s)

* the whole application should be reasonably secure, although audit/review from additional experts would be advisable before production deploy ;)


## Setup

* create a `.env` file with a `API_SECRET_KEY=in-dev-environment-can-use-anything` entry for use with jwt tokens

* run `bundle install` and then `bin/rails s`


## Notes

* user cannot reset their password. also no e-mail confirmation. using an authentication gem like https://github.com/heartcombo/devise could be a good choice as a next step

* role-based access very simple with just enum in the database. could use a gem like https://github.com/CanCanCommunity/cancancan instead

* next step should also add unit tests for models (e.g. validations)

* shouldn't use sqlite in any production setting (even probably should use PostgreSQL/MySQL in development teams). for prototyping sqlite is fine I guess

* probably want to use serializers for json responses, or a gem like https://github.com/rails/jbuilder (instead of overriding `as_json`)

* add meaningful error messages for the case the user gets deleted from the database but the token is still being used with that `user_id`

* I have more experience with RSpec and a more mocking & stubbing approach to testing. Here I wanted to work with the tools that come with Rails 'out of the box'