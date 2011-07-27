require 'test_helper'

class AnswersHelperTest < ActionView::TestCase
  context "invoking answer_delimiter method" do
    should "return html_safe string" do
      assert answer_delimiter.html_safe?
    end
  end
end
