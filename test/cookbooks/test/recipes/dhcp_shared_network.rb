dhcp_shared_network 'single' do
  subnets(
    '192.168.1.0' => {
      'subnet' => '192.168.1.0',
      'broadcast' => '192.168.1.255',
      'netmask' => '255.255.255.0',
      'options' => {
        'routers' => '192.168.1.1',
      },
      'pool' => {
        'range' => '192.168.1.20 192.168.1.30',
      },
    }
  )
end

dhcp_shared_network 'multiple' do
  subnets(
    '192.168.2.0' => {
      'subnet' => '192.168.2.0',
      'broadcast' => '192.168.2.255',
      'netmask' => '255.255.255.0',
      'options' => {
        'routers' => '192.168.2.1',
      },
      'pool' => {
        'range' => '192.168.2.20 192.168.2.30',
      },
    },
    '192.168.3.0' => {
      'subnet' => '192.168.3.0',
      'broadcast' => '192.168.3.255',
      'netmask' => '255.255.255.0',
      'options' => {
        'routers' => '192.168.3.1',
      },
      'pool' => {
        'range' => [
          '192.168.3.20 192.168.3.30',
          '192.168.3.40 192.168.3.50',
        ],
      },
    }
  )
end
