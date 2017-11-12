require 'spec_helper'

describe 'kafka::client' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('kafka::params') }
      it { is_expected.to contain_class('kafka::client::install').that_comes_before('kafka::client::config') }
      it { is_expected.to contain_class('kafka::client::config') }
    end
  end
end
