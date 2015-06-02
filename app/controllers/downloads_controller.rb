require 'sufia/models/noid'

class DownloadsController < ApplicationController
  include Sufia::Noid # for normalize_identifier method
  include Hydra::Controller::DownloadBehavior
  prepend_before_filter :normalize_identifier, except: [:index, :new, :create]

  def datastream_to_show
    super
  rescue Exception => e
    if params[:datastream_id] == 'thumbnail'
      respond_with_default_thumbnail_image
      return false
    else
      raise e
    end
  end

  ## Overriding Hydra::Controller::DownloadBehavior.datastream_name to return asset.filename instead of asset.label
  def datastream_name
    params[:filename] || asset.filename
  end

  protected

  def render_404
    if params[:datastream_id] == 'thumbnail'
      respond_with_default_thumbnail_image
    else
      super
    end
  end

  # Send default thumbnail image
  def respond_with_default_thumbnail_image
    image= ActionController::Base.helpers.asset_path("curate/default.png", type: :image)
    redirect_to image
  end

end
