require "open3"

class AndroidEmulator
  attr_reader :android_home, :emulator_name

  def initialize(emulator_name, android_home = ENV["ANDROID_HOME"])
    @android_home = android_home
    @emulator_name = emulator_name
  end

  def run_application(apk_path, app_bundle, app_activity, sleep_time = 15)
    run_emulator do
      install_apk apk_path
      run_app app_bundle, app_activity
      sleep sleep_time
    end
  end

  private

  def run_app(app_bundle, app_activity)
    `adb shell am start -n #{app_bundle}/#{app_activity}`
  end

  def run_emulator(&block)
    Open3.popen2(*emulator_command) do |stdin, stdout, wait_thr|
      wait_for_device

      while is_booting?
        sleep 1
      end

      begin
        yield
      rescue
        # swallow any errors here so that we can shutdown the emulator
      end

      shutdown
    end
  end

  def install_apk(path)
    `adb install -r #{path}`
  end

  def emulator_command
    [
      "#{android_home}/emulator/emulator",
      "@#{emulator_name}",
      "-no-boot-anim",
      "-noaudio",
      "-no-snapshot"
    ]
  end

  def wait_for_device
    `adb wait-for-device`
  end

  def is_booting?
    `adb shell getprop sys.boot_completed`.strip != "1"
  end

  def shutdown
    `adb shell reboot -p`
  end

  def install_application(apk_path)
    Kernel.system("adb", "install", "-r", apk_path)
  end
end
