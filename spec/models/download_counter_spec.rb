require 'rails_helper'

RSpec.describe DownloadCounter, type: :model do
  let(:download_counter){ create(:download_counter) }
  it "generates a valid model" do
    expect(download_counter).to be_valid
  end

end
