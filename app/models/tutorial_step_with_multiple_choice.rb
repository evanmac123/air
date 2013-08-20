class TutorialStepWithMultipleChoice < TutorialStep
  def step_definitions
    unless @_step_definitions
      @_step_definitions = super

      # Step 2 is when the user does a sample tile. The base TutorialStep is
      # appropriate for keyword tiles, so we override the settings for this 
      # step to be appropriate for multiple choice tiles.

      @_step_definitions[2][:instruct] = "Read the tile below, then click the right answer for points."
      @_step_definitions[2].delete(:arrow_dir)
      @_step_definitions[2][:highlighted] = '#0'
      @_step_definitions[2][:position] = "top"
      @_step_definitions[2][:x] = -486
      @_step_definitions[2][:y] = -20
    end

    @_step_definitions
  end
end
