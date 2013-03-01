#! /usr/bin/env ruby

require 'net/http'
require 'csv'

last_successful = 0
current_record = []

SONAR_RESULT_TEST_COVERAGE = 'sonar_result_test_coverage'
File.new(SONAR_RESULT_TEST_COVERAGE, 'w') unless File.exists?(SONAR_RESULT_TEST_COVERAGE)

last_record_line = IO.readlines(SONAR_RESULT_TEST_COVERAGE)[-1]
unless last_record_line.nil?
  CSV::Reader.parse(last_record_line) {|row| last_successful = row.first.to_f}
end

url = "http://10.196.18.179:9000/dashboard/index/1"
data = Net::HTTP.get_response(URI.parse(url)).body
current_coverage =  data.scan(/\<span id='m_coverage'\s+?\>([0-9.]+)%\<\/span\>/i).flatten.first.to_f

current_record << [current_coverage, last_successful].max
current_record << current_coverage
current_record << Time.now
File.open(SONAR_RESULT_TEST_COVERAGE, 'a') { |file| CSV::Writer.generate(file)  {|csv| csv << current_record} }

if current_coverage < last_successful
  puts "测试覆盖率下降了！这绝对无法容忍"
  exit 1
end