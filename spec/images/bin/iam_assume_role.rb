#!/usr/bin/env ruby

require "bundler/setup"
require "aws-sdk-iam"
require "aws-sdk-ec2"

#####################################################
# This script uses IAM role with permissions and uses 
# AssumeRole to create credentials dynamically in 'role_credentials'
######################################################
def main
    check_prerequisites

    role_arn = "arn:aws:iam::"+env('ACCOUNT_ID')+":role/"+env('ROLE_NAME')       

    puts role_arn

    role_credentials = Aws::AssumeRoleCredentials.new(
    role_arn: role_arn,
    role_session_name: "cluster_backup_checker_session"
    )
    puts role_credentials.inspect
    
    client = Aws::EC2::Client.new(
    region: env('AWS_REGION'),
    credentials: role_credentials
    )

    opts = {
    filters: [
        { name: "status", values: [ "completed" ] },
        { name: "tag:KubernetesCluster", values: [env('KUBERNETES_CLUSTER')] },
    ]
    }

    snapshots = get_snapshots(client, opts)

end


def check_prerequisites
    %w(
        ACCOUNT_ID
        ROLE_NAME
        AWS_REGION
        KUBERNETES_CLUSTER
    ).each do |var|
      env(var)
    end
end
  
def env(var)
    ENV.fetch(var)
end
#####################################################
# get_snapshots() uses AWS API describe_snapshots to get 
# the list of snapshots with the filters given in 'opts'. 
# 'result' is looped until the next_token string is null. 
######################################################  
def get_snapshots(client, opts)
  snapshots = []
  next_token = "dummy"

  while !next_token.nil?
    puts "Calling the AWS API..."
    result = client.describe_snapshots(opts)
    snapshots += result.snapshots
    next_token = result.next_token
    opts[:next_token] = next_token
  end

  snapshots
end
  
main