deploy = node[:deploy]

opsworks_deploy_user do
    deploy_data node[:opsworks][:deploy_user]
end

opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
end

node[:deploy].each do |application, deploy|
    # Chef::Log.info("deploy data: #{deploy}")
    opsworks_deploy do
        app application
        deploy_data deploy
    end
end
    