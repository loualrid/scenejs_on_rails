class ScenejsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def get_scenejs_data
    #scenejs grabs plugins from this path

    #In the source, at the end of the file is
    #SceneJS.configure({ pluginPath: (((location.protocol.length === 0) ? 'http://' : location.protocol + '//') + location.host + '/scenejs/get_scenejs_data?file=') });
    # Thats all that the system should need...

    #You may need to edit engines as they may not grab things from plugin path if they werent written correctly!

    if params[:file]
      if params[:file].include?('..')
        raise "ActionController::UnpermittedParameters"
        puts "Browser is attempting to access files it should not have access to! This is an attempt to exploit ScenejsOnRails from #{request.remote_ip}!"
      end

      params[:file] = params[:file].gsub('[object Object]','') # just in case...

      if params[:file].to_s[0] == "/" #sanity check, we dont need the leading slash but most calls will include it
        params[:file] = params[:file].slice(1..params[:file].length)
      end

      if params[:file].include?('.png') || params[:file].include?('.jpg') || params[:file].include?('.gif')
        binary = true
      elsif !params[:file].include?('.js')
        params[:file] = "#{params[:file]}.js"
        binary = false
      end

      in_gem_file_ref = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', "vendor","assets","javascripts","scenejs_plugins", params[:file])
      in_app_vendor_file_ref = Rails.root.join("vendor","assets","javascripts","scenejs_plugins", params[:file])
      in_app_lib_file_ref = Rails.root.join("lib","assets","javascripts","scenejs_plugins", params[:file])

      if File.exist?(in_app_lib_file_ref)
        fileloc = in_app_lib_file_ref
      elsif File.exist?(in_app_vendor_file_ref)
        fileloc = in_app_vendor_file_ref
      elsif File.exist?(in_gem_file_ref)
        fileloc = in_gem_file_ref
      end

      @file = File.read(fileloc) if fileloc

      if @file
        if binary #serves binary image data
          send_data(@file)
        else #serves inline js (system may send as application/zip but this causes no issues)
          respond_to do |format|
            format.js { render js: @file, layout: false, content_type: Mime::JS }
          end
        end
      else
        raise "ActionController::RoutingError(Scenejs Plugin not found either in gem or app locations:\n #{in_gem_file_ref}\n #{in_app_file_ref})"
      end
    end
  end
end
