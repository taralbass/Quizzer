require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  context "an Answer instance" do
    should belong_to(:question)

    should allow_mass_assignment_of(:question_id)
    should allow_mass_assignment_of(:text)

    should have_readonly_attribute(:question_id)

    should validate_presence_of(:question)
    should validate_presence_of(:text)

    should ensure_length_of(:text).is_at_most(50)

    context "" do
      setup do
        Factory :answer
      end

      should validate_uniqueness_of(:text).scoped_to(:question_id)
    end
  end
end
