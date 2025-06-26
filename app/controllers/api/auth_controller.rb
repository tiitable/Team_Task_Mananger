class Api::AuthController < ApplicationController
  before_action :ensure_api_authentication, only: [:current_user_info, :update_profile]
  protect_from_forgery with: :null_session
  respond_to :json

  def sign_up
    user = User.new(user_params)
    
    if user.save
      render json: {
        status: 'success',
        message: 'User created successfully',
        user: user_response(user)
      }, status: :created
    else
      render json: {
        status: 'error',
        message: 'User creation failed',
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def sign_in
    user = User.find_by(email: params[:email])
    
    if user&.valid_password?(params[:password])
      # Generate JWT token manually for now
      token = JWT.encode(
        { 
          user_id: user.id, 
          exp: 24.hours.from_now.to_i 
        }, 
        Rails.application.credentials.secret_key_base
      )
      
      response.headers['Authorization'] = "Bearer #{token}"
      
      render json: {
        status: 'success',
        message: 'Signed in successfully',
        user: user_response(user),
        token: token  # Also include in response body for easier testing
      }, status: :ok
    else
      render json: {
        status: 'error',
        message: 'Invalid email or password'
      }, status: :unauthorized
    end
  end

  def sign_out
    # JWT token will be automatically revoked by devise-jwt
    render json: {
      status: 'success',
      message: 'Signed out successfully'
    }, status: :ok
  end

  def current_user_info
    if current_user
      render json: {
        status: 'success',
        user: user_response(current_user)
      }, status: :ok
    else
      render json: {
        status: 'error',
        message: 'Not authenticated'
      }, status: :unauthorized
    end
  end

  def update_profile
    Rails.logger.info "Update profile called with params: #{params}"
    Rails.logger.info "Current user: #{current_user&.id}"
    Rails.logger.info "Profile params: #{profile_params}"
    
    if current_user
      # Log avatar info if present
      if profile_params[:avatar]
        Rails.logger.info "Avatar update - length: #{profile_params[:avatar].length}"
        Rails.logger.info "Avatar starts with: #{profile_params[:avatar][0..50]}"
      end
      
      if current_user.update(profile_params)
        Rails.logger.info "Profile updated successfully for user #{current_user.id}"
        Rails.logger.info "User avatar after update: #{current_user.avatar.present? ? 'present' : 'nil'}"
        render json: {
          status: 'success',
          message: 'Profile updated successfully',
          user: user_response(current_user)
        }
      else
        Rails.logger.error "Profile update failed: #{current_user.errors.full_messages}"
        render json: {
          status: 'error',
          message: 'Profile update failed',
          errors: current_user.errors.full_messages
        }, status: :unprocessable_entity
      end
    else
      Rails.logger.error "User not authenticated in update_profile"
      render json: {
        status: 'error',
        message: 'User not authenticated'
      }, status: :unauthorized
    end
  end

  private

  def ensure_api_authentication
    Rails.logger.info "ensure_api_authentication called, @current_user: #{@current_user&.id}"
    unless current_user
      Rails.logger.error "API authentication failed in ensure_api_authentication"
      render json: { status: 'error', message: 'Authentication required' }, status: :unauthorized
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :nickname, :avatar)
  end

  def profile_params
    params.require(:user).permit(:nickname, :avatar)
  end

  def user_response(user)
    {
      id: user.id,
      email: user.email,
      nickname: user.nickname,
      avatar: user.avatar_url,
      has_avatar: user.has_avatar?,
      created_at: user.created_at
    }
  end
end