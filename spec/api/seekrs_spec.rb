require 'rails_helper'

describe 'the employers endpoint' do
  it 'can successfully create' do
    post api_employers_path, attributes_for(:employer).to_json, 'CONTENT_TYPE' => 'application/json'
    get api_employers_path
    expect(latest_response['name']).to eq 'Makers'
  end

  it 'can successfully get' do
    create :employer
    get api_employers_path
    expect(latest_response['name']).to eq 'Makers'
  end
end

describe 'the jobseekers endpoint' do

  it 'can successfully create' do
    post api_jobseekers_path, attributes_for(:jobseeker).to_json, 'CONTENT_TYPE' => 'application/json'
    get api_jobseekers_path
    expect(latest_response['name']).to eq 'Bob Monkhouse'
  end

  it 'can successfully get' do
    create :jobseeker
    get api_jobseekers_path
    expect(latest_response['name']).to eq 'Bob Monkhouse'
  end
end

describe 'get the jobs from the endpoint' do
  it 'successfully' do
    create :employer
    create :job
    get api_jobs_path
    expect(latest_response['title']).to eq 'Dream Makerneer'
  end
end

describe 'get an individual jobseeker from the end point/id' do
  it 'successfully' do
    jobseeker = create :jobseeker
    get api_jobseeker_path(jobseeker)
    expect(last_response.body).to include 'Bob Monkhouse'
  end
end

describe 'get an individual job from the end point/id' do
  it 'successfully' do
    create :employer
    job = create :job
    get api_jobs_path(job)
    expect(last_response.body).to include 'Ptolemy'
  end
end

describe 'can create a new job by posting to an end point' do
  it 'successfully' do
    attributes = attributes_for(:job)
    employer   = create(:employer)
    post api_jobs_path, attributes.merge(employer_id: employer.id).to_json, 'CONTENT_TYPE' => 'application/json'
    get api_jobs_path
    expect(latest_response['title']).to eq 'Dream Makerneer'
  end

  it 'only if a title is entered' do
    create :employer
    post api_jobs_path, attributes_for(:job, title: '').to_json, 'CONTENT_TYPE' => 'application/json'
    get api_jobs_path
    expect(latest_response).to eq nil
  end
end

describe 'can delete a job' do
  it 'successfully' do
    create :employer
    job = create :job
    delete '/api/jobs/' + job.id.to_s
    get api_jobs_path
    expect(latest_response).to eq nil
  end
end

describe 'can send a skill and assign it to a user' do
  it 'successfully' do
    jobseeker = create :jobseeker
    post '/api/skills', {jobseeker_id: jobseeker.id.to_s, skill: 'Maths'}.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(latest_response).to include 'saved successfully'
  end
end

describe 'can accept and reject an offer' do
  it 'successfully accepts an offer' do
    create :employer
    job = create :job
    jobseeker = create :jobseeker
    post 'api/offers', {job_id: job.id.to_s, jobseeker_id: jobseeker.id.to_s, accepted: true}.to_json, 'CONTENT_TYPE' => 'application/json'
    get 'api/offers/job/' + job.id.to_s
    expect(JSON.parse(last_response.body)['accepted']).to eq true
  end
end

describe 'can ask for jobseekers' do
  it 'that are both accepted and rejected' do
    create :employer
    job = create :job
    jobseeker1 = create :jobseeker
    post 'api/offers', {job_id: job.id.to_s, jobseeker_id: jobseeker1.id.to_s, accepted: true}.to_json, 'CONTENT_TYPE' => 'application/json'
    get 'api/offers/all/' + job.id.to_s
    expect(latest_response).to equal nil
  end
end

describe 'can view all offers for a specific jobseeker' do
  it 'successfully' do
    create :employer
    job = create :job
    jobseeker = create :jobseeker
    post 'api/offers', {job_id: job.id.to_s, jobseeker_id: jobseeker.id.to_s, accepted: true}.to_json, 'CONTENT_TYPE' => 'application/json'
    get 'api/jobseeker/' + jobseeker.id.to_s + '/offers'
    expect(latest_response['title']).to include 'Dream Makerneer'
  end
end
