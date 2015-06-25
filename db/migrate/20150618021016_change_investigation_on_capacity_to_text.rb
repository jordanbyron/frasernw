class ChangeInvestigationOnCapacityToText < ActiveRecord::Migration
  def up
    # repeat for all your tables and all your columns
    execute 'ALTER TABLE "capacities" ALTER COLUMN "investigation" TYPE character varying;'
  end

  def down
    # repeat for all your tables and all your columns
    execute 'ALTER TABLE "capacities" ALTER COLUMN "investigation" TYPE character varying(255);'
  end
end
