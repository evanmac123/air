module S3UploadHelper

  def file_type_font_for name
    ext = File.extname(name).downcase
    case ext
    when ".pdf"
      type = "file-pdf-o"
    when ".bmp", ".jpeg", ".jpg", ".png"
      type = "file-image-o"
    when ".xls", ".xlsx", ".csv"
      type = "file-excel-o"
    when ".doc", ".docx"
      type = "file-word-o"
    when ".ppt", ".pptx"
      type = "file-powerpoint-o"
    when ".mp4","mpeg", "wmv"
      type = "file-video-o"
    when ".mp3","ogg", "wma"
      type = "file-audio-o"
    when ".zip","tar"
      type = "file-archive-o"
    when ".txt"
      type = "file-text-o"
    else
      type = "file-o"
    end
      fa_icon(type, class: "icon-tile-attachment")
  end

  def s3_uploader_form(options = {}, &block)
    uploader = S3Uploader.new(options)
    form_tag(uploader.url, uploader.form_options) do
      uploader.fields.map do |name, value|
        hidden_field_tag(name, value)
      end.join.html_safe + capture(&block)
    end
  end

  class S3Uploader
    def initialize(options)
      @options = options.reverse_merge(
        aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
        bucket: S3_TILE_BUCKET,
        acl: "public-read",
        expiration: 10.hours.from_now.utc,
        max_file_size: 2.5.megabytes.to_i,
      )
    end

    def form_options
      {
        id: @options[:id],
        method: "post",
        authenticity_token: false,
        multipart: true,
        class: @options[:class],
        style: @options[:style],
        data: @options[:data]
      }
    end

    def fields
      {
        :key => key,
        :acl => @options[:acl],
        :policy => policy,
        :signature => signature,
        "AWSAccessKeyId" => @options[:aws_access_key_id],
        :success_action_status => "201",
      }
    end

    def key
      @key ||= "#{base_path}/#{SecureRandom.hex}/${filename}"
    end

    def base_path
      @options.fetch(:data, {}).fetch(:path, nil) || "uploads"
    end

    def url
      "https://#{@options[:bucket]}.s3.amazonaws.com/"
    end

    def policy
      Base64.encode64(policy_data.to_json).gsub("\n", "")
    end

    def policy_data
      {
        expiration: @options[:expiration],
        conditions: [
          ["starts-with", "$utf8", ""],
          ["starts-with", "$key", ""],
          ["content-length-range", 0, @options[:max_file_size]],
          {bucket: @options[:bucket]},
          {success_action_status: "201"},
          {acl: @options[:acl]}
        ]
      }
    end

    def signature
      Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest::Digest.new('sha1'),
          @options[:aws_secret_access_key], policy
        )
      ).gsub("\n", "")
    end
  end
end
