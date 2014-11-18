#
# Cookbook Name:: mon-lvs-clusters
# Recipe:: default
#
# Copyright 2014, Rakuten Inc.
#
# All rights reserved - Do Not Redistribute
#


raise 'Please define "state" as MASTER or BACKUP' if not ['MASTER', 'BACKUP'].include? node['lvs-director']['state']

node.default['lvs-director']['label'] = node['lvs-director']['label'] || node['lvs-director']['state'].downcase

package 'ipvsadm' do
    version node['lvs-director-packages']['ipvsadm']
end

package 'keepalived' do
    version node['lvs-director-packages']['keepalived']
end

nodes = search(:node, 'tags:lvs-real-server')

raise 'No node tagged with lvs-real-server was found.' if nodes.nil?

param ||= {}

if not data_bag_item('lvs-director', 'lvs-director').nil?
    node.default['lvs-director']['schedule_method'] =
      data_bag_item('lvs-director', 'lvs-director')['schedule-method'] || 'wrr'
else
    node.default['lvs-director']['schedule_method'] = 'wrr'
end

param['vip_configs'] ||= {}

raise 'Data bag not found or data bag item not found' if nodes.nil?

nodes.each do |n|
    unless n['lvs-real-server'].nil?
        n['lvs-real-server']['service'].select{|k,v| node['lvs-director']['service'].include? k }
         .each do |sname, config|
            config['vip_configs'].each do |h|
                param['vip_configs'][h['vip']] ||= {}
                param['vip_configs'][h['vip']][h['vport']] ||= []
                if param['vip_configs'][h['vip']][h['vport']].select{ |cf|
                        cf['rip']== n['ipaddress'] ## and cf['rport'] == h['rport']
                    }.empty?
                    param['vip_configs'][h['vip']][h['vport']] <<
                    {'rip' => n['ipaddress'], 'rport' => h['rport'], 'weight'=>h['weight']}
                end
            end
      end
    end
end

param['vips'] = param['vip_configs'].keys

node.default['lvs-director'] = node['lvs-director'].merge param

template '/etc/keepalived/keepalived.conf' do
    source 'keepalived.conf.erb'
    mode '0755'
    variables({
               :label => node['lvs-director']['label'],
               :state => node['lvs-director']['state'],
               :vip_configs => node['lvs-director']['vip_configs'],
               :vips => node['lvs-director']['vips'],
               :schedule_method => node['lvs-director']['schedule_method'],
               :services => node['lvs-director']['service'].join('_')
              })
end
