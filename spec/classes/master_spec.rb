require 'spec_helper'

describe 'ansible::master' do

  context "When you add an ansible::master class" do
    let(:facts) { {:osfamily => 'Debian' } }

    it { should contain_class('ansible::user').with('sudo' => 'enable')}
    it { should contain_class('ansible::install') }
    it { should contain_class('ansible::params') }

    it '' do
      should contain_file('/etc/ssh/ssh_known_hosts').with(
        'ensure'  => 'file',
        'path'    => '/etc/ssh/ssh_known_hosts',
        'mode'    => '0644'
      )
    end

  end

  context "When you add an ansible::master class with manage_user disabled" do
    let(:facts) { {:osfamily => 'Debian' } }
    let(:params) { {:manage_user  => false} }

    it { should_not contain_class('ansible::user')}
    it { should contain_class('ansible::install') }
    it { should contain_class('ansible::params') }

    it '' do
      should contain_file('/etc/ssh/ssh_known_hosts').with(
        'ensure'  => 'file',
        'path'    => '/etc/ssh/ssh_known_hosts',
        'mode'    => '0644'
      )
    end

  end

  context "When you add an ansible::master class with sudo disabled" do
    let(:facts) { {:osfamily => 'Debian' } }
    let(:params) { {:sudo  => 'disable'} }

    it { should contain_class('ansible::user').with('sudo' => 'disable')}
    it { should contain_class('ansible::install') }
    it { should contain_class('ansible::params') }

    it '' do
      should contain_file('/etc/ssh/ssh_known_hosts').with(
        'ensure'  => 'file',
        'path'    => '/etc/ssh/ssh_known_hosts',
        'mode'    => '0644'
      )
    end

  end

  context "When you add an ansible::master class with the manual provider" do
    let(:facts) { {:osfamily => 'Debian' } }
    let(:params) { {:provider  => 'manual'} } 
    it { should_not  contain_class('ansible::install') }
  end

  context "When you add an ansible::master class with the default provider" do
    let(:facts) { {:osfamily => 'Debian' } }
    let(:params) { {:provider  => 'automatic'} } 

    it 'ansible is present and installed with the automatic provider' do
      should contain_class('ansible::install').with(
          'provider' => 'automatic'
      )
    end
  end

  context "When you add an ansible::master class with non supported provider" do
    let(:facts) { {:osfamily => 'Debian' } }
    let(:params) { {:provider  => 'anonsupportedprovider'} } 
    it do
        expect {
            should contain_class('ansible::install')
        }.to raise_error(Puppet::Error, /Unsupported provider/)
    end
  end

end
