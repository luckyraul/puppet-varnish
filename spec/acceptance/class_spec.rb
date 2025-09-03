# frozen_string_literal: true

require 'docker'
require 'serverspec'

# Increase Docker timeouts to prevent TimeoutError
Docker.options[:read_timeout] = 300 # 5 minutes
Docker.options[:write_timeout] = 300

# Helper to strip ANSI color codes from strings
def strip_ansi_codes(str)
  str.gsub(%r{\e\[[\d;]*m}, '') # regex matches ANSI escape sequences
end

def apply_manifest(container, manifest)
  puts "\n--- Applying manifest ---"
  container.store_file('/manifest.pp', manifest)
  result = container.exec(
    ['puppet', 'apply', '--verbose', '--detailed-exitcodes', '/manifest.pp'],
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
      container = Docker::Container.create(
        'Image' => "puppet-lab:#{ENV['GITHUB_RUN_ID']}",
        'HostConfig' => {
          'CgroupnsMode' => 'host',
          'Binds' => ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
          'Privileged' => true
        },
        'Volumes' => {
          '/sys/fs/cgroup' => {}
        },
      )
      puts "::group::Creating container #{container.id}"
      container.start
      set :backend, :docker
      set :docker_container, container.id
      Specinfra.backend.instance_variable_set(:@container, container)
    end

    after(:context) do
      puts "Stopping container #{container.id}..."
      container&.stop
      puts 'Container was stopped'
      container&.delete
      puts '::endgroup::'
    end

    it 'works idempotently with no errors' do
      pp = <<-EOS
        # include dummy_service
        include varnish
      EOS

      puts "First apply on container #{container.id}"
      apply_manifest(container, pp)

      puts "Second apply on container #{container.id}"
      apply_manifest(container, pp)
    end

    it 'checks if varnish package is installed' do
      puts "Validate container #{container.id}"
      expect(package('varnish')).to be_installed
      command_result = command('varnishd -V')
      puts "Version: #{command_result.stderr}"
      # Match the version string in stderr (matches "varnishd x.y.z" and stops before the copyright text)
      expect(command_result.stderr).to match(%r{varnishd\s+\(varnish-\d+\.\d+\.\d+})
    end

    describe service('varnish') do
      it { is_expected.to be_enabled }
    end
  end

  context 'manage stable repos' do
    container = nil

    before(:context) do
      container = Docker::Container.create(
        'Image' => "puppet-lab:#{ENV['GITHUB_RUN_ID']}",
        'HostConfig' => {
          'CgroupnsMode' => 'host',
          'Binds' => ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
          'Privileged' => true
        },
        'Volumes' => {
          '/sys/fs/cgroup' => {}
        },
      )
      puts "::group::Creating container #{container.id}"
      container.start
      set :backend, :docker
      set :docker_container, container.id
      Specinfra.backend.instance_variable_set(:@container, container)
    end

    after(:context) do
      puts "Stopping container #{container.id}..."
      container&.stop
      puts 'Container was stopped'
      container&.delete
      puts '::endgroup::'
    end

    it 'works idempotently with no errors' do
      pp = <<-EOS
        # include dummy_service
        class { 'varnish':
          manage_repos => true
        }
      EOS

      puts "First apply on container #{container.id}"
      apply_manifest(container, pp)

      puts "Second apply on container #{container.id}"
      apply_manifest(container, pp)
    end

    it 'checks if varnish package is installed' do
      puts "Validate container #{container.id}"
      expect(package('varnish')).to be_installed
      command_result = command('varnishd -V')
      puts "Version: #{command_result.stderr}"
      # Match the version string in stderr (matches "varnishd x.y.z" and stops before the copyright text)
      expect(command_result.stderr).to match(%r{varnishd\s+\(varnish-\d+\.\d+\.\d+})
    end

    describe service('varnish') do
      it { is_expected.to be_enabled }
    end
  end

  context 'manage fresh repos' do
    container = nil

    before(:context) do
      container = Docker::Container.create(
        'Image' => "puppet-lab:#{ENV['GITHUB_RUN_ID']}",
        'HostConfig' => {
          'CgroupnsMode' => 'host',
          'Binds' => ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
          'Privileged' => true
        },
        'Volumes' => {
          '/sys/fs/cgroup' => {}
        },
      )
      puts "::group::Creating container #{container.id}"
      container.start
      set :backend, :docker
      set :docker_container, container.id
      Specinfra.backend.instance_variable_set(:@container, container)
    end

    after(:context) do
      puts "Stopping container #{container.id}..."
      container&.stop
      puts 'Container was stopped'
      container&.delete
      puts '::endgroup::'
    end

    it 'works idempotently with no errors' do
      pp = <<-EOS
        # include dummy_service
        class { 'varnish':
          manage_repos => true,
          package_source => 'fresh',
        }
      EOS

      puts "First apply on container #{container.id}"
      apply_manifest(container, pp)

      puts "Second apply on container #{container.id}"
      apply_manifest(container, pp)
    end

    it 'checks if varnish package is installed' do
      puts "Validate container #{container.id}"
      expect(package('varnish')).to be_installed
      command_result = command('varnishd -V')
      puts "Version: #{command_result.stderr}"
      # Match the version string in stderr (matches "varnishd x.y.z" and stops before the copyright text)
      expect(command_result.stderr).to match(%r{varnishd\s+\(varnish-\d+\.\d+\.\d+})
    end

    describe service('varnish') do
      it { is_expected.to be_enabled }
    end
  end
end
