class LogsController < ApplicationController
  AUTH_CONFIG = YAML.load_file("#{Rails.root}/config/auth_config.yml")[Rails.env]
  if AUTH_CONFIG['perform_authentication']
    http_basic_authenticate_with name: AUTH_CONFIG['username'], password: AUTH_CONFIG['password']
  end

  def index
  end

end
