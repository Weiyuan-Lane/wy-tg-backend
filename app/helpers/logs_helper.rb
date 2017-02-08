require 'json'
require 'english'
require 'csv'

module LogsHelper
  def combineHashPair (originalHash, overridingHash)
    return originalHash.clone.merge(overridingHash)
  end

  def combineHashes (hashes)
    mainHash = {}
    hashes.each_with_index do |hash, index|
      if index == 0
        mainHash = hash
      else
        mainHash = combineHashPair(mainHash, hash)
      end
    end

    return mainHash
  end

  def combineJsonObjects (jsonObjects)
    hashes = []
    jsonObjects.each do |jsonObject|
      hashes << JSON.parse(jsonObject)
    end

    mainHash = combineHashes(hashes)
    return mainHash.to_json
  end

  def isPositiveInteger? (str)
    str.size > 0 && str.to_i.to_s == str && str.to_i >= 0
  end

  def findCsvRowError (row)
    error = nil

    if row.size != 4
      error = 'Row does not have 4 entries'
    elsif !row.key?('object_id') || row['object_id'] == '' || !isPositiveInteger?(row['object_id'])
      error = 'Row object_id does not correspond to a valid integer'
    elsif !row.key?('object_type') || row['object_type'] == ''
      error = 'Row object_type does not correspond to a non-empty string'
    elsif !row.key?('timestamp') || row['timestamp'] == '' || !isPositiveInteger?(row['timestamp'])
      error = 'Row timestamp does not correspond to a valid integer'
    elsif !row.key?('object_changes')
      error = 'Row object_changes is not a valid json structure'
    else
      begin
        JSON.parse(row['object_changes'])
      rescue JSON::ParserError => e
        error = 'Row object_changes is not a valid json structure'
      end
    end

    return error
  end

  def findCsvFileError (file)
    error = nil
    if file.readlines.size == 0
      error = 'File is empty'
    else
      text = File.read(file).gsub(/\\"/,'""')
      CSV.parse(text, headers: true) do |row|
        rowError = findCsvRowError(row.to_hash)
        if !rowError.nil?
          error = 'Row ' + $INPUT_LINE_NUMBER.to_s + ': ' + rowError
          break
        end
      end
    end
    return error
  end

  def saveCSVFileContentsToDB (file)
    text = File.read(file).gsub(/\\"/,'""')
    arr = []
    CSV.parse(text, headers: true) do |row|
      rowHash = row.to_hash
      rowHash['log_timestamp'] = Time.at(rowHash['timestamp'].to_i)
      rowHash.delete('timestamp')
      puts(rowHash)
      arr << rowHash
    end

    Log.create(arr)
  end

  def findLogs (objectId, objectType, timestamp)
    Log.where(object_id: objectId, object_type: objectType)
       .where("log_timestamp <= ?", Time.at(timestamp.to_i))
       .order("log_timestamp")
  end
end
