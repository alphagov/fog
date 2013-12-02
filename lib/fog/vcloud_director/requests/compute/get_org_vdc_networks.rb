module Fog
  module Compute
    class VcloudDirector
      class Real

        # List all OrgVdcNetworks for this Org vDC.
        #
        # @param [String] id Object identifier of the vDC.
        # @return [Excon::Response]
        #   * body<~Hash>:
        #
        # @raise [Fog::Compute::VcloudDirector::Forbidden]
        #
        # @see http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.api.reference.doc_51/doc/operations/GET-OrgVdcNetworks.html
        # @since vCloud API version 5.1
        def get_org_vdc_networks(id)
          response = request(
            :expects    => 200,
            :idempotent => true,
            :method     => 'GET',
            :parser     => Fog::ToHashDocument.new,
            :path       => "admin/vdc/#{id}/networks"
          )
          #TODO 
          #ensure_list! response.body, :OrgVdcNetworkRecord
          response
        end
      end

      class Mock

        def get_org_vdc_networks(vdc_id)
          unless data[:vdcs][vdc_id]
            raise Fog::Compute::VcloudDirector::Forbidden.new(
              "No access to entity \"(com.vmware.vcloud.entity.vdc:#{vdc_id})\"."
            )
          end

          body = {
            :OrgVdcNetworkRecord => [],
          }

          # need to handle finding shared networks for this vDC too
          data[:networks].each do |id,attrs|
            if data[:networks][id][:vdc] == vdc_id || data[:networks][id][:isShared]
              body[:OrgVdcNetworkRecord] << 
                {:name=>attrs[:name],
                 :href=>make_href("network/#{id}"),
                 :vdc=>make_href("vdc/#{attrs[:vdc]}"),
                 :vdcName=>data[:vdcs][attrs[:vdc]][:name],
                 #:connectedTo=>TODO,
                 #linkType=>TODO,
                 #isBusy=>TODO,
                 :isShared=>attrs[:isShared],
                 :gateway=>attrs[:Gateway],
                 :netmask=>attrs[:Netmask],
                 :dns1=>attrs[:Dns1],
                 :dns2=>attrs[:Dns2],
                 :dns_suffix=>attrs[:DnsSuffix],
                }
            end
          end

          Excon::Response.new(
            :status => 200,
            :headers => {'Content-Type' => "#{body[:type]};version=#{api_version}"},
            :body => body
          )

        end

      end

    end
  end
end
