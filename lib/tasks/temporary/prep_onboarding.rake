namespace :db do
  namespace :admin do
    desc "Prep data for onboarding"
    task prep_onboarding: :environment do
      puts "updating explore topics"
      Topic.all.each { |t| t.update_attribtues(is_explore:true) }

      puts "creating new topics and topic boards"
      [["Open Enrollment", 1714], ["Financial Education", 1715], ["Biometrics", 1716], ["Prescription Drugs", 1717], ["Health Plan Basics", 1718]].each do |t|
        topic = Topic.create(name: t.first, is_explore: false)

        TopicBoard.create(demo_id: t.last, topic_id: topic.id, is_onboarding: true)
      end

      TopicBoard.create(demo_id: 1719, topic_id: 1)
    end
  end
end
