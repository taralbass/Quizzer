require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  context "the show_path_helper method" do
    should "return the correct helper for an object" do
      object = Object.new
      assert_equal :object_path, show_path_helper(object)
    end
  end
  
  context "the edit_path_helper method" do
    should "return the correct helper for an object" do
      object = Object.new
      assert_equal :edit_object_path, edit_path_helper(object)
    end
  end

  context "the substitute_html_breaks method" do
    should "substitute html breaks for newlines" do
      assert_equal "foo<br>bar", substitute_html_breaks("foo\nbar")
    end

    should "escape string" do
      assert_equal "foo&lt;&gt;bar", substitute_html_breaks("foo<>bar")
    end

    should "return html_safe string" do
      assert substitute_html_breaks("foo<>bar").html_safe?
    end
  end

  context "the pluralize_based_on_count" do
    should "pluralize if count is 0" do
      assert_equal "questions", pluralize_based_on_count("question", 0)
    end

    should "pluralize if count is 2" do
      assert_equal "questions", pluralize_based_on_count("question", 2)
    end

    should "not pluralize if count is 1" do
      assert_equal "question", pluralize_based_on_count("question", 1)
    end
  end

  context "invoking link_delimiter method" do
    should "return html_safe string" do
      assert link_delimiter.html_safe?
    end
  end
end
