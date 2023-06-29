require 'xcodeproj'

def install_fcm_notifications_ios_pod_target(application_path = nil)
    # defined_in_file is set by CocoaPods and is a Pathname to the Podfile.
    application_path ||= File.dirname(defined_in_file.realpath) if self.respond_to?(:defined_in_file)
    raise 'Could not find application path in install_fcm_notifications_ios_pod_target' unless application_path

    flutter_install_ios_engine_pod application_path
    pod 'awesome_notifications', :path => File.join('.symlinks', 'plugins', 'awesome_notifications', 'ios')
    pod 'fcm_notifications', :path => File.join('.symlinks', 'plugins', 'fcm_notifications', 'ios')
end

def update_fcm_notifications_service_target(target_name, xcodeproj_path, flutter_root)
     project = Xcodeproj::Project.open(File.join(xcodeproj_path, 'Runner.xcodeproj'))
     
     project.targets.each do |target|
         target.build_configurations.each do |config|
             config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'
         end
     end
     
     target = project.targets.select { |t| t.name == target_name }.first
     if target.nil? || project.targets.count == 1
         raise "You need to create a Notification Service Extension to properly use fcm_notifications\n"
     end
     target.build_configurations.each do |config|
         config.build_settings['ENABLE_BITCODE'] = 'NO'
         config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
         config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'
     end
     
     project.save
end