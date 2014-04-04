class TimecardsController < ApplicationController

  before_action :set_timecard, only: [:show, :edit, :update, :destroy]

  # GET /timecards
  # GET /timecards.json
  def index
    @timecards = Timecard.all
  end

  # GET /timecards/1
  # GET /timecards/1.json
  def show
  end

  def upload_form
  end

  def upload
    file_data = params['Upload CSV']
    if file_data.respond_to?(:read)
      contents = file_data.read
      Timecard.upload_file_contents(contents)
      p "1111", contents
    elsif file_data.respond_to?(:path)
      xml_contents = File.read(file_data.path)
      p "222", xml_contents
    else
      logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
    end
    redirect_to timecards_url,  notice: "Uploading Records in Progress"
  end


  # GET /timecards/new
  def new
    @timecard = Timecard.new
  end

  # GET /timecards/1/edit
  def edit
  end

  # POST /timecards
  # POST /timecards.json
  def create
    @timecard = Timecard.new(timecard_params)

    respond_to do |format|
      if @timecard.save
        format.html { redirect_to @timecard, notice: 'Timecard was successfully created.' }
        format.json { render action: 'show', status: :created, location: @timecard }
      else
        format.html { render action: 'new' }
        format.json { render json: @timecard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /timecards/1
  # PATCH/PUT /timecards/1.json
  def update
    respond_to do |format|
      if @timecard.update(timecard_params)
        format.html { redirect_to @timecard, notice: 'Timecard was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @timecard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /timecards/1
  # DELETE /timecards/1.json
  def destroy
    @timecard.destroy
    respond_to do |format|
      format.html { redirect_to timecards_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_timecard
    @timecard = Timecard.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def timecard_params
    params.require(:timecard).permit(:week_ending_date, :name, :employee_id, :client, :project, :sub_project, :date, :billable_hours, :client_non_billable_hours, :tw_non_billable_hours, :country, :state, :work_responsibility, :percentage, :grade, :role)
  end



end
