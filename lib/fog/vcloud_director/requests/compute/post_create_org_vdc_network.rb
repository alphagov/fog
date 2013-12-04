module Fog
  module Compute
    class VcloudDirector
      class Real

        # Create an Org vDC network.
        #
        # This operation is asynchronous and returns a task that you can
        # monitor to track the progress of the request.
        #
        # Produce media type(s):
        # application/vnd.vmware.vcloud.orgVdcNetwork+xml
        # Output type:
        # OrgVdcNetworkType
        #
        # @param [String] id Object identifier of the vDC
        # @param [String] name Network Name
        # @param [Hash] options
        # @option options [String] :Gateway      Edge Gateway ID
        # @option options [String] :Gateway      Edge Gateway IP
        # @option options [String] :Netmask      Subnet mask of this network
        # @option options [String] :Dns1         DNS Server 1 for this network
        # @option options [String] :Dns2         DNS Server 2 for this network
        # @option options [String] :DnsSuffix    DNS Suffix for this network
        # @option options [String] :FenceMode    Fence mode of network [optional]
        # @option options [Array]  :IpRanges     Array of { :start => "1.2.3.4", :end => "5.6.7.8" } ip range hashes
        #
        # @return [Excon::Response]
        #   * body<~Hash>:
        #
        # @see http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.api.reference.doc_51/doc/operations/POST-CreateOrgVdcNetwork.html
        # @since vCloud API version 5.1
        def post_create_org_vdc_network(id, name, options={})
          body = Nokogiri::XML::Builder.new do
            attrs = {
              :xmlns => 'http://www.vmware.com/vcloud/v1.5',
              :name  => name
            }
            OrgVdcNetwork(attrs) {
              Description options[:Description] if options.key?(:Description)
              Configuration {
                IpScopes {
                  IpScope {
                    #IsInherited  false 
                    Gateway      options[:Gateway]
                    Netmask      options[:Netmask]
                    Dns1         options[:Dns1]        if options.key?(:Dns1)
                    Dns2         options[:Dns2]        if options.key?(:Dns2)
                    DnsSuffix    options[:DnsSuffix]   if options.key?(:DnsSuffix)
                    if ip_ranges = options[:IpRanges]
                      IpRanges {
                        # TODO this is only handling the single IpRange case
                        #      and needs to handle >=1 IpRange elements
                        if ip_range = ip_ranges[:IpRange]
                          IpRange {
                            StartAddress ip_range[:StartAddress]
                            EndAddress   ip_range[:EndAddress]
                          }
                        end
                      }
                    end
                  }
                }
                FenceMode    options[:fence_mode]
              }
              if edgegw = options[EdgeGateway]
                EdgeGateway(:href => edgegw[:href])
              end
              IsShared       options[:is_shared] if options.key?(:is_shared)
            }

          end.to_xml

          request(
            :body    => body,
            :expects => 201,
            :headers => {'Content-Type' => 'application/vnd.vmware.vcloud.orgVdcNetwork+xml'},
            :method  => 'POST',
            :parser  => Fog::ToHashDocument.new,
            :path    => "admin/vdc/#{id}/networks"
          )
        end
      end

      class Mock

        def post_create_org_vdc_network(vdc_id, name, options={})
          unless data[:vdcs][vdc_id]
            raise Fog::Compute::VcloudDirector::Forbidden.new(
              "No access to entity \"(com.vmware.vcloud.entity.vdc:#{vdc_id})\"."
            )
          end

          type = 'network'
          id = uuid

          network_body = {
            :name           => name,
            :vdc            => vdc_id,
            :isShared       => options[:IsShared],
            :ApplyRateLimit => 'false',
            :Description    => options[:Description],
            :Dns1           => options[:Dns1],
            :Dns2           => options[:Dns2],
            :DnsSuffix      => options[:DnsSuffix],
            :Gateway        => options[:Gateway],
            :FenceMode      => options[:FenceMode],
          }

          owner = {
            :href => make_href("#{type}/#{id}"), # ???
            :type => "application/vnd.vmware.vcloud.#{type}+xml"
          }
          task_id = enqueue_task(
            "Adding #{type} #{name} (#{id})", 'CreateOrgVdcNetwork', owner,
            :on_success => lambda do
              data[:networks][id] = network_body
            end
          )

          body = {
            :xmlns => xmlns,
            :xmlns_xsi => xmlns_xsi,
            :xsi_schemaLocation => xsi_schema_location
          }.merge(task_body(task_id))

          Excon::Response.new(
            :status => 201,
            :headers => {'Content-Type' => "#{body[:type]};version=#{api_version}"},
            :body => body
          )

        end
      end
    end
  end
end
