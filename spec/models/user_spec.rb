require 'spec_helper'

describe User do
  describe '#find_or_create_by_github' do
    git_data = {
      name: 'Adam Krzysztof Stankiewicz',
      email: 'sheerun@sher.pl'
    }

    github_data = {
      name: 'Adam Stankiewicz',
      email: 'sheerun@sher.pl',
      username: 'sheerun'
    }

    it 'creates new user in simple case' do
      user = User.find_or_create_from_github(github_data)

      user.email.should == github_data[:email]
      user.name.should == github_data[:name]
      user.username.should == github_data[:username]

      User.count.should == 1
    end

    it 'does not create second user of one already exist' do
      User.find_or_create_from_github(github_data)
      User.find_or_create_from_github(github_data)
      User.count.should == 1
    end

    it 'forces first and last name update if username is known' do
      User.find_or_create_from_github(git_data)
      User.find_or_create_from_github(github_data)
      User.last.name.should == github_data[:name]
      User.last.username.should == github_data[:username]
    end

    it 'does not save user if his data did not change' do
      User.find_or_create_from_github(github_data)
      User.any_instance.should_not_receive(:save!)
      User.find_or_create_from_github(github_data)
    end
  end
end
