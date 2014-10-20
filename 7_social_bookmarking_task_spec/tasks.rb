require 'faker'

FactoryGirl.define do
	factory :task do |f|
		f.name 				{ Faker::Hacker.adjective + Faker::Hacker.noun + Faker::Hacker.ingverb }
		f.url 				{ Faker::Internet.url }
		f.description { Faker::Lorem.paragraph }
	end

	factory :invalid_task, parent: :task do |f|
		f.name nil
	end
end