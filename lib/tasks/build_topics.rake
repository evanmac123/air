namespace :db do
  namespace :admin do

    desc "Populates the Topics Table"

    task :build_topics => :environment do

      topics = {
        "Wellness" => [
          "Healthy Recipe of the Week",
          "Workout of the Week",
        ],
        "Compliance" => [
          "Explain a Complex Policy", 
          "Gather Policy Acknowledgment", 
          "Update Contact Information",
          "Gather Policy Feedback"
        ],
        "Recruitment" => [
          "Promote Job Referrals", 
        ],
        "Other" => [
        ]
      }

      Topic.make_topics_with_tags topics 

      other = Topic.find_by_name("Other")
      TileTag.where(topic_id: nil).each do|tag|
        tag.topic = other
        tag.save
      end
    end

  end
end
