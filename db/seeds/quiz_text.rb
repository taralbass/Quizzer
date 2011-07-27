module QuizText

RelativeConstantsQuestion = <<-QUESTION
module M
  C = 1
  module M
    C = 2
  end
  def self.foo; M::C; end
end
M.foo
QUESTION

AbsoluteConstantsQuestion = <<-QUESTION
module M
  C = 1
  module M
    C = 2
  end
  def self.foo; ::M::C; end
end
M.foo
QUESTION

AncestorsQuestion = <<-QUESTION
class A
  include M1
  include M2
end
class B < A
  include M3
end

B.ancestors
QUESTION

RemoveMethodQuestion = <<-QUESTION
class ParentClass
  def foo
    "parent"
  end
end

class ChildClass < ParentClass
  def foo
    "child"
  end

  remove_method :foo
end

ChildClass.new.foo
QUESTION


UndefMethodQuestion = <<-QUESTION
class ParentClass
  def foo
    "parent"
  end
end

class ChildClass < ParentClass
  def foo
    "child"
  end

  undef_method :foo
end

ChildClass.new.foo
QUESTION


BasicBlockQuestion = <<-QUESTION
def foo a, b
  100 + yield(a, b)
end

foo(30, 20) { |x,y| y - x }
QUESTION


BlockBindingsQuestion = <<-QUESTION
def foo
  x = 100
  yield 1
end
  
x = 200
foo { |y| x + y }
QUESTION

BlockScopeQuestion = <<-QUESTION
def foo
  yield
end

x = 1
foo do
  x += 1
end
x
QUESTION

BlockOutOfScopeQuestion = <<-QUESTION
def foo
  yield
end

foo do
  x = 1
end
x
QUESTION

LocalVariablesInMethodQuestion = <<-QUESTION
module A
  x = 10
  module B
    y = 10
    def self.foo
      z = 10
      local_variables
    end
  end
end

A::B.foo
QUESTION

LocalVariablesAndIfQuestion = <<-QUESTION
x = 10
if true
  y = 10
  if true
    z = 10
  end
  local_variables
end
QUESTION

LocalVariablesAndWhileQuestion = <<-QUESTION
x = 10
while (x == 10)
  x += 1
  y = 10
end
local_variables

QUESTION

LocalVariablesAndTimesQuestion = <<-QUESTION
x = 10
3.times do
  y = 10
end
local_variables
QUESTION

LocalVariablesAndEachQuestion = <<-QUESTION
x = 10
y = []
(1..3).each do
  z = 10
  y = local_variables
end
y
QUESTION

ClassScopeBarrierQuestion = <<-QUESTION
x = 10
class A
  y = x + 10
end
QUESTION

ModuleScopeBarrierQuestion = <<-QUESTION
x = 10
module A
  @y = x + 10
  def self.foo
    @y
  end
end
A.foo
QUESTION

ModuleScopeBarrierWorkaroundQuestion = <<-QUESTION
x = 10
A = Module.new do
  @y = x + 10
  def self.foo
    @y
  end
end
A.foo
QUESTION

MethodScopeBarrierQuestion = <<-QUESTION
class A
  x = 10
  def foo
    x + 10
  end
end
A.new.foo
QUESTION

MethodScopeBarrierWorkaroundQuestion = <<-QUESTION
class A
  x = 10
  define_method :foo do
    x + 10
  end
end
A.new.foo
QUESTION

InstanceEvalQuestion = <<-QUESTION
class A
  @x = 5
  def foo
    @x
  end
end
a = A.new
a.instance_exec { @x = 10 }
a.foo
QUESTION

ProcEqualityQuestion1 = <<-QUESTION
def foo &block
  block
end

p = Proc.new { |x| x + 1 }
p == foo(&p)
QUESTION

ProcEqualityQuestion2 = <<-QUESTION
def foo &block
  block
end

p = foo { |x| x + 1 }
q = Proc.new { |x| x + 1 }
p == q
QUESTION

ProcReturnQuestion1 = <<-QUESTION
def foo &block
  block.call("Hello")
end

