module Reply
  def construct_reply(raw_reply)
    result = raw_reply

    # Works like I18n.interpolate, but with interpolation keys set off by
    # @{key} rather than %{key}.

    channel_specific_translations.each do |translation_key, translation_value|
      _translation_value = translation_value || ''
      result.gsub!(/@\{#{translation_key}\}/, _translation_value)
    end

    result
  end
end
