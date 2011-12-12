class Admin::BadWordsController < AdminBaseController
  def index
    @demo = Demo.find(params[:demo_id]) if params[:demo_id]

    base = if @demo
             @demo.bad_words
           else
             BadWord.generic
           end

    @bad_words = base.alphabetical
  end

  def create
    new_words = params[:new_bad_words].split(/,/).map(&:strip).map(&:downcase)
    new_words.each {|new_word| BadWord.create!(:value => new_word, :demo_id => params[:demo_id])}
    redirect_to :back
  end

  def destroy
    BadWord.find(params[:id]).destroy
    redirect_to :back
  end
end
