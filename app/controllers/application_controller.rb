class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods  
  helper_method :resource, :current_user

  before_action :authenticate!

  rescue_from AuthorizationError do
    head :unauthorized
  end

  rescue_from ActionController::ParameterMissing do |exception|
    @exception = exception

    render :exception, status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordInvalid, ActiveModel::StrictValidationFailed do
    render :errors, status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotFound do
    @exception = 'Not Found'

    render :exception, status: :not_found
  end

  def create
    render :errors unless resource.save
  end

  def current_user
    authenticate_or_request_with_http_token do |token, options|
      @current_user ||= Session.find_by(auth_token: token).user
    end
  end

  private
  def authenticate!
    current_user || raise(AuthorizationError)
  end
end
