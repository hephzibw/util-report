json.array!(@timecards) do |timecard|
  json.extract! timecard, :id, :week_ending_date, :name, :employee_id, :client, :project, :sub_project, :date, :billable_hours, :client_non_billable_hours, :tw_non_billable_hours, :country, :state, :work_responsibility, :percentage, :grade, :role
  json.url timecard_url(timecard, format: :json)
end
