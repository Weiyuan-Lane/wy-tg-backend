class LogsController < ApplicationController
  include LogsHelper

  #Authentication configuration
  AUTH_CONFIG = YAML.load_file("#{Rails.root}/config/auth_config.yml")[Rails.env]
  if AUTH_CONFIG['perform_authentication']
    http_basic_authenticate_with name: AUTH_CONFIG['username'], password: AUTH_CONFIG['password']
  end

  def index
    render 'setCsv'
  end

  def setCsv
  end

  # Route corresponds to uploading of csv file for instantiating one or more
  # logs
  def uploadCsv
    #  Validate file parameter
    if params[:file].blank? || !params[:file].respond_to?(:read)
      @error = 'No valid file uploaded'
    else
      uploadedCsv = params[:file].tempfile
      @error = findCsvFileError(uploadedCsv)
    end

    #  No error found - save
    if @error.nil?
      @logs = saveCSVFileContentsToDB(uploadedCsv)
    end
    render 'setCsv'
  end

  def queryLogs
  end

  # Route correponds to retrieval of logs and compressing the json data
  # single structure for representation purposes
  def retrieveLogs
    queryParams = validateQueryParams
    if queryParams[:error].nil?
      logs = findLogs(queryParams[:params][:object_id],
                      queryParams[:params][:object_type],
                      queryParams[:params][:timestamp])
      jsonObjects = []
      logs.each do |log|
        jsonObjects << log[:object_changes]
      end
      @consolidatedJson =  combineJsonObjects(jsonObjects)
    else
      @error = queryParams[:error]
    end
    render 'queryLogs'
  end

  private
    # Perform validation on query parameters, prepared for the log model
    def validateQueryParams
      targetParams = params.permit(:object_id, :timestamp, :object_type)
      result = {}
      if (!targetParams.key?(:object_id) ||  !isPositiveInteger?(targetParams[:object_id]))
        result[:error] = 'Furnished id is not valid'
      elsif (!targetParams.key?(:object_type) || targetParams[:object_type] == '')
        result[:error] = 'Furnished type is not valid'
      elsif (!targetParams.key?(:timestamp) || !isPositiveInteger?(targetParams[:timestamp]))
        result[:error] = 'Furnished timestamp is not valid'
      else
        result[:params] = targetParams
        result[:error] = nil
      end

      return result
    end
end
