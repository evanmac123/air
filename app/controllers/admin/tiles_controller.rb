class Admin::TilesController < AdminBaseController
  before_filter :find_demo_by_demo_id
  before_filter :find_tile, :only => [:edit, :update, :destroy]
  before_filter :parse_times, :only => [:create, :update]
  
  def index
    @tiles = @demo.tiles.includes(:prerequisites).includes(:rule_triggers).sort_by(&:position)
  end

  def sort
    Tile.set_position_within_demo(@demo, params[:tile])
    render :nothing => true
  end

  def new
    @tile = @demo.tiles.new
    load_surveys_tiles_and_values
  end

  def create
    @tile = @demo.tiles.build(params[:tile])
    @tile.position = Tile.next_position(@demo)
    @tile.status = 'active'

    if @tile.valid?
      @tile.save!
      set_up_completion_triggers

      flash[:success] = "New tile created"
      redirect_to :action => :index
    else
      add_failure "There was a problem saving the record"
      load_surveys_tiles_and_values
      render :new
    end
  end

  def edit
    @existing_tiles = find_existing_tiles(@demo) - [@tile] # no circular dependencies kthx
    @surveys = @demo.surveys
    @primary_values = RuleValue.visible_from_demo(@demo).primary.alphabetical
    @selected_rule_ids = @tile.rule_triggers.map(&:rule_id)
    @require_referrer = @tile.rule_triggers.first.try(:referrer_required)
    @selected_survey_id = @tile.survey_trigger.try(:survey_id)
  end

  def update
    case params[:commit]
    when 'Remove image'
      remove_image
      flash[:success] = "Image removed"
    when 'Remove thumbnail'
      remove_thumbnail
      flash[:success] = "Thumbnail removed"
    else
      @tile.attributes = params[:tile]
      @tile.save!
      set_up_completion_triggers

      flash[:success] = "Tile updated"
    end

    redirect_to :action => :index
  end

  def destroy
    @tile.destroy
    add_success "Tile '#{@tile.headline}' has been destroyed"
    redirect_to admin_demo_tiles_path
  end

  protected
  
  def find_tile
    @tile = Tile.find(params[:id])
  end

  def find_existing_tiles(demo)
    @demo.tiles.alphabetical
  end
  
  def load_surveys_tiles_and_values
    @surveys = @demo.surveys
    @existing_tiles = find_existing_tiles(@demo)
    @primary_values = RuleValue.visible_from_demo(@demo).primary.alphabetical
  end


  def set_up_completion_triggers
    return unless params[:completion].present?

    set_up_rule_triggers(params[:completion][:rule_ids], params[:completion][:referrer_required])
    set_up_survey_trigger(params[:completion][:survey_id])
  end

  def set_up_rule_triggers(rule_ids, referrer_required)
    _rule_ids = rule_ids.present? ? rule_ids : []
    referrer_required = referrer_required || false

    @tile.rule_triggers = _rule_ids.map{|rule_id| Trigger::RuleTrigger.new(:rule_id => rule_id, :referrer_required => referrer_required) }
  end

  def set_up_survey_trigger(survey_id)
    _survey_id = survey_id.present? ? survey_id : nil

    return if @tile.survey_trigger.try(:survey_id) == _survey_id
    @tile.survey_trigger.destroy if @tile.survey_trigger

    if _survey_id
      @tile.survey_trigger = Trigger::SurveyTrigger.create!(:survey_id => _survey_id)
    end
  end

  def parse_times
    [:start_time, :end_time].each do |time_name|
      next unless params[:tile][time_name].present?
      # using guess => false and <returned_time>.first to force our default time of day to 00:00
      opts = {:ambiguous_time_range => 6, :guess => false}
      params[:tile][time_name] = Chronic.parse(params[:tile][time_name], opts).first.to_s
    end
  end

  def remove_image
    @tile.image = nil
    @tile.save!
  end

  def remove_thumbnail
    @tile.thumbnail = nil
    @tile.save!
  end
end
