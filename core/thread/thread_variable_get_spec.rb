require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

ruby_version_is "2.0" do
  describe "Thread#thread_variable_get" do
    it "gives access to thread local values" do
      th = Thread.new do
        Thread.current.thread_variable_set(:value, 5)
      end
      th.join
      th.thread_variable_get(:value).should == 5
      Thread.current.thread_variable_get(:value).should == nil
    end

    it "is not shared across threads" do
      t1 = Thread.new do
        Thread.current.thread_variable_set(:value, 1)
      end
      t2 = Thread.new do
        Thread.current.thread_variable_set(:value, 2)
      end
      [t1,t2].each {|x| x.join}
      t1.thread_variable_get(:value).should == 1
      t2.thread_variable_get(:value).should == 2
    end

    it "is accessable using strings or symbols" do
      t1 = Thread.new do
        Thread.current.thread_variable_set(:value, 1)
      end
      t2 = Thread.new do
        Thread.current.thread_variable_set("value", 2)
      end
      [t1,t2].each {|x| x.join}
      t1.thread_variable_get(:value).should == 1
      t1.thread_variable_get("value").should == 1
      t2.thread_variable_get(:value).should == 2
      t2.thread_variable_get("value").should == 2
    end

    it "raises exceptions on the wrong type of keys" do
      lambda { Thread.current.thread_variable_get(nil) }.should raise_error(TypeError)
      lambda { Thread.current.thread_variable_get(5) }.should raise_error(TypeError)
    end
  end
end