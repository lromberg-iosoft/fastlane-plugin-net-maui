require 'fastlane/action'
require_relative '../helper/xamarin_native_helper'

module Fastlane
  module Actions
    class DotnetAction < Action
       DOTNET = '/usr/local/share/dotnet/dotnet'.freeze
       ACTION = %w(build publish).freeze
       TARGET = %w(build rebuild clean).freeze
       CONFIGURATION = %w(Release Debug).freeze
       FRAMEWORK = %(net10.0-ios net10.0-android net9.0-ios net9.0-android net8.0-ios net8.0-android)
       RUNTIME_IDENTIFIER = %w(ios-arm64 android-arm64).freeze
       PRINT_ALL = [true, false].freeze

      def self.run(params)
        build(params)
      end

      def self.build(params)       
        action = params[:action]
        target = params[:target]
        configuration = params[:configuration]
        framework = params[:framework]
        runtime_identifier = params[:runtime_identifier]
        solution = params[:solution]
        project = params[:project]
        output_path = params[:output_path]
        ipa_name = params[:ipa_name]
        sign_apk = params[:sign_apk]
        android_signing_keystore = params[:android_signing_keystore]
        android_signing_key_pass = params[:android_signing_key_pass]
        android_signing_store_pass = params[:android_signing_store_pass]
        android_signing_key_alias = params[:android_signing_key_alias]

        command = "#{DOTNET} "
        command << "#{action} "
        command << "-t:#{target} " if target != nil
        command << "-r #{runtime_identifier} " if runtime_identifier != nil
        command << "-f #{framework} " if framework != nil
        command << "-c #{configuration} " if configuration != nil
        command << "-o #{output_path} " if output_path != nil

        command << "-p:BuildIpa=True " if ipa_name != nil
        command << "-p:IpaPackageName=#{ipa_name} " if ipa_name != nil
        
        command << "-p:AndroidKeyStore=true " if sign_apk == true
        command << "-p:AndroidSigningKeyStore=#{android_signing_keystore} " if  android_signing_keystore != nil
        command << "-p:AndroidSigningKeyPass=#{android_signing_key_pass} " if android_signing_key_pass != nil
        command << "-p:AndroidSigningStorePass=#{android_signing_store_pass} " if  android_signing_store_pass != nil
        command << "-p:AndroidSigningKeyAlias=#{android_signing_key_alias} " if  android_signing_key_alias != nil
        
        command << project if project != nil
        command << solution if solution != nil
        Helper::XamarinNativeHelper.bash(command, !params[:print_all])
      end

      def self.description
         "Build .NET MAUI iOS and Android projects using msbuild"
      end

      def self.authors
        ["illania"]
      end

      def self.available_options
        [
           FastlaneCore::ConfigItem.new(
            key: :action,
              env_name: 'FL_XN_BUILD_ACTION',
              description: 'Build or Publish action',
              type: String,
              optional: false,
              verify_block: proc do |value|
              UI.user_error!("Unsupported value! Use one of #{ACTION.join '\' '}".red) unless ACTION.include? value
              end
          ),

          FastlaneCore::ConfigItem.new(
            key: :solution,
              env_name: 'FL_XN_BUILD_SOLUTION',
              description: 'Path to Maui.sln file',
              type: String,
              optional: true,
              verify_block: proc do |value|
                UI.user_error!('File not found'.red) unless File.file? value
              end
          ),
          
          FastlaneCore::ConfigItem.new(
              key: :project,
              env_name: 'FL_XN_BUILD_PROJECT',
              description: 'Project to build or publish',
              type: String,
              optional: true,
              verify_block: proc do |value|
                UI.user_error!('File not found'.red) unless File.file? value
              end
          ),

           FastlaneCore::ConfigItem.new(
            key: :framework,
            env_name: 'FL_XN_BUILD_FRAMEWORK',
            description: 'Build Framework',
            type: String,
            optional: false,
            verify_block: proc do |value|
              UI.user_error!("Unsupported value! Use one of #{FRAMEWORK.join '\' '}".red) unless FRAMEWORK.include? value
            end
          ),

          FastlaneCore::ConfigItem.new(
            key: :runtime_identifier,
            env_name: 'FL_XN_BUILD_RUNTIME_IDENTIFIER',
            description: 'Runtime Identifier',
            type: String,
            optional: true,
            verify_block: proc do |value|
              UI.user_error!("Unsupported value! Use one of #{RUNTIME_IDENTIFIER.join '\' '}".red) unless RUNTIME_IDENTIFIER.include? value
            end
          ),

          FastlaneCore::ConfigItem.new(
              key: :configuration,
              env_name: 'FL_XN_CONFIGURATION',
              description: 'Release or Debug',
              type: String,
              optional: false,
              verify_block: proc do |value|
                UI.user_error!("Unsupported value! Use one of #{CONFIGURATION.join '\' '}".red) unless CONFIGURATION.include? value
              end
          ),

          FastlaneCore::ConfigItem.new(
            key: :target,
            env_name: 'FL_XN_BUILD_TARGET',
            description: 'Target build type',
            type: String,
            optional: true,
            verify_block: proc do |value|
              UI.user_error!("Unsupported value! Use one of #{TARGET.join '\' '}".red) unless TARGET.include? value
            end
          ),

          FastlaneCore::ConfigItem.new(
            key: :print_all,
            env_name: 'FL_XN_BUILD_PRINT_ALL',
            description: 'Print std out',
            default_value: true,
            is_string: false,
            optional: true,
            verify_block: proc do |value|
              UI.user_error!("Unsupported value! Use one of #{PRINT_ALL.join '\' '}".red) unless PRINT_ALL.include? value
            end
          ),

          FastlaneCore::ConfigItem.new(
              key: :output_path,
              env_name: 'FL_XN_BUILD_OUTPUT_PATH',
              description: 'Build output path for ipa and apk files',
              is_string: true,
              optional: true
          ),
           FastlaneCore::ConfigItem.new(
              key: :ipa_name,
              env_name: 'FL_XN_BUILD_IPA_NAME',
              description: 'Ipa name for iOS app',
              is_string: true,
              optional: true
          ),
           FastlaneCore::ConfigItem.new(
              key: :sign_apk,
              env_name: 'FL_XN_BUILD_SIGN_APK',
              description: 'Sets if apk should be created and signed',
              is_string: false,
              optional: true,
              default_value: false
          ),
           FastlaneCore::ConfigItem.new(
              key: :android_signing_keystore,
              env_name: 'FL_XN_BUILD_DROID_SIGNING_KEYSTORE',
              description: 'Sets Android Signing KeyStore',
              is_string: true,
              optional: true
          ),
           FastlaneCore::ConfigItem.new(
              key: :android_signing_key_pass,
              env_name: 'FL_XN_BUILD_DROID_SIGNING_KEY_PASS',
              description: 'Sets Android Signing Key Password',
              is_string: true,
              optional: true
          ),
           FastlaneCore::ConfigItem.new(
              key: :android_signing_store_pass,
              env_name: 'FL_XN_BUILD_DROID_SIGNING_STORE_PASS',
              description: 'Sets Android Signing Store Password',
              is_string: true,
              optional: true
          ),
           FastlaneCore::ConfigItem.new(
              key: :android_signing_key_alias,
              env_name: 'FL_XN_BUILD_DROID_SIGNING_KEY_ALIAS',
              description: 'Sets Android Signing Key Alias',
              is_string: true,
              optional: true
          )
        ]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end

    end
  end
end
