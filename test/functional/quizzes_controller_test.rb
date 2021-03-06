require 'test_helper'

class QuizzesControllerTest < ActionController::TestCase
  context "on index" do
    setup do
      Factory :published_quiz
      Factory :quiz
    end

    context "" do
      setup do
        get :index
      end

      should assign_to(:quizzes).with(Quiz.published)
      should assign_to(:manage).with(false)
      should respond_with(:success)
      should render_with_layout(:application)
      should render_template(:index)
      should_not set_the_flash
      should respond_with_content_type(:html)

      should "have a link to quiz management" do
        assert_tag :a, :attributes => { :href => quizzes_path(:manage_quizzes => 1) }
      end

      should "not have a link to create a new quiz" do
        assert_no_tag :a, :attributes => { :href => new_quiz_path }
      end
    end

    context "with manage params" do
      setup do
        get :index, :manage_quizzes => "1"
      end

      should assign_to(:quizzes).with(Quiz.unpublished)
      should assign_to(:manage).with("1")

      should "not have a link to quiz management" do
        assert_no_tag :a, :attributes => { :href => quizzes_path(:manage_quizzes => 1) }
      end

      should "have a link to create a new quiz" do
        assert_tag :a, :attributes => { :href => new_quiz_path }
      end
    end
  end

  context "on show" do
    context "for existing quiz" do
      setup do
        @quiz = Factory.create_with_stubbing :quiz
        get :show, :id => @quiz.id
      end

      should assign_to(:quiz).with(@quiz)
      should respond_with(:success)
      should render_with_layout(:application)
      should render_template(:show)
      should_not set_the_flash
      should respond_with_content_type(:html)
    end

    context "with xhr request" do
      setup do
        quiz = Factory :quiz
        xhr :get, :show, :id => quiz.id, :attr => :name
      end

      before_should "delegate to inlinified_show" do
        proxy.mock(@controller).inlinified_show
      end
    end
  end

  context "on new" do
    setup { get :new }

    should assign_to(:quiz).with_kind_of(Quiz)
    should respond_with(:success)
    should render_with_layout(:application)
    should render_template(:new)
    should_not set_the_flash
    should respond_with_content_type(:html)
  end

  context "on create" do
    context "with valid parameters" do
      setup do
        @quiz = Factory.build_with_stubbing :quiz
        post :create, :quiz => @quiz.attributes
      end

      should assign_to(:quiz).with(@quiz)
      should_not set_the_flash
      should redirect_to("quizzes_url") { quiz_url(@quiz) }

      should "save the new quiz" do
        assert_true @quiz.persisted?
      end
    end

    context "with invalid parameters" do
      setup do
        @quiz = Factory.build_with_stubbing :quiz, :name => ""
        post :create, :quiz => @quiz.attributes
      end

      should assign_to(:quiz).with_kind_of(@quiz)
      should respond_with(:success)
      should render_with_layout(:application)
      should render_template(:new)
      should_not set_the_flash
      should respond_with_content_type(:html)

      should "not save the new quiz" do
        assert_false @quiz.persisted?
      end
    end
  end

  should "be inlinified for :edit and :update actions" do
    [ :edit, :update ].each do |action|
      assert_true @controller.respond_to?(action)
    end
  end

  context "on destroy" do
    setup do
      @quiz = Factory.create_with_stubbing :quiz
      delete :destroy, :id => @quiz.id
    end

    should set_the_flash
    should redirect_to("quizzes_url") { quizzes_url(:manage_quizzes => true)}

    should "destroy the quiz" do
      assert_nil Quiz.find_by_id(@quiz.id)
    end
  end

  context "the require_unpublished method" do
    should "raise an Argument exception if published quiz is identified" do
      published_quiz = Factory :published_quiz
      stub(@controller).params { { :id => published_quiz.id } }
      assert_raise ArgumentError do
        @controller.send(:require_unpublished)
      end
    end

    should "not raise an Argument exception if unpublished quiz is identified" do
      unpublished_quiz = Factory :quiz
      stub(@controller).params { { :id => unpublished_quiz.id } }
      assert_nothing_raised do
        @controller.send(:require_unpublished)
      end
    end
  end
end
