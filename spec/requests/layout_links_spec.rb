require 'spec_helper'

describe "LayoutLinks" do

  it "should have a home page at '/'" do
      get '/'
      response.should have_selector('title', :content => "Home" )
  end

  it "should have a contact page at '/contact'" do
      get '/contact'
      response.should have_selector('title', :content => "Contact" )
  end

  it "should have an about page at '/about'" do
      get '/about'
      response.should have_selector('title', :content => "About" )
  end

  it "should have a help page at '/help'" do
      get '/help'
      response.should have_selector('title', :content => "Help" )
  end

  it "should have a sign up page at '/signup'" do
      get '/signup'
      response.should have_selector('title', :content => "Sign up" )
  end

  describe "when not signed in" do
    
    it "should display the sign in link" do
      visit root_path
      response.should have_selector("a", :href => signin_path, :content => "Sign in")
    end
    
  end

  describe "when signed in" do
    
    before(:each) do
      @user = Factory(:user)
      integration_sign_in(@user)
    end
    
    it "should display the sign out link" do
      visit root_path
      response.should have_selector("a", :href => signout_path, :content => "Sign out")
    end
    
    it "should display a profile link" do
      visit root_path
      response.should have_selector("a", :href => user_path(@user), :content => "Profile")
    end
    
    it "should display the users link" do
      visit root_path
      response.should have_selector("a", :href => users_path, :content => "Users")
    end
    
  end  
  
end
