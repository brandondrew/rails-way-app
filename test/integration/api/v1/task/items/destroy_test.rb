# frozen_string_literal: true

require "test_helper"

class APIV1TaskItemsDestroyTest < ActionDispatch::IntegrationTest
  test "#destroy responds with 401 when API token is invalid" do
    user = users(:one)
    task = task_items(:one)
    headers = [ {}, api_v1_helper.authorization_header(SecureRandom.hex(20)) ].sample

    delete(api_v1_helper.task__item_url(member!(user).inbox, task, format: :json), headers:)

    api_v1_helper.assert_response_with_error(:unauthorized)
  end

  test "#destroy responds with 404 when task list is not found" do
    user = users(:one)
    task = task_items(:one)

    url = api_v1_helper.task__item_url(TaskList.maximum(:id) + 1, task.id, format: :json)

    delete(url, headers: api_v1_helper.authorization_header(user))

    api_v1_helper.assert_response_with_error(:not_found)
  end

  test "#destroy responds with 404 when task is not found" do
    user = users(:one)

    url = api_v1_helper.task__item_url(member!(user).inbox, TaskItem.maximum(:id) + 1, format: :json)

    delete(url, headers: api_v1_helper.authorization_header(user))

    api_v1_helper.assert_response_with_error(:not_found)
  end

  test "#destroy responds with 404 when task list belongs to another user" do
    user = users(:one)
    task = task_items(:two)

    delete(api_v1_helper.task__item_url(task.task_list, task, format: :json), headers: api_v1_helper.authorization_header(user))

    api_v1_helper.assert_response_with_error(:not_found)
  end

  test "#destroy responds with 200 when task is destroyed" do
    user = users(:one)
    task = task_items(:one)

    assert_difference -> { member!(user).inbox.task_items.count }, -1 do
      delete(
        api_v1_helper.task__item_url(member!(user).inbox, task, format: :json),
        headers: api_v1_helper.authorization_header(user)
      )
    end

    assert_response :no_content
  end
end
