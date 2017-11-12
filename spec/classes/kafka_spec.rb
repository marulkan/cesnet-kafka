require 'spec_helper'

describe 'kafka::config', :type => 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile.with_all_deps }
      it { should contain_file('/etc/kafka/conf/server.properties') }
    end
  end
end

describe 'kafka' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('kafka::params') }
      it { is_expected.to contain_class('kafka::install').that_comes_before('kafka::config') }
      it { is_expected.to contain_class('kafka::config') }
      it { is_expected.to contain_class('kafka::service').that_subscribes_to('kafka::config') }

      it { is_expected.to contain_service('kafka-server') }
      it { is_expected.to contain_package('kafka-server').with_ensure('present') }
    end
  end
end
