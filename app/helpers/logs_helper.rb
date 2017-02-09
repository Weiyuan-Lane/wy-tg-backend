require 'json'
require 'english'
require 'csv'

# To be included in the logs controller class, as a service file to simplify the
# code between the model and the controller
module LogsHelper

  # Combine two hashes to one hash
  # The second hash is always the hash that has precedence in the hash values
  # Returns the fallback locales for the_locale.
  #
  # For example:
  #   combineHashPair ({unique: 'One', overriding: 'Two'}, {overriding: 'Three'})
  #     => {unique: 'One', overriding: 'Three'}
  def combineHashPair (originalHash, overridingHash)
    return originalHash.clone.merge(overridingHash)
  end

  # For several input hashes, utilise combineHashPair to combine hashes, with
  # higher indexes of the collection having increased precedence in values to be
  # preserved
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

  # For several input jsons, utilise combineHashes to combine hashes, with
  # higher indexes of the collection having increased precedence in values to be
  # preserved
  def combineJsonObjects (jsonObjects)
    hashes = []
    jsonObjects.each do |jsonObject|
      hashes << JSON.parse(jsonObject)
    end

    mainHash = combineHashes(hashes)
    return mainHash.to_json
  end

  # Given some string, return the boolean condition if the str corresponds to a
  # positive integer
  #
  # For example:
  #   isPositiveInteger? "10"
  #     => true
  #   isPositiveInteger? "this is a string"
  #     => false
  def isPositiveInteger? (str)
    str.size > 0 && str.to_i.to_s == str && str.to_i >= 0
  end

  # For the log model columns, check if a row of contents read from csv file are
  # present and return the earliest error found for the row (if structure or
  # data types are not satisfactory)
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

  # From an input csv file, check if the contents fit the csv assumptions for
  # inserting into the Log model. Utilises the findCsvRowError function to check
  # for each row. The function will return an error, if the csv contents are not
  # valid
  #
  # For example:
  #   findCsvFileError (badFile)
  #     => "Some error here"
  #   findCsvFileError (goodFile)
  #     => nil
  def findCsvFileError (file)
    error = nil
    if file.readlines.size == 0
      error = 'File is empty'
    else
      # Convert escape quotes, CSV library can't read without exception
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

  # From a csv file with validated contents for Log model, create the Log
  # entries and batch insert
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

  # Find all logs that fit the query parameters, ordered in ascending timestamps
  def findLogs (objectId, objectType, timestamp)
    Log.where(object_id: objectId, object_type: objectType)
       .where("log_timestamp <= ?", Time.at(timestamp.to_i))
       .order("log_timestamp")
  end
end
