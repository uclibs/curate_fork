module FileInputHelper
  
  def file_input_multiple_bool(local_assigns)
    if local_assigns.has_key? :multiple and local_assigns[:multiple] == true
      return true
    else 
      return false
    end
  end

end
