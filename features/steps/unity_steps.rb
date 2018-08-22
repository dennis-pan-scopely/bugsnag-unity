When("I build a Unity application for {string}") do |platform|
  run_required_commands([
    ["features/scripts/create_unity_project.sh #{platform}"]
  ])
end

When("run the MacOS application") do
  run_required_commands([
    ["features/scripts/launch_mac_unity_application.sh"]
  ])
end

Given("I configure the bugsnag notify endpoint") do
  steps %Q{
    When I set environment variable "MAZE_ENDPOINT" to "http://localhost:#{MOCK_API_PORT}"
  }
end
