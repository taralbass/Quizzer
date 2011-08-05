module QuizConstructor
  class QuestionConstructor
    def initialize question
      @question = question
    end

    def with_answer answer
      @question.answers << Answer.new(:text => answer)
      self
    end

    def with_answers *answers
      @question.answers << answers.map{ |a| Answer.new :text => a }
      self
    end
  end
end
