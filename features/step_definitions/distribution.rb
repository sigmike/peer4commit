
Given(/^a GitHub user "(.*?)" who has set his address to "(.*?)"$/) do |arg1, arg2|
  create(:user, email: "#{arg1}@example.com", nickname: arg1, bitcoin_address: arg2)
end

Given(/^the user with email "(.*?)" has set his address to "(.*?)"$/) do |arg1, arg2|
  User.find_by(email: arg1).update(bitcoin_address: arg2)
end

Given(/^a GitHub user "([^"]*?)"$/) do |arg1|
  create(:user, email: "#{arg1}@example.com", nickname: arg1, bitcoin_address: nil)
end

Given(/^an user with email "(.*?)"$/) do |arg1|
  create(:user, email: arg1, nickname: nil, bitcoin_address: nil)
end

Given(/^an user with email "(.*?)" and without password nor confirmation token$/) do |arg1|
  user = create(:user, email: arg1, nickname: nil, bitcoin_address: nil, password: nil, confirmation_token: nil)
  user.update(confirmed_at: nil)
end

Given(/^I add the GitHub user "(.*?)" to the recipients$/) do |arg1|
  within ".panel", text: "GitHub user" do
    find("input:enabled").set(arg1)
    click_on "Add"
  end

  wait_for_ajax
end

Given(/^I add the email address "(.*?)" to the recipients$/) do |arg1|
  within ".panel", text: "email address" do
    find("input").set(arg1)
    click_on "Add"
  end
end


Given(/^I add the user with email "(.*?)" through his identifier to the recipients$/) do |arg1|
  user = User.find_by(email: arg1)
  within ".panel", text: "Peer4commit user" do
    find("input:enabled").set(user.identifier)
    click_on "Add"
  end

  wait_for_ajax
end

When(/^I select the commit recipients "(.*?)"$/) do |arg1|
  within ".panel", text: "Authors of commits" do
    click_on arg1
  end
end

When(/^I add the commit "(.*?)" to the recipients$/) do |arg1|
  within ".panel", text: "Author of a commit" do
    find("input:enabled").set(arg1)
    click_on "Add"
  end

  wait_for_ajax
end

Given(/^I fill the amount to "(.*?)" with "(.*?)"$/) do |arg1, arg2|
  begin
    within "#recipients tr", text: /^#{Regexp.escape arg1}/ do
      fill_in "Amount", with: arg2
    end
  rescue
    p all("#recipients tr").map(&:text)
    p errors: all(".alert.alert-danger").map(&:text)
    raise
  end
end

Given(/^I fill the comment to "(.*?)" with "(.*?)"$/) do |arg1, arg2|
  within "#recipients tr", text: /^#{Regexp.escape arg1}/ do
    fill_in "Comment", with: arg2
  end
end

When(/^I remove the recipient "(.*?)"$/) do |arg1|
  within "#recipients tr", text: /^#{Regexp.escape arg1}/ do
    check "Remove"
  end
end

Then(/^I should see these distribution lines:$/) do |table|
  table.hashes.each do |row|
    begin
      tr = find("#distribution-show-page tbody tr", text: row["recipient"])
    rescue
      puts "Rows: " + all("#distribution-show-page tbody tr").map(&:text).inspect
      raise
    end
    tr.find(".recipient").text.should eq(row["recipient"])
    tr.find(".address").text.should eq(row["address"]) if row["address"]
    tr.find(".reason").text.should eq(row["reason"]) if row["reason"]
    if row["amount"]
      text = tr.find(".amount").text
      if row["amount"] =~ /\A[0-9.]+\Z/
        text.to_d.should eq(row["amount"].to_d)
      else
        text.should eq(row["amount"])
      end
    end
    if row["percentage"]
      text = tr.find(".percentage").text
      if row["percentage"] =~ /\A[0-9.]+\Z/
        text.to_d.should eq(row["percentage"].to_d)
      else
        text.should eq(row["percentage"])
      end
    end
    tr.find(".tip-comment").text.should eq(row["comment"]) if row["comment"]
  end
  table.hashes.size.should eq(all("#distribution-show-page tbody tr").size)
end

Then(/^the distribution form should have these recipients:$/) do |table|
  table.hashes.each do |row|
    begin
      tr = find("#distribution-form #recipients tr", text: row["recipient"])
    rescue
      puts "Rows: " + all("#distribution-form #recipients tr").map(&:text).inspect
      p errors: all(".alert.alert-danger").map(&:text)
      raise
    end
    tr.find(".recipient").text.should eq(row["recipient"])
    tr.find(".reason").text.should eq(row["reason"]) if row["reason"]
    if row["amount"]
      text = tr.find_field("Amount").value
      if row["amount"] =~ /\A[0-9.]+\Z/
        text.to_d.should eq(row["amount"].to_d)
      else
        text.should eq(row["amount"])
      end
    end
    if row["comment"]
      text = tr.find_field("Comment").value
      text.should eq(row["comment"])
    end
  end
  all("#distribution-form tbody tr").size.should eq(table.hashes.size)
end

When(/^the tipper is started$/) do
  BitcoinTipper.work
end

Then(/^no coins should have been sent$/) do
  BitcoinDaemon.instance.list_transactions("*").should eq([])
end

When(/^I set my address to "(.*?)"$/) do |arg1|
  step 'I go to edit my profile'
  fill_in "Peercoin address", with: arg1
  if has_field?("Current password")
    fill_in "Current password", with: "password"
  end
  click_on "Update"
  page.should have_content "You updated your account successfully"
end

When(/^I click on the last distribution$/) do
  find("#distribution-list .distribution-link:first-child").click
end

Then(/^an email should have been sent to "(.*?)"$/) do |arg1|
  ActionMailer::Base.deliveries.map(&:to).should include([arg1])
  @email = ActionMailer::Base.deliveries.detect { |email| email.to == [arg1] }
end

Then(/^the email should include "(.*?)"$/) do |arg1|
  @email.body.should include(arg1)
end

Then(/^the email should include a link to the last distribution$/) do
  distribution = Distribution.last
  @email.body.should include(project_distribution_url(distribution.project, distribution))
end

When(/^I visit the link to set my password and address from the email$/) do
  step "I click on the \"Set your password and Peercoin address\" link in the email"
end

Then(/^the user with email "(.*?)" should have "(.*?)" as password$/) do |arg1, arg2|
  User.find_by(email: arg1).valid_password?(arg2).should eq(true)
end

Then(/^the user with email "(.*?)" should have "(.*?)" as peercoin address$/) do |arg1, arg2|
  User.find_by(email: arg1).bitcoin_address.should eq(arg2)
end

Given(/^I save the distribution$/) do
  click_on "Save"
  page.should have_content(/Distribution (created|updated)/)
end
