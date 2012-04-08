# encoding: utf-8

require 'spec_helper'

class DummyController < AdminBaseController
  skip_before_filter :authenticate
  def echo
    render :text => params[:text]
  end
end

describe DummyController do
  before(:all) do
    Health::Application.routes.draw do 
      match "/echo", :controller => :dummy, :action => :echo
    end
  end

  after(:all) do
    load "config/routes.rb"
  end

  before(:each) do
    @controller.current_user = Factory :site_admin
  end

  describe "#strip_smart_punctuation" do
    it "should substitute plain Latin-1 punctuation for the fancy kind put in by a word processor" do
      get :echo, :text => "“”‘’–—"

      response.body.should == "\"\"''--"
    end
  end
end
