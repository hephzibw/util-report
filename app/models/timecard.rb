require 'csv'

class Timecard
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :week_ending_date, type: Date
  field :name, type: String
  field :employee_id, type: String
  field :client, type: String
  field :project, type: String
  field :sub_project, type: String
  field :date, type: Date
  field :billable_hours, type: Float
  field :client_non_billable_hours, type: Float
  field :tw_non_billable_hours, type: Float
  field :country, type: String
  field :state, type: String
  field :work_responsibility, type: String
  field :percentage, type: Float
  field :grade, type: String
  field :role, type: String

  index({employee_id: 1, date: 1}, unique: true)

  TIMECARD_HEADER_MAPPING =
      {"Week Ending Dt" => :week_ending_date, "Name" => :name, "ID" => :employee_id, "Client" => :client,
       "Project" => :project, "Subproj" => :sub_project, "Date" => :date, "Billable" => :billable_hours,
       "Client Nonbillable" => :client_non_billable_hours, "TW Nonbillable" => :tw_non_billable_hours,
       "Time Cntry" => :country, "Time State" => :state, "Work Responsibility" => :work_responsibility,
       "Percent Allocation" => :percentage, "Grade" => :grade, "Role" => :role
      }

  def self.upload_file_contents contents
    records = []
    CSV.parse(contents, {:headers => true}) do |row|
      timecard = {}
      row.to_hash.each do |k, v|
        unless k.nil?
          key = TIMECARD_HEADER_MAPPING[k] || k.underscore.to_sym
          v = Time.strptime(v,'%m/%d/%Y') if [:week_ending_date, :date].include? key and !v.nil?
          timecard[key] = v
        end
      end
      records << timecard  if timecard != {}
    end
    Timecard.create records
  end
end
