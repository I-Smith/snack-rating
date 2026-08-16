class ApplicationController < ActionController::Base
  before_action :require_login

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def require_login
    authenticate_or_request_with_http_basic("Snack Vault") do |u, p|
      u == ENV["SNACK_APP_USER"] && p == ENV["SNACK_APP_PASSWORD"]
     end
  end
end
