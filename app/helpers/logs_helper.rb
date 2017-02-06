require 'json'

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
end
