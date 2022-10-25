require 'test_helper'

class BasesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get bases_show_url
    assert_response :success
  end

end
