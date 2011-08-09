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
      @evaluation = Factory.create_with_stubbing :evaluation
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
      @evaluation = Factory.build_with_stubbing :evaluation, :quiz_id => 1, :parent_id => 123
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
        @evaluation = Factory.build_with_stubbing :evaluation
        post :create, :evaluation => @evaluation.attributes
      end

      should_not set_the_flash
      should redirect_to("edit_evaluation_url") { edit_evaluation_url(@evaluation) }

      should "save the new evaluation" do
        assert_true @evaluation.persisted?
      end
    end

    context "with invalid parameters" do
      setup do
        @evaluation = Factory.build_with_stubbing :evaluation
        @evaluation.add_update_failure_stubbing
        post :create, :evaluation => @evaluation.attributes
      end

      should redirect_to("root url") { root_url }
      should_not set_the_flash
    end
  end

  context "on edit" do
    setup do
      @evaluation = Factory.create_with_stubbing :evaluation
      stub(@evaluation).randomized_question_ids { [2, 3, 1, 4] }
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
        @evaluation = Factory.create_with_stubbing :evaluation, :completed => false
      end

      context "with xhr request" do
        setup do
          xhr :put, :update, :id => @evaluation.id, :evaluation => { :completed => true }
        end

        should respond_with(:success)
        should_not set_the_flash
        should respond_with_content_type(:js)

        should "save attribute changes" do 
          assert_true @evaluation.reload.completed
        end

        before_should "render nothing" do
          mock.proxy(@controller).render(:nothing => true)
        end
      end

      context "with a non-xhr request" do
        setup do
          put :update, :id => @evaluation.id, :evaluation => { :completed => true }
        end

        should redirect_to("evaluation") { @evaluation }
        should_not set_the_flash

        should "save attribute changes" do 
          assert_true @evaluation.reload.completed
        end
      end
    end

    context "with a failed update" do
      should "propagate validation error" do
        @evaluation = Factory.create_with_stubbing :evaluation
        @evaluation.add_update_failure_stubbing
        assert_raise ActiveRecord::RecordInvalid do
          put :update, :id => @evaluation.id, :evaluation => { :completed => true }
        end
      end
    end
  end

  context "on pose_question" do
    setup do
      @question = Factory.create_with_stubbing :question
      @evaluation = Factory.create_with_stubbing :evaluation, :quiz => @question.quiz
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
      @question = Factory.create_with_stubbing :question, :quiz => @quiz
      @evaluation = Factory.create_with_stubbing :evaluation, :quiz => @quiz
    end

    context "with correct answers" do
      setup do
        stub(@question).correct_answers? { true }
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
        proxy.stub(@evaluation).add_result(@question.id, "correct")
      end
    end

    context "with incorrect answers" do
      setup do
        stub(@question).correct_answers? { false }
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
        do_not_allow(@evaluation).add_result
      end
    end

    context "with non-xhr request" do
      setup do
        get :compare_answers, :id => @evaluation.id, :question_id => @question.id,
          :answers => { "0" => "a", "1" => "b" }
      end

      should redirect_to("root_url") { root_url }
    end

    context "with question_id not included in evaluation" do
      setup do
        @question2 = Factory.create_with_stubbing :question
        xhr :get, :compare_answers, :id => @evaluation.id, :question_id => @question2.id,
            :answers => { "0" => "a", "1" => "b" }
      end

      should redirect_to("root_url") { root_url }
    end
  end
end
