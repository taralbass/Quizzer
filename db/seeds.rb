require 'quiz_constructor'
require_relative 'seeds/quiz_text'

include QuizConstructor
include QuizText

Answer.delete_all
Question.delete_all
Quiz.delete_all

quiz "Ruby 1.9: Classes, Modules and Inheritance" do
  description "Questions about the Ruby object model. Assumes Ruby 1.9"

  asks("File.instance_methods.include? :exist?").with_answer("false")
  asks("File.methods.include? :exist?").with_answer("true")
  asks("file_object.methods.include? :each").with_answer("true")
  asks("file_object.methods.include? :exist?").with_answer("false")

  asks("File.class").with_answer("Class")
  asks("file_object.class").with_answer("File")
  asks("Class.class").with_answer("Class")
  asks("Module.class").with_answer("Class")
  asks("String.superclass").with_answer("Object")
  asks("Class.superclass").with_answer("Module")
  asks("Module.superclass").with_answer("Object")
  asks("Object.superclass").with_answer("BasicObject")
  asks("BasicObject.superclass").with_answer("nil")

  asks("false in Object#methods(false) and Module.instance_methods(false) excludes what?")
    .with_answer("inherited methods")

  asks("the instance methods defined by Class are:")
    .with_answers(":allocate", ":new", ":superclass")

  asks("the typical uses of a Module are:").with_answers("mixin", "namespacing")
  asks("the typical uses of a Class are:").with_answers("instantiation", "inheritance")
  asks("true or false: classes and modules are implemented independently of each other")
    .with_answer("false")
  asks("true or false: classes and modules share much of their implementation and functionality")
    .with_answer("true")

  asks("a = SomeClass\na.new.class").with_answer("SomeClass")

  asks(RelativeConstantsQuestion).with_answer("2")
  asks(AbsoluteConstantsQuestion).with_answer("1")

  asks(AncestorsQuestion)
    .with_answer("[B, M3, A, M2, M1, Object, Kernel, BasicObject]")

  asks("the seemingly global method :puts is actually what?")
    .with_answer("a private instance method of Kernel")

  asks("self [from top-level]").with_answer("main")
  asks("self.class [from top-level]").with_answer("Object")
end

quiz "Ruby 1.9: Methods" do
  description "Questions about Ruby methods. Assumes Ruby 1.9"

  asks("rewrite the following expressing using send: obj.foo(100)")
    .with_answer("obj.send(:foo, 100)")
  asks("true or false: send can be used to call private methods")
    .with_answer("true")

  asks("reasons to use symbols over Strings")
    .with_answers("immutability", "speed", "convention")

  asks("where is define_method defined?").with_answer("Module#define_method")
  asks("where is method_missing defined?").with_answer("BasicObject#method_missing")

  asks("where is the error 'NoMethodError: undefined method <method_name> for #<object>' raised from?")
    .with_answer("BasicObject#method_missing")

  asks("when overriding method_missing, what other method(s) should be overridden to ensure the class behaves consistently?")
    .with_answers("Kernel#respond_to?", "Kernel#*methods (in some cases, but not usually)")

  asks(RemoveMethodQuestion).with_answer("parent")
  asks(UndefMethodQuestion).with_answer("NoMethodError")

  asks("reserved methods that shouldn't be undefined or removed follow what naming convention?")
    .with_answer("leading double underscore")

  asks("ways to implement a blank slate object:")
    .with_answers("undef appropriate instance methods", "inherit from BasicObject")
end

