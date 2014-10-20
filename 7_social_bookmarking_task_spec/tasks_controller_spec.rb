require 'rails_helper'

describe TasksController do
	render_views

	before :each do
		@user = FactoryGirl.create(:user)
		sign_in(@user)
	end

	describe "GET #index" do
		it "populates an array of tasks" do
			task = FactoryGirl.create(:task)
			get :index
			expect(assigns(:tasks)).to eq([task])
		end
		it "renders the :index template" do
			get :index
			expect(response).to render_template :index
		end
	end

	describe "GET #show" do
		it "assigns the requested task to task" do
			task = FactoryGirl.create(:task)
			get :show, id: task
			expect(assigns(:task)).to eq(task)
		end
		it "renders the :show template" do
			get :show, id: FactoryGirl.create(:task)
			expect(response).to render_template :show
		end
	end
	describe "GET #new" do
		it "assigns a new task to task" do
			get :new
			expect(assigns(:task)).to be_a_new(Task)
		end
		it "renders the :new template" do
			get :new
			expect(response).to render_template :new
		end

	end
	describe "GET #edit" do
		it "assigns the requested task to task" do
			task = FactoryGirl.create(:task)
			get :edit, id: task
			expect(assigns(:task)).to eq(task)
		end
		it "renders the :edit template" do
			task = FactoryGirl.create(:task)
			get :edit, id: task
			expect(response).to render_template :edit
		end
	end
	describe "POST #create" do
		context "with valid attributes" do
			it "saves the new task to the database" do
				expect{
					post :create, task: FactoryGirl.attributes_for(:task)
				}.to change(Task, :count).by(1)
			end
			it "redirects to the #show action" do
				post :create, task: FactoryGirl.attributes_for(:task)
				expect(response).to redirect_to(Task.last)
			end
		end
		context "with invalid attributes" do
			it "does not save the new task in the database" do
				expect{
					post :create, task: FactoryGirl.attributes_for(:invalid_task)
				}.to change(Task, :count).by(0)
			end
			it "re-renders the :new template" do
				post :create, task: FactoryGirl.attributes_for(:invalid_task)
				expect(response).to render_template :new
			end
		end
	end
	describe "PUT #update" do
		before :each do
			@task = FactoryGirl.create(:task)
		end
		context "with valid attributes" do
			it "located the requested @task" do
				put :update, id: @task, task: FactoryGirl.attributes_for(:task)
				expect(assigns(:task)).to eq(@task)
			end

			it "changes @contact's attributes" do
				new_attribs = FactoryGirl.attributes_for(:task)
				put :update, id: @task,
					task: FactoryGirl.attributes_for(:task, name: new_attribs[:name], url: new_attribs[:url], description: new_attribs[:description])
				@task.reload
				expect(@task.name).to eq(new_attribs[:name])
				expect(@task.url).to eq(new_attribs[:url])
				expect(@task.description).to eq(new_attribs[:description])
			end

			it "redirects to the #show action" do
				put :update, id: @task, task: FactoryGirl.attributes_for(:task)
				expect(response).to redirect_to(Task.last)
			end
		end
		context "with invalid attributes" do
			it "does not update the task in the database" do
				expect{
					put :update, id: @task, task: FactoryGirl.attributes_for(:invalid_task)
				}.to change(Task, :count).by(0)
			end
			it "re-renders the :edit template" do
				put :update, id: @task, task: FactoryGirl.attributes_for(:invalid_task)
				expect(response).to render_template :edit
			end
		end
	end
	describe "POST #destroy" do
		it "deletes the task from the database" do
			@task = FactoryGirl.create(:task)
			expect {
				post :destroy, id: @task
				}.to change(Task, :count).by(-1)
		end
		it "redirects to the #index action" do
			@task = FactoryGirl.create(:task)
			post :destroy, id: @task
			expect(response).to redirect_to :tasks
		end
	end
end