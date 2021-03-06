module PACKMAN
  class Commands
    def self.status
      if CommandLine.packages.empty?
        CLI.report_error "No package name is provided!"
      end
      CommandLine.packages.each do |package_name|
        if not ConfigManager.package_options.has_key? package_name
          CLI.report_error "Package #{CLI.red package_name} is not recorded in #{CLI.blue CommandLine.config_file}!"
        end
        package = Package.instance package_name
        set = ConfigManager.package_options[package_name]['compiler_set_indices']
        CompilerManager.activate_compiler_set set.first
        if not package.respond_to? :status
          CLI.report_error "#{CLI.red package_name} does not provide #{CLI.blue 'status'} method!"
        end
        status = package.status
        case status
        when :on, true
          PACKMAN::CLI.report_notice "#{CLI.blue package_name} is #{CLI.green 'on'}."
        when :off, false, nil
          PACKMAN::CLI.report_notice "#{CLI.blue package_name} is #{CLI.red 'off'}."
        else
          PACKMAN::CLI.report_notice "#{CLI.blue package_name} is #{CLI.red status}."
        end
      end
    end
  end
end
