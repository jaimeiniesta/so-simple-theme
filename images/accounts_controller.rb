class AccountsController < ApplicationController
  layout 'simple'
  before_action :authenticate_user!
end
