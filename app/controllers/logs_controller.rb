class LogsController < ApplicationController
  include LogsHelper

  #Authentication configuration
  AUTH_CONFIG = YAML.load_file("#{Rails.root}/config/auth_config.yml")[Rails.env]
  if AUTH_CONFIG['perform_authentication']
    http_basic_authenticate_with name: AUTH_CONFIG['username'], password: AUTH_CONFIG['password']
  end

  def index
  end

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

    render 'index'
  end

  def queryOrderLogs
    queryParams = validateQueryParams
    if queryParams[:error].nil?
      logs = Log.where(object_id: queryParams[:params][:object_id],
                       object_type: 'Order')
                .where("log_timestamp <= ?",
                       Time.at(queryParams[:params][:object_changes].to_i))
                .order("log_timestamp")
      puts(logs)
      jsonObjects = []
      logs.each do |log|
        jsonObjects << log[:object_changes]
      end
      @consolidatedJson =  combineJsonObjects(jsonObjects)
    else
      @error = queryParams[:error]
    end

    render 'index'
  end

  private
    def validateQueryParams
      targetParams = params.permit(:object_id, :object_changes)
      result = {}
      if (targetParams[:object_id] && !isPositiveInteger?(targetParams[:object_id]))
        result[:error] = 'Furnished id is not valid'
      elsif (targetParams[:object_changes] && !isPositiveInteger?(targetParams[:object_changes]))
        result[:error] = 'Furnished timestamp is not valid'
      else
        result[:params] = targetParams
        result[:error] = nil
      end

      return result
    end
end
