require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest	
  
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

  test "valid signup information" do
  	get signup_path
  	assert_difference 'User.count', 1 do
  		post_via_redirect users_path, user: { name: "Example User",
  														   email: "valid@user.com",
  														   password: "test123",
  														   password_confirmation: "test123"}
  	end
  	assert_template 'users/show'
    assert_not flash.empty?
  	#assert is_logged_in?    
  end
  
end
