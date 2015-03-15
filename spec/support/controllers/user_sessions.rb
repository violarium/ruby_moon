# Sign in user for controller tests.
#
# @param user [User]
def controller_sign_in(user = nil)
  user = FactoryGirl.create(:user) if user.nil?
  @controller.send(:sign_in_user, user)
  user
end