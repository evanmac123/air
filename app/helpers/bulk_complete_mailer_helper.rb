module BulkCompleteMailerHelper
  EMAIL_DIVIDER = "\n    ".freeze

  def explain_bucket(bucket_name, bucket_label, states)
    bucket = states[bucket_name]
    if bucket
      formatted_contents = EMAIL_DIVIDER + bucket.join(EMAIL_DIVIDER)
      "#{bucket_label} #{bucket.length}:#{formatted_contents}"
    else
      "#{bucket_label}"
    end
  end

  def uncompleted_sum(states)
    total = 0

    states.each {|k,v| total += v.length unless k == :completed}
    "Not completed #{total}"
  end
end
