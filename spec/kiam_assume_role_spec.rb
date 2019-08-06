require "spec_helper"
# Prerequsities
###################
#Create a role 
#
#with a assume_role with right permissions
#createa an annotation for the namespace
#create an annotation for a pod 
# test whether the pod runs with assume role with namespace annotations and pod annotations
# test whether the pod runs with assume role without namespace annoations and with pod annotations and viceversa



describe "kiam" do
  let(:role) { ENV.fetch('ROLE_NAME') }
  let(:namespace) { "monitoring" }
  let(:account_id) { ENV.fetch('ACCOUNT_ID') }
  let(:aws_region) { ENV.fetch('AWS_REGION') }
  let(:kubernetes_cluster) { ENV.fetch('KUBERNETES_CLUSTER') }
#   before(:all) do
#     create_iam_role(role)
#   end

#   after(:all) do
#     delete_iam_role(role)
#   end

#   before do
#     create_namespace(role_whitelist: namespace_role_whitelist)
#     create_deployment
#   end

#   after do
#     delete_namespace
#   end

  context "when pod is allowed to assume role" do
    let(:pod_role_whitelist) { [ role ] }

    context "when namespace whitelists *" do
      let(:namespace_role_whitelist) { "*" }

      it "can assume role" do
        expect {
          try_to_assume_role(role)
        }.to_not raise_error("Assume role failure")
      end
    end
  end
 

#     context "when namespace whitelists the role*" do
#       let(:namespace_role_whitelist) { "foo,#{role},bar" }

#       it "can assume role" do
#         expect {
#           try_to_assume_role(role)
#         }.to_not raise_error(AWS::RoleError)
#       end
#     end

#     context "when namespace whitelists other roles" do
#       let(:namespace_role_whitelist) { "foo,bar" }

#       it "cannot assume role" do
#         expect {
#           try_to_assume_role(role)
#         }.to raise_error(AWS::RoleError)
#       end
#     end

#     context "when namespace whitelists no roles" do
#       let(:namespace_role_whitelist) { "" }

#       it "cannot assume role" do
#         expect {
#           try_to_assume_role(role)
#         }.to raise_error(AWS::RoleError)
#       end
#     end
#   end

#   context "when pod is not allowed to assume any roles" do
#     let(:pod_role_whitelist) { [] }

#     context "when namespace whitelists *" do
#       let(:namespace_role_whitelist) { "*" }

#       it "can assume role" do
#         expect {
#           try_to_assume_role(role)
#         }.to_not raise_error(AWS::RoleError)
#       end
#     end
#   end

#   context "when pod is allowed to assume other roles" do
#     let(:pod_role_whitelist) { ["foo", "bar"] }

#     context "when namespace whitelists *" do
#       let(:namespace_role_whitelist) { "*" }

#       it "can assume role" do
#         expect {
#           try_to_assume_role(role)
#         }.to_not raise_error(AWS::RoleError)
#       end
#     end
#   end
end

def try_to_assume_role(role)

  # this pod returns 'I can assume role' if AssumeRole for given role is permitted
  create_job(namespace, "spec/fixtures/iam-assume-role-job.yaml.erb", {
    job_name: "integration-test-kiam-assume-role-pod",
    role: role,
    account_id: account_id,
    aws_region: aws_region,
    kubernetes_cluster: kubernetes_cluster
  })

  # output = `kubectl --namespace #{namespace} exec -it integration-test-kiam-assume-role-pod -- sh #{role}`
  # output = 'I was not able to assume role #{role}'
  # if output.match(/I was able to assume role #{role}/)
  #   true
  # else
  #   false
  # end
end