class TilePreviewIntrosPresenter
  class IntroStep < Struct.new(:copy, :step)
    def to_data
      {intro: copy, step: step}
    end
  end

  def initialize(key_copy_enabled_triples)
    @steps = ActiveSupport::OrderedHash.new

    key_copy_enabled_triples.each_with_index do |triple, index|
      key, copy, is_enabled = triple
      if is_enabled
        @steps[key] = IntroStep.new(copy, index + 1)
      end
    end
  end

  def any_active?
    @steps.present?
  end

  def data_for(key)
    step = @steps[key]
    return {} unless step.present?
    step.to_data
  end
end
