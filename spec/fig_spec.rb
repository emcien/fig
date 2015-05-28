require "spec_helper"
require "pry"

describe Fig::Config do
  let(:cfg) do
    Fig::Config.new(
      yaml_path("params.yml"),
      yaml_path("defaults.yml"),
      yaml_path("config.yml"),
      "FIG")
  end

  it "should provide the expected top level config keys" do
    expect(cfg).to_not be_nil
    expect(cfg.foo).to_not be_nil
  end

  it "should have a correct config for base" do
    expect(cfg.a).to eq("goodbye")
    expect(cfg.b).to eq(2)
  end

  it "should have correct types for all supplied values" do
    expect(cfg.a).to be_a(String)
    expect(cfg.foo.real).to be_a(FalseClass)
    expect(cfg.foo.how_many).to be_a(Fixnum)
  end

  it "should have correct types for all default values" do
    expect(cfg.b).to be_a(Fixnum)
  end
end
