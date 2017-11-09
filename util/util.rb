
require 'yaml'

class Util
    def self.set_path
        if File.exists?('util.rb')
            puts "Switching to parent folder"
            Dir.chdir('..');
            puts "Process in #{Dir.pwd}"
        end
    end
    def self.get_constant
        return YAML.load_file('util/constant.yml')
    end
    def self.get_img_dpi
        const = Util.get_constant
        return const['img-dpi']
    end
    def self.get_img_size
        const = Util.get_constant
        return const['img-sizes']
    end
end