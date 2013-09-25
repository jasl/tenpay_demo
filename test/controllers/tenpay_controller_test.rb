require 'test_helper'

class TenpayControllerTest < ActionController::TestCase
  test "should get notify" do
    get :notify
    assert_response :success
  end

  test "should get callback" do
    get :callback
    assert_response :success
  end

end
