Rake::Task[:'test:units'].prerequisites.delete "test:prepare"
p Rake::Task[:'test:units'].inspect
