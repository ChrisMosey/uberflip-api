class SinValidator < ActiveModel::Validator
  SIN_LENGTH = 9
  def validate(record)
    sin = record.sin
    raise StandardError if sin.blank? || sin.length != SIN_LENGTH
    sin_sum = 0
    sin.split("").each_with_index do |num_str, index|
      num = num_str.to_i

      multiplier = (index + 1)%2 == 0 ? 2 : 1

      new_num = num * multiplier

      if new_num > 9
        new_num = new_num.to_s[0].to_i + new_num.to_s[1].to_i
      end
      sin_sum += new_num
    end

    raise StandardError unless sin_sum%10 == 0
    
  rescue
    record.errors.add :base, "Sin invalid"
  end
end

class User < ApplicationRecord
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :email, :presence => true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :hourly_wage, :presence => true, numericality: true
  validates :sin, uniqueness: true
  validates_with SinValidator
end
