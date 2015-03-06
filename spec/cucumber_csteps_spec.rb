require 'spec_helper'
require 'cucumber_csteps'

include CucumberCsteps

describe "cucumber csteps parser" do
  it "should parse simple steps with no arguments" do
    line = 'GIVEN("the room is warm")()'

    step = CucumberCsteps.parse_cstep(line)
    step.keyword.should == "Given"
    step.regex.should == /the room is warm/
    step.c_args.should == [ ]
  end

  it "should parse simple steps with no arguments and trailing garbage" do
    line = 'GIVEN("the room is warm")() {'

    step = CucumberCsteps.parse_cstep(line)
    step.keyword.should == "Given"
    step.regex.should == /the room is warm/
    step.c_args.should == [ ]
  end


  it "should parse simple steps with one arguments" do
    line = 'GIVEN("the room is at (\d+) degrees")(int degrees)'

    step = CucumberCsteps.parse_cstep(line)
    step.keyword.should == "Given"
    step.regex.should == /the room is at (\d+) degrees/
    step.c_args.should == [ CArg.new('int', 'degrees') ]
  end

  it "should parse simple steps with more than one argument" do
    line = 'GIVEN("the room is at (\d+) degrees and (\d+) persons are in the room")(int degrees, int num_persons)'

    step = CucumberCsteps.parse_cstep(line)
    step.keyword.should == "Given"
    step.regex.should == /the room is at (\d+) degrees and (\d+) persons are in the room/
    step.c_args.should == [ CArg.new('int', 'degrees'), CArg.new('int', 'num_persons') ]
  end

  it "should work for string arguments" do
    # Given the room is warm
    line = 'GIVEN("the (\w+) is (\w+)")(char* room, char* temp)'

    step = CucumberCsteps.parse_cstep(line)
    step.keyword.should == "Given"
    step.regex.should == /the (\w+) is (\w+)/ 
    step.c_args.should == [ CArg.new('char*', 'room'), CArg.new('char*', 'temp') ]
  end

  it "should cope with escaped quotes" do
    # Given the "room" is "warm"
    line = 'GIVEN("the \"(\w+)\" is \"(\w+)\"")(char* room, char* temp)'

    step = CucumberCsteps.parse_cstep(line)
    step.keyword.should == "Given"
    step.regex.should == /the \"(\w+)\" is \"(\w+)\"/ 
    step.c_args.should == [ CArg.new('char*', 'room'), CArg.new('char*', 'temp') ]
  end

  it "should cope with commas" do
    line = 'GIVEN("a list with 1, 2, 3")()'

    step = CucumberCsteps.parse_cstep(line)
    step.keyword.should == "Given"
    step.regex.should == /a list with 1, 2, 3/ 
    step.c_args.should == []
  end
end
