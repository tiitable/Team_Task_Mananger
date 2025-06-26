class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user_from_token, if: :api_request?
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
  end
  
  private
  
  def api_request?
    request.path.starts_with?('/api/')
  end
  
  def authenticate_user_from_token
    Rails.logger.info "authenticate_user_from_token called, api_request?: #{api_request?}"
    return unless api_request?
    
    auth_header = request.headers['Authorization']
    Rails.logger.info "Auth header: #{auth_header}"
    return unless auth_header&.start_with?('Bearer ')
    
    token = auth_header.split(' ').last
    Rails.logger.info "Token: #{token[0..20]}..." # Only log first 20 chars for security
    
    begin
      decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
      user_id = decoded_token[0]['user_id']
      @current_user = User.find(user_id)
      @api_authenticated_user = @current_user  # Store in a separate variable as backup
      Rails.logger.info "Successfully authenticated user: #{@current_user.id}, @current_user set to: #{@current_user.inspect}"
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT decode error: #{e.message}"
      @current_user = nil
      @api_authenticated_user = nil
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "User not found: #{e.message}"
      @current_user = nil
      @api_authenticated_user = nil
    end
  end
  
  def current_user
    if api_request?
      Rails.logger.info "current_user called for API request, @current_user: #{@current_user&.id}, @api_authenticated_user: #{@api_authenticated_user&.id}"
      Rails.logger.info "current_user call stack: #{caller[0..2].join(' -> ')}"
      
      # If @current_user is nil but @api_authenticated_user exists, restore it
      if @current_user.nil? && @api_authenticated_user
        Rails.logger.warn "Restoring @current_user from @api_authenticated_user"
        @current_user = @api_authenticated_user
      end
      
      return @current_user
    else
      return super
    end
  end
  
  def authenticate_user!
    Rails.logger.info "authenticate_user! called, api_request?: #{api_request?}, @current_user: #{@current_user&.id}"
    
    if api_request?
      unless @current_user
        Rails.logger.error "API authentication failed - @current_user is nil"
        render json: { status: 'error', message: 'Authentication required' }, status: :unauthorized
        return false
      end
      Rails.logger.info "API authentication successful for user: #{@current_user.id}"
      return true
    else
      return super
    end
  end
end
