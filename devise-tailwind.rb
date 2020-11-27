run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# GEMFILE
########################################
inject_into_file 'Gemfile', before: 'group :development, :test do' do
  <<~RUBY
    gem 'devise'

    gem 'autoprefixer-rails'
    gem 'font-awesome-sass'
    gem 'simple_form'
  RUBY
end

inject_into_file 'Gemfile', after: 'group :development, :test do' do
  <<-RUBY
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'dotenv-rails'
  RUBY
end

gsub_file('Gemfile', /# gem 'redis'/, "gem 'redis'")

# Assets
########################################
run 'rm -rf app/assets/stylesheets/application.css'
run 'rm -rf vendor'
run "mkdir -p app/javascript/stylesheets"
run "mkdir -p app/javascript/stylesheets/components"
run "mkdir -p app/javascript/stylesheets/images"
run "mkdir -p app/javascript/stylesheets/images/icons"

run 'curl -L https://raw.githubusercontent.com/maeldd/rails-templates/master/tailwindcss/application.scss -o application.scss -s && mv application.scss app/javascript/stylesheets'
run 'curl -L https://raw.githubusercontent.com/maeldd/rails-templates/master/tailwindcss/tailwind.config.js -o tailwind.config.js -s && mv tailwind.config.js app/javascript/stylesheets'
run 'curl -L https://raw.githubusercontent.com/maeldd/rails-templates/master/tailwindcss/assets/stylesheets/application.scss -o application.scss -s && mv application.scss app/assets/stylesheets'

run 'curl -L https://raw.githubusercontent.com/maeldd/rails-templates/master/tailwindcss/components/_buttons.scss -o _buttons.scss -s && mv _buttons.scss app/javascript/stylesheets/components'
run 'curl -L https://raw.githubusercontent.com/maeldd/rails-templates/master/tailwindcss/components/_forms.scss -o _forms.scss -s && mv _forms.scss app/javascript/stylesheets/components'

run 'curl -L https://raw.githubusercontent.com/maeldd/rails-templates/master/tailwindcss/images/icons/checkmark.svg -o checkmark.svg -s && mv checkmark.svg app/javascript/stylesheets/images/icons'

# Dev environment
########################################
gsub_file('config/environments/development.rb', /config\.assets\.debug.*/, 'config.assets.debug = false')

# Layout
########################################
if Rails.version < "6"
  scripts = <<~HTML
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload', defer: true %>
        <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
  HTML
  gsub_file('app/views/layouts/application.html.erb', "<%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>", scripts)
end
gsub_file('app/views/layouts/application.html.erb', "<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>", "<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload', defer: true %>")
style = <<~HTML
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
      <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
      <%= stylesheet_pack_tag  'application', media: 'all', 'data-turbolinks-track': 'reload' %>
HTML
gsub_file('app/views/layouts/application.html.erb', "<%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>", style)

# Flashes
########################################
file 'app/views/shared/_flashes.html.erb', <<~HTML
  <% if notice %>
    <div class="bg-green-500">
      <div class="container px-2 py-4 mx-auto font-sans font-medium text-center text-white"><%= notice %></div>
    </div>
  <% end %>
  <% if alert %>
    <div class="bg-red-500">
      <div class="container px-2 py-4 mx-auto font-sans font-medium text-center text-white"><%= alert %></div>
    </div>
  <% end %>
HTML

run 'curl -L https://raw.githubusercontent.com/maeldd/rails-templates/master/tailwindcss/views/_navbar.html.erb > app/views/shared/_navbar.html.erb'

inject_into_file 'app/views/layouts/application.html.erb', after: '<body>' do
  <<-HTML

    <%= render 'shared/navbar' %>
    <%= render 'shared/flashes' %>
  HTML
end

# README
########################################
markdown_file_content = <<-MARKDOWN
Rails app generated with [maeldd/rails-templates](https://github.com/maeldd/rails-templates).
MARKDOWN
file 'README.md', markdown_file_content, force: true

# Generators
########################################
generators = <<~RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.test_framework :test_unit, fixture: false
  end
RUBY

environment generators

########################################
# AFTER BUNDLE
########################################
after_bundle do
  # Generators: db + simple form + pages controller
  ########################################
  rails_command 'db:drop db:create db:migrate'
  generate('simple_form:install')
  generate(:controller, 'pages', 'home', '--skip-routes', '--no-test-framework')

  # Routes
  ########################################
  route "root to: 'pages#home'"

  # Git ignore
  ########################################
  append_file '.gitignore', <<~TXT
    # Ignore .env file containing credentials.
    .env*
    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT

  # Devise install + user
  ########################################
  generate('devise:install')
  generate('devise', 'User')

  # App controller
  ########################################
  run 'rm app/controllers/application_controller.rb'
  file 'app/controllers/application_controller.rb', <<~RUBY
    class ApplicationController < ActionController::Base
    #{  "protect_from_forgery with: :exception\n" if Rails.version < "5.2"}  before_action :authenticate_user!
    end
  RUBY

  # migrate + devise views
  ########################################
  rails_command 'db:migrate'
  generate('devise:views')

  # Pages Controller
  ########################################
  run 'rm app/controllers/pages_controller.rb'
  file 'app/controllers/pages_controller.rb', <<~RUBY
    class PagesController < ApplicationController
      skip_before_action :authenticate_user!, only: [ :home ]

      def home
      end
    end
  RUBY

  # Environments
  ########################################
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: 'development'
  environment 'config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }', env: 'production'

  # Webpacker / Yarn
  ########################################
  # Until all the plugin are on postcss@8 we need to use tailwindcss@compat to be complatible with postcss@7 plugin
  run "yarn add tailwindcss@compat postcss@^7 autoprefixer@^9"
  run "yarn add @fullhuman/postcss-purgecss"
  append_file 'app/javascript/packs/application.js', <<~JS


    // ----------------------------------------------------
    // Note: ABOVE IS RAILS DEFAULT CONFIGURATION
    // WRITE YOUR OWN JS STARTING FROM HERE 👇
    // ----------------------------------------------------

    // External imports

    // Internal imports, e.g:
    // import { initSelect2 } from '../components/init_select2';
    import "stylesheets/application"

    document.addEventListener('turbolinks:load', () => {
      // Call your functions here, e.g:
      // initSelect2();
    });
  JS

  inject_into_file 'config/webpack/environment.js', before: 'module.exports' do
    <<~JS
      const webpack = require('webpack');
      // Preventing Babel from transpiling NodeModules packages
      environment.loaders.delete('nodeModules');
      // Bootstrap 4 has a dependency over jQuery & Popper.js:

    JS
  end

  run "rm postcss.config.js"
  run 'curl -L https://raw.githubusercontent.com/maeldd/rails-templates/master/tailwindcss/postcss.config.js -o postcss.config.js -s'

  # Dotenv
  ########################################
  run 'touch .env'

  # Rubocop
  ########################################
  run 'curl -L https://raw.githubusercontent.com/maeldd/rails-templates/master/.rubocop.yml -o .rubocop.yml -s'

  # Git
  ########################################
  git add: '.'
  git commit: "-m 'Initial commit with devise template from https://github.com/maeldd/rails-templates'"

  # Fix puma config
  gsub_file('config/puma.rb', 'pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }', '# pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }')
end
