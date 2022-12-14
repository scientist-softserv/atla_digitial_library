# NOTE(dewey4iv): overriden from bulkrax gem
# frozen_string_literal: true

require_dependency 'bulkrax/application_controller'
require_dependency 'oai'
require 'fileutils'

module Bulkrax
  class ImportersController < ApplicationController
    include Hyrax::ThemedLayoutController
    include Bulkrax::DownloadBehavior
    include Bulkrax::API
    include Bulkrax::ValidationHelper

    protect_from_forgery unless: -> { api_request? }
    before_action :token_authenticate!, if: -> { api_request? }, only: [:create, :update, :delete]
    before_action :authenticate_user!, unless: -> { api_request? }
    before_action :set_importer, only: [:show, :edit, :update, :destroy]
    with_themed_layout 'dashboard'

    # GET /importers
    def index
      @importers = Importer.all
      if api_request?
        json_response('index')
      else
        add_breadcrumb t(:'hyrax.controls.home'), main_app.root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb 'Importers', bulkrax.importers_path
      end
    end

    # GET /importers/1
    def show
      if api_request?
        json_response('show')
      else
        add_breadcrumb t(:'hyrax.controls.home'), main_app.root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb 'Importers', bulkrax.importers_path
        add_breadcrumb @importer.name
        @work_entries = @importer.entries
                                 .where(type: @importer.parser.entry_class.to_s)
                                 .page(params[:work_entries_page])
        @collection_entries = @importer.entries
                                       .where(type: @importer.parser.collection_entry_class.to_s)
                                       .page(params[:collections_entries_page])
      end
    end

    # GET /importers/new
    def new
      @importer = Importer.new
      if api_request?
        json_response('new')
      else
        add_breadcrumb t(:'hyrax.controls.home'), main_app.root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb 'Importers', bulkrax.importers_path
      end
    end

    # GET /importers/1/edit
    def edit
      if api_request?
        json_response('edit')
      else
        add_breadcrumb t(:'hyrax.controls.home'), main_app.root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb 'Importers', bulkrax.importers_path
      end
    end

    # POST /importers
    # rubocop:disable Metrics/MethodLength
    def create
      # rubocop:disable Style/IfInsideElse
      if api_request?
        return return_json_response unless valid_create_params?
      end
      file = params.to_unsafe_h[:importer][:parser_fields].delete(:file)
      cloud_files = params.to_unsafe_h.delete(:selected_files)
      @importer = Importer.new(importer_params)
      field_mapping_params
      @importer.validate_only = true if params[:commit] == 'Create and Validate'
      if @importer.save
        files_for_import(file, cloud_files)
        Bulkrax::ImporterJob.send(@importer.parser.perform_method, @importer.id)
        if api_request?
          json_response('create', :created, 'Importer was successfully created.')
        else
          redirect_to importers_path, notice: 'Importer was successfully created.'
        end
      else
        if api_request?
          json_response('create', :unprocessable_entity)
        else
          render :new
        end
      end

      # rubocop:enable Style/IfInsideElse
    end

    # PATCH/PUT /importers/1
    def update
      # rubocop:disable Style/IfInsideElse
      if api_request?
        return return_json_response unless valid_update_params?
      end
      # skipped for calls from continue
      if params[:importer][:parser_fields].present?
        file = params.to_unsafe_h[:importer][:parser_fields].delete(:file)
        cloud_files = params.to_unsafe_h.delete(:selected_files)
        field_mapping_params
      end

      if @importer.update(importer_params)
        files_for_import(file, cloud_files) unless file.nil? && cloud_files.nil?
        # do not perform the import
        if params[:commit] == 'Update Importer'
        # do nothing
        # OAI-only - selective re-harvest
        elsif params[:commit] == 'Update and Harvest Updated Items'
          Bulkrax::ImporterJob.perform_later(@importer.id, true)
        # Perform a full metadata and files re-import; do the same for an OAI re-harvest of all items
        elsif params[:commit] == ('Update and Re-Import (update metadata and replace files)' ||
                                  'Update and Re-Harvest All Items')
          @importer.parser_fields['replace_files'] = true
          @importer.save
          Bulkrax::ImporterJob.perform_later(@importer.id)
        # In all other cases, perform a metadata-only re-import
        else
          Bulkrax::ImporterJob.perform_later(@importer.id)
        end
        if api_request?
          json_response('updated', :ok, 'Importer was successfully updated.')
        else
          redirect_to importers_path, notice: 'Importer was successfully updated.'
        end
      else
        if api_request?
          json_response('update', :unprocessable_entity, 'Something went wrong.')
        else
          render :edit
        end
      end
      # rubocop:enable Style/IfInsideElse
    end
    # rubocop:enable Metrics/MethodLength

    # DELETE /importers/1
    def destroy
      @importer.destroy
      if api_request?
        json_response('destroy', :ok, notice: 'Importer was successfully destroyed.')
      else
        redirect_to importers_url, notice: 'Importer was successfully destroyed.'
      end
    end

    # PUT /importers/1
    def continue
      @importer = Importer.find(params[:importer_id])
      params[:importer] = { name: @importer.name }
      @importer.validate_only = false
      update
    end

    # GET /importer/1/upload_corrected_entries
    def upload_corrected_entries
      @importer = Importer.find(params[:importer_id])
      add_breadcrumb t(:'hyrax.controls.home'), main_app.root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb 'Importers', bulkrax.importers_path
      add_breadcrumb @importer.name, bulkrax.importer_path(@importer.id)
      add_breadcrumb 'Upload Corrected Entries'
    end

    # POST /importer/1/upload_corrected_entries_file
    def upload_corrected_entries_file
      file = params[:importer][:parser_fields].delete(:file)
      @importer = Importer.find(params[:importer_id])
      if file.present?
        @importer[:parser_fields]['partial_import_file_path'] = @importer.parser.write_partial_import_file(file)
        @importer.save
        Bulkrax::ImporterJob.perform_later(@importer.id, true)
        redirect_to importer_path(@importer), notice: 'Corrected entries uploaded successfully.'
      else
        redirect_to importer_upload_corrected_entries_path(@importer), alert: 'Importer failed to update with new file.'
      end
    end

    def external_sets
      if list_external_sets
        render json: { base_url: params[:base_url], sets: @sets }
      else
        render json: { base_url: params[:base_url], error: "unable to pull data from #{params[:base_url]}" }
      end
    end

    # GET /importers/1/export_errors
    def export_errors
      @importer = Importer.find(params[:importer_id])
      @importer.write_errored_entries_file
      send_content
    end

    private

      def files_for_import(file, cloud_files)
        return if file.blank? && cloud_files.blank?

        @importer[:parser_fields]['import_file_path'] = @importer.parser.write_import_file(file) if file.present?
        if cloud_files.present?
          # For BagIt, there will only be one bag, so we get the file_path back and set import_file_path
          # For CSV, we expect only file uploads, so we won't get the file_path back
          # and we expect the import_file_path to be set already
          target = @importer.parser.retrieve_cloud_files(cloud_files)
          @importer[:parser_fields]['import_file_path'] = target if target.present?
        end
        @importer.save
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_importer
        @importer = Importer.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def importer_params
        params.require(:importer).permit(
          :name,
          :admin_set_id,
          :user_id,
          :frequency,
          :parser_klass,
          :limit,
          :validate_only,
          selected_files: {},
          field_mapping: {},
          parser_fields: [valid_parser_fields] # NOTE(dewey4iv): overriden from bulkrax gem
        )
      end

      # NOTE(dewey4iv): overriden from bulkrax gem
      # TODO(dewey4iv): we need to upgrade the version of bulkrax.
      # Upgrading bulkrax was a bigger ask that the time allowed.
      def valid_parser_fields
        params&.[](:importer)&.[](:parser_fields)&.keys - ["file"]
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

      def field_mapping_params
        # @todo replace/append once mapping GUI is in place
        field_mapping_key = Bulkrax.parsers.map do |m|
          m[:class_name] if m[:class_name] == params[:importer][:parser_klass]
        end .compact.first
        @importer.field_mapping = Bulkrax.field_mappings[field_mapping_key] if field_mapping_key
      end

      def setup_client(url)
        return false if url.nil?
        headers = { from: Bulkrax.server_name }
        @client ||= OAI::Client.new(url, headers: headers, parser: 'libxml', metadata_prefix: 'oai_dc')
      end

      # Download methods

      def file_path
        @importer.errored_entries_csv_path
      end

      def download_content_type
        'text/csv'
      end
  end
end
