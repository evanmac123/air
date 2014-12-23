class IntercomPurger
  def initialize(segment_id)
    @segment_id = segment_id
  end

  def purge!
    user_collection.each {|user| schedule_deletion(user)}
  end

  protected

  def user_collection
    @user_collection ||= Intercom::User.find_all(segment_id: @segment_id)
  end

  def schedule_deletion(user)
    Delayed::Job.enqueue PurgeJob.new(user)
  end

  class PurgeJob
    def initialize(user)
      @user_id = user.id
    end

    def perform
      Intercom::User.find(id: @user_id).delete
    end
  end
end
