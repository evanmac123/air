require 'spec_helper'

describe BoardActivity do

	describe ".active_boards" do

		it "list selects boards with activity" do
			expect(BoardActivity.active_boards.any?).to be_true
		end

	end

end
