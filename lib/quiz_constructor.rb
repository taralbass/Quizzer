module QuizConstructor
  def quiz name
    @current_quiz = Quiz.new :name => name
    @current_quiz.published = true
    yield self
    @current_quiz.save!
  end

  def description description
    @current_quiz.description = description
  end

  def asks text
    @current_quiz.questions << q = Question.new(:text => text)
    QuestionConstructor.new(q)
  end
end
