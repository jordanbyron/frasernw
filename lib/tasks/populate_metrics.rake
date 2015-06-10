namespace :pathways do
  task :populate_metrics, [:delay] => :environment do |t, args|
    args.with_defaults(
      delay: 'false'
    )

    # looks like magic strings are safer as params than bool args, in this case
    # either rake or bash is parsing the bools I pass to strings...
    if args[:delay] == 'true'
      Analytics::Populator::All.delay.exec
    else
      Analytics::Populator::All.exec
    end
  end
end
