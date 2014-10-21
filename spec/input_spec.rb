require_relative 'spec_helper.rb'

# input_spec.rb - That not adding an input parameter shows the help message and any other cases where it should bomb out.

describe "input parameters" do

  it "displays help message if input not specified" do
    run_simple "video-sprites no input"
    expect(stdout_from("video-sprites no input")).to start_with("Missing required option(s): input")
  end

end