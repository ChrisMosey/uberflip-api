class UsersController < ApplicationController
  def get_users
    limit = params[:limit] || 10
    first_name = params[:first_name]
    last_name = params[:last_name]

    args = {}
    args[:first_name] = first_name unless first_name.blank?
    args[:last_name] = last_name unless last_name.blank?

    users = User.limit(limit)

    users = users.where(**args) unless args.blank?

    render json: users, status: 200
  end

  def create_user
    first_name = params[:first_name]
    last_name = params[:last_name]
    email = params[:email]
    hourly_wage = params[:hourly_wage]
    sin = params[:sin]

    user = User.new(
      first_name: first_name,
      last_name: last_name,
      email: email,
      hourly_wage: hourly_wage,
      sin: sin
    )

    raise StandardError unless user.valid?

    user.save!

    render json: user, status: 200

  rescue StandardError
    render json: { messages: user.errors.map(&:type) }, status: 500
  end

  def get_user
    user_id = params[:user_id]

    user = User.find(user_id)

    raise StandardError if user.blank?

    render json: user, status: 200

  rescue StandardError
    render json: { message: "User not Found" }, status: 404
  end

  def update_user
    user_id = params[:user_id]
    first_name = params[:first_name]
    last_name = params[:last_name]
    email = params[:email]
    hourly_wage = params[:hourly_wage]
    sin = params[:sin]

    user = User.find(user_id)
    
    user.assign_attributes(
      first_name: first_name || user.first_name,
      last_name: last_name || user.last_name,
      email: email || user.email,
      hourly_wage: hourly_wage || user.hourly_wage,
      sin: sin || user.sin
    )

    raise StandardError unless user.valid?

    user.save!

    render json: user, status: 200

  rescue StandardError
    render json: { messages: user.errors.map(&:type) }, status: 500
  end

  def delete_user
    user_id = params[:user_id]
    
    user = User.find(user_id)

    raise StandardError if user.blank?

    user.delete # normally would mark as deleted, but keep the record

    render json: { message: "success" }, status: 201

  rescue StandardError
    render json: { message: "user not found" }, status: 404
  end
end
