define :opsworks_deploy do
  application = params[:app]
  deploy = params[:deploy_data]

  directory "#{deploy[:deploy_to]}" do
    group deploy[:group]
    owner deploy[:user]
    mode "0775"
    action :create
    recursive true
  end

  if deploy[:scm]
    options_data={}
    options_data[:user] = deploy[:user]
    options_data[:group] = deploy[:group]
    options_data[:home] = deploy[:home]
    options_data[:ssh_key] = deploy[:scm][:ssh_key]
    prepare_git_checkouts do
      options options_data
    end
  end


  directory "#{deploy[:deploy_to]}/shared/cached-copy" do
    recursive true
    action :delete
    only_if do
      deploy[:delete_cached_copy]
    end
  end

  ruby_block "change HOME to #{deploy[:home]} for source checkout" do
    block do
      ENV['HOME'] = "#{deploy[:home]}"
    end
  end

  def create_dirs_before_symlink(deploy)
    dirs = deploy[:create_dirs_before_symlink]
    dirs.each do |dir|
      directory "#{deploy[:deploy_to]}/shared/#{dir}" do
        user deploy[:user]
        group deploy[:group]
        recursive true
        action :create
        not_if { ::File.directory?("#{deploy[:deploy_to]}/shared/#{dir}") }
      end
    end
  end
  
  def symlink_before_migrate(deploy)
    links = deploy[:symlink_before_migrate] || {}
    links.each do |source, target|
      link "#{deploy[:deploy_to]}/current/#{target}" do
        group deploy[:group]
        owner deploy[:user]
        to "#{deploy[:deploy_to]}/shared/#{source}"
      end
    end
  end
  
  def symlinks(deploy)
    links = deploy[:symlinks]
    links.each do |source, target|
      link "#{deploy[:deploy_to]}/current/#{target}" do
        group deploy[:group]
        owner deploy[:user]
        to "#{deploy[:deploy_to]}/shared/#{source}"
      end
    end
  end
  def purge_before_symlink(deploy)
    dirs = deploy[:purge_before_symlink]
    dirs.each do |target|
      dirPath = "#{deploy[:deploy_to]}/current/#{target}";
      directory dirPath  do
        recursive true
        action :delete
        only_if { ::File.directory?(dirPath) }
      end
    end
  end

  # setup deployment & checkout
  if deploy[:scm] && deploy[:scm][:scm_type] != 'other'
    Chef::Log.debug("Checking out source code of application #{application} with type #{deploy[:application_type]}")
    timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
    deploy_path=deploy[:deploy_to]
    # Create a new release folder
    release_path = "#{deploy_path}/releases/#{timestamp}"
    directory release_path do
      group deploy[:group]
      owner deploy[:user]
      recursive true
    end

    git release_path do
      repository deploy[:scm][:repository]
      user deploy[:user]
      group deploy[:group]
      revision deploy[:scm][:revision]
      action deploy[:action]
    end

    ["public","tmp"].each do |folder|
      dirPath = "#{release_path}/#{folder}"
      directory dirPath do
        group deploy[:group]
        owner deploy[:user]
        recursive true
        not_if { ::File.directory?(dirPath) }
      end
    end

    link "#{deploy_path}/current" do
      group deploy[:group]
      owner deploy[:user]
      to release_path
    end

    purge_before_symlink(deploy) unless deploy[:purge_before_symlink].nil?
    create_dirs_before_symlink(deploy)  unless deploy[:create_dirs_before_symlink].nil?
    symlink_before_migrate(deploy)   unless deploy[:symlink_before_migrate].nil?
    symlinks(deploy) unless deploy[:symlinks].nil?
    releases = Dir.glob("#{deploy_path}/releases/*").sort_by { |f| File.mtime(f) }
    # Keep the last 5 releases and remove the older ones
    (releases - (releases.last(deploy[:keep_releases]||5))).each do |old_release|
      Chef::Log.info("old_release:#{old_release}")
      directory old_release do
        action :delete
        recursive true
      end
    end
  end

  ruby_block "change HOME back to /root after source checkout" do
    block do
      ENV['HOME'] = "/root"
    end
  end


  bash "Enable selinux var_log_t target for application log files" do
    dir_path_log = "#{deploy[:deploy_to]}/shared/log"
    context = "var_log_t"

    user "root"
    code <<-EOH
    semanage fcontext --add --type #{context} "#{dir_path_log}(/.*)?" && restorecon -rv "#{dir_path_log}"
    EOH
    not_if { OpsWorks::ShellOut.shellout("/usr/sbin/semanage fcontext -l") =~ /^#{Regexp.escape("#{dir_path_log}(/.*)?")}\s.*\ssystem_u:object_r:#{context}:s0/ }
    only_if { platform_family?("rhel") && ::File.exist?("/usr/sbin/getenforce") && OpsWorks::ShellOut.shellout("/usr/sbin/getenforce").strip == "Enforcing" }
  end

  template "/etc/logrotate.d/opsworks_app_#{application}" do
    backup false
    source "logrotate.erb"
    cookbook 'smart_custom'
    owner "root"
    group "root"
    mode 0644
    variables( :log_dirs => ["#{deploy[:deploy_to]}/shared/log" ] )
  end
end
