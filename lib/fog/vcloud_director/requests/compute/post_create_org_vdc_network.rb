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
        # @param [String] vdc_id Object identifier of the vDC
        # @param [String] name   The name of the entity.
        # @param [Hash] options
        # @option options [String] :Description Optional description.
        # @option options [Hash] :Configuration Network configuration.
        # @option options [Hash] :EdgeGateway  EdgeGateway that connects this 
        #   Org vDC network. Applicable only for routed networks.
        # @option options [Hash] :ServiceConfig Specifies the service 
        #   configuration for an isolated Org vDC networks.
        # @option options [Boolean] :IsShared True if this network is shared 
        #   to multiple Org vDCs.
        #   * :Configuration<~Hash>: NetworkConfigurationType
        #     * :IpScopes<~Hash>:
        #       * :IpScope<~Hash>:
        #         * :IsInherited<~Boolean>: ?
        #         * :Gateway<~String>: IP address of gw
        #         * :Netmask<~String>: Subnet mask of network
        #         * :Dns1<~String>: Primary DNS server.
        #         * :Dns2<~String>: Secondary DNS server.
        #         * :DnsSuffix<~String>: DNS suffix.
        #         * :IsEnabled<~String>: Indicates if subnet is enabled or not.
        #                                Default value is True.
        #         * :IpRanges<~Hash>: IP ranges used for static pool allocation
        #                             in the network.
        #   * :EdgeGateway<~Hash>:
        #   * :ServiceConfig<~Hash>:
        #
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
        def post_create_org_vdc_network(vdc_id, name, options={})
          body = Nokogiri::XML::Builder.new do
            attrs = {
              :xmlns => 'http://www.vmware.com/vcloud/v1.5',
              :name  => name
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
                              if ip_range = ip_ranges[:IpRange]
                                # TODO this is only handling the single IpRange case
                                #      and needs to handle >=1 IpRange elements?
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
                  # TODO
                  #if features = configuration[:Features]
                  #  Feature {
                  #  }
                  #end
                  # TODO
                  #if syslog = configuration[:SyslogServerSettings]
                  #  SyslogServerSettings {
                  #  }
                  #end
                  if router_info = configuration[:RouterInfo]
                    RouterInfoType {
                      ExternalIp router_info[:ExternalIp]
                    }
                  end
                }
              end

              if edgegw = options[:EdgeGateway]
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

          # Description
          # Configuration
          #   IpScopes
          #     IpScope
          #       IsInherited
          #       Gateway
          #       Netmask
          #       Dns1
          #       Dns2
          #       DnsSuffix
          #       IsEnabled
          #       IpRanges
          #         IpRange
          #           StartAddress
          #           EndAddress
          #   FenceMode
          # EdgeGateway
          # IsShared

          network_body = {
            :name           => name,
            :vdc            => vdc_id,
          }

          [:Description, :IsShared].each do |key|
            network_body[key] = options[key] if options.key?(key)
          end

          if options.key?(:EdgeGateway)
            network_body[:EdgeGateway] = 
              options[:EdgeGateway][:href].split('/').last
          end

          if configuration = options[:Configuration]
            if ip_scopes = configuration[:IpScopes]
              if ip_scope = ip_scopes[:IpScope]
                [:IsInherited, :Gateway, :Netmask, 
                  :Dns1, :Dns2, :DnsSuffix, :IsEnabled].each do |key|
                    network_body[key] = ip_scope[key] if ip_scope.key?(key)
                end
              end
            end
            network_body[:FenceMode] = configuration[:FenceMode] if ip_scope.key?(:FenceMode)
          end

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
