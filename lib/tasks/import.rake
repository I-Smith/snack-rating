namespace :import do
  desc "Import snacks from a CSV file. Usage: bin/rails import:snacks[path/to/file.csv,dry_run]"
  task :snacks, [:file, :mode] => :environment do |_, args|
    require "csv"

    file = args[:file] || "snacks.csv"
    dry_run = args[:mode] == "dry_run"

    puts "DRY RUN — no data will be saved" if dry_run

    unless File.exist?(file)
      puts "File not found: #{file}"
      exit 1
    end

    imported = 0
    errors = 0

    CSV.foreach(file, headers: true) do |row|
      snack = Snack.new(
        brand:             row["brand"],
        name:              row["name"],
        isaac_rating:      row["isaac_rating"],
        kristina_rating:   row["kristina_rating"],
        notes:             row["notes"],
        tried_on:          row["tried_on"],
        country_of_origin: row["country_of_origin"]
      )

      if snack.valid?
        imported += 1
        puts "OK: #{snack.brand} – #{snack.name}"
        snack.save unless dry_run
      else
        errors += 1
        puts "Failed: #{row["name"]} — #{snack.errors.full_messages.join(", ")}"
      end
    end

    puts "\nDone. #{imported} #{"would be " if dry_run}imported, #{errors} failed."
  end
end