foo { |x| return "\#{x} world!" }
QUESTION

LambdaReturnQuestion1 = <<-QUESTION
def foo &block
  block.call("Hello")
end

l = lambda { |x| return "\#{x} world!" }
foo &l
QUESTION

ProcReturnQuestion2 = <<-QUESTION
def foo
  p = proc { return 1 }
  p.call
  2
end

foo
QUESTION

LambdaReturnQuestion2 = <<-QUESTION
def foo
  l = lambda { return 1 }
  l.call
  2
end

foo
QUESTION

ProcArityQuestion = <<-QUESTION
def foo block
  block.call(1)
end

foo(proc { |x, y| x if y })
QUESTION

LambdaArityQuestion = <<-QUESTION
def foo block
  block.call(1)
end

foo(lambda { |x, y| x if y })
QUESTION

StubbyLambdaQuestion = <<-QUESTION
how would you write the following in -> notation?
  lambda { |x| x + 1 }
QUESTION

SelfQuestion1 = <<-QUESTION
module A
  self
end
QUESTION

SelfQuestion2 = <<-QUESTION
class A
  def self.foo
    self
  end
end
A.foo
QUESTION

SelfQuestion3 = <<-QUESTION
class A
  def foo
    self
  end
end
A.new.foo
QUESTION

CurrentClassQuestion1 = <<-QUESTION
class A; end
A.instance_eval { def foo; end }
where is foo defined?
QUESTION

CurrentClassQuestion2 = <<-QUESTION
class A; end
A.class_eval { def foo; end }
where is foo defined?
QUESTION

CurrentClassQuestion3 = <<-QUESTION
class A; end
A.class_eval { def self.foo; end }
where is foo defined?
QUESTION

CurrentClassQuestion4 = <<-QUESTION
class A
  def foo1
    def foo2; end
  end
end
A.new.foo1
where is foo2 defined?
QUESTION

CurrentClassQuestion5 = <<-QUESTION
class A; end
a = A.new
a.instance_eval { def foo; end }
where is foo defined?
QUESTION

ClassVsInstanceEvalQuestion = <<-QUESTION
class A
  def foo
    @a = 10
  end
end
A.class_eval { @a } == A.instance_eval { @a }
QUESTION

ClassVariableQuestion = <<-QUESTION
class A
  @a = 10
  def foo
    @a
  end
end
A.new.foo
QUESTION

SingletonMethodQuestion = <<-QUESTION
a = "hello"
def a.foo
  ...
end
what is foo?
QUESTION

EigenclassClassQuestion = <<-QUESTION
(assume method eigenclass returns object's eigenclass)
"hello".eigenclass.class
QUESTION

EigenclassSuperclassQuestion = <<-QUESTION
(assume method eigenclass returns object's eigenclass)
"hello".eigenclass.superclass
QUESTION

ClassEigenclassSuperClassQuestion = <<-QUESTION
(assume method eigenclass returns object's eigenclass)
class A; end
class B < A; end
B.eigenclass.superclass
QUESTION

BasicObjectEigenclassSuperClassQuestion = <<-QUESTION
(assume method eigenclass returns object's eigenclass)
BasicObject.eigenclass.superclass
QUESTION

ClassExtensionQuestion1 = <<-QUESTION
module Foo
  def foo; end
end
class A
  class << self
    include Foo
  end
end
A.new.respond_to? :foo
QUESTION

ClassExtensionQuestion2 = <<-QUESTION
module Foo
  def foo; end
end
class A
  class << self
    include Foo
  end
end
A.respond_to? :foo
QUESTION

AliasQuestion = <<-QUESTION
class String
  alias :girth :size
  def size
    1
  end
end
"abcd".girth
QUESTION

AliasRecursionQuestion = <<-QUESTION
class String
  alias :old_size :size
  def size  # vowels count twice!
    old_size + self.gsub(/[^aeiou]/, '').size
  end
end
"abcde".size
QUESTION

EvalBindingsQuestion = <<-QUESTION
def foo
  x = 1
  binding
end

b = foo
x = 2
eval "x", b
QUESTION

end

