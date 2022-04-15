require 'rails_helper'

RSpec.describe "Employees", type: :request do
  describe "GET /" do
    it "returns all timesheets" do
      create(:timesheet)
      get "/timesheets"

      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body.count).to eq(1)
    end

    it "returns timesheets with correct wages" do
      user = create(:user, hourly_wage: 12, sin: 192260636)
      create(:timesheet, start: Time.now.yesterday, end: Time.now)
      get "/timesheets"

      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body.first["wage_owed"]).to eq(24.0)
    end

    it "limits timesheet results" do
      create(:timesheet)
      create(:timesheet, user: create(:user, sin: 934679382))

      get "/timesheets", params: { limit: 1 }

      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body.count).to eq(1)
    end

    it "filters by user id" do
      create(:timesheet)
      timesheet = create(:timesheet, user: create(:user, sin: 934679382))

      get "/timesheets", params: { employee_id: timesheet.user_id }

      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body.count).to eq(1)
      expect(response_body.first["user_id"]).to eq(timesheet.user_id)
    end

    it " filters by start date" do
      create(:timesheet, start: Time.now.yesterday)
      create(:timesheet, start: Time.now.days_ago(3), user: create(:user, sin: 934679382))

      get "/timesheets", params: { from_datetime: Time.now.days_ago(2), to_datetime: Time.now }

      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)

      expect(response_body.count).to eq(1)
    end
  end

  describe "POST /clock_in" do
    it "clocks in an employee" do
      user = create(:user)
      post "/timesheets/#{user.id}/clock_in"

      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)
      response_start_time = response_body["start"].to_datetime.strftime('%H:%M')

      expect(response_start_time).to eq(Time.now.strftime('%H:%M')) # this could be flakey
    end

    it "errors if user is not found" do
      post "/timesheets/-1/clock_in"

      expect(response).to have_http_status(404)
    end

    it "errors if there is still an open clock in" do
      user = create(:user)
      timesheet = create(:timesheet, user: user, start: Time.now.yesterday)

      post "/timesheets/#{user.id}/clock_in"

      expect(response).to have_http_status(500)
    end
  end

  describe "POST /clock_out" do
    it "clocks out an employee" do
      user = create(:user)
      timesheet = create(:timesheet, user: user, start: Time.now.yesterday)
      post "/timesheets/#{user.id}/clock_out"

      expect(response).to have_http_status(:success)

      response_body = JSON.parse(response.body)
      response_end_time = response_body["end"].to_datetime.strftime('%H:%M')

      expect(response_end_time).to eq(Time.now.strftime('%H:%M')) # this could be flakey
    end

    it "errors if the user is not found" do
      post "/timesheets/-1/clock_out"

      expect(response).to have_http_status(404)
    end

    it "errors if there is no open clock in" do
      user = create(:user)
      timesheet = create(:timesheet, user: user, start: Time.now.yesterday, end: Time.now)
      post "/timesheets/#{user.id}/clock_out"

      expect(response).to have_http_status(500)
    end
  end
end