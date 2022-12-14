require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Rights statements render correctly on Work show page', js: false do
  context 'a logged in user' do
    let(:title) { 'My Test Work 2' }
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let(:workflow) do
      Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template)
    end

    before do
      # Create a single action that can be taken
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'user',
        agent_id: user.user_key,
        access: 'deposit'
      )
      login_as user
    end

    after do
      Work.where(title: [title]).each do |w|
        w.destroy(eradicate: true)
      end
    end

    scenario "Selected Rights Statement renders the correct url link (https)" do
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"

      # If you generate more than one work uncomment these lines
      # choose "payload_concern", option: "Work"
      # click_button "Create work"

      click_link "Files" # switch tab
      within('span#addfiles') do
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/image.jp2", visible: false)
        attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/jp2_fits.xml", visible: false)
      end
      click_link "Descriptions" # switch tab
      fill_in('Title', with: title)
      fill_in('Creator', with: 'Doe, Jane')
      fill_in('Keyword', with: 'testing')
      select('Attribution-NoDerivatives 4.0 International', from: 'Rights statement')

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element
      find('body').click
      choose('work_visibility_open')
      check('agreement')

      click_on('Save')
      expect(page.html).to include('<a rel="license"',
                                  'href="https://creativecommons.org/licenses/by-nd/4.0/"',
                                  'target="_blank">https://creativecommons.org/licenses/by-nd/4.0/</a>')
    end
  end
end
