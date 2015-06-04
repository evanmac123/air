module TilePreview
  class IntrosPresenter

    class IntroStep < Struct.new(:step_name, :copy, :step)
      def to_data
        {intro: copy, step: step, step_name: step_name}
      end
    end

    def initialize(key_copy_enabled_triples)
      @steps = ActiveSupport::OrderedHash.new

      key_copy_enabled_triples.each_with_index do |triple, index|
        key, copy, is_enabled = triple
        if is_enabled
          @steps[key] = IntroStep.new(key, copy, index + 1)
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
end
