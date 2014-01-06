module Fog
  module Compute
    class VcloudDirector
      class Real
        # Compose a vapp.
        #
        # The response includes a Task element. You can monitor the task to
        # track the creation of the vApp.
        #
        # @param [String] vdc_id Object identifier of the vDC.
        # @param [String] name Name of the new vApp.
        # @param [Hash] options
        # @option options [String] :Description Optional description.
        # @return [Excon::Response]
        #   * body<~Hash>:
        #
        # @see http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.api.reference.doc_51/doc/operations/POST-ComposeVApp.html
        # @since vCloud API version 0.9
        def post_compose_vapp(vdc_id, name, options={})
          body = Nokogiri::XML::Builder.new do
            attrs = {
                'xmlns' => 'http://www.vmware.com/vcloud/v1.5',
                'xmlns:ovf' => 'http://schemas.dmtf.org/ovf/envelope/1',
                :name => name
            }
            ComposeVAppParams(attrs) {
              Description options[:Description] if options.key?(:Description)
            }
          end.to_xml
          request(
              :body => body,
              :expects => 201,
              :headers => {'Content-Type' => 'application/vnd.vmware.vcloud.composeVAppParams+xml'},
              :method => 'POST',
              :parser => Fog::ToHashDocument.new,
              :path => "vdc/#{vdc_id}/action/composeVApp"
          )
        end
      end
    end
  end
end
