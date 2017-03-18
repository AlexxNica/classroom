# frozen_string_literal: true
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    memcachedcloud_servers = ENV.fetch('MEMCACHEDCLOUD_SERVERS', 'http://locacalhost:11211').split(',')

    dalli_store_config = {
      namespace:  'CLASSROOM_DEVELOPMENT',
      expires_in: (ENV['REQUEST_CACHE_TIMEOUT'] || 30).to_i.minutes,
      pool_size:  (ENV['RAILS_MAX_THREADS'] || 5).to_i
    }

    config.cache_store = :dalli_store, memcachedcloud_servers, dalli_store_config

    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }

    config.peek.adapter = :memcache, {
      client: Dalli::Client.new(memcachedcloud_servers, dalli_store_name_and_password)
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
