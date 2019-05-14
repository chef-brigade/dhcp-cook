require 'spec_helper'

describe 'dhcp::_networks Exceptions' do
  before(:each) do
    Fauxhai.mock(platform: 'ubuntu', version: '14.04')
    @chef_run = ChefSpec::ServerRunner.new
  end

  it 'should not raise error unless when bags are missing' do
    @chef_run.converge 'dhcp::_networks'
  end
end

describe 'dhcp::_networks' do
  context 'driven by node attributes' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'centos', version: '6.8', step_into: %w(dhcp_subnet dhcp_shared_network)) do |node|
        node.default['chef_environment'] = 'production'
        node.override['dhcp']['use_bags'] = false
        node.override['dhcp']['networks'] = ['192.168.9.0/24', '192.168.11.0/24']
        node.override['dhcp']['network_data']['192.168.9.0/24'] = {
          'routers' => ['192.168.9.1'],
          'address' => '192.168.9.0',
          'netmask' => '255.255.255.0',
          'broadcast' => '192.168.9.255',
          'range' => '192.168.9.50 192.168.9.240',
          'options' => ['time-offset 10'],
          'next_server' => '192.168.9.11',
        }
        node.override['dhcp']['network_data']['192.168.11.0/24'] = {
          'address' => '192.168.11.0',
          'netmask' => '255.255.255.0',
        }
        node.override['dhcp']['shared_network_data']['mysharednet']['subnets']['192.168.10.0/24'] = {
          'routers' => ['192.168.10.1'],
          'address' => '192.168.10.0',
          'netmask' => '255.255.255.0',
          'broadcast' => '192.168.10.255',
          'range' => '192.168.10.50 192.168.10.240',
          'next_server' => '192.168.10.11',
        }
        node.override['dhcp']['shared_network_data']['mysharednet']['subnets']['10.0.2.0/24'] = {
          'address' => '10.0.2.0',
          'netmask' => '255.255.255.0',
        }
      end.converge(described_recipe)
    end

    it 'declares subnet 192.168.9.0' do
      expect(chef_run).to add_dhcp_subnet('192.168.9.0')
        .with(broadcast: '192.168.9.255', netmask: '255.255.255.0', routers: ['192.168.9.1'],
              options: ['time-offset 10'], next_server: '192.168.9.11',
              conf_dir: '/etc/dhcp', evals: [], key: {}, zones: [])

      # Check that pools are defined for the subnet
      subnet = chef_run.dhcp_subnet '192.168.9.0'
      expect(subnet.pools.count).to eq 1

      # Check that the pool is defined correctly
      subnet_pool = chef_run.dhcp_pool '192.168.9.0-pool0'
      expect(subnet_pool).to do_nothing
      expect(subnet_pool.range).to eq '192.168.9.50 192.168.9.240'
    end

    it 'generates subnet config for 192.168.9.0' do
      expect(chef_run).to create_template '/etc/dhcp/subnets.d/192.168.9.0.conf'
      expect(chef_run).to render_file('/etc/dhcp/subnets.d/192.168.9.0.conf').with_content(File.read(File.join(File.dirname(__FILE__), 'fixtures', '192.168.9.0.conf')))
    end

    it 'generates blank subnet config for 192.168.11.0' do
      expect(chef_run).to create_template '/etc/dhcp/subnets.d/192.168.11.0.conf'
      expect(chef_run).to render_file('/etc/dhcp/subnets.d/192.168.11.0.conf').with_content(File.read(File.join(File.dirname(__FILE__), 'fixtures', '192.168.11.0.conf')))
    end

    it 'declares shared-network mysharednet' do
      expect(chef_run).to add_dhcp_shared_network('mysharednet')
    end

    it 'declares the subnets in the mysharednet shared-network' do
      subnet1 = chef_run.dhcp_subnet 'mysharednet-192.168.10.0'
      expect(subnet1).to do_nothing
      expect(subnet1.pools.count).to eq 1
      expect(subnet1.subnet).to eq '192.168.10.0'
      expect(subnet1.netmask).to eq '255.255.255.0'
      subnet1_pool = chef_run.dhcp_pool 'mysharednet-192.168.10.0-pool0'
      expect(subnet1_pool).to do_nothing
      expect(subnet1_pool.range).to eq '192.168.10.50 192.168.10.240'

      subnet2 = chef_run.dhcp_subnet 'mysharednet-10.0.2.0'
      expect(subnet2).to do_nothing
      expect(subnet2.pools).to be_nil
      expect(subnet2.subnet).to eq '10.0.2.0'
      expect(subnet2.netmask).to eq '255.255.255.0'
    end

    it 'generates a shared network config' do
      expect(chef_run).to create_template '/etc/dhcp/shared_networks.d/mysharednet.conf'
      expect(chef_run).to render_file('/etc/dhcp/shared_networks.d/mysharednet.conf').with_content(File.read(File.join(File.dirname(__FILE__), 'fixtures', 'mysharednet.conf')))
    end
  end
end
