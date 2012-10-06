# == Schema Information
#
# Table name: plan_details
#
#  id         :integer          not null, primary key
#  request_id :integer          default(0), not null
#  week       :integer          not null
#  percentage :integer          default(80), not null
#  ok_mon     :boolean          default(TRUE), not null
#  ok_tue     :boolean          default(TRUE), not null
#  ok_wed     :boolean          default(TRUE), not null
#  ok_thu     :boolean          default(TRUE), not null
#  ok_fri     :boolean          default(TRUE), not null
#  ok_sat     :boolean          default(FALSE), not null
#  ok_sun     :boolean          default(FALSE), not null
#

class PlanDetail < ActiveRecord::Base
  unloadable

  include Redmine::I18n

  belongs_to :request, :class_name => 'PlanRequest', :foreign_key => 'request_id'

  validates_uniqueness_of :week, :scope => [:request_id]

  attr_protected :request_id, :week, :week_start_date

  default_scope order(:week)


  def self.bulk_update(request, detail_params, num)
    detail_list = []

    start_date = detail_params[:week_start_date]
    if start_date
      date = Date.parse(start_date)
    else
      date = Date.commercial(detail_params[:year], detail_params[:week], 1)
    end

    for i in 1..num
      detail = self.where(:request_id => request.id, :week => date.cwyear * 100 + date.cweek).first_or_initialize
      detail.update_attributes(detail_params)
      detail_list << detail
      date += 7
    end
    detail_list
  end

  def cwyear
    week / 100
  end

  def cweek
    week % 100
  end

  def week_start_date
    return nil if week == nil
    Date.commercial(self.cwyear, self.cweek, 1)
  end

  def week_start_date=(str)
    date = Date.parse(str)
    self.week = date.cwyear * 100 + date.cweek
  end

  def can_edit?
    request.can_edit?
  end
end
