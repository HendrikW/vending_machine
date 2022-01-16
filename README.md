# README

## Regarding the Bonus ..

*  JWT authentication is stateless 
    * this means persisting sessions server-side would defeat the purpose to some degree
    * if we wanted to enable the user to log out all their clients/devices session persistence on the server would have to be implemented
    * other approaches exist. e.g.
        * checking session/state only for certain more critical operations
        * using a long running token and re-issuing shorter-lived tokens periodically
    * note that Rails' default CookieStorage "suffers" from the same limitation (in a way it's pretty similar to JWT)

* the whole application should be reasonably secure, although audit/review from additional experts would be advisable before production deploy ;)


## Setup

* create a `.env` file with a `API_SECRET_KEY=in-dev-environment-can-use-anything` entry for use with jwt tokens

* run `bundle install` and then `bin/rails s`

* run `rake test` to run the included tests


## Notes

* user cannot reset their password. also no e-mail confirmation. using an authentication gem like https://github.com/heartcombo/devise could be a good choice as a next step

* role-based access very simple with just enum in the database. could use a gem like https://github.com/CanCanCommunity/cancancan instead

* next step should also add unit tests for models (e.g. validations)

* shouldn't use sqlite in any production setting (even probably should use PostgreSQL/MySQL in development teams). for prototyping sqlite is fine I guess

* probably want to use serializers for json responses, or a gem like https://github.com/rails/jbuilder (instead of overriding `as_json`)

* the tests for /buy route need to be expanded to test more edge cases