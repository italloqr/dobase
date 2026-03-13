# frozen_string_literal: true

require "application_system_test_case"

class BoardsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @tool = tools(:project_board)
    sign_in_as(@user)
  end

  test "viewing the board shows columns and cards" do
    visit tool_board_path(@tool)

    # Column names render uppercase via CSS
    assert_text "TO DO"
    assert_text "IN PROGRESS"
    assert_text "DONE"
    assert_text "First task"
    assert_text "Second task"
    assert_text "Third task"
  end

  test "entering and exiting reorder mode" do
    visit tool_board_path(@tool)

    click_on "Edit"

    assert_current_path tool_board_path(@tool, reorder: 1)
    assert_selector "a", text: "Done"

    click_on "Done"

    assert_current_path tool_board_path(@tool)
  end

  test "adding a new column" do
    visit tool_board_path(@tool)

    click_on "Add Column"

    within "dialog#add-column-modal" do
      fill_in "Column name", with: "New Column Name"
      click_on "Add Column"
    end

    # Column names render uppercase via CSS
    assert_text "NEW COLUMN NAME"
  end

  test "opening card detail dialog" do
    visit tool_board_path(@tool)

    find("[data-card-id='#{cards(:first_task).id}']").click

    # Dialog content loads via fetch — wait for it
    assert_selector "dialog[open]", wait: 5
    within "dialog[open]" do
      assert_text "First task"
      assert_text "Description" # Section header
    end
  end

  test "editing card title inline" do
    visit tool_board_path(@tool)
    card = cards(:first_task)

    find("[data-card-id='#{card.id}']").click
    assert_selector "dialog[open]", wait: 5

    within "dialog[open]" do
      find("[data-board-card-target='titleDisplay']").click
      title_input = find("[data-board-card-target='titleInput']")
      title_input.fill_in with: "Updated Title"
      title_input.native.send_keys(:return)

      sleep 0.5
    end

    assert_equal "Updated Title", card.reload.title
  end

  test "closing card dialog" do
    visit tool_board_path(@tool)

    find("[data-card-id='#{cards(:first_task).id}']").click
    assert_selector "dialog[open]", wait: 5

    within "dialog[open]" do
      assert_text "First task"
      find("[title='Close']").click
    end

    assert_no_selector "dialog[open]"
  end

  test "deleting a card" do
    visit tool_board_path(@tool)
    card = cards(:first_task)

    find("[data-card-id='#{card.id}']").click
    assert_selector "dialog[open]", wait: 5

    within "dialog#card-detail-modal" do
      click_on "Delete card"
    end

    # Custom turbo confirm dialog
    within "dialog#turbo-confirm-dialog" do
      find("button[value='confirm']").click
    end

    assert_no_text "First task", wait: 5
    assert_raises(ActiveRecord::RecordNotFound) { card.reload }
  end

  test "adding a new card" do
    visit tool_board_path(@tool)

    within ".board-column", match: :first do
      click_on "Add card"

      fill_in "title", with: "My New Card"
      find("textarea[name='title']").native.send_keys(:return)
    end

    assert_text "My New Card"
    assert Boards::Card.exists?(title: "My New Card")
  end

  private

  def sign_in_as(user)
    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_on "Sign In"
    assert_selector ".sidebar", wait: 5
  end
end
