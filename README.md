# README

## Setup

Have to create a `.env` file with a `API_SECRET_KEY=in-dev-environment-can-use-anything` entry for use with jwt tokens

## Notes

* user cannot reset their password. also no e-mail confirmation. using an authentication gem like https://github.com/heartcombo/devise could be a good choice as a next step

* role-based access very simple with just enum in the database. could use a gem like https://github.com/CanCanCommunity/cancancan instead

* next step should also add unit tests for models (e.g. validations)

* shouldn't use sqlite in any production setting (even probably should use PostgreSQL/MySQL in development teams). for prototyping sqlite is fine I guess

* probably want to use serializers for json responses, or a gem like https://github.com/rails/jbuilder (instead of overriding `as_json`)