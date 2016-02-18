module Fog
  module Compute
    class VcloudDirector
      class Real
        require 'fog/vcloud_director/generators/compute/recompose_vapp'
        def post_recompose_vapp(id, options={})
          body = Fog::Generators::Compute::VcloudDirector::RecomposeVapp.new(options).generate_xml

          request(
            :body => body,
            :expects => 202,
            :headers => { 'Content-Type' => 'application/vnd.vmware.vcloud.recomposeVAppParams+xml' },
            :method => 'POST',
            :parser => Fog::ToHashDocument.new,
            :path => "vApp/#{id}/action/recomposeVApp"
          )
        end
      end
      class Mock
        def post_recompose_vapp(id, options={})
          unless vapp = data[:vapps][id]
            raise Fog::Compute::VcloudDirector::Forbidden.new(
            'This operation is denied.'
            )
          end
          owner = {
            :href => make_href("vApp/#{id}"),
            :type => 'application/vnd.vmware.vcloud.recomposeVAppParams+xml'
          }
          task_id = enqueue_task(
            "Updating vApp #{data[:vapps][id][:name]}(#{id})", 'recomposeVapp', owner,
              :on_success => lambda do
                # TODO - when mocks support :NetworkConfigSection, update it here
            end
          )
          body = {
            :xmlns => xmlns,
            :xmlns_xsi => xmlns_xsi,
            :xsi_schemaLocation => xsi_schema_location,
          }.merge(task_body(task_id))

          Excon::Response.new(
            :status => 202,
            :headers => {'Content-Type' => "#{body[:type]};version=#{api_version}"},
            :body => body
          )
        end        
      end
    end
  end
end
