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
        end

      end

    end
  end
end
