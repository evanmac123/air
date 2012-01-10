module BulkCompleteMailerHelper
  EMAIL_DIVIDER = "\n    ".freeze

  def explain_bucket(bucket_name, bucket_label, states)
    bucket = states[bucket_name]
    formatted_contents = EMAIL_DIVIDER + bucket.join(EMAIL_DIVIDER)
    "#{bucket_label} #{bucket.length}:#{formatted_contents}"
  end

  def uncompleted_sum(states)
    total = 0

    states.each {|k,v| total += v.length unless k == :completed}
    "Not completed #{total}"
  end
end
