# frozen_string_literal: true

require 'spec_helper'

describe vpc('vpc-bootstrap') do
  it { should exist }
  it { should be_available }
  it { should have_route_table('vpc-bootstrap-rt-public') }
  it { should have_tag('terraform').value('true') }
  it { should have_tag('bootstrap').value('true') }
end

describe internet_gateway('vpc-bootstrap-igw') do
  it { should exist }
  it { should be_attached_to('vpc-bootstrap') }
  it { should have_tag('terraform').value('true') }
  it { should have_tag('bootstrap').value('true') }
end

describe subnet('vpc-bootstrap-subnet-public-us-east-1b') do
  it { should exist }
  it { should have_tag('terraform').value('true') }
  it { should have_tag('bootstrap').value('true') }
end

describe subnet('vpc-bootstrap-subnet-public-us-east-1c') do
  it { should exist }
  it { should have_tag('terraform').value('true') }
  it { should have_tag('bootstrap').value('true') }
end

describe subnet('vpc-bootstrap-subnet-public-us-east-1d') do
  it { should exist }
  it { should have_tag('terraform').value('true') }
  it { should have_tag('bootstrap').value('true') }
end

describe efs('efs-bootstrap') do
  it { should exist }
  its(:number_of_mount_targets) {should eq(1)}
  it { should have_tag('terraform').value('true') }
  it { should have_tag('bootstrap').value('true') }
end

describe security_group('vpc-sg-efs-bootstrap') do
  it { should exist }
  its(:inbound) { should be_opened(2049).protocol('tcp') }
  it { should have_tag('terraform').value('true') }
  it { should have_tag('bootstrap').value('true') }
end

describe security_group('vpc-sg-bootstrap-swarm') do
  it { should exist }
  its(:inbound) { should be_opened(443).protocol('tcp').for('0.0.0.0/0') }
  its(:inbound) { should be_opened(80).protocol('tcp').for('0.0.0.0/0') }
  its(:inbound) { should be_opened(8153).protocol('tcp').for('0.0.0.0/0') }
  its(:inbound) { should be_opened(8154).protocol('tcp').for('0.0.0.0/0') }
  its(:inbound) { should be_opened(22).protocol('tcp').for('0.0.0.0/0') }
  its(:inbound) { should be_opened(2376).protocol('tcp').for('0.0.0.0/0') }
  its(:inbound) { should be_opened(3376).protocol('tcp').for('0.0.0.0/0') }
  it { should have_tag('terraform').value('true') }
  it { should have_tag('bootstrap').value('true') }
end

describe iam_policy('bootstrap-host-policy') do
  it { should exist }
  it { should be_attachable }
  it { should be_attached_to_role('bootstrap-host-role') }
end

describe iam_role('bootstrap-host-role') do
  it { should exist }
  it { should be_allowed_action('ec2:DescribeInstances') }
end

describe ec2('bootstrap01') do
  it { should exist }
  it { should be_running }
  it { should have_iam_instance_profile('bootstrap-host-profile') }
  it { should have_security_group('vpc-sg-bootstrap-swarm') }
  it { should belong_to_subnet('vpc-bootstrap-subnet-public-us-east-1b') }
  it { should have_tag('terraform').value('true') }
end