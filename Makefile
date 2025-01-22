up:
	docker compose build
	docker compose run web bin/rails db:migrate RAILS_ENV=development
	docker compose up
	echo "http://localhost:3000/api-docs/index.html / http://localhost:3000/"


# git clone https://PAT@github.com/saifkhan192/ruby-on-rails-api-with-swagger.git


setup-git:
	git config user.name "Saifullah Khan"
	git config user.email saifkhan912@gmail.com


