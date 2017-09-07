require 'spec_helper'

describe FlashConcern, type: :controller do
  controller(ApplicationController) do
    include FlashConcern

    def add_flash_to_headers_action
      add_flash_to_headers(type: 'success', message: 'flash')
      redirect_to 'mock_url'
    end
  end

  before do
    routes.draw {
      get 'add_flash_to_headers' => 'anonymous#add_flash_to_headers_action'
    }
  end

  describe '#add_flash_to_headers' do
    it "adds given type as the 'X-Message-Type header'" do
      get 'add_flash_to_headers_action'

      expect(response.headers['X-Message-Type']).to eq('success')
    end

    it "adds given message as the 'X-Message header'" do
      get 'add_flash_to_headers_action'

      expect(subject.response.headers['X-Message']).to eq('flash')
    end
  end
end
