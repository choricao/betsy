require "test_helper"

describe ProductsController do

  describe "index" do

    it 'displays all products' do

      get products_path
      must_respond_with :success

    end

    it 'succeeds with a category ID as a parameter' do

      @category = categories(:category_1)
      # Product.all.count.must_be :>, 0
      # Category.all.count.must_be :>, 0

      get category_products_path(@category.id)
      must_respond_with :success

    end

    it 'will display all products for a specific user' do

      #Arrange
      @user_2 = users(:user_2)

      #Act
      get user_products_path(@user_2.id)

      #Assert
      must_respond_with :success
      #how to get the specific category to return.
    end

  end

  describe 'New' do

    # PASSING
    it 'will display a new product form' do

      @user_2 = users(:user_2)
      login(@user_2)
      get new_user_product_path(users(:user_1).id)
      must_respond_with :success
    end
  end

  describe 'Create' do

    #ALL CREATE PASSING

    before do
      @user_1 = users(:user_1)
    end

    it 'will create a new valid product for a user' do

      #Arrange

      login(@user_1)
      session[:user_id].must_equal @user_1.id
      before_count = Product.all.count

      #Act
      post user_products_path(@user_1.id),
      params: {
        product: {
          name: "A Product",
          is_active: true,
          description: "ldkfjsldkfj",
          price: 111,
          photo_url: nil,
          stock: 12,
          user_id: users(:user_1).id
          }
        }

      new_product = Product.last
      after_count = Product.all.count
      new_product.name.must_equal "A Product"
      new_product.is_active.must_equal true
      # new_product.price.must_equal 11
      #model method multiplies by 100 ?
      new_product.photo_url.must_equal nil
      new_product.stock.must_equal 12
      new_product.user_id.must_equal @user_1.id


      flash[:result_text].must_equal "A Product has been successfully created!"

      must_respond_with :redirect
      must_redirect_to product_path(Product.last.id)

    end

    it 'will not create a product with invalid inputs' do

      #Arrange
      @user_2 = users(:user_2)

      #Act
        proc {
          post user_products_path(users(:user_2).id),
          params:{
            product:{ name: "",
              is_active: products(:product_2).is_active,
              description: products(:product_2).description,
              price: products(:product_2).price,
              photo_url: products(:product_2).photo_url,
              stock: products(:product_2).stock,
              user_id: users(:user_2).id}
              }
        }.wont_change 'Product.count'
        # must_respond_with :bad_request
    end

    it 'will not allow a user to create a product for another user ID' do

      #Arrange
      login(@user_1)
      session[:user_id].must_equal @user_1.id

      #Act

      proc {
        post user_products_path(users(:user_2).id),
        params:{
          product:{ name: "",
            is_active: products(:product_2).is_active,
            description: products(:product_2).description,
            price: products(:product_2).price,
            photo_url: products(:product_2).photo_url,
            stock: products(:product_2).stock,
            user_id: users(:user_1).id}
            }
      }.wont_change 'Product.count'
      must_respond_with :bad_request

    end
  end

  describe 'Show' do

    # ALL SHOW PASSING

    it "will display a product's detail page, even for a logged-out user" do

      get product_path(products(:product_4).id)
      must_respond_with :success

      #an existing yml object is showing nil?
    end

    it "will render 404 not found for a product that does not exist, even for a logged-out user" do

      non_existant_id = -100001
      get product_path(non_existant_id)
      must_respond_with :not_found

    end
  end

  describe 'Edit' do

    it 'will provide the populated fields necessary for editing for a logged-in user for their own product' do

      #Passing

      #Arrange
      @user_1 = users(:user_1)
      login(@user_1)

      @product_1 = products(:product_1)
      @product_1.user_id = @user_1.id
      @product_1.save

      #Validate test

      modified_1 = Product.find_by(user_id: @user_1.id)
      modified_1.name.must_equal "product_1"

      #Act

      get edit_product_path(@product_1.id)
      must_respond_with :success

      #update to confirm all fields are passing in correctly#
    end

    it 'will NOT provide the populated fields necessary for editing for editing a product, even for a logged-in user, for a product that does not belong to that user' do

      #PASSING
        #Arrange
        @user_4 = users(:user_4)
        login(@user_4)

        @user_1 = users(:user_1)

        @product_6 = products(:product_6)
        @product_6.user_id = @user_1.id

        #Validate test
        @user_4.id.wont_equal @product_6.user_id

        get edit_product_path(@product_6.id)

        flash[:result_text].must_equal "Merchants are only allowed to modify their own products"

        #update to confirm all fields are passing in correctly#
    end

    it 'will NOT provide the populated fields necessary for editing for a person who is not logged in' do

        #PASSING
        #Arrange
        @user_2 = users(:user_2)
        login(@user_2)

        delete logout_path

        @product_2 = products(:product_2)
        @product_2.user_id.must_equal @user_2.id

        modified_2 = Product.find_by(user_id: @user_2.id)

        #Validate test
        modified_2.id.must_equal @product_2.id

        #Act

        get edit_product_path(@product_2.id)

        #Assert
        # Provides appropriat error messages
        must_redirect_to github_login_path
    end



    it 'will render 404 not found for a request to edit a product that does not exist, even for a logged in user' do

      #PASSING
      #Arrange
      @user_1 = users(:user_1)
      login(@user_1)

      non_existant_id = 2

      #Validate test
      Product.find_by(id: non_existant_id).must_be_nil

      #Act
      get edit_product_path(non_existant_id)

      #Assert
      must_respond_with :not_found
    end
  end

  describe 'Update' do

    it 'will allow a user to update an existing product' do

      #PASSING
      #Arrange

      @user_1 = users(:user_1)
      login(@user_1)

      @product_1 = products(:product_1)
      @product_1.user_id = @user_1.id



      proc  {patch product_path(products(:product_1).id), params:{
          product:{ name: "new product name",
            is_active: products(:product_1).is_active,
            description: products(:product_1).description,
            price: products(:product_1).price,
            photo_url: products(:product_1).photo_url,
            stock: products(:product_1).stock,
            user_id: users(:user_1).id }
        }}.wont_change 'Product.count'
        must_respond_with :redirect
        must_redirect_to product_path(products(:product_1))

      end

    it 'will render 404 if the product being requested to update does not exist' do

      #PASSING
      @user_1 = users(:user_1)
      login(@user_1)

      non_existant_id = -100001
      patch product_path(non_existant_id)
      must_respond_with :not_found

    end

    it "will not allow other users to update another user's product" do

      #PASSING

      proc  {patch product_path(products(:product_1)), params:{
          product:{ name: "new product name",
            is_active: products(:product_2).is_active,
            description: products(:product_2).description,
            price: products(:product_2).price,
            photo_url: products(:product_2).photo_url,
            stock: products(:product_2).stock,
            user_id: users(:user_1).id }
        }}.wont_change 'Product.count'
        must_respond_with :redirect
    end

    it "will not allow a user to update a product with invalid data" do

      #PASSING

      @user_1 = users(:user_1)
      login(@user_1)

      proc  {patch product_path(products(:product_1).id), params:{
          product:{ name: "",
            is_active: products(:product_1).is_active,
            description: products(:product_1).description,
            price: products(:product_1).price,
            photo_url: products(:product_1).photo_url,
            stock: products(:product_1).stock,
            user_id: users(:user_1).id }
        }}.wont_change 'Product.count'

        must_respond_with :bad_request
    end

      # it "will not allow a user to modify the amount of stock" do
      #
      # end


  end

  describe 'Set Status' do

    before do

      @user_1 = users(:user_1)
      login(@user_1)

    end

    it "an existing product's status can be updated" do

      #PASSING

      login(@user_1)

      @product_1 = products(:product_1)

      put product_set_status_path(@product_1.id)

      must_respond_with :found

    end

    it 'a product that does not exist will be sent a 404' do

      #PASSING

        non_existant_id = -100001
        put product_set_status_path(non_existant_id)
        must_respond_with :not_found
    end

  end
end
