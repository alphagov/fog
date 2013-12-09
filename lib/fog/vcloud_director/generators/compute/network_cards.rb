module Fog
  module Generators
    module Compute
      module VcloudDirector
        # This is the data structure it accepts: the output
        # of get_network_cards_items_list
        #
        # :Item=>
        #  [{:"rasd:Address"=>"00:50:56:01:01:01",
        #    :"rasd:AddressOnParent"=>"1",
        #    :"rasd:AutomaticAllocation"=>"true",
        #    :"rasd:Connection"=>{
        #      :attributes => {
        #        :xmlns_ns12=>"http://www.vmware.com/vcloud/v1.5",
        #        :ns12_ipAddress=>"192.168.0.1",
        #        :ns12_primaryNetworkConnection=>"false",
        #        :ns12_ipAddressingMode=>"MANUAL",
        #      },
        #      :value => "NetworkTest3",
        #    },
        #    :"rasd:Description"=>"E1000 ethernet adapter on \"NetworkTest3\"",
        #    :"rasd:ElementName"=>"Network adapter 1",
        #    :"rasd:InstanceID"=>"1",
        #    :"rasd:ResourceSubType"=>"E1000",
        #    :"rasd:ResourceType"=>"10"},
        #   {:"rasd:Address"=>"00:50:56:01:01:02",
        #    :"rasd:AddressOnParent"=>"0",
        #    :"rasd:AutomaticAllocation"=>"true",
        #    :"rasd:Connection"=>{
        #      :attributes => {
        #        :xmlns_ns12=>"http://www.vmware.com/vcloud/v1.5",
        #        :ns12_ipAddress=>"192.168.1.1",
        #        :ns12_primaryNetworkConnection=>"true",
        #        :ns12_ipAddressingMode=>"MANUAL",
        #      },
        #      :value => "Default",
        #    },
        #    :"rasd:Description"=>"E1000 ethernet adapter on \"Default\"",
        #    :"rasd:ElementName"=>"Network adapter 0",
        #    :"rasd:InstanceID"=>"2",
        #    :"rasd:ResourceSubType"=>"E1000",
        #    :"rasd:ResourceType"=>"10"}]}
        #
        # @see http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.api.reference.doc_51/doc/types/RasdItemsListType.html
        class NetworkCards

          def initialize(data)
            raise "Invalid data for NetworkCards (no :Item)" unless data.key?(:Item)
            raise "Invalid data for NetworkCards (:Item should be Array)" unless data[:Item].is_a? Array
            @items = data[:Item]
          end

          def generate_xml
            Nokogiri::XML::Builder.new do |xml|
              # NB: xmlns:ns12 defined here rather than on Connection as
              #     Nokogiri strips it from there for some strange reason
              xml.RasdItemsList(
                'xmlns'      => 'http://www.vmware.com/vcloud/v1.5',
                'xmlns:ns12' => 'http://www.vmware.com/vcloud/v1.5',
                'xmlns:rasd' => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData',
                'type'       => 'application/vnd.vmware.vcloud.rasdItemsList+xml'
              ) {
                @items.each do |item|
                  ca = item[:'rasd:Connection'][:attributes]
                  connection_attributes = {
                    'ns12:ipAddress'  => ca[:'ns12_ipAddress'],
                    'ns12:primaryNetworkConnection' =>
                         ca[:'ns12_primaryNetworkConnection'],
                    'ns12:ipAddressingMode' => ca[:'ns12_ipAddressingMode'],
                  }
                  xml.Item {
                    xml['rasd'].Address item[:'rasd:Address']
                    xml['rasd'].AddressOnParent item[:'rasd:AddressOnParent']
                    xml['rasd'].AutomaticAllocation item[:'rasd:AutomaticAllocation']
                    xml['rasd'].Connection( connection_attributes ) {xml.text(item[:'rasd:Connection'][:value])}
                    xml['rasd'].Description item[:'rasd:Description']
                    xml['rasd'].ElementName item[:'rasd:ElementName']
                    xml['rasd'].InstanceID item[:'rasd:InstanceID']
                    xml['rasd'].ResourceSubType item[:'rasd:ResourceSubType']
                    xml['rasd'].ResourceType '10'
                  }
                end
              }
            end.to_xml
          end

        end
      end
    end
  end
end
