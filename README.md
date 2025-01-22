## How to Setup Docker for Ruby on Rails 7

[Check out our detailed guide on setting up Docker for Ruby on Rails 7](https://dev.to/jetthoughts_61/setting-up-docker-for-ruby-on-rails-7-50cd)

## Run the Application on docker

## Step to build and run the application docker

Step 1: docker-compose build
Step 2: docker-compose run web rails db:create
Step 3: docker-compose up
run rails by command : docker-compose run web rails

## Step to create/migrate the application's DB (Make sure the docker is running)

Step 1: Access the Docker Container's Bash docker exec -it <docker-container-name> bash
Step 2: Create DB <rails db:create>
Step 3: Create DB <rails db:migrate>

## How to test the API

1. Using swagger document by visiting http://localhost:3000/api-docs/index.html (Locally) (rswag)
2. Using postman with the appropriate endpoint and parameters

## How to run the unit tests

-   In the docker bash command, run the following command <bundle exec rspec>
-   Config the minimun minimum_coverage by modifying the minimum_coverage in spec_helper.rb file (Using simplecov for the code coverage)

## Setting up with package manager

- System dependencies
	* ruby 3.1.4
	* 'rails', '~> 7.0.8', '>= 7.0.8.1'
	* nodejs
	* postgres 11

## DB Configuration Locally
	- Host: localhost, port: 5432
	- Database: rails_7_with_docker
	- username: postgres
	- password: postgres