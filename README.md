# Rails Templates

Quickly generate a rails app [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).

## Templates with Bootstrap.

### Minimal

Get a minimal rails 5.1+ app ready to be deployed on Heroku with Bootstrap, Simple form and debugging gems.

```bash
rails new \
  --database postgresql \
  --webpack \
  --skip-test \
  -m https://raw.githubusercontent.com/maeldd/rails-templates/master/minimal.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

### Devise

Same as minimal **plus** a Devise install with a generated `User` model.

```bash
rails new \
  --database postgresql \
  --webpack \
  --skip-test \
  -m https://raw.githubusercontent.com/maeldd/rails-templates/master/devise.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

### React

Same as Devise **plus** a React install.

```bash
rails new \
  --database postgresql \
  --webpack \
  --skip-test \
  -m https://raw.githubusercontent.com/maeldd/rails-templates/master/devise.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Templates with Tailwind.

### Minimal

Get a minimal rails 5.1+ app ready to be deployed on Heroku with Tailwind, Simple form and debugging gems.

```bash
rails new \
  --database postgresql \
  --webpack \
  --skip-test \
  -m https://raw.githubusercontent.com/maeldd/rails-templates/master/minimal-tailwind.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

### Devise

Same as minimal **plus** a Devise install with a generated `User` model.

```bash
rails new \
  --database postgresql \
  --webpack \
  --skip-test \
  -m https://raw.githubusercontent.com/maeldd/rails-templates/master/devise-tailwind.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

### React

Same as Devise **plus** a React install.

```bash
rails new \
  --database postgresql \
  --webpack \
  --skip-test \
  -m https://raw.githubusercontent.com/maeldd/rails-templates/master/devise.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## API Templates

```bash
rails new \
  --database postgresql \
  --api \
  --skip-test \
  --skip-action-text \
  --skip-sprockets \
  --skip-javascript \
  --skip-webpack-install \
  -m https://raw.githubusercontent.com/maeldd/rails-templates/master/devise-api.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```
