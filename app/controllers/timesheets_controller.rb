require 'exceptions'
class TimesheetsController < ApplicationController
  def get_timesheets
    user_id = params[:employee_id]
    start_datetime = params[:start_datetime]
    end_datetime = params[:end_datetime]
    limit = params[:limit] || 10

    args = {}
    args[:user_id] = user_id unless user_id.blank?

    # should make it not dependant on both start and end date
    # if start is blank, check beginning of time to end
    # if end is blank, start date to end of time
    args[:start] = start_datetime..end_datetime unless start_datetime.blank?

    timesheets = Timesheet.limit(limit)

    timesheets = timesheets.where(**args) unless args.blank?

    json_data = []

    timesheets.each do |timesheet|
      wage_owed = 0
      if timesheet.start.present? && timesheet.end.present?
        wage_owed = (timesheet.end.to_time - timesheet.start.to_time) / 1.hours
        wage_owed = wage_owed.round(2)
      end

      json_data << {
        start: timesheet.start,
        end: timesheet.end,
        user_id: timesheet.user_id,
        first_name: timesheet.user.first_name,
        last_name: timesheet.user.last_name,
        email: timesheet.user.email,
        hourly_wage: timesheet.user.hourly_wage,
        wage_owed: wage_owed,
      }
    end

    render json: json_data, status: 200
  end

  def clock_in
    user_id = params[:user_id]

    user = User.find_by(id: user_id)
    raise Exceptions::UserNotFoundError if user.blank?

    last_timesheet = Timesheet.find_by(user_id: user_id)
    raise Exceptions::TimesheetNotValidError if (last_timesheet && last_timesheet.end.blank?)

    timesheet = Timesheet.create(user_id: user_id, start: Time.now)

    render json: timesheet, status: 200
  rescue Exceptions::UserNotFoundError
    render json: { message: "User not Found" }, status: 404
  rescue Exceptions::TimesheetNotValidError
    render json: { message: "Cannot clock in before clocking out" }, status: 500
  end

  def clock_out
    user_id = params[:user_id]

    user = User.find_by(id: user_id)
    raise Exceptions::UserNotFoundError if user.blank?

    last_timesheet = Timesheet.find_by(user_id: user_id)
    raise Exceptions::TimesheetNotValidError unless last_timesheet.end.blank?

    timesheet = Timesheet.create(user_id: user_id, end: Time.now)

    render json: timesheet, status: 200
  rescue Exceptions::UserNotFoundError
    render json: { message: "User not Found" }, status: 404
  rescue Exceptions::TimesheetNotValidError
    render json: { message: "Cannot clock out before clocking in" }, status: 500
  end
end
