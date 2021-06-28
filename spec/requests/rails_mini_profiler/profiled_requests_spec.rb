# frozen_string_literal: true

require 'rails_helper'

module RailsMiniProfiler
  RSpec.describe '/profiled_requests', type: :request do
    let(:user_id) { '127.0.0.1' }

    let(:context) { RailsMiniProfiler.context }
    let(:repository) { Repositories::ProfiledRequestRepository.create_repository(user_id) }
    let(:profiled_request) do
      Models::ProfiledRequest.new(user_id: user_id, request: RequestWrapper.new, response: ResponseWrapper.new)
    end
    let(:stored_request) { repository.create(profiled_request) }

    where(case_names: ->(a) { "in #{a.to_sym}" }, storage: [Storage::ActiveRecord])

    with_them do
      before do
        RailsMiniProfiler.configure { |configuration| configuration.storage = storage }
      end

      describe 'GET /index' do
        it 'renders a successful response' do
          get profiled_requests_url
          expect(response).to be_successful
        end
      end

      describe 'GET /show' do
        it 'without item redirects and shows error' do
          get profiled_request_url(-1)

          expect(flash[:alert]).to be_present
        end

        it 'with stored item return successful' do
          get profiled_request_url(stored_request.id)

          expect(response).to be_successful
        end
      end

      describe 'DELETE /destroy' do
        it 'destroys the requested profiled_request' do
          delete profiled_request_url(stored_request.id)

          expect { repository.find(profiled_request.id) }.to raise_error(RecordNotFound)
        end
      end
    end
  end
end
