module ParamsHelper

  def scrub_params(params)
    safe_params = Hash.new;

    unless params["f"].nil?
      safe_params["f"] = Hash.new;
      safe_params["f"]["desc_metadata__creator_sim"] = params["f"]["desc_metadata__creator_sim"]
      safe_params["f"]["desc_metadata__language_sim"] = params["f"]["desc_metadata__language_sim"]
      safe_params["f"]["desc_metadata__publisher_sim"] = params["f"]["desc_metadata__publisher_sim"]
      safe_params["f"]["generic_type_sim"] = params["f"]["generic_type_sim"]
      safe_params["f"]["human_readable_type_sim"] = params["f"]["human_readable_type_sim"]
    end

    safe_params["controller"] = params["controller"]
    safe_params["action"] = params["action"]

    params.clear

    unless safe_params["f"].nil?
      params["f"] = Hash.new
      params["f"]["desc_metadata__creator_sim"] = safe_params["f"]["desc_metadata__creator_sim"] unless safe_params["f"]["desc_metadata__creator_sim"].nil?
      params["f"]["desc_metadata__language_sim"] = safe_params["f"]["desc_metadata__language_sim"] unless safe_params["f"]["desc_metadata__language_sim"].nil?
      params["f"]["desc_metadata__publisher_sim"] = safe_params["f"]["desc_metadata__publisher_sim"] unless safe_params["f"]["desc_metadata__publisher_sim"].nil?
      params["f"]["generic_type_sim"] = safe_params["f"]["generic_type_sim"] unless safe_params["f"]["generic_type_sim"].nil?
      params["f"]["human_readable_type_sim"] = safe_params["f"]["human_readable_type_sim"] unless safe_params["f"]["human_readable_type_sim"].nil?
    end

    params["controller"] = safe_params["controller"] unless safe_params["controller"].nil?
    params["action"] = safe_params["action"] unless safe_params["action"].nil?
  end

end
