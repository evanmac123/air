require 'spec_helper'

# TODO: Why do we need this????
class DummyController < AdminBaseController
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
    sign_in_as(FactoryGirl.create(:site_admin))
  end

  describe "#strip_smart_punctuation" do
    it "should substitute plain Latin-1 punctuation for the fancy kind put in by a word processor" do
      get :echo, :text => "“”‘’–—"
      expect(response.status).to eq(200)
      response.body.should == "\"\"''--"
    end
  end
end
