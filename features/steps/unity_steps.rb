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

When("run the Android application") do
  emu = AndroidEmulator.new("nexus")
  emu.run_application "features/fixtures/mazerunner.apk",
    "com.bugsnag.mazerunner",
    "com.unity3d.player.UnityPlayerActivity"
end

Given("I configure the bugsnag notify endpoint with {string}") do |host|
  steps %Q{
    When I set environment variable "MAZE_ENDPOINT" to "http://#{host}:#{MOCK_API_PORT}"
  }
end
