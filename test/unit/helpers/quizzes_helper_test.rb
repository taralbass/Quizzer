require 'test_helper'

class QuizzesHelperTest < ActionView::TestCase
  context "the estimate_rows_for_text_area method" do
    should "return the number of rows if all rows are shorter than cols" do
      assert_equal 4, estimate_rows_for_text_area("aa\nbb\ncc\ndd", 5)
    end

    should "add an additional rows for lines over longer than cols" do
      assert_equal 7, estimate_rows_for_text_area("aaaaa\nbbbbbb\ncc\nddddddddddd", 5)
    end

    should "add an additional rows for blank lines" do
      assert_equal 3, estimate_rows_for_text_area("aa\n\nbb", 5)
    end

    should "return 3 for nil string value" do
      assert_equal 3, estimate_rows_for_text_area(nil, 5)
    end
  end
end
