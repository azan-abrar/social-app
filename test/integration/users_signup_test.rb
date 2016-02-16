require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest	
  
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invlaid signup information" do
  	get signup_path
  	assert_no_difference 'User.count' do
  		post users_path, user: { name: "",
  														 email: "invalid@user",
  														 password: "foobar",
  														 password_confirmation: "bar"}
		end
		assert_template 'users/new'
		assert_select 'div#<CSS id for error explanation>'
    assert_select 'div.<CSS class for field with error>'
  end

  test "valid signup information with account activation" do
  	get signup_path
  	assert_difference 'User.count', 1 do
  		post users_path, user: { name: "Example User",
  														   email: "valid@user.com",
  														   password: "test123",
  														   password_confirmation: "test123"}
  	end

    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # log in without activation
    log_in_as(user)
    assert_not is_logged_in?
    # log in with wrong activation token
    get edit_account_activation_path("invalid_token")
    assert_not is_logged_in?
    # log in with wrong activation email
    get edit_account_activation_path(user.activation_token, email: "wrong_email")
    assert_not is_logged_in?
    # log in with valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
  	assert_template 'users/show'
    assert_not flash.empty?
  	assert is_logged_in?    
  end

end
