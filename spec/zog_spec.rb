require 'spec_helper'

describe "Zog, the global module" do
  subject { Zog }
  it 'loads without crashing' do
    expect(subject).to_not be_nil
  end

  it 'creates a internal default Zog::Heart instance' do
    expect(subject.class_variable_defined?(:@@zog)).to be_truthy
    expect(subject.class_variable_get(:@@zog)).to be_instance_of(Zog::Heart)
  end

  it 'configures internal Zog::Heart instance' do
    expect{ subject.deny(:all, :_zog_internal) }.to_not raise_error
  end

  it 'passes all methods/logger calls to internal default Zog::Heart instance' do #note we switch off _zog_internal above
    expect{ subject._zog_internal("test message") }.to_not output.to_stderr
  end

end