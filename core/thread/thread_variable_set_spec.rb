require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

ruby_version_is "2.0" do
  describe "Thread#thread_variable_set" do

    it "raises exceptions on the wrong type of keys" do
      lambda { Thread.current.thread_variable_set(nil, true) }.should raise_error(TypeError)
      lambda { Thread.current.thread_variable_set(5, true) }.should raise_error(TypeError)
    end

    it "raises a RuntimeError when a local has been set and the thread is frozen" do
      t = Thread.new { }.join
      t.thread_variable_set :foo, "bar"
      t.freeze
      lambda { t.thread_variable_set(:baz, "qux") }.should raise_error(RuntimeError)
    end

    it "raises a RuntimeError when locals are empty and the thread is frozen" do
      t = Thread.new { }.join
      t.freeze
      lambda { t.thread_variable_set(:baz, "qux") }.should raise_error(RuntimeError)
    end

    it "is shared across fibers" do
      fib = Fiber.new do
        Thread.current.thread_variable_set(:value, 1)
        Fiber.yield
        Thread.current.thread_variable_get(:value).should == 2
      end
      fib.resume
      Thread.current.thread_variable_get(:value).should == 1
      Thread.current.thread_variable_set(:value, 2)
      fib.resume
    end

    it "stores a local in another thread when in a fiber" do
      fib = Fiber.new do
        t = Thread.new do
          sleep
          Thread.current.thread_variable_get(:value).should == 1
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