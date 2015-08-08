require_relative 'gitlab_init'
require_relative 'gitlab_net'
require_relative 'gitlab_access_status'
require_relative 'names_helper'
require 'json'

class GitlabSync
  class AccessDeniedError < StandardError; end

  include NamesHelper

  attr_reader :config, :repo_path, :repo_name, :changes

  def initialize(repo_path, changes)
    @config = GitlabConfig.new
    @repo_path = repo_path.strip
    @repo_name = extract_repo_name(@repo_path.dup, config.repos_path.to_s)
    @changes = changes.lines
  end

  def exec
    api.sync_changes(@repo_name, @changes)

    true
  rescue GitlabNet::ApiUnreachableError
    $stderr.puts "GitLab: Failed to authorize your Git request: internal API unreachable"
    false
  end

  protected

  def api
    GitlabNet.new
  end
end
