class ProductsController < ApplicationController

  def index
    @products = Product.all
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.user = User.find(params[:user_id])
#     if params[:user_id]
#       #want this to be a session id - to connect with a cart possibly?
# end
    if @product.save
      flash[:status] = :success
      flash[:result_text] = "#{@product.name} has been successfully created!"
      redirect_to product_path(@product.id)
    else
      flash[:status] = :failure
      flash[:result_text] = "Could not create this product."
      flash[:messages] = @product.errors.messages
      render :new, status: :bad_request
    end
    redirect_to
  end

  def show
    @product = Product.find_by(id: params[:id])
    @review = Review.new
  end

  def edit
  end

  def update
    @product = Product.new(product_params)
    if @product.save
      flash[:status] = :success
      flash[:result_text] = "#{@product.name} has been successfully updated!"
      redirect_to product_path(@product.id)
    else
      flash[:status] = :failure
      flash[:result_text] = "Update failed."
      flash[:messages] = @product.errors.messages
      render :edit, status: :bad_request
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :is_active, :description, :price, :photo_url, :stock, :user_id)
  end
end
