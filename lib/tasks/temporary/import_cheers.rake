namespace :db do
  namespace :admin do
    desc "Import legacy cheers"
    task import_cheers: :environment do
      Cheer.destroy_all
      cheers = File.read("cheers.csv")
      csv = CSV.parse(cheers, headers: true)
      csv.each do |row|
        row = row.to_hash
        cheer = Cheer.create!(row)
        cheer.update_attributes(created_at: row["created_at"])

        puts "Cheer created. Cheer count: #{Cheer.count}"
      end
    end
  end
end
