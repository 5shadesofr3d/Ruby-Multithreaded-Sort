require 'test/unit'
require 'csv'
require 'json'
class IOController
  include Test::Unit::Assertions

  def initialize(file)
    #pre
    assert file.is_a? String
    assert FileTest.exist? @fileName

    @fileName = file

    #post
    assert FileTest.exist? @fileName
    assert @fileName.is_a? String
  end

  #We assume the CSV file is ONE row, n cols.
  #We only support importing Numerics with CSV
  def parse_csv
    #pre
    assert @fileName.end_with? ".csv"
    assert FileTest.exist? @fileName

    objList = CSV.read(@fileName, converters: :numeric) #converts to numerics

    #post
    assert objList[0].is_a? Array
    assert objList[0].each { |a| assert a.is_a? Numeric }
    return objList[0] #grab 0 because we want to omit other rows
  end

  #header is the property in json file that values are stored under.. see test.json
  # ie for the json file: {"data":[42, 25, 11, 1111, 124151, 89]}
  # pass in the header value "data" and we will get the corresponding list attached to it
  def parse_json(header)
    #pre
    assert @fileName.end_with? ".json"
    assert header.is_a? String
    assert FileTest.exist? @fileName

    jsonFile = File.read(@fileName)
    objList = JSON.parse(jsonFile)
    data = objList[header]

    #post
    assert jsonFile.is_a? String
    assert data.is_a? Array
    assert data.each {|a| assert a.is_a? Numeric}
    return data
  end

end
