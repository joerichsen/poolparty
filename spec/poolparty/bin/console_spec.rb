require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/poolparty/helpers/console'
require File.dirname(__FILE__) + '/../../../lib/poolparty/helpers/binary'

reset!

describe "Console" do
  before(:each) do
    ::File.stub!(:readable?).and_return true
    Dir.stub!(:pwd).and_return "/flop"
    Dir.stub!(:[]).and_return []
    Dir.stub!(:[]).with("/flop/*/*.rb").and_return ["clouds.rb"]    
  end
  describe "load_pool" do
    before(:each) do
      reset!
      @string =<<-EOS
      pool :app do
        maximum_instances 2
        cloud :rawr do
          maximum_instances 2
        end
      end
      EOS
      self.stub!(:open).and_return @string
      @string.stub!(:read).and_return @string
    end
    it "should give you the load_pool method" do
      self.respond_to?(:load_pool).should == true
    end
    it "should call script inflate on the filename" do      
      PoolParty::Script.should_receive(:inflate).once
      load_pool("pop")
    end
    describe "calling" do
      before(:each) do
        reset!
        load_pool("pop")
      end
      it "should instance_eval the string" do
        pool(:app).should_not be_nil
      end
      it "should store the cloud inside the pool after inflating" do
        pool(:app).cloud(:rawr).should_not be_nil
      end
      it "should say that the cloud inside the pool's parent is the containing parent" do      
        pool(:app).cloud(:rawr).parent.should == pool(:app)
      end
      it "should say that the maximum_instances on the cloud is the containing pool's option" do
        pool(:app).cloud(:rawr).maximum_instances.should == 2
      end
    end
  end  
  describe "reload!" do
    before(:each) do
      reset!
      self.stub!(:require).and_return true
    end
    it "should call reset!" do
      self.should_receive(:reset!).once
    end
    after do
      reload!
    end
  end
  describe "pools" do
    before(:each) do
      @filename = "myspec.spec"
      ::File.stub!(:readable?).with(@filename).and_return true
      @filename.stub!(:read).and_return "spec contents"
      self.stub!(:open).with(@filename).and_return @filename
      Binary.stub!(:get_existing_spec_location).and_return @filename
    end
    it "should call readable on the string sent in to load_pool" do      
      lambda {
        ::File.should_receive(:readable?).with(@filename).and_return false
        load_pool(@filename)
      }
    end
    it "should call inflate from Script with the poolspec" do
      PoolParty::Script.should_receive(:inflate).with("spec contents", "myspec.spec").and_return true
      load_pool(@filename)
    end
  end
  describe "print" do
    before(:each) do
      reset!
      @string =<<-EOS
      pool :app do
        maximum_instances 2
        cloud :rawr do          
        end
      end
      EOS
      self.stub!(:open).and_return @string
      @string.stub!(:read).and_return @string
      load_pool("pop")
    end
    it "should be able to print the clouds" do      
      pools.should_not be_empty
      hide_output do
        pool_describe.should == pools.size
      end      
    end
  end
end