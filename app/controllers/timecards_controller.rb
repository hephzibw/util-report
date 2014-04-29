class TimecardsController < ApplicationController


  def upload_form
  end

  def upload
    file_data = params['Upload CSV']
    if file_data.respond_to?(:read)
      contents = file_data.read
      Timecard.upload_file_contents(contents)
    else
      logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
    end
    redirect_to authenticated_root_path,  notice: "Uploading Records in Progress"
  end

  def report
  end

end
