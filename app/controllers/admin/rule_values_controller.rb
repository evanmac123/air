class Admin::RuleValuesController < AdminBaseController
  # TODO: an Akephalos feature here
  def destroy
    RuleValue.find(params[:id]).destroy
    render :text => 'ok'
  end
end
