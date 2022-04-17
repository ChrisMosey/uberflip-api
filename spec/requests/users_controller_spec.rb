require 'rails_helper'

RSpec.describe "Employees", type: :request do
  describe "GET /" do
    it "returns all employees" do
      user = create(:user)
      get "/employees"
      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body.count).to eq(1)
    end

    it "returns limited employees" do
      unique_sin_numbers = [ # should be in a helper file
        "862536414",
        "138152798",
        "934679382",
        "427839477",
        "443392949"
      ]
      unique_sin_numbers.each do |sin|
        create(:user, sin: sin)
      end

      get "/employees", params: { limit: 3 }
      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body.count).to eq(3)
    end

    it "defaults to a limit of 10 if no limit specified" do
      unique_sin_numbers = [ # should be in a helper file
        "862536414",
        "138152798",
        "934679382",
        "427839477",
        "443392949",
        "192260636",
        "237014311",
        "412468803",
        "260339775",
        "437738206",
        "540901048",
        "839289014"
      ]
      unique_sin_numbers.each do |sin|
        create(:user, sin: sin)
      end

      get "/employees"
      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body.count).to eq(10)
    end

    it "searches by first name" do
      create(:user)
      create(:user, first_name: "fred", sin: "443392949")

      get "/employees", params: { first_name: "fred" }
      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body.count).to eq(1)
    end

    it "searches by last name" do
      create(:user)
      create(:user, last_name: "jones", sin: "443392949")

      get "/employees", params: { last_name: "jones" }
      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body.count).to eq(1)
    end

    it "searches by first name and limits results" do
      create(:user)
      create(:user, first_name: "fred", sin: "443392949")
      create(:user, first_name: "fred", sin: "192260636")

      get "/employees", params: { first_name: "fred", limit: 1 }
      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body.count).to eq(1)
    end
  end

  describe "POST /" do
    it "returns http success" do
      params = {
        first_name: "joe",
        last_name: "smith",
        email: "joe.smith@example.com",
        hourly_wage: 15.50,
        sin: "130692544"
      }

      post "/employees", params: params
      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body["first_name"]).to eq("joe")
    end

    it "returns an error if first name is missing" do
      params = {
        last_name: "smith",
        email: "joe.smith@example.com",
        hourly_wage: 15.50,
        sin: "130692544"
      }

      post "/employees", params: params

      expect(response).to have_http_status(500)
    end

    it "returns an error if last name is missing" do
      params = {
        first_name: "joe",
        email: "joe.smith@example.com",
        hourly_wage: 15.50,
        sin: "130692544"
      }

      post "/employees", params: params

      expect(response).to have_http_status(500)
    end

    it "returns an error if email is missing" do
      params = {
        first_name: "joe",
        last_name: "smith",
        hourly_wage: 15.50,
        sin: "130692544"
      }

      post "/employees", params: params

      expect(response).to have_http_status(500)
    end

    it "returns an error if email is invalid" do
      params = {
        first_name: "joe",
        last_name: "smith",
        email: "foobar",
        hourly_wage: 15.50,
        sin: "130692544"
      }

      post "/employees", params: params

      expect(response).to have_http_status(500)
    end

    it "returns an error if hourly wage is missing" do
      params = {
        first_name: "joe",
        last_name: "smith",
        email: "joe.smith@example.com",
        sin: "130692544"
      }

      post "/employees", params: params

      expect(response).to have_http_status(500)
    end

    it "returns an error if hourly wage is invalid" do
      params = {
        first_name: "joe",
        last_name: "smith",
        email: "joe.smith@example.com",
        hourly_wage: "abc123",
        sin: "130692544"
      }

      post "/employees", params: params

      expect(response).to have_http_status(500)
    end

    it "returns an error if sin is missing" do
      params = {
        first_name: "joe",
        last_name: "smith",
        email: "joe.smith@example.com",
        hourly_wage: 15.50
      }

      post "/employees", params: params

      expect(response).to have_http_status(500)
    end
    
    it "returns an error if sin is short" do
      params = {
        first_name: "joe",
        last_name: "smith",
        email: "joe.smith@example.com",
        hourly_wage: 15.50,
        sin: "13069254"
      }

      post "/employees", params: params

      expect(response).to have_http_status(500)
    end

    it "returns an error if sin is long" do
      params = {
        first_name: "joe",
        last_name: "smith",
        email: "joe.smith@example.com",
        hourly_wage: 15.50,
        sin: "1306925444"
      }

      post "/employees", params: params

      expect(response).to have_http_status(500)
    end

    it "returns an error if sin is invalid" do
      params = {
        first_name: "joe",
        last_name: "smith",
        email: "joe.smith@example.com",
        hourly_wage: 15.50,
        sin: "123456789"
      }

      post "/employees", params: params

      expect(response).to have_http_status(500)
      response_body = JSON.parse(response.body)

      expect(response_body["messages"].count).to eq(1)
    end

    it "returns an error if sin is duplicated" do
      create(:user, sin: "527024616")
      params = {
        first_name: "joe",
        last_name: "smith",
        email: "joe.smith@example.com",
        hourly_wage: 15.50,
        sin: "527024616"
      }

      post "/employees", params: params

      expect(response).to have_http_status(500)
      response_body = JSON.parse(response.body)

      expect(response_body["messages"].count).to eq(1)
    end
  end

  describe "GET /get_user" do
    it "returns http success" do
      user = create(:user)
      get "/employees/#{user.id}"
      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body["id"]).to eq(user.id)
    end

    it "throws error if user not found" do
      user = create(:user)
      get "/employees/-1"
      expect(response).to have_http_status(404)
    end
  end

  describe "PUT /update_user" do
    it "returns http success" do
      user = create(:user, email: "test@example.com")
      put "/employees/#{user.id}", params: { first_name: "joe", last_name: "smith" }

      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body["first_name"]).to eq("joe")
    end

    # if I had more time, I would include the tests from create here as well
  end

  describe "DELETE /delete_user" do
    it "returns http success" do
      user = create(:user)
      delete "/employees/#{user.id}"
      expect(response).to have_http_status(:success)
    end

    it "returns error if user not found" do
      delete "/employees/-1"
      expect(response).to have_http_status(404)
    end
  end

end
