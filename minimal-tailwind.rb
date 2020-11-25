run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# GEMFILE
########################################
inject_into_file 'Gemfile', before: 'group :development, :test do' do
  <<~RUBY
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

# Procfile
########################################
file 'Procfile', <<~YAML
  web: bundle exec puma -C config/puma.rb
YAML

# Assets
########################################
run 'rm -rf app/assets/stylesheets/application.css'
run 'rm -rf vendor'
run "mkdir -p app/javascript/stylesheets"
run "mkdir -p app/javascript/stylesheets/components"

run 'curl -L https://github.com/maeldd/rails-templates/tree/master/tailwindcss/application.scss -o application.scss -s && mv application.scss app/javascript/stylesheets'
run 'curl -L https://github.com/maeldd/rails-templates/tree/master/tailwindcss/tailwind.config.js -o tailwind.config.js -s && mv tailwind.config.js app/javascript/stylesheets'

run 'curl -L https://github.com/maeldd/rails-templates/tree/master/tailwindcss/assets/stylesheets/application.scss -o application.scss -s && mv application.scss app/assets/stylesheets'
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
else
  gsub_file('app/views/layouts/application.html.erb', "<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>", "<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload', defer: true %>")
end

gsub_file('app/views/layouts/application.html.erb', "<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>", "<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload', defer: true %>")
style = <<~HTML
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
      <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
      <%= stylesheet_pack_tag  'application', media: 'all', 'data-turbolinks-track': 'reload' %>
HTML
gsub_file('app/views/layouts/application.html.erb', "<%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>", style)

# README
########################################
markdown_file_content = <<~MARKDOWN
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

  # Webpacker / Yarn
  ########################################
  run "yarn add tailwindcss"
  run "yarn add @fullhuman/postcss-purgecss"
  append_file 'app/javascript/packs/application.js', <<~JS
    // ----------------------------------------------------
    // Note: ABOVE IS RAILS DEFAULT CONFIGURATION
    // WRITE YOUR OWN JS STARTING FROM HERE 👇
    // ----------------------------------------------------

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

    JS
  end

  run "rm postcss.config.js"
  run 'curl -L https://github.com/maeldd/rails-templates/tree/master/tailwindcss/postcss.config.js -o postcss.config.js -s'

  # Dotenv
  ########################################
  run 'touch .env'

  # Rubocop
  ########################################
  run 'curl -L https://github.com/maeldd/rails-templates/blob/master/.rubocop.yml -o .rubocop.yml -s'

  # Git
  ########################################
  git add: '.'
  git commit: "-m 'Initial commit with minimal tailwind template from https://github.com/maeldd/rails-templates'"

  # Fix puma config
  gsub_file('config/puma.rb', 'pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }', '# pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }')
end
