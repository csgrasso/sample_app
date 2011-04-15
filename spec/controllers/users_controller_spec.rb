require 'spec_helper'

describe UsersController do
  render_views
  
  describe "GET 'index'" do
    
    describe "for non-signed in users" do
      
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/
      end
    
    end
    
    describe "for signed in users" do
      
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @users = [@user]
        30.times do
          @users << Factory(:user, :email => Factory.next(:email))
        end
        
      end
      
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end
      
      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end
      
      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2", :content => "2")
        response.should have_selector("a", :href => "/users?page=2", :content => "Next")
      end
    
    end
    
  end
        
  describe "GET 'new'" do

    it "should be successful" do
      get :new
      response.should be_success
    end
  
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign up")
    end

  end

  describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
    end

    it "should be successful" do
      get :show, :id => @user.id
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user.id
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, :id => @user #same as @user.id
      response.should have_selector("title", :content => @user.name)
    end

    it "should include the users name" do
      get :show, :id => @user #same as @user.id
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user #same as @user.id
      response.should have_selector("h1>img", :class => "gravatar")
    end

  end

  describe "GET 'edit'" do
    before (:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end
    
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector(:title, :content => "Edit user")
    end
    
    it "should have a link to change the gravataar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url, :content => "change")
    end
    
  end
  
  describe "POST 'create'" do
    
    describe "failure" do

      before(:each) do
        @attr = {:name => "", :email => "", :password => "", :password_confirmation => ""}
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end

    end #end failure

    describe "success" do

      before(:each) do
        @attr = {:name => "Chris Grasso",
                 :email => "csgrasso@gmail.com",
                 :password => "foobar",
                 :password_confirmation => "foobar"}
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to the sample app/i
      end

      it "should be signed in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
      
    end #end success

  end

  describe "PUT 'update'" do
    
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    describe "failure" do
  
      before(:each) do
        @attrs = {:name => "", :email => "", :password => "", :password_confirmation => ""}
      end
      
      it "should render the edit page" do
        put :update, :id => @user, :user => @attrs
        response.should render_template('edit')
      end
      
      it "should have the right title" do
        put :update, :id => @user, :user => @attrs
        response.should have_selector("title", :content => "Edit user")
      end
      
    end
    
    describe "success" do
  
      before(:each) do
        @attrs = {:name => "new user", :email => "abc@gmail.com", :password => "barbaz", :password_confirmation => "barbaz"}
      end
      
      it "should update the users attributes" do
        put :update, :id => @user, :user => @attrs
        @user.reload
        @user.name.should == @attrs[:name]
        @user.email.should == @attrs[:email]
      end
    
      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attrs
        response.should redirect_to(user_path(@user))
      end
      
      it "should have a successful flash message" do
        put :update, :id => @user, :user => @attrs
        flash[:success].should =~ /updated/
      end
    
    end
    
  end
  
  describe "DELETE 'destroy'" do
  
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as non-signed in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end
    
    describe "as admin user" do

      before(:each) do
        admin = Factory(:user, :email => "admin@gmail.com", :admin =>true)
        test_sign_in(admin)
      end
      
      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)        
      end
      
      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
    
  end
  
  describe "authentication of edit/update pages" do

    before(:each) do
      @user = Factory(:user)
    end
    
    describe "for non-signed in users" do
      
    describe  "for signed in users" do
      
      before(:each) do
        wrong_user = Factory(:user, :email => "differentemail@user.com")
        test_sign_in(wrong_user)
      end
      
      it "should require matching users for edit" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      
      it "should require matching users for update" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
      
      
    end  
      
            
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end
      
      it "should deny access to update" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
            
    end
  end
  
end
