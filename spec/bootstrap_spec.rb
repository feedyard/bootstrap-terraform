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
