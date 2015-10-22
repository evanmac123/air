namespace :db do
  namespace :admin do

    desc "Populates the Topics Table"

    task :build_topics => :environment do

      topics = {
        "Wellness" => [
          "Recipe Of The Week",
          "Workout Of The Week",
        ],
        "Compliance" => [
          "Introduce a Policy", 
          "Sign a Policy", 
          "Other"
        ],
        "Recruitment" => [
          "Social Recruiting", 
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
