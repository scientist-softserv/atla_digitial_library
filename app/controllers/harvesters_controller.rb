class HarvestersController < ApplicationController
  include Sufia::DashboardControllerBehavior

  before_action :set_harvester, only: [:show, :edit, :update, :destroy]
  before_action :new_and_edit_befores, only: [:new, :edit]

  def index
    @harvesters = Harvester.all
  end

  def show
  end

  def new
    @harvester = Harvester.new
  end

  def edit
  end

  def create
    @harvester = Harvester.new(harvester_params)

    respond_to do |format|
      if @harvester.save
        format.html { redirect_to harvesters_path, notice: 'Harvester was successfully created.' }
        format.json { render :show, status: :created, location: @harvester }

        if params[:commit] == 'Create And Harvest'
          HarvestSetJob.perform_later(@harvester.id)
        end
      else
        format.html { render :new }
        format.json { render json: @harvester.errors, status: :unprocessable_entity }
      end
    end

  end

  def update
    respond_to do |format|
      if @harvester.update(harvester_params)
        format.html { redirect_to harvesters_path, notice: 'Harvester was successfully updated.' }
        format.json { render :show, status: :ok, location: @harvester }

        if params[:commit] == 'Harvest Updates'
          HarvestSetJob.perform_later(@harvester.id)
        elsif params[:commit] == 'Re-Harvest All Data' # here we reset the last_harvested_at to ensure that we are pulling all new data
          HarvestSetJob.perform_later(@harvester.id)
        end
      else
        format.html { render :edit }
        format.json { render json: @harvester.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @harvester.destroy
    respond_to do |format|
      format.html { redirect_to harvesters_url, notice: 'Harvester was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def external_sets
    if list_external_sets
      render json: { base_url: params[:base_url], sets: @sets }
    else
      render json: { base_url: params[:base_url], error: "unable to pull data from #{params[:base_url]}" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_harvester
      @harvester = Harvester.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def harvester_params
      params.require(:harvester).permit(:name, :base_url, :user_id, :admin_set_id, :institution_name, :metadata_prefix, :external_set_id, :frequency, :limit, :importer_name, :right_statement, :thumbnail_url)
    end

    def new_and_edit_befores
      rights_statements
      admin_sets
      list_external_sets
    end

    def rights_statements
      @rights ||= CurationConcerns::LicenseService.new
    end

    def admin_sets
      @admin_sets = []
      AdminSet.all.each { |a| @admin_sets << ["#{a.title.first} (#{a.id})", a.id] }
    end

    def list_external_sets
      url = params[:base_url] || (@harvester ? @harvester.base_url : nil)
      setup_client(url) if url.present?

      @sets = [['All', 'all']]

      begin
        @client.list_sets.each do |s|
          @sets << [s.name, s.spec]
        end
      rescue
        return false
      end

      @sets
    end

    def setup_client(url)
      return false if url.nil?

      headers = { from: 'server@atla.com' }

      @client ||= OAI::Client.new(url, headers: headers, parser: 'libxml', metadata_prefix: 'oai_dc')
    end
end
