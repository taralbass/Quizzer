Factory.define :quiz do |q|
  q.sequence(:name) { |n| "Quiz ##{n}" }
  q.description "description of the quiz"
  q.published false
end

Factory.define :published_quiz, :parent => :quiz do |q|
  q.published true
end

Factory.define :question do |q|
  q.sequence(:text) { |n| "What is the answer to question ##{n}?" }
  q.association :quiz
end

Factory.define :answer do |a|
  a.sequence(:text) { |n| "answer ##{n}?" }
  a.association :question
end

Factory.define :evaluation do |e|
  e.completed true
  e.association :quiz
end

Factory.define :repeat_evaluation, :parent => :evaluation do |e|
  e.parent { |e| e.association :evaluation }
end

Factory.define :result do |r|
  r.result 'correct'
  r.association :evaluation
  r.association :question
  r.after_build do |obj|
    obj.question.quiz_id = obj.evaluation.quiz_id
  end
end

Factory.define :correct_result, :parent => :result do |r|
end

Factory.define :incorrect_result, :parent => :result do |r|
  r.result 'incorrect'
end

Factory.define :ignored_result, :parent => :result do |r|
  r.result 'ignored'
end
