require 'rails_helper'

describe Task do

	it "has a valid factory" do
		#FactoryGirl.create(:task).should be_valid
		expect(FactoryGirl.create(:task)).to be_valid
	end

	it "is invalid without a name" do
		expect(FactoryGirl.build(:task, name: nil)).to_not be_valid
	end

	it "is invalid without a url" do
		expect(FactoryGirl.build(:task, url: nil)).to_not be_valid
	end

	it "is invalid without a description" do
		expect(FactoryGirl.build(:task, description: nil)).to_not be_valid
	end

	it "must be unique" do
		task_one = FactoryGirl.create(:task)
		expect(FactoryGirl.build(:task, name: task_one.name, url: task_one.url, description: task_one.description)).to_not be_valid
	end

end