require 'test_helper'
require 'json'

class LogsHelperTest < ActionView::TestCase
  firstHash = {}
  firstHash["overriding"] = "or_first"
  firstHash["original_first"] = "o_first"

  secondHash = {}
  secondHash["overriding"] = "or_second"
  secondHash["original_second"] = "o_second"

  thirdHash =  {}
  thirdHash["overriding"] = "or_third"
  thirdHash["original_third"] = "o_third"

  test "Combine incorrect hash pair" do
    answer = {}
    answer["overriding"] = "or_second"
    answer["original_first"] = "o_first"
    answer["original_second"] = "o_second"

    assert_not_equal answer, combineHashPair(secondHash, firstHash)
  end

  test "Combine hash pair" do
    answer = {}
    answer["overriding"] = "or_second"
    answer["original_first"] = "o_first"
    answer["original_second"] = "o_second"

    assert_equal answer, combineHashPair(firstHash, secondHash)
  end

  test "Combine incorrect hashes" do
    answer = {}
    answer["original_first"] = "o_first"
    answer["original_second"] = "o_second"
    answer["original_third"] = "o_third"
    answer["overriding"] = "or_third"
    assert_not_equal answer, combineHashes([thirdHash, firstHash, secondHash])
  end

  test "Combine hashes" do
    answer = {}
    answer["original_first"] = "o_first"
    answer["original_second"] = "o_second"
    answer["original_third"] = "o_third"
    answer["overriding"] = "or_third"

    assert_equal answer, combineHashes([firstHash, secondHash, thirdHash])
  end

  test "Combine incorrect JSON objects" do
    answer = {}
    answer["original_first"] = "o_first"
    answer["original_second"] = "o_second"
    answer["original_third"] = "o_third"
    answer["overriding"] = "or_third"
    jsonAns = combineJsonObjects([thirdHash.to_json,
                                  firstHash.to_json,
                                  secondHash.to_json])

    assert_not_equal answer, JSON.parse(jsonAns)
  end

  test "Combine JSON objects" do
    answer = {}
    answer["original_first"] = "o_first"
    answer["original_second"] = "o_second"
    answer["original_third"] = "o_third"
    answer["overriding"] = "or_third"
    jsonAns = combineJsonObjects([firstHash.to_json,
                                  secondHash.to_json,
                                  thirdHash.to_json])

    assert_equal answer, JSON.parse(jsonAns)
  end

  test "Incorrect integer - empty string check" do
    integer = ''
    assert_not isPositiveInteger?(integer)
  end

  test "Incorrect integer - random string check" do
    integer = 'abc10'
    assert_not isPositiveInteger?(integer)
  end

  test "Incorrect integer - negative check" do
    integer = '-10'
    assert_not isPositiveInteger?(integer)
  end

  test "Correct integer check" do
    integer = '10'
    assert isPositiveInteger?(integer)
  end

  test "Empty CSV row" do
    csvRow = {}
    answer = 'Row does not have 4 entries'

    assert_equal answer, findCsvRowError(csvRow)
  end

  test "CSV row missing object_id" do
    csvRow = {}
    csvRow['object_id_name_wrong'] = '1'
    csvRow['object_type'] = 'Order'
    csvRow['timestamp'] = '1'
    csvRow['object_changes'] = "{\"customer_name\":\"Jack\"}"

    answer = 'Row object_id does not correspond to a valid integer'

    assert_equal answer, findCsvRowError(csvRow)
  end

  test "CSV row missing object_type" do
    csvRow = {}
    csvRow['object_id'] = '1'
    csvRow['object_type_name_wrong'] = 'Order'
    csvRow['timestamp'] = '1'
    csvRow['object_changes'] = "{\"customer_name\":\"Jack\"}"

    answer = 'Row object_type does not correspond to a non-empty string'

    assert_equal answer, findCsvRowError(csvRow)
  end

  test "CSV row empty object_type" do
    csvRow = {}
    csvRow['object_id'] = '1'
    csvRow['object_type'] = ''
    csvRow['timestamp'] = '1'
    csvRow['object_changes'] = "{\"customer_name\":\"Jack\"}"

    answer = 'Row object_type does not correspond to a non-empty string'

    assert_equal answer, findCsvRowError(csvRow)
  end

  test "CSV row missing timestamp" do
    csvRow = {}
    csvRow['object_id'] = '1'
    csvRow['object_type'] = 'Object'
    csvRow['timestamp_name_wrong'] = '1'
    csvRow['object_changes'] = "{\"customer_name\":\"Jack\"}"

    answer = 'Row timestamp does not correspond to a valid integer'

    assert_equal answer, findCsvRowError(csvRow)
  end

  test "CSV row missing object_changes" do
    csvRow = {}
    csvRow['object_id'] = '1'
    csvRow['object_type'] = 'Object'
    csvRow['timestamp'] = '1'
    csvRow['object_changes_name_wrong'] = "{\"customer_name\":\"Jack\"}"

    answer = 'Row object_changes is not a valid json structure'

    assert_equal answer, findCsvRowError(csvRow)
  end

  test "CSV row invalid object_changes json" do
    csvRow = {}
    csvRow['object_id'] = '1'
    csvRow['object_type'] = 'Object'
    csvRow['timestamp'] = '1'
    csvRow['object_changes'] = "{\"customer_name\":\"Jack\""

    answer = 'Row object_changes is not a valid json structure'

    assert_equal answer, findCsvRowError(csvRow)
  end

  test "CSV row correct" do
    csvRow = {}
    csvRow['object_id'] = '1'
    csvRow['object_type'] = 'Object'
    csvRow['timestamp'] = '1'
    csvRow['object_changes'] = "{\"customer_name\":\"Jack\"}"

    assert_not findCsvRowError(csvRow)
  end

  test "Empty CSV file" do
    csvFile = file_fixture('logs_empty.csv')
    assert_equal 'File is empty', findCsvFileError(csvFile)
  end

  test "CSV file with only headers" do
    csvFile = file_fixture('logs_only_headers.csv')
    assert_not findCsvFileError(csvFile)
  end

  test "CSV file not csv" do
    csvFile = file_fixture('logs_not_csv.csv')
    assert_equal 'Row 2: Row does not have 4 entries', findCsvFileError(csvFile)
  end

  test "CSV file with one correct row" do
    csvFile = file_fixture('logs_one_correct_row.csv')
    assert_not findCsvFileError(csvFile)
  end

  test "CSV file with seven correct row" do
    csvFile = file_fixture('logs_seven_correct_rows.csv')
    assert_not findCsvFileError(csvFile)
  end
end
