Before do
  ActionMailer::Base.deliveries.clear
end

Then(/^there should be (\d+) email sent$/) do |arg1|
  begin
    expect(ActionMailer::Base.deliveries.size).to eq(arg1.to_i)
  rescue
    p ActionMailer::Base.deliveries
    raise
  end
  @email = ActionMailer::Base.deliveries.first
end

Then(/^(\d+) email should have been sent$/) do |arg1|
  step "there should be #{arg1} email sent"
end

Then(/^no email should have been sent$/) do
  expect(ActionMailer::Base.deliveries).to eq([])
end

When(/^the email counters are reset$/) do
  ActionMailer::Base.deliveries.clear
end

Given(/^the tip for commit is "(.*?)"$/) do |arg1|
  CONFIG["tip"] = arg1.to_f
end

Given(/^our fee is "(.*?)"$/) do |arg1|
  CONFIG["our_fee"] = arg1.to_f
end

Given(/^a project$/) do
  @project = Project.create!(name: "test", full_name: "example/test", bitcoin_address: 'mq4NtnmQoQoPfNWEPbhSvxvncgtGo6L8WY', address_label: "example_project_account", hold_tips: false)
end

Given(/^a project "([^"]*?)"$/) do |arg1|
  @project = Project.create!(name: "test", full_name: "example/#{arg1}", bitcoin_address: 'mq4NtnmQoQoPfNWEPbhSvxvncgtGo6L8WY', hold_tips: false)
end

Given(/^a project "(.*?)" holding tips$/) do |arg1|
  @project = Project.create!(name: "test", full_name: "example/#{arg1}", bitcoin_address: 'mq4NtnmQoQoPfNWEPbhSvxvncgtGo6L8WY', hold_tips: true)
end

Given(/^a deposit of "(.*?)"$/) do |arg1|
  Deposit.create!(project: @project, amount: arg1.to_d * COIN, confirmations: 1, created_at: 2.minutes.ago)
end

Given(/^a refunded tip of "([^"]*)"$/) do |arg1|
  Tip.create!(project: @project, amount: arg1.to_d * COIN, created_at: 2.minutes.ago, refunded_at: 1.minute.ago)
end

Given(/^the last known commit is "(.*?)"$/) do |arg1|
  @project.update!(last_commit: arg1)
end

def add_new_commit(id, params = {})
  @commits ||= {}
  defaults = {
    sha: id,
    commit: {
      message: "Some changes",
      author: {
        email: "anonymous@example.com",
      },
      committer: {
        date: Time.now,
      }
    },
  }
  @commits[id] = defaults.deep_merge(params)
end

def find_new_commit(id)
  @commits[id]
end

Given(/^a new commit "(.*?)" with parent "([^"]*?)"$/) do |arg1, arg2|
  add_new_commit(arg1, parents: [{sha: arg2}])
end

Given(/^a new commit "(.*?)" with parent "(.*?)" and "(.*?)"$/) do |arg1, arg2, arg3|
  add_new_commit(arg1, parents: [{sha: arg2}, {sha: arg3}], commit: {message: "Merge #{arg2} and #{arg3}"})
end

Given(/^(\d+) new commits$/) do |arg1|
  arg1.to_i.times do
    add_new_commit(Digest::SHA1.hexdigest(SecureRandom.hex))
  end
end

Given(/^(\d+) new commits by "([^"]*)"$/) do |arg1, arg2|
  arg1.to_i.times do
    add_new_commit(Digest::SHA1.hexdigest(SecureRandom.hex), author: {login: arg2}, commit: {author: {email: "#{arg2}@example.com"}})
  end
end

Given(/^a new commit "([^"]*?)"$/) do |arg1|
  add_new_commit(arg1)
end

Given(/^a new commit "([^"]*?)" by "([^"]*)"$/) do |arg1, arg2|
  add_new_commit(arg1, author: {login: arg2}, commit: {author: {email: "#{arg2}@example.com"}})
end

Given(/^the project holds tips$/) do
  @project.update(hold_tips: true)
end

Given(/^the message of commit "(.*?)" is "(.*?)"$/) do |arg1, arg2|
  find_new_commit(arg1).deep_merge!(commit: {message: arg2})
end

Given(/^the email of commit "(.*?)" is "(.*?)"$/) do |arg1, arg2|
  find_new_commit(arg1).deep_merge!(commit: {author: {email: arg2}})
end

When(/^the new commits are read$/) do
  @project.reload
  expect(@project).to receive(:get_commits).and_return(@commits.values.map(&:to_ostruct))
  @project.update_commits
  expect(@project).to receive(:get_commits).and_return(@commits.values.map(&:to_ostruct))
  @project.tip_commits
end

Then(/^there should be no tip for commit "(.*?)"$/) do |arg1|
  expect(Tip.where(commit: arg1).to_a).to eq([])
end

Then(/^there should be a tip of "(.*?)" for commit "(.*?)"$/) do |arg1, arg2|
  amount = Tip.find_by(commit: arg2).amount
  expect(amount).not_to be_nil
  expect((amount.to_d / COIN)).to eq(arg1.to_d)
end

Then(/^the tip amount for commit "(.*?)" should be undecided$/) do |arg1|
  expect(Tip.find_by(commit: arg1).undecided?).to be true
end

Then(/^the new last known commit should be "(.*?)"$/) do |arg1|
  expect(@project.reload.last_commit).to eq(arg1)
end

Given(/^the project collaborators are:$/) do |table|
  @project.reload
  @project.collaborators.each(&:destroy)
  table.raw.each do |name,|
    @project.collaborators.create!(login: name)
  end
end

Given(/^the project single collaborator is "(.*?)"$/) do |arg1|
  @project.reload
  @project.collaborators.each(&:destroy)
  @project.collaborators.create!(login: arg1)
end

Given(/^a project managed by "(.*?)"$/) do |arg1|
  user = create(:user, email: "#{arg1}@example.com", nickname: arg1)
  user.confirm
  user.save!
  @project = Project.create!(name: "#{arg1} project", bitcoin_address: 'mq4NtnmQoQoPfNWEPbhSvxvncgtGo6L8WY', address_label: "example_project_account")
  @project.collaborators.create!(login: arg1)
end

Given(/^the author of commit "(.*?)" is "(.*?)"$/) do |arg1, arg2|
  find_new_commit(arg1).deep_merge!(author: {login: arg2}, commit: {author: {email: "#{arg2}@example.com"}})
end

Given(/^the author of commit "(.*?)" is the non identified email "(.*?)"$/) do |arg1, arg2|
  find_new_commit(arg1).deep_merge!(commit: {author: {email: arg2}})
end

Given(/^an illustration of the history is:$/) do |string|
  # not checked
end

Given(/^the current time is "(.*?)"$/) do |arg1|
  Timecop.travel(Time.parse(arg1))
end

After do
  Timecop.return
end

Then(/^pending$/) do
  pending
end

Then(/^these amounts should have been sent from the account of the project:$/) do |table|
  expect(BitcoinDaemon.instance.list_transactions(@project.address_label).map do |tx|
    if tx["category"] == "send"
      {
        "address" => tx["address"],
        "amount" => (-tx["amount"]).to_s,
      }
    end
  end.compact.sort_by { |x| x["address"] }).to eq(table.hashes.sort_by { |x| x["address"] })
end

When(/^the transaction history is cleared$/) do
  BitcoinDaemon.instance.clear_transaction_history
end
