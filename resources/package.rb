#
# Cookbook:: dhcp
# Resource:: package
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unified_mode true

include Dhcp::Cookbook::Helpers

property :packages, [String, Array],
          default: lazy { dhcpd_packages }

action_class do
  def do_action(package_action)
    package 'ISC DHCPD' do
      package_name new_resource.packages

      action package_action
    end
  end
end

action :install do
  do_action(action)
end

action :remove do
  do_action(action)
end
