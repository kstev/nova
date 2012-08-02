#
# Cookbook Name:: nova
# Recipe:: nova-db-monitoring
#
# Copyright 2012, Rackspace US, Inc.
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

include_recipe "osops-utils"
include_recipe "monitoring"

mysql_info = get_settings_by_role("mysql-master", "mysql")

monitoring_procmon "mysqld" do
  service_name = node["nova"]["platform"]["mysql_service"]

  process_name "mysqld"
  start_cmd "/usr/sbin/service #{service_name} start"
  stop_cmd "/usr/sbin/service #{service_name} stop"
end

# This is going to fail for an external database server...
monitoring_metric "mysqld-proc" do
  type "proc"
  proc_name "mysqld"
  proc_regex node["nova"]["platform"]["mysql_service"]

  alarms(:failure_min => 1.0)
end

monitoring_metric "mysql" do
  type "mysql"
  host mysql_info["bind_address"]
  user "root"
  password node["mysql"]["server_root_password"]
  port 3306

  alarms("max_connections" => {
           :warning_max => node["mysql"]["tunable"]["max_connections"].to_i * 0.8,
           :failure_max => node["mysql"]["tunable"]["max_connections"].to_i * 0.9
         })

end
