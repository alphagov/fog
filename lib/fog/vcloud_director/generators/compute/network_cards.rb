module Fog
  module Generators
    module Compute
      module VcloudDirector
        # This is the data structure it accepts, this is the output 
        # of get_network_cards_items_list
        #
        # :Item=>
        #  [{:"rasd:Address"=>"00:50:56:01:01:01",
        #    :"rasd:AddressOnParent"=>"1",
        #    :"rasd:AutomaticAllocation"=>"true",
        #    :"rasd:Connection"=>"NetworkTest3",
        #    :"rasd:Description"=>"E1000 ethernet adapter on \"NetworkTest3\"",
        #    :"rasd:ElementName"=>"Network adapter 1",
        #    :"rasd:InstanceID"=>"1",
        #    :"rasd:ResourceSubType"=>"E1000",
        #    :"rasd:ResourceType"=>"10"},
        #   {:"rasd:Address"=>"00:50:56:01:01:02",
        #    :"rasd:AddressOnParent"=>"0",
        #    :"rasd:AutomaticAllocation"=>"true",
        #    :"rasd:Connection"=>"Default",
        #    :"rasd:Description"=>"E1000 ethernet adapter on \"Default\"",
        #    :"rasd:ElementName"=>"Network adapter 0",
        #    :"rasd:InstanceID"=>"2",
        #    :"rasd:ResourceSubType"=>"E1000",
        #    :"rasd:ResourceType"=>"10"}]}
        #
        # This is what it generates:
        #
        #<vcloud:RasdItemsList
        #    xmlns:rasd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData"
        #    xmlns:vcloud="http://www.vmware.com/vcloud/v1.5"
        #    type="application/vnd.vmware.vcloud.rasdItemsList+xml">
        #    <vcloud:Item>
        #        <rasd:Address>00:50:56:01:01:01</rasd:Address>
        #        <rasd:AddressOnParent>1</rasd:AddressOnParent>
        #        <rasd:AutomaticAllocation>true</rasd:AutomaticAllocation>
        #        <rasd:Connection>NetworkTest3</rasd:Connection>
        #        <rasd:Description>E1000 ethernet adapter</rasd:Description>
        #        <rasd:ElementName>Network adapter 1</rasd:ElementName>
        #        <rasd:InstanceID>1</rasd:InstanceID>
        #        <rasd:ResourceSubType>E1000</rasd:ResourceSubType>
        #        <rasd:ResourceType>10</rasd:ResourceType>
        #    </vcloud:Item>
        #    <vcloud:Item>
        #        <rasd:Address>00:50:56:01:01:02</rasd:Address>
        #        <rasd:AddressOnParent>0</rasd:AddressOnParent>
        #        <rasd:AutomaticAllocation>true</rasd:AutomaticAllocation>
        #        <rasd:Connection>Default</rasd:Connection>
        #        <rasd:Description>E1000 ethernet adapter</rasd:Description>
        #        <rasd:ElementName>Network adapter 0</rasd:ElementName>
        #        <rasd:InstanceID>2</rasd:InstanceID>
        #        <rasd:ResourceSubType>E1000</rasd:ResourceSubType>
        #        <rasd:ResourceType>10</rasd:ResourceType>
        #    </vcloud:Item>
        #</vcloud:RasdItemsList>
        #
        # @see http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.api.reference.doc_51/doc/types/RasdItemsListType.html
        class NetworkCards

          def initialize(data)
            raise "Invalid data for NetworkCards (no :Item)" unless data.key?(:Item)
            items = data[:Item]
            if items.is_a? Hash
              @items = [ items ]
            elsif items.is_a? Array
              @items = items
            else
              raise "Invalid data for NetworkCards"
            end
          end

          def generate_xml
            Nokogiri::XML::Builder.new do |xml|
              xml['vcloud'].RasdItemsList(
                      'xmlns:vcloud' => 'http://www.vmware.com/vcloud/v1.5',
                      'xmlns:rasd'   => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData',
                      'type'         => 'application/vnd.vmware.vcloud.rasdItemsList+xml'
              ) {
                @items.each do |item|
                  xml['vcloud'].Item {
                    xml['rasd'].Address item[:'rasd:Address']
                    xml['rasd'].AddressOnParent item[:'rasd:AddressOnParent']
                    xml['rasd'].AutomaticAllocation item[:'rasd:AutomaticAllocation']
                    xml['rasd'].Connection item[:'rasd:Connection']
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
