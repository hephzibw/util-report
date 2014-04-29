require 'csv'

class Timecard
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :working_office, type: String
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
       "Percent Allocation" => :percentage, "Grade" => :grade, "Role" => :role,
       "Work in Office as of End Dt" => :working_office
      }

  def self.upload_file_contents contents
    CSV.parse(contents, {:headers => true}) do |row|
      timecard = {}
      row.to_hash.each do |k, v|
        unless k.nil?
          key = TIMECARD_HEADER_MAPPING[k] || k.underscore.to_sym
          v = Date.strptime(v, '%m/%d/%y') if [:week_ending_date, :date].include? key and !v.nil?
          timecard[key] = v
        end
      end
      if timecard != {}
        Timecard.where(:employee_id => timecard[:employee_id], :date => timecard[:date], :project => timecard[:project]).first_or_initialize do |timecard_entry|
         timecard_entry.update(timecard)
        end
      end
    end
  end

  def self.latest_week_ending_date_display
    date = latest_week_ending_date
    "#{date.day}-#{date.month}-#{date.year}"
  end

  def self.latest_week_ending_date
    Timecard.distinct(:week_ending_date).last
  end

  def self.hours_distribution
    match = {"$match" => {"week_ending_date" => latest_week_ending_date, "country" => "IND"}}
    group = {"$group" => {
        "_id" => "$country",
        "billable_hours" => {"$sum" => "$billable_hours"},
        "client_non_billable_hours" => {"$sum" => "$client_non_billable_hours"},
        "tw_non_billable_hours" => {"$sum" => "$tw_non_billable_hours"}
    }
    }

    result = Timecard.collection.aggregate([match, group]).first
    utilization = utilization(result)
    non_billable = 100 - utilization

    [
        {name: 'Billable Hours', y: utilization, sliced: true, selected: true},
        ['Non-Billable Hours', non_billable]
    ]
  end

  def self.by_country_distribution
    match = {"$match" => {"week_ending_date" => latest_week_ending_date, "country" => {"$ne" => nil}}}
    group = {"$group" => {
        "_id" => "$country",
        "billable_hours" => {"$sum" => "$billable_hours"},
        "client_non_billable_hours" => {"$sum" => "$client_non_billable_hours"},
        "tw_non_billable_hours" => {"$sum" => "$tw_non_billable_hours"}
    }
    }

    results = Timecard.collection.aggregate([match, group])

    results.collect do |row|
      {
          name: row["_id"],
          data: utilization(row)
      }
    end
  end

  def self.by_office_distribution
    calculate_utilization_by "working_office"
  end


  def self.by_role_distribution
    calculate_utilization_by "role"
  end

  def self.by_grade_distribution
    calculate_utilization_by "grade"
  end

  def self.by_project_distribution
    calculate_utilization_by "project"
  end

  def self.calculate_utilization_by parameter
    match = {"$match" => {"week_ending_date" => latest_week_ending_date, "country" => "IND", parameter => {"$ne" => nil}}}
    group = {"$group" => {
        "_id" => "$#{parameter}",
        "billable_hours" => {"$sum" => "$billable_hours"},
        "client_non_billable_hours" => {"$sum" => "$client_non_billable_hours"},
        "tw_non_billable_hours" => {"$sum" => "$tw_non_billable_hours"}
    }
    }

    results = Timecard.collection.aggregate([match, group])

    results.collect do |row|
      {
          name: row["_id"],
          data: utilization(row)
      }
    end
  end

  def self.utilization(row)
    ((row["billable_hours"] * 100) / (row["billable_hours"] + row["tw_non_billable_hours"] + row["client_non_billable_hours"])).round(2)
  end


end
