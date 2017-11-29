json.tiles_digest_automator do
  json.merge! @automator.attributes
end

json.helpers do
  json.sendAtTime tiles_digest_last_sent_or_scheduled_message
end
