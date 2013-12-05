module Fog
  module Compute
    class VcloudDirector
      class Real

        require 'fog/vcloud_director/generators/compute/network_cards'

        # Update all RASD items that specify network card properties of a VM.
        #
        # This operation is asynchronous and returns a task that you can
        # monitor to track the progress of the request.
        #
        # @param [String] id Object identifier of the VM.
        # @param [Hash] options rasd:ItemList
        #
        # @return [Excon::Response]
        #   * body<~Hash>:
        #
        # @see http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.api.reference.doc_51/doc/operations/PUT-NetworkCards.html
        # @since vCloud API version 0.9
        def put_network_cards(id, options)
          body = Fog::Generators::Compute::VcloudDirector::NetworkCards.new(options).generate_xml
          request(
            :body    => body,
            :expects => 202,
            :headers => {'Content-Type' => 'application/vnd.vmware.vcloud.rasdItemsList+xml'},
            :method  => 'PUT',
            :parser  => Fog::ToHashDocument.new,
            :path    => "vApp/#{id}/virtualHardwareSection/networkCards"
          )
        end
      end
    end
  end
end
