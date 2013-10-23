module Fog
  module Compute
    class VcloudDirector
      class Real

        # Create a 'Organization vDC Network'
        # If a gateway_ip is supplied, then consider this a 'routed org vDc network'
        # otherwise, consider 'isolated'
        #
        # @param [String] id Object identifier of the vDC
        # @param [String] name Network Name
        # @param [Hash] options
        # @option options [String] :gateway_id    Edge Gateway ID
        # @option options [String] :gateway_ip    IP address of Edge Gateway
        # @option options [String] :netmask       Subnet mask of this network
        # @option options [String] :dns1          DNS Server for this network
        # @option options [String] :suffix        DNS Suffix for this network
        # @option options [String] :fence_mode    Fence mode of network [optional]
        # @option options [Array]  :ip_ranges     Array of { :start => "1.2.3.4", :end => "5.6.7.8" } ip range hashes
        #
        # @return [Excon::Response]
        #   * body<~Hash>:
        #
        # @see http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.api.reference.doc_51/doc/operations/POST-OrgVdcNetwork.html
        # @since vCloud API version 5.1

        def post_org_vdc_network(id, name, options={})

          unless options[:fence_mode]
            options[:fence_mode] = options[:gateway_id] ? 'natRouted' : 'isolated'
          end

          body = Nokogiri::XML::Builder.new do
            attrs = {
              :xmlns => 'http://www.vmware.com/vcloud/v1.5',
              :name  => name
            }
            OrgVdcNetwork(attrs) {
              if options[:gateway_id]
                EdgeGateway(:href => "#{@end_point}gateway/#{gateway_id}")
              end
              Configuration {
                IpScopes {
                  IpScope {
                    IsInherited  'false'
                    Gateway      options[:gateway_ip]
                    Netmask      options[:netmask]
                    Dns1         options[:dns1]         unless options[:dns1].nil?
                    DnsSuffix    options[:dns_suffix]   unless options[:dns_suffix].nil?
                    if options[:ip_ranges] && options[:ip_ranges].to_a.size > 0
                      IpRanges {
                        ip_ranges.to_a.each do |ip_range|
                          IpRange {
                            StartAddress "#{ip_range[:start]}"
                            EndAddress   "#{ip_range[:end]}"
                          }
                        end
                      }
                    end
                  }
                }
                FenceMode    options[:fence_mode]
              }
              IsShared       'true'
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
    end
  end
end
