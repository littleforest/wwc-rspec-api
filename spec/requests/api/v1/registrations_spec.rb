require 'rails_helper'

RSpec.describe "API::V1::Registrations", type: :request do
  describe "POST #create" do
    let(:path) { "/v1/sign_up" }

    context "with valid params" do
      let(:params) {
        {
          email: "foo@example.com",
          password: "supersecret",
          password_confirmation: "supersecret",
        }
      }

      it "increases user count" do
      end

      it "returns HTTP status success" do
      end

      it "returns user info in response" do
      end
    end

    context "with invalid params" do
      it "does not increase user count" do
      end

      it "returns HTTP 422 status" do
      end

      it "returns error info in response" do
      end
    end
  end
end
