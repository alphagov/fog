module Fog
  module Generators
    module Compute
      module VcloudDirector

        # @see http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.api.reference.doc_51/doc/types/OrgVdcNetworkType.html
        class OrgVdcNetwork
          attr_reader :options

          def initialize(options={})
            @options = options
          end

          def generate_xml

            body = Nokogiri::XML::Builder.new do
              attrs = {
                :xmlns => 'http://www.vmware.com/vcloud/v1.5',
                :name  => options[:name]
              }
              OrgVdcNetwork(attrs) {
                Description options[:Description] if options.key?(:Description)
                if configuration = options[:Configuration]
                  Configuration {
                    if ip_scopes = configuration[:IpScopes]
                      IpScopes {
                        if ip_scope = ip_scopes[:IpScope]
                          IpScope {
                            IsInherited  ip_scope[:IsInherited] if ip_scope.key?(:IsInherited)
                            Gateway      ip_scope[:Gateway]     if ip_scope.key(:Gateway)
                            Netmask      ip_scope[:Netmask]     if ip_scope.key(:Network)
                            Dns1         ip_scope[:Dns1]        if ip_scope.key?(:Dns1)
                            Dns2         ip_scope[:Dns2]        if ip_scope.key?(:Dns2)
                            DnsSuffix    ip_scope[:DnsSuffix]   if ip_scope.key?(:DnsSuffix)
                            IsEnabled    ip_scope[:IsEnabled]   if ip_scope.key?(:IsEnabled)
                            if ip_ranges = ip_scope[:IpRanges]
                              IpRanges {
                                ip_ranges.each do |ip_range|
                                  IpRange {
                                    StartAddress ip_range[:StartAddress]
                                    EndAddress   ip_range[:EndAddress]
                                  }
                                end
                              }
                            end
                          }
                        end
                      }
                    end
                    FenceMode    configuration[:fence_mode]
                    if router_info = configuration[:RouterInfo]
                      RouterInfoType {
                        ExternalIp router_info[:ExternalIp]
                      }
                    end
                  }
                end # Configuration

                if edgegw = options[:EdgeGateway]
                  EdgeGateway(:href => edgegw[:href])
                elsif configuration[:fence_mode] == 'isolated'
                  # isolated networks can specify ServiceConfig
                  if sc = options[:ServiceConfig]
                    ServiceConfig {
                      if dhcp = sc[:GatewayDhcpService]
                        IsEnabled dhcp[:IsEnabled] if dhcp[:IsEnabled]
                        if pool = dhcp[:Pool]
                          IsEnabled        pool[:IsEnabled]
                          DefaultLeaseTime pool[:DefaultLeaseTime]
                          MaxLeaseTime     pool[:MaxLeaseTime]
                          LowIpAddress     pool[:LowIpAddress]
                          HighIpAddress    pool[:HighIpAddress]
                        end
                      end
                    }
                  end
                end

                IsShared       options[:is_shared] if options.key?(:is_shared)

              }
            end.to_xml
          end

        end
      end
    end
  end
end
