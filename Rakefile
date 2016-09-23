require 'shellwords'

$UNITY = "/Applications/Unity/Unity.app/Contents/MacOS/Unity"

desc "Build the plugin"
task :build do

  $path = Dir.pwd + "/temp.unityproject"
  sh "rm -r temp.unityproject" if File.exist? "temp.unityproject"
  sh "#$UNITY -batchmode -quit -createproject #{Shellwords.escape($path)}"

  Rake::Task[:copy_into_project].invoke

  sh "#$UNITY -batchmode -quit -projectpath #{Shellwords.escape($path)} -exportpackage Assets Bugsnag.unitypackage"
  cp $path + "/Bugsnag.unitypackage", "."

end

desc "Update the example app's C# scripts"
task :update do
  cp_r "src/Assets", Dir.pwd + "/example"
end

namespace :build do

  desc "Build and run the iOS app"
  task :ios do
    Dir.chdir "example" do
      sh "#$UNITY -batchmode -quit -logFile build.log -executeMethod NotifyButtonScript.BuildIos"
    end
  end

  desc "Build and run the Android app"
  task :android do
    Dir.chdir "example" do
      sh "#$UNITY -batchmode -quit -logFile build.log -executeMethod NotifyButtonScript.BuildAndroid"
    end
  end

end


desc "Update the example app's dependencies"
task :update_example_plugins do
  $path = Dir.pwd + "/example"
  Rake::Task[:copy_into_project].invoke
end

task :copy_into_project do
  unless defined?($path)
    raise "Use rake build instead."
  end

  # Copy unity-specific files for all plugins
  cp_r "src/Assets", $path

  # Create the individual platform plugins
  Rake::Task[:create_ios_plugin].invoke
  Rake::Task[:create_android_plugin].invoke
  Rake::Task[:create_osx_plugin].invoke
  Rake::Task[:create_tvos_plugin].invoke

end

task :create_ios_plugin do
  unless defined?($path)
    raise "Use rake build instead."
  end

  # Create iOS directory
  ios_dir = $path + "/Assets/Plugins/iOS/Bugsnag"
  mkdir_p ios_dir

  # Copy iOS bugsnag notifier and KSCrash directory files
  kscrash_dir = "bugsnag-cocoa/Carthage/Checkouts/KSCrash/Source/KSCrash/"
  recording_path = kscrash_dir + "Recording"
  swift_path = kscrash_dir + "swift"
  llvm_path = kscrash_dir + "llvm"
  bugsnag_path = "bugsnag-cocoa/Source"
  `find #{recording_path} #{swift_path} #{llvm_path} #{bugsnag_path} -name '*.m' -or -name '*.c' -or -name '*.mm' -or -name '*.h' -or -name '*.cpp'`.split("\n").each do |x|
    cp x, ios_dir
  end

  # Copy over basic additional KSCrash reporting files
  kscrash_filter_path = kscrash_dir + "Reporting/Filters/"
  cp kscrash_filter_path + "Tools/KSVarArgs.h", ios_dir
  cp kscrash_filter_path + "Tools/Container+DeepSearch.h", ios_dir
  cp kscrash_filter_path + "Tools/Container+DeepSearch.m", ios_dir
  cp kscrash_filter_path + "KSCrashReportFilter.h", ios_dir
  cp kscrash_filter_path + "KSCrashReportFilter.m", ios_dir

  # Copy unity to bugsnag-cocoa wrapper
  cp "src/BugsnagUnity.mm", ios_dir

  # Replace framework reference <Bugsnag/Bugsnag.h> with direct header file "Bugsnag.h" in the wrapper file
  wrapper_file = ios_dir + "/BugsnagUnity.mm"
  `sed -e 's/^#import <Bugsnag\\/Bugsnag.h>/#import \"Bugsnag.h\"/' -i '' #{wrapper_file}`

  # Rename any <KSCrash/*.h> framework references to the specific header files
  Dir[ios_dir + "/*.*"].each do |file|
    `sed -e 's/^\\(#import \\)<KSCrash\\/\\(.*.h\\)>/\\1\"\\2\"/' -i '' #{file}`
  end
end

task :create_android_plugin do
  unless defined?($path)
    raise "Use rake build instead."
  end

  # Create android directory
  android_dir = $path + "/Assets/Plugins/Android/Bugsnag"
  mkdir_p android_dir

  # Create clean build of the android notifier
  cd 'bugsnag-android' do
    sh "./gradlew clean build"
  end

  cp "bugsnag-android/build/outputs/aar/bugsnag-android-release.aar", android_dir
end

task :create_osx_plugin do
  unless defined?($path)
    raise "Use rake build instead."
  end

  # Create OSX directory
  osx_dir = $path + "/Assets/Plugins/OSX/Bugsnag"
  mkdir_p osx_dir

  # Create the OSX notifier framework and copy it into the Unity OSX project
  rm_rf "bugsnag-osx/bugsnag-osx/Bugsnag.framework"
  cd 'bugsnag-cocoa' do
    sh "make BUILD_OSX=1 build/Build/Products/Release/Bugsnag.framework"
    cp_r "build/Build/Products/Release/Bugsnag.framework", "../bugsnag-osx/bugsnag-osx"
  end

  # Create the Unity OSX bundle and copy it to the OSX directory
  cd 'bugsnag-osx' do
    sh "xcodebuild -configuration Release build clean build | tee xcodebuild.log | xcpretty"
    cp_r "build/Release/bugsnag-osx.bundle", osx_dir
  end
end

task :create_tvos_plugin do
  unless defined?($path)
    raise "Use rake build instead."
  end

  # Create tvOS directory
  tvos_dir = $path + "/Assets/Plugins/tvOS/Bugsnag"
  mkdir_p tvos_dir

  # Create the tvOS notifier framework and copy it into the Unity tvOS project
  rm_rf "bugsnag-tvos/bugsnag-tvos/Bugsnag.framework"
  cd 'bugsnag-cocoa' do
    sh "make SDK=appletvsimulator9.2"
    cp_r "build/Build/Products/Release/Bugsnag.framework", "../bugsnag-tvos/bugsnag-tvos"
  end

  # Create the Unity tvOS bundle and copy it to the tvOS directory
  cd 'bugsnag-tvos' do
    sh "xcodebuild -configuration Release build clean build | tee xcodebuild.log | xcpretty"
    cp_r "build/Release-appletvos/libbugsnag-tvos.a", tvos_dir
  end
end


task default: [:build]
