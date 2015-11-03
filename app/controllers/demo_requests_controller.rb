class DemoRequestsController < ApplicationController

 def create
   DemoRequest.create(params[:demo_request])
   head :ok
 end

end

