require 'aws-sdk'
module Concerns::Attachable 
  # This module provides some basic functionality for managing files on S3
  # when mixed in to an AR model that has a textfield called file_attachments
  # it will convert a an array of AWS S3 urls submitted via the tile builder
  # into a hash key by the filename
  #  if the tile is deleted it will delete the s3 assets
  #

 # TODO consider changing this implentation to simply use the file_attachments
  # field as a serialized array, forgo the whole conversion to hash and working
  # directly from the URL returned by s3
  # Since we are re-writing the serialized value everytime something changes it
  # might simplify things
  #
  # 
  BASE_ATTACHMENT_PATH ="tile_attachments/board"
  BUCKET_URL = "https://#{APP_BUCKET}.s3.amazonaws.com"
  extend ActiveSupport::Concern
  included do
    # attachments is an array of urls submitted via the form.
    # we use it to populate the file_attachments serialized hash
    attr_accessor :attachments 
    serialize :file_attachments, Hash
    before_destroy :delete_s3_attachments 
    before_validation :update_attachments
    before_save :copy_to_self,  unless: :new_record?
  end

  def documents
    h = {}
    file_attachments.each do |filename,path|
      filename = filename.gsub("_dot_" , "." )
      h[filename]="#{BUCKET_URL}#{path}"
    end
    h
  end

  def delete_s3_attachments
    get_attachments.map(&:delete)
  end


  def copy_s3_attachments_to tile
    file_attachments.map do |filename, path|
     obj = get_s3_object s3_key_from(path)
      copy_attachment obj, filename, tile unless already_attached?(path, tile)
    end
  end

  def tile_attachments_path
    base =  "#{BASE_ATTACHMENT_PATH}/#{demo_id}/tile"
    base += "/#{id}" unless new_record?
    base
  end 

  def copy_attachment object, filename, target
    unencoded_file_name = filename.gsub("_dot_", "." ).gsub("%20", " ")
    new_key = "#{target.tile_attachments_path}/#{SecureRandom.hex}/#{unencoded_file_name}"
    copy = object.copy_to(new_key, {:acl => :public_read})
    new_path = copy.public_url.path.gsub("%20", " " )
    target.file_attachments[filename]= new_path
  end

  private

  def already_attached? path, tile
    path.include?("tile/#{tile.id}")
  end

  def copy_to_self
    copy_s3_attachments_to self
  end

  def s3
    @s3 ||= AWS::S3.new
  end

  def s3_attachment_bucket
    @bucket ||= s3.buckets[APP_BUCKET]
  end

  def get_attachments
    file_attachments.map do |filename,path |
      get_s3_object s3_key_from(path)
    end
  end

  def s3_key_from path
    key = path[1..-1]
    URI.decode(key)
  end

  def get_s3_object s3_key
    s3_attachment_bucket.objects[s3_key]
  end

  def update_attachments
    if all_attachments_deleted?
      delete_s3_attachments
      self.file_attachments = {}
    elsif attachments_changed?
      self.file_attachments = {}
      attachments.drop_while{|x|x=="DELETE"}.each do |url|
        uri = URI.parse(URI.escape(url))
        filename = File.basename(uri.path).gsub(".", "_dot_")
        self.file_attachments[filename]=uri.path.gsub("%20", " ")
      end
    end
  end

  def attachments_changed_or_deleted
    all_attachments_deleted? || attachments_changed?
  end

  def all_attachments_deleted?
    attachments && attachments.count == 1 && attachments[0] == "DELETE"
  end

  def attachments_changed?
    attachments && attachments.count > 1 && attachments[1..-1].count != file_attachments.count
  end

 
end
