require "open3"
require "xcodeproj"

$UNITY = ['/Applications/Unity/Unity.app/Contents/MacOS/Unity', 'C:\Program Files\Unity\Editor\Unity.exe'].find do |unity|
  File.exists? unity
end

def unity(*cmd)
  cmd = cmd.unshift($UNITY, "-batchmode", "-nographics", "-logFile", "unity.log", "-quit")
  sh *cmd do |ok, res|
    if !ok
      sh "cat", "unity.log"
      raise "unity error"
    end
  end
end

desc "Build the plugin"
task :build do
  # remove any leftover artifacts from the package generation directory
  sh "git", "clean", "-dfx", "unity"
  current_directory = File.dirname(__FILE__)
  project_path = File.join(current_directory, "unity", "PackageProject")
  assets_path = File.join(current_directory, "src", "Assets")

  # Copy unity-specific files for all plugins
  cp_r assets_path, project_path

  assets_path = File.join(project_path, "Assets", "Plugins")

  # Create the individual platform plugins
  Rake::Task[:create_webgl_plugin].invoke(assets_path)
  Rake::Task[:create_osx_plugin].invoke(assets_path)
  Rake::Task[:create_ios_plugin].invoke(assets_path)
  Rake::Task[:create_android_plugin].invoke(assets_path)
  Rake::Task[:create_csharp_plugin].invoke(assets_path)

  package_output = File.join(current_directory, "Bugsnag.unitypackage")
  rm_f package_output
  unity "-projectpath", project_path, "-exportpackage", "Assets", package_output
end

task :clean do
  cd 'bugsnag-android' do
    sh "./gradlew", "clean", "--quiet"
  end
  cd 'bugsnag-cocoa' do
    sh "make", "clean"
    sh "make", "BUILD_OSX=1", "clean"
  end
end

namespace :build do
  desc "Build and run the iOS app"
  task :ios do
    cd "example" do
      sh $UNITY, "-batchmode", "-quit", "-logFile", "build.log", "-executeMethod", "NotifyButtonScript.BuildIos"
    end
  end

  desc "Build and run the Android app"
  task :android do
    cd "example" do
      sh $UNITY, "-batchmode", "-quit", "-logFile", "build.log", "-executeMethod", "NotifyButtonScript.BuildAndroid"
    end
  end
end

task :update_example_plugins, [:package_path] do |task, args|
  sh $UNITY, "-batchmode", "-quit", "-projectpath", "example", "-logFile", "build.log", "-importPackage", args[:package_path]
  cd "example" do
  end
end

task :create_webgl_plugin, [:path] do |task, args|
  bugsnag_js = File.realpath(File.join("bugsnag-js", "src", "bugsnag.js"))
  cd args[:path] do
    webgl_file = File.join("WebGL", "bugsnag.jspre")
    cp bugsnag_js, webgl_file
  end
end

task :create_android_plugin, [:path] do |task, args|
  android_dir = File.join(args[:path], "Android")

  cd 'bugsnag-android' do
    sh "./gradlew", "sdk:build", "--quiet"
  end

  android_lib = File.join("bugsnag-android", "sdk", "build", "outputs", "aar", "bugsnag-android-release.aar")

  cp android_lib, android_dir
end

task :create_ios_plugin, [:path] do |task, args|
  bugsnag_unity_file = File.realpath("BugsnagUnity.mm", "src")
  ios_dir = File.join(args[:path], "iOS", "Bugsnag")

  # Copy iOS bugsnag notifier and KSCrash directory files
  bugsnag_path = "bugsnag-cocoa/Source"
  kscrash_dir = "bugsnag-cocoa/Source/KSCrash/Source/KSCrash/"
  recording_path = kscrash_dir + "Recording"
  reporting_path = kscrash_dir + "Reporting"

  # Copy over basic additional KSCrash reporting files
  recording_sentry_path = kscrash_dir + "Recording/Sentry"
  recording_tools_path = kscrash_dir + "Recording/Tools"
  kscrash_filter_path = kscrash_dir + "Reporting/Filters/"

  `find #{recording_path} #{reporting_path} #{bugsnag_path} #{recording_sentry_path} #{recording_tools_path} #{kscrash_filter_path} -name '*.m' -or -name '*.c' -or -name '*.mm' -or -name '*.h' -or -name '*.cpp'`.split("\n").each do |x|
    cp x, ios_dir, verbose: false
  end

  # Copy unity to bugsnag-cocoa wrapper
  cp bugsnag_unity_file, ios_dir

  # Replace framework reference <Bugsnag/Bugsnag.h> with direct header file "Bugsnag.h" in the wrapper file
  wrapper_file = ios_dir + "/BugsnagUnity.mm"
  `sed -e 's/^\\(#import \\)<Bugsnag\\/\\(.*.h\\)>/\\1\"\\2\"/' -i '' #{wrapper_file}`

  # Rename any <KSCrash/*.h> framework references to the specific header files
  Dir[ios_dir + "/*.*"].each do |file|
    `sed -e 's/^\\(#import \\)<KSCrash\\/\\(.*.h\\)>/\\1\"\\2\"/' -i '' #{file}`
  end
end

task :create_osx_plugin, [:path] do |task, args|
  build_dir = "bugsnag-cocoa-build"
  project_name = "bugsnag-osx"
  FileUtils.rm_rf build_dir
  FileUtils.mkdir_p build_dir
  bugsnag_unity_file = File.realpath("BugsnagUnity.mm", "src")

  FileUtils.cp_r "bugsnag-cocoa/Source", build_dir
  public_headers = [
    "BugsnagMetaData.h",
    "Bugsnag.h",
    "BugsnagBreadcrumb.h",
    "BugsnagCrashReport.h",
    "BSG_KSCrashReportWriter.h",
    "BugsnagConfiguration.h",
  ]

  cd build_dir do
    project_file = File.join("#{project_name}.xcodeproj")
    project = Xcodeproj::Project.new(project_file)
    target = project.new_target(:bundle, "bugsnag-osx", :osx, "10.11")
    group = project.new_group("Bugsnag")

    source_files = Dir.glob(File.join("Source", "**", "*.{c,h,mm,cpp,m}"))
      .map(&File.method(:realpath))
      .tap { |files| files << bugsnag_unity_file }
      .map { |f| group.new_file(f) }

    target.add_file_references(source_files) do |build_file|
      if public_headers.include? build_file.file_ref.name
        build_file.settings = { "ATTRIBUTES" => ["Public"] }
      end
    end

    project.build_configurations.each do |build_configuration|
      case build_configuration.type
      when :debug
        build_configuration.build_settings["OTHER_CFLAGS"] = "-fembed-bitcode-marker"
      when :release
        build_configuration.build_settings["OTHER_CFLAGS"] = "-fembed-bitcode"
      end
    end

    project.save
    Open3.pipeline(["xcodebuild", "-project", "#{project_name}.xcodeproj", "-configuration", "Release", "build", "build"], ["xcpretty"])
    osx_dir = File.join(args[:path], "OSX", "Bugsnag")
    cd "build" do
      cp_r File.join("Release", "bugsnag-osx.bundle"), osx_dir
    end
  end
end

task :create_csharp_plugin, [:path] do |task, args|
  sh "./build.sh"
  dll = File.join("src", "Bugsnag.Unity", "bin", "Release", "net35", "Bugsnag.Unity.dll")
  cp File.realpath(dll), args[:path]
end

task default: [:build]