quiz "Ruby 1.9: Blocks, Procs and Lambdas" do
  description "Questions about Ruby's blocks, procs and lambdas. Assumes Ruby 1.9"

  asks(BasicBlockQuestion).with_answer("90")
  asks("how can you tell whether a block was provided to the currently executing method?")
    .with_answer("Kernel#block_given?")
  asks(BlockBindingsQuestion).with_answer("201")
  asks("what does a closure retains from whever it is invoked?").with_answer("local bindings")
  asks(BlockScopeQuestion).with_answer("2")
  asks(BlockOutOfScopeQuestion).with_answer("NameError")

  asks(LocalVariablesInMethodQuestion).with_answer("[:z]")
  asks(LocalVariablesAndIfQuestion).with_answer("[:y, :z, :x]")
  asks(LocalVariablesAndWhileQuestion).with_answer("[:y, :x]")
  asks(LocalVariablesAndTimesQuestion).with_answer("[:x]")
  asks(LocalVariablesAndEachQuestion).with_answer("[:z, :y, :x]")

  asks("when does Ruby open a new scope?").with_answers("module definition", "class definition", "method definition")

  asks(ModuleScopeBarrierQuestion).with_answer("NoMethodError")
  asks(ModuleScopeBarrierWorkaroundQuestion).with_answer("20")

  asks(MethodScopeBarrierQuestion).with_answer("NameError")
  asks(MethodScopeBarrierWorkaroundQuestion).with_answer("20")

  asks("given a reference to an object, how can you bypass ecapsulation and manipulate its internal context?").with_answers("BasicObject#instance_eval", "BasicObject#instance_exec", "Kernel#instance_variable_get", "Kernel#instance_variable_set")

  asks(InstanceEvalQuestion).with_answer("10")

  asks("what are the ways to package code to be executed later?")
    .with_answers("blocks", "procs", "lambdas", "methods")

  asks("what are the ways to create a Proc (including a lambda)?")
    .with_answers("Proc.new", "Kernel#proc", "Kernel#lambda", "& (in method arguments)")
  asks(ProcEqualityQuestion1).with_answer("true")
  asks(ProcEqualityQuestion2).with_answer("false")

  asks(ProcReturnQuestion1).with_answer("LocalJumpError")
  asks(LambdaReturnQuestion1).with_answer("Hello world!")
  asks(ProcReturnQuestion2).with_answer("1")
  asks(LambdaReturnQuestion2).with_answer("2")
  asks(ProcArityQuestion).with_answer("nil")
  asks(LambdaArityQuestion).with_answer("ArgumentError")

  asks(StubbyLambdaQuestion).with_answer("->(x) { x + 1 }")

  asks("\"foo\".method(:size).class").with_answer("Method")
  asks("\"foo\".method(:size).unbind.class").with_answer("UnboundMethod")
  asks("\"hello world\".method(:size).unbind.bind(\"foo\").call").with_answer("3")
end
  

quiz "Ruby 1.9: Eigenclasses" do
  description "Questions about Ruby classes and eigenclasses. Assumes Ruby 1.9"

  asks(SelfQuestion1).with_answer("A")
  asks(SelfQuestion2).with_answer("A")
  asks(SelfQuestion3).with_answer("reference to object of class A")

  asks(CurrentClassQuestion1).with_answer("A.foo")
  asks(CurrentClassQuestion2).with_answer("A#foo")
  asks(CurrentClassQuestion3).with_answer("A.foo")
  asks(CurrentClassQuestion4).with_answer("A#foo")
  asks(CurrentClassQuestion5).with_answer("#a#foo")

  asks(ClassVsInstanceEvalQuestion).with_answer("true")
  asks(ClassVariableQuestion).with_answer("nil")

  asks(SingletonMethodQuestion).with_answer("singleton method")
  asks("a class method is actually what?")
    .with_answer("singleton method of Class object of the class")
  asks("what are class macros such as attr_reader?")
    .with_answer("instance methods of Module")

  asks("where do an object's singleton methods live?")
    .with_answer("its eigenclass")
  asks("write a code snippet to get the eigenclass for an object called obj")
    .with_answer("class << obj; self; end")
  asks(EigenclassClassQuestion).with_answer("Class")
  asks(EigenclassSuperclassQuestion).with_answer("String")
  asks("If an instance method is defined in both an object's eigenclass and its class, which version will be used?")
    .with_answer("eigenclass")
  asks(ClassEigenclassSuperClassQuestion).with_answer("#A")
  asks(BasicObjectEigenclassSuperClassQuestion).with_answer("Class")

  asks(ClassExtensionQuestion1).with_answer("false")
  asks(ClassExtensionQuestion2).with_answer("true")

  asks(AliasQuestion).with_answer("4")
  asks(AliasRecursionQuestion).with_answer("SystemStackError")  

  # Chapter 5
  asks(EvalBindingsQuestion).with_answer("1")
end

# create unpublished clones of quizzes to seed quiz management demo
Quiz.published.each do |quiz|
  cloned_quiz = quiz.clone
  cloned_quiz.name += ' (copy)'
  cloned_quiz.published = false;
  cloned_quiz.save!
end


