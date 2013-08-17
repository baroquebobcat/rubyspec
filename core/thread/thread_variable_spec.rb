require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

ruby_version_is "2.0" do
  describe "Thread#thread_variable?" do
    before :each do
      @th = Thread.new do
        Thread.current.thread_variable_set(:oliver, "a")
      end
      @th.join
    end

    it "tests for existance of thread local variables using symbols or strings" do
      @th.thread_variable?(:oliver).should == true
      @th.thread_variable?("oliver").should == true
      @th.thread_variable?(:stanley).should == false
      @th.thread_variable?(:stanley.to_s).should == false
    end

    quarantine! do
      it "raises exceptions on the wrong type of thread_variables" do
        lambda { Thread.current.thread_variable? nil }.should raise_error(TypeError)
        lambda { Thread.current.thread_variable? 5 }.should raise_error(ArgumentError)
      end
    end

    it "raises exceptions on the wrong type of thread_variables" do
      lambda { Thread.current.thread_variable? nil }.should raise_error(TypeError)
      lambda { Thread.current.thread_variable? 5 }.should raise_error(TypeError)
    end

    it "is shared across fibers" do
      fib = Fiber.new do
        Thread.current.thread_variable_set(:val1, 1)
        Fiber.yield
        Thread.current.thread_variable?(:val1).should be_true
        Thread.current.thread_variable?(:val2).should be_true
      end
      Thread.current.thread_variable?(:val1).should_not be_true
      fib.resume
      Thread.current.thread_variable_set(:val2, 2)
      fib.resume
      Thread.current.thread_variable?(:val1).should be_true
      Thread.current.thread_variable?(:val2).should be_true
    end

    it "stores a local in another thread when in a fiber" do
      fib = Fiber.new do
        t = Thread.new do
          sleep
          Thread.current.thread_variable?(:value).should be_true
        end

        Thread.pass while t.status and t.status != "sleep"
        t.thread_variable_set(:value, 1)
        t.wakeup
        t.join
      end
      fib.resume
    end
  end
end