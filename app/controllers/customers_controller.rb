class CustomersController < ApplicationController
  before_action :set_customer, only: [:show]

  def show
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end
end
