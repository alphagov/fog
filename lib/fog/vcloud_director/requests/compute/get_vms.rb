module Fog
  module Compute
    class VcloudDirector
      class Real
        require 'fog/vcloud_director/parsers/compute/vms'

        # Retrieve a vApp or VM.
        #
        # @note This should probably be deprecated.
        #
        # @param [String] id Object identifier of the vApp or VM.
        # @return [Excon::Response]
        #   * body<~Hash>:
        #
        # @see #get_vapp
        def get_vms(id)
          request(
            :expects    => 200,
            :idempotent => true,
            :method     => 'GET',
            :parser     => Fog::Parsers::Compute::VcloudDirector::Vms.new,
            :path       => "vApp/#{id}"
          )
        end
      end

      class Mock

        def get_vms(id)
          unless vapp = data[:vapps][id]
            raise Fog::Compute::VcloudDirector::Forbidden.new(
              'This operation is denied.'
            )
          end

          vm = get_vm_from_vapp_id(id)
          vm_details = vm[1]
          type = "application/vnd.vm_detailsware.vcloud.vm_details+xml"

          body = {
            :vms=>
              [{:ip_address=>"",
                :name=>vm_details[:name],
                :type=>type,
                :href=>make_href(vm[0]),
                :id=>vm[0],
                :vapp_id=>id,
                :cpu=>vm_details[:cpu_count],
                :memory=>vm_details[:memory_in_mb]}]
          }

          Excon::Response.new(
            :status => 200,
            :headers => {'Content-Type' => "#{type};version=#{api_version}"},
            :body => body
          )
        end

        private

        def get_vm_from_vapp_id(id)
          for vm in data[:vms] do
            if id == vm[1][:parent_vapp]
              vapp_vm = vm
            end
          end
          vapp_vm
        end

      end

    end
  end
end
