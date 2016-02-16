require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
  	ActionMailer::Base.deliveries.clear
  	@user = users(:michael)
  end

  test "password resets" do
  	get new_password_reset_path
  	assert_template 'password_resets/new'
  	# with invalid email
  	post password_resets_path, password_reset: { email: "" }
  	assert_not flash.empty?
  	assert_template 'password_resets/new'
  	# with valid email
  	post password_resets_path, password_reset: { email: @user.email }
  	assert_not_equal @user.reset_digest, @user.reload.reset_digest
  	assert_equal 1, ActionMailer::Base.deliveries.size
  	assert_not flash.empty?
  	assert_redirected_to root_url
  	# check with password reset form
  	user = assigns(:user)
  	# wrong email in form
  	get edit_password_reset_path(user.reset_token, email: "")
  	assert_redirected_to root_url
  	# Inactive use
  	user.toggle!(:activated)
  	get edit_password_reset_path(user.reset_token, email: user.email)
  	assert_redirected_to root_url
  	user.toggle!(:activated)
  	# wrong token with right email
  	get edit_password_reset_path('wrong token', email: user.email)
  	assert_redirected_to root_url
  	# right email with right token
  	get edit_password_reset_path(user.reset_token, email: user.email)
  	assert_template 'password_resets/edit'
  	assert_select "input[name=email][type=hidden][value=?]", user.email
  	# Invalid password and confirmation
  	patch password_reset_path(user.reset_token), 	email: user.email,
  																								user: { password: "abscer",
  																												password_confirmation: "wdsdsda"}
  	assert_select "div#error_explanation"
  	# giving empty password
  	patch password_reset_path(user.reset_token), 	email: user.email,
  																								user: { password: "",
  																												password_confirmation: ""}
  	assert_select "div#error_explanation"
  	# valid password and confirmation
  	patch password_reset_path(user.reset_token), 	email: user.email,
  																								user: { password: "abcef1",
  																												password_confirmation: "abcef1" }
  	assert is_logged_in?
  	assert_not flash.empty?
  	assert_redirected_to user
  end

end