require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

ruby_version_is "2.0" do
  describe "Thread#thread_variables" do
    it "returns an array of the names of the thread-local variables as symbols" do
      th = Thread.new do
        Thread.current.thread_variable_set("cat",'woof')
        Thread.current.thread_variable_set(:cat, 'meow')
        Thread.current.thread_variable_set(:dog, 'woof')
      end
      th.join
      th.thread_variables.sort_by {|x| x.to_s}.should == [:cat,:dog]
    end

    it "is shared across fibers" do
      fib = Fiber.new do
        Thread.current.thread_variable_set(:val4, 1)
        Fiber.yield
        Thread.current.thread_variables.should include(:val4)
        Thread.current.thread_variables.should include(:val5)
      end
      Thread.current.thread_variables.should_not include(:val4)
      fib.resume
      Thread.current.thread_variable_set(:val5, 2)
      fib.resume
      Thread.current.thread_variables.should include(:val5)
      Thread.current.thread_variables.should include(:val4)
    end

    it "stores a local in another thread when in a fiber" do
      fib = Fiber.new do
        t = Thread.new do
          sleep
          Thread.current.thread_variables.should include(:value)
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
