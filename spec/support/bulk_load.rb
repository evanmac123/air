def rig_user_ids_for_bulk_removal(keyholder, ids_to_save)
  ids_to_save.each {|id| redis.sadd(keyholder.redis_user_ids_to_remove_key, id)}
end

def expect_user_ids_in_queue(keyholder, user_ids_to_remove)
  ids_queued_to_remove = if keyholder.respond_to?(:user_ids_to_remove)
                           keyholder.user_ids_to_remove
                         else
                           redis.smembers(keyholder.redis_user_ids_to_remove_key)
                         end
  user_ids_to_remove.map(&:to_s).sort.should == ids_queued_to_remove.map(&:to_s).sort
end

def expect_user_ids_in_queue_and_object(keyholder, user_ids_to_remove)
  expect_user_ids_in_queue(keyholder, user_ids_to_remove)
  keyholder.user_ids_to_remove.map(&:to_s).sort.should == user_ids_to_remove.map(&:to_s).sort
end
