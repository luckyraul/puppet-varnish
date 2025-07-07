# frozen_string_literal: true

require 'docker'

# Helper to strip ANSI color codes from strings
def strip_ansi_codes(str)
  str.gsub(%r{\e\[[\d;]*m}, '') # regex matches ANSI escape sequences
end

def apply_manifest(container, manifest)
  puts "\n--- Applying manifest ---"
  container.store_file('/tmp/manifest.pp', manifest)
  result = container.exec(
    ['/opt/puppetlabs/bin/puppet', 'apply', '--verbose', '--detailed-exitcodes', '/tmp/manifest.pp'],
    tty: true,
  )

  stdout_raw = result[0]
  stderr_raw = result[1]
  exit_code = result[2]

  # Join lines, strip ANSI codes, normalize newlines
  stdout_clean = strip_ansi_codes(stdout_raw.join).gsub("\r\n", "\n")
  stderr_clean = strip_ansi_codes(stderr_raw.join).gsub("\r\n", "\n")

  puts "STDOUT:\n#{stdout_clean}"
  puts "STDERR:\n#{stderr_clean}" unless stderr_clean.empty?
  puts "Exit code: #{exit_code}"
  unless [0, 2].include?(exit_code)
    raise "Puppet apply failed with exit code #{exit_code}"
  end
  puts "--- Manifest applied ---\n"
end

describe 'varnish class' do
  context 'default parameters' do
    container = nil

    before(:context) do
      puts 'Creating container...'
      container = Docker::Container.create(
        'Cmd' => ['tail', '-f', '/dev/null'],
        'Image' => "puppet-lab:#{ENV['GITHUB_RUN_ID']}",
      )
      puts 'Starting container...'
      container.start
    end

    after(:context) do
      puts 'Stopping container...'
      container&.stop
    end

    it 'works idempotently with no errors' do
      pp = <<-EOS
        include dummy_service
        include varnish
      EOS

      puts 'First puppet apply:'
      apply_manifest(container, pp)

      puts 'Second puppet apply:'
      apply_manifest(container, pp)
    end
  end
  context 'manage stable repos' do
    container = nil

    before(:context) do
      puts 'Creating container...'
      container = Docker::Container.create(
        'Cmd' => ['tail', '-f', '/dev/null'],
        'Image' => "puppet-lab:#{ENV['GITHUB_RUN_ID']}",
      )
      puts 'Starting container...'
      container.start
    end

    after(:context) do
      puts 'Stopping container...'
      container&.stop
    end

    it 'works idempotently with no errors' do
      pp = <<-EOS
        include dummy_service
        class { 'varnish':
          manage_repos => true
        }
      EOS

      puts 'First puppet apply:'
      apply_manifest(container, pp)

      puts 'Second puppet apply:'
      apply_manifest(container, pp)
    end
  end
  context 'manage fresh repos' do
    container = nil

    before(:context) do
      puts 'Creating container...'
      container = Docker::Container.create(
        'Cmd' => ['tail', '-f', '/dev/null'],
        'Image' => "puppet-lab:#{ENV['GITHUB_RUN_ID']}",
      )
      puts 'Starting container...'
      container.start
    end

    after(:context) do
      puts 'Stopping container...'
      container&.stop
    end

    it 'works idempotently with no errors' do
      pp = <<-EOS
        include dummy_service
        class { 'varnish':
          manage_repos => true,
          package_source => 'fresh',
        }
      EOS

      puts 'First puppet apply:'
      apply_manifest(container, pp)

      puts 'Second puppet apply:'
      apply_manifest(container, pp)
    end
  end
end
