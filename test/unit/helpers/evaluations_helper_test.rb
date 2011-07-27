require 'test_helper'

include AnswersHelper

class EvaluationsHelperTest < ActionView::TestCase
  context "the evaluation_answer_delimiter method" do
    context "when answer count is 1" do
      should "indicate non_numeric class" do
        assert_match /class=\"delimiter non_numeric\"/, evaluation_answer_delimiter(1, 1)
      end

      should "use answer_delimiter" do
        self.expects(:answer_delimiter)
        evaluation_answer_delimiter(1, 1)
      end
    end

    context "when answer count is more than 1" do
      should "indicate numeric class" do
        assert_match /class=\"delimiter numeric\"/, evaluation_answer_delimiter(5, 3)
      end

      should "use user numeric delimiter" do
        self.expects(:answer_delimiter).never
        assert_match /3\./, evaluation_answer_delimiter(5, 3)
      end
    end

    should "return an html_safe string" do
      assert evaluation_answer_delimiter(1, 1).html_safe?
    end
  end
end
