require_relative 'spec_helpers'

describe Config do
  describe 'once loaded' do
    let(:config) do
      Peril::Config.new(
        'present' => 'value',
        'multi' => { 'tiered' => 'thing' }
      )
    end

    it 'accesses values by string' do
      config.optional('present').must_equal 'value'
    end

    it 'accesses values by symbol' do
      config.optional(:present).must_equal 'value'
    end

    it 'accesses multi-tiered values' do
      config.optional(:multi, :tiered).must_equal 'thing'
    end

    it 'defaults to nil' do
      config.optional(:missing).must_be_nil
    end

    it 'defaults to nil for multi-tiered configs' do
      config.optional(:missing, :multi).must_be_nil
    end

    it 'allows a specified default' do
      config.default(:missing, 'foo').must_equal 'foo'
      config.default(%w(missing multi), 'foo').must_equal 'foo'
      config.default(%w(multi missing), 'foo').must_equal 'foo'
    end

    it 'raises if a required setting is missing' do
      proc { config.required(:missing) }.must_raise Peril::MissingConfigError
    end

    it 'raises if any step of a multi-tiered config is missing' do
      proc { config.required(:missing, :multi) }.must_raise Peril::MissingConfigError
      proc { config.required(:multi, :bad) }.must_raise Peril::MissingConfigError
    end
  end
end
