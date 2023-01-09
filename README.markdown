model_receiver
===============

This gem is written to work with rails 3+ or sinatra applications using
activerecord.
Add/Update record through ActiveRecord according with received model attributes.

Quick Start For Sinatra Applications
------------------------------------

Add the dependency to your Gemfile

```ruby
gem "model_receiver", git: "https://github.com/hexopay/model_receiver_ecomm.git"
```

Install it...

```ruby
bundle
```

You probably want to password protect the interface, an easy way is to add something like this:

```ruby
require 'model_receiver'

module YourSinatra
  class ModelReceiverApp < ModelReceiver::App

    helpers do
      def protected_www
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Enter your user name and password")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        @auth ||=  ::Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials &&
          @auth.credentials == ['login', 'password']
      end
    end

    before { protected_www }

  end
end
```

Add a route to your applications to `config.ru` file

```ruby
run Rack::URLMap.new({
  "/"               => YourSinatra::App,
  "/model_receiver" => YourSinatra::ModelReceiverApp
})
```

Quick Start For Rails 7 Applications
------------------------------------

Add the dependency to your Gemfile:

```ruby
gem "model_receiver", git: "https://github.com/hexopay/model_receiver_ecomm.git", branch: 'feature/DEV-29/allow-to-update-habtm-join-tables'
```

Install it:

```ruby
bundle
```

Add a route to your application for accessing the interface (`config/routes.rb`):

```ruby
match "/model_receiver" => ModelReceiver::App, :anchor => false
```

To password protect the interface you should add this to `config/initializers/model_receiver.rb`:

```ruby
ModelReceiver::App.use Rack::Auth::Basic do |username, password|
  username == Settings.sync_service.username && password == Settings.sync_service.password
end
```

Quick Start For Rails 3 Applications
------------------------------------

Add the dependency to your Gemfile

```ruby
gem "model_receiver", git: "https://github.com/hexopay/model_receiver_ecomm.git"
```

Install it...

```ruby
bundle
```

Add a route to your application for accessing the interface

```ruby
match "/model_receiver" => ModelReceiver::App, :anchor => false
```

You probably want to password protect the interface, an easy way is to add this to your `config.ru` file:

```ruby
if Rails.env.production?
  ModelReceiver::App.use Rack::Auth::Basic do |username, password|
    username == 'username' && password == 'password'
  end
end
```

Author
------

Mikhail Davidovich