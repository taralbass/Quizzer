require 'test_helper'

class EvaluationsControllerTest < ActionController::TestCase
  context "on index" do
    should "raise ActionController::RoutingError" do
      assert_raises ActionController::RoutingError do
        get :index
      end
    end
  end

  context "on show" do
    setup do
      @evaluation = Factory :evaluation
      get :show, :id => @evaluation.id
    end
    
    should assign_to(:evaluation).with(@evaluation)
    should respond_with(:success)
    should render_with_layout(:application)
    should render_template(:show)
    should_not set_the_flash
    should respond_with_content_type(:html)
  end


  context "on new" do
    setup do
      @evaluation = Factory.build :evaluation, :quiz_id => 1, :parent_id => 123
      Evaluation.stubs(:new).returns(@evaluation)
      get :new, :evaluation => { :quiz_id => 1, :parent_id => 123 }
    end

    should assign_to(:evaluation).with(@evaluation)
    should respond_with(:success)
    should render_with_layout(:application)
    should render_template(:new)
    should_not set_the_flash
    should respond_with_content_type(:html)

    should "add hidden field tag for quiz_id" do
      assert_tag :input, :attributes => { :id => 'evaluation_quiz_id', :value => 1, :type => 'hidden' }
    end

    should "add hidden field tag for parent_id" do
      assert_tag :input, :attributes => { :id => 'evaluation_parent_id', :value => 123, :type => 'hidden' }
    end
  end

  context "on create" do
    context "with valid parameters" do
      setup do
        @evaluation = Factory.build :evaluation
        Evaluation.stubs(:new).with(@evaluation.attributes).returns(@evaluation)
      end

      context "" do
        setup do
          post :create, :evaluation => @evaluation.attributes
        end

        should_not set_the_flash
        should redirect_to("edit_evaluation_url") { edit_evaluation_url(@evaluation) }

        before_should "save the new evaluation" do
          @evaluation.expects(:save).returns(true)
          @controller.stubs(:edit_evaluation_url).returns('/some_path')
        end
      end
    end

    context "with invalid parameters" do
      setup do
        Evaluation.any_instance.stubs(:save).returns(false)
        post :create, :evaluation => Factory.build(:evaluation)
      end

      should redirect_to("root url") { root_url }
      should_not set_the_flash
    end
  end

  context "on edit" do
    setup do
      @evaluation = Factory :evaluation
      @evaluation.stubs(:randomized_question_ids).returns([2, 3, 1, 4])
      Evaluation.stubs(:find).with(@evaluation.id, anything).returns(@evaluation)
      get :edit, :id => @evaluation.id
    end

    should assign_to(:evaluation).with(@evaluation)
    should assign_to(:question_ids).with([2, 3, 1, 4])
    should respond_with(:success)
    should render_with_layout(:application)
    should render_template(:edit)
    should_not set_the_flash
    should respond_with_content_type(:html)

    should "add hidden field tag for completed" do
      assert_tag :input, :attributes => { :id => 'evaluation_completed', :value => true, :type => 'hidden' }
    end

    should "add data-question-ids attribute to #evaluation_in_progress" do
      assert_tag :div, :attributes => { :id => 'evaluation_in_progress', :'data-question-ids' => '[2,3,1,4]'}
    end
  end

  context "on update" do
    context "with a successful update" do
      setup do
        @evaluation = Factory :evaluation
        @evaluation.stubs(:update_attributes!).returns(true)
        Evaluation.stubs(:find).with(@evaluation.id, anything).returns(@evaluation)
      end

      context "with xhr request" do
        setup do
          xhr :put, :update, :id => @evaluation.id, :evaluation => { :completed => true }
        end

        should respond_with(:success)
        should_not set_the_flash
        should respond_with_content_type(:js)

        before_should "delegate to update_attriutes!" do
          @evaluation.expects(:update_attributes!).returns(true)
        end

        before_should "render nothing" do
          @controller.expects(:render).with(:nothing => true)
          @controller.expects(:render).with()
        end
      end

      context "with a non-xhr request" do
        setup do
          put :update, :id => @evaluation.id, :evaluation => { :completed => true }
        end

        should redirect_to("evaluation") { @evaluation }
        should_not set_the_flash

        before_should "delegate to update_attriutes!" do
          @evaluation.expects(:update_attributes!).returns(true)
        end
      end
    end
  end

  context "on pose_question" do
    setup do
      @question = Factory(:question)
      @evaluation = Factory :evaluation, :quiz => @question.quiz
    end

    context "with xhr request" do
      setup do
        xhr :get, :pose_question, :id => @evaluation.id, :question_id => @question.id
      end

      should assign_to(:evaluation).with(@evaluation)
      should assign_to(:question).with(@question)
      should respond_with(:success)
      should render_template(:pose_question)
      should_not render_with_layout(:application)
      should_not set_the_flash
      should respond_with_content_type(:js)
    end

    context "with non-xhr request" do
      setup do
        get :pose_question, :id => @evaluation.id, :question_id => @question.id
      end

      should redirect_to("root_url") { root_url }
    end
  end

  context "on compare_answers" do
    setup do
      @quiz = Factory :quiz
      @question = Factory :question, :quiz => @quiz
      @evaluation = Factory :evaluation, :quiz => @quiz

      Evaluation.stubs(:find).with(@evaluation.id, anything).returns(@evaluation)
      @evaluation.stubs(:question).with(@question.id).returns(@question)
    end

    context "with correct answers" do
      setup do
        @question.stubs(:correct_answers?).returns(true)
        xhr :get, :compare_answers, :id => @evaluation.id, :question_id => @question.id,
          :answers => { "0" => "a", "1" => "b" }
      end

      should assign_to(:evaluation).with(@evaluation)
      should assign_to(:question).with(@question)
      should assign_to(:partial).with('matched_answers')
      should respond_with(:success)
      should render_template(:compare_answers)
      should_not render_with_layout(:application)
      should_not set_the_flash
      should respond_with_content_type(:js)

      before_should "add a correct result" do
        @evaluation.expects(:add_result).with(@question.id, "correct")
      end
    end

    context "with incorrect answers" do
      setup do
        @question.stubs(:correct_answers?).returns(false)
        xhr :get, :compare_answers, :id => @evaluation.id, :question_id => @question.id,
          :answers => { "0" => "a", "1" => "b" }
      end

      should assign_to(:evaluation).with(@evaluation)
      should assign_to(:question).with(@question)
      should assign_to(:partial).with('mismatched_answers')
      should respond_with(:success)
      should render_template(:compare_answers)
      should_not render_with_layout(:application)
      should_not set_the_flash
      should respond_with_content_type(:js)

      before_should "not add a result" do
        @evaluation.expects(:add_result).never
      end
    end

    context "with non-xhr request" do
      setup do
        get :compare_answers, :id => @evaluation.id, :question_id => @question.id,
          :answers => { "0" => "a", "1" => "b" }
      end

      should redirect_to("root_url") { root_url }
    end
  end
end
