require 'test_helper'
require 'json'

class LogsHelperTest < ActionView::TestCase
  firstHash = {}
  firstHash["overriding"] = "or_first"
  firstHash["original_first"] = "o_first"

  secondHash = {}
  secondHash["overriding"] = "or_second"
  secondHash["original_second"] = "o_second"

  answerOne = {}
  answerOne["overriding"] = "or_second"
  answerOne["original_first"] = "o_first"
  answerOne["original_second"] = "o_second"

  test "Combine hash pair" do
    assert_equal answerOne, combineHashPair(firstHash, secondHash)
  end
  test "Combine incorrect hash pair" do
    assert_not_equal answerOne, combineHashPair(secondHash, firstHash)
  end

  thirdHash =  {}
  thirdHash["overriding"] = "or_third"
  thirdHash["original_third"] = "o_third"

  answerTwo = answerOne.clone
  answerTwo["original_third"] = "o_third"
  answerTwo["overriding"] = "or_third"

  test "Combine hashes" do
    assert_equal answerTwo, combineHashes([firstHash, secondHash, thirdHash])
  end
  test "Combine incorrect hashes" do
    assert_not_equal answerTwo, combineHashes([thirdHash, firstHash, secondHash])
  end

  answerThree = answerTwo.clone.to_json
  test "Combine JSON objects" do
    assert_equal answerThree, combineJsonObjects([firstHash.to_json, secondHash.to_json, thirdHash.to_json])
  end
  test "Combine incorrect JSON objects" do
    assert_not_equal answerThree, combineJsonObjects([thirdHash.to_json, firstHash.to_json, secondHash.to_json])
  end
end
