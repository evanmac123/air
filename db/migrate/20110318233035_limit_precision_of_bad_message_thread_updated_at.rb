class LimitPrecisionOfBadMessageThreadUpdatedAt < ActiveRecord::Migration
  def self.up
    # Got to do this with execute_sql because Rails apparently drops the 
    # precision argument on timestamps, even though Postgres would probably
    # be happy to respect it. No biggie.
    #
    # This gives us 3 decimal places of seconds (i.e. millisecond resolution)
    execute 'ALTER TABLE "bad_message_threads" ALTER COLUMN "updated_at" TYPE timestamp (3)'
  end

  def self.down
    execute 'ALTER TABLE "bad_message_threads" ALTER COLUMN "updated_at" TYPE timestamp'
  end
end
