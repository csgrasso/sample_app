require 'spec_helper'

describe "FriendlyForwardings" do
  
  it "should forward to the requested page after signin" do
    user = Factory(:user)
    visit edit_user_path(user)
    #the test automatically follows the redirect to the signin page (user is not signed in)
    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button
    #the test should automatically follow the redirect back to the originally requested page, the edit page
    response.should render_template('users/edit')
  end
    
end
