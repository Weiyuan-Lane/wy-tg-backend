require 'json'
require 'english'

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
    elsif !row.key?(:object_id) || row[:object_id] == '' || !isPositiveInteger?(row[:object_id])
      error = 'Row object_id does not correspond to a valid integer'
    elsif !row.key?(:object_type) || row[:object_type] == ''
      error = 'Row object_type does not correspond to a non-empty string'
    elsif !row.key?(:timestamp) || row[:timestamp] == '' || !isPositiveInteger?(row[:timestamp])
      error = 'Row timestamp does not correspond to a valid integer'
    elsif !row.key?(:object_changes)
      error = 'Row object_changes is not a valid json structure'
    else
      begin
        JSON.parse(row[:object_changes])
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
      #Restore temp file
      file.seek(0)
      CSV.foreach(file.path, :headers => true) do |row|
        rowError = findCsvRowError(row)
        if !rowError.nil?
          error $INPUT_LINE_NUMBER + ' row: ' + rowError
          break
        end
      end
    end

    return error
  end
end
