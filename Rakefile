# Checks if we are inside Travis CI.
#
# @return [Boolean] whether we are inside Travis CI.
# @example
#   travis? #=> false
def travis?
  ENV['TRAVIS'] == 'true'
end

namespace :style do
  desc 'Run Ruby style checks'
  task :ruby do
    sh '/opt/chefdk/embedded/bin/cookstyle --version'
    sh '/opt/chefdk/embedded/bin/cookstyle'
  end

  desc 'Run Chef style checks'
  task :chef do
    sh '/opt/chefdk/embedded/bin/foodcritic --version'
    sh '/opt/chefdk/embedded/bin/foodcritic -f any . --exclude spec'
  end
end

desc 'Run styling tests'
task style: ['style:ruby', 'style:chef']

namespace :unit do
  desc 'Run ChefSpec'
  task :spec do
    sh 'rm -f Policyfile.lock.json'
    sh '/opt/chefdk/embedded/bin/chef exec rspec'
  end
end

desc 'Run unit tests'
task unit: ['unit:spec']

namespace :integration do
  def run_kitchen
    sh '[ -e Policyfile.lock.json ] || /opt/chefdk/embedded/bin/chef install'
    sh "kitchen test #{ENV['KITCHEN_ARGS']} #{ENV['KITCHEN_INSTANCE']}"
  end

  desc 'Run Test Kitchen integration tests using vagrant'
  task :vagrant do
    ENV.delete('KITCHEN_LOCAL_YAML')
    run_kitchen
  end

  desc 'Run Test Kitchen integration tests using dokken'
  task :dokken do
    ENV['KITCHEN_LOCAL_YAML'] = '.kitchen.dokken.yml'
    run_kitchen
  end
end

desc 'Run Test Kitchen integration tests'
task integration: travis? ? %w(integration:dokken) : %w(integration:vagrant)

task default: [:style, :unit, :integration]
