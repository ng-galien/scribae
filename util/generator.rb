require 'fileutils'
require 'date'
require 'i18n'
require 'rmagick'
require 'lorem_ipsum_amet'
require 'jekyll'
require 'yaml'
require 'rainbow'

require_relative "util"

include Magick

class Generator
    
    @@util_dir = "util"
    @@css_dir = "css"
    @@sass_dir = "_sass"
    @@asset_dir = "assets"
    @@img_dir = "img"
    @@post_dir = "_posts"
    @@post_asset = "post"
    @@task_dir = "_tasks"
    @@task_asset = "task"
    @@story_dir = "_story"
    @@story_asset = "story"
    @@album_dir = "_albums"
    @@album_asset = "albums"
    @@home_asset = "home"
    @@import_dir = "import"

    @@env_url = "SCRIBAE_URL"
    @@env_baseurl = "SCRIBAE_BASEURL"
    @@env_gh_user = "SCRIBAE_GH_USER"
    @@env_gh_pwd = "SCRIBAE_GH_PWD"
    @@env_gh_repo = "SCRIBAE_GH_REPO"

    attr_reader :verb
    attr_reader :cfg_url
    attr_reader :cfg_baseurl
    attr_reader :cfg_gh_user
    attr_reader :cfg_gh_pwd
    attr_reader :cfg_repo

    def initialize(verb)  
        @verb = verb
        I18n.config.available_locales = :en
        log "Use locale: #{I18n.locale.to_s}"
        log "Process in #{Dir.pwd}"
        if File.exists?('generator.rb')
            log "Switching to parent folder"
            Dir.chdir('..');
            log "Process in #{Dir.pwd}"
        end
    end

    def log(string = nil)
        #puts "verbose: #{@verb}" 
        if !string.nil? and @verb
            puts string
        end
    end

    def sanitizeFilename(filename)
        # Split the name when finding a period which is preceded by some
        # character, and is followed by some character other than a period,
        # if there is no following period that is followed by something
        # other than a period (yeah, confusing, I know)
        filename = I18n.transliterate(filename)
        fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m
      
        # We now have one or two parts (depending on whether we could find
        # a suitable period). For each of these parts, replace any unwanted
        # sequence of characters with an underscore
        fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '-' }
      
        # Finally, join the parts with a period and return the result
        res = fn.join '-'
        return res.downcase
      end




    #Create directory structure
    def checkdirs ()
        log ":checkdirs"

        path = File.join(@@import_dir)
        log "Check import dir: #{path}"
        if !Dir.exist?(path)
            Dir::mkdir(path, 0777)
        end 
        
        path = File.join(@@css_dir)
        log "Check css dir: #{path}"
        if !Dir.exist?(path)
            Dir::mkdir(path, 0777)
        end 

        path = File.join(@@asset_dir, @@img_dir)
        log "Check asset dir: #{path}"
        if !Dir.exist?(path)
            Dir::mkdir(path, 0777)
        end 

        log "Check asset subdirs"
        [@@home_asset, @@post_asset, @@task_asset, @@story_asset, @@album_asset].each do |dir|
            path = File.join(@@asset_dir, @@img_dir, dir)
            log " ->Check asset dir: #{path}"
            if !Dir.exist?(path)
                Dir::mkdir(path, 0777)
            end  
        end 

        log "Check collections dir"

        ["posts", @@post_dir, @@task_dir, @@story_dir, @@album_dir].each do |dir|
            log "   ->Check collection dir: #{dir}"
            if !Dir.exist?(dir)
                Dir::mkdir(dir, 0777)
            end  
        end 
    end

    def copy_pages(force = false) 
        log ":copy_pages"
        dir = 'util/pages/'
        if Dir.exist?(dir)
            pages = Dir.entries(dir)
            pages.each do |page|
                if page.end_with?('.md', '.html')
                    src = dir + page
                    dest = page
                    #specific for posts
                    if(page == 'index.html')
                        dest = './posts/'+ page
                    end
                    if not File.exists?(dest) or force
                        log "   ->Copy #{dest}"
                        FileUtils.cp(src, dest)
                    end
                end
            end
        end 
    end

    def copy_config(force = false)
        log ":copy_config"
        prod_config = '_config.yml'
        dev_config = '_config_dev.yml'
        @cfg_url = ENV[@@env_url]
        @cfg_baseurl = ENV[@@env_baseurl]
        @cfg_gh_user = ENV[@@env_gh_user]
        @cfg_gh_pwd = ENV[@@env_gh_pwd]
        @cfg_gh_repo = ENV[@@env_gh_repo]

        if !File.exists?(prod_config) or force
            config = YAML.load_file('util/_config-default.yml')
            config['url'] = @cfg_url
            config['baseurl'] = @cfg_baseurl 
            log "   ->Copy #{prod_config}"
            File.open(prod_config,'w') do |h| 
                h.write config.to_yaml
             end
        end 
        if !File.exists?(dev_config) or force
            config = YAML.load_file('util/_config-default.yml')
            config['url'] = @cfg_url
            config['baseurl'] = ""
            config['future'] = true
            config['local'] = true
            config['incremental'] = true
            config['profile'] = true
            log "   ->Copy #{dev_config}"
            File.open(dev_config,'w') do |h| 
                h.write config.to_yaml
             end
        end 
    end
    #------------- STYLES -------------#
    # Copy main color definition
    def copy_theme_color(force = false)
        color_style = "colors.scss"
        dest = File.join(@@sass_dir, color_style)
        if not File.exist?(dest) or force
            src = File.join(@@util_dir, "scss", color_style)
            log "Write #{dest}"
            FileUtils.cp(src, dest)
        end
    end

    def gen_style(idx = 0)
        log ":gen_style in #{Dir.pwd}"
        name = File.join(@@css_dir, "style-#{idx}.scss")
        file = File.open(name, "w+")
        log "Write #{file}"
        style = [
            "---",
            "# Only the main Sass file needs front matter",
            "---",
            "//Import Color",
            "@import \"colors\";",
            "//Define primary colors",
            "$theme_primary: $theme_#{idx}_p;",
            "$theme_secondary: $theme_#{idx}_s;",
            "$theme_background: $theme_#{idx}_b;",
            "$theme_md: $theme_#{idx}_md;",
            "//Import components",
            "@import \"theme\";",
            "@import \"materialize\";",
            "@import \"menu\";",
            "@import \"home\";",
            "@import \"general\";",
        ].join("\n") + "\n"
        file << style
    ensure
        file.close
    end

    def gen_style_set(nb = 5)
        idx = 0
        nb.times do
            gen_style(idx)
            idx += 1
        end
    end

    def init(force = false) 
        checkdirs
        copy_config(force)
        copy_pages(force)
        copy_theme_color(force)
        gen_style_set
        
    end

    def gen_post(sample = true, title = 'Article exemple', intro = nil, date = nil, featured = false)
        log "gen postfi"
        if date.nil?
            date = DateTime.now 
        end
        name = date.strftime('%Y-%m-%d-') + sanitizeFilename(title)
        postFile = File.join(@@post_dir, name + '.md')
        assetDir = File.join( @@asset_dir, @@img_dir, @@post_asset, name)
        if !Dir.exist?(assetDir)
            Dir::mkdir(assetDir, 0777)
        end 
        file = File.open(postFile, "w")
        if intro.nil?
            intro = "L'article #{title} a été généré automatiquement (intro)"
        end
        head = [
            "---",
            "#--------------",
            "# Modèle page article",
            "#--------------",
            "# Ne pas modifier cette section pour les débutants!",
            "layout: post",
            "# Titre de l'article",
            "title: \"#{title}\"",
            "# Phrase d'introduction",
            "intro: \"#{intro}\"",
            "# Date de publication, format ISO 8601",
            "date: #{date.iso8601}",
            "# Si l'article est mis en avant dans la, page d'accueil",
            "featured: #{featured}",
            "# Theme spécifique (couleur en fonction de l'ordre de la page)",
            "theme: 1",
            "# Gestion simplifée des ressources images, voir doc",
            "md-asset: true",
            "# Catégories, séparées d'un espace",
            "categories: exemple automatique",
            "---",
        ].join("\n") + "\n"
        file << head
        if sample
            img = File.join(assetDir, 'sample.jpg')
            FileUtils.cp('util/model/sample.jpg', img)
            file << "\n\n# " + LoremIpsum.lorem_ipsum(w: 4) 
            file << "\n\n"
            file << "![sample.jpg]()"
            file << "\n\n"
            file << ">" + LoremIpsum.lorem_ipsum(w: 20) + "\n"
            file << "\n"
            file << "\n"
            file << LoremIpsum.lorem_ipsum(w: 150) + "\n"
        end
    ensure
        file.close
    end

    def gen_post_set(nb = 10, title = 'Article généré automatiquement ')
        log "gen posts set"
        idx = 1
        nb.times do 
            date = DateTime.now.prev_day(idx)
            name = title + ' ' + idx.to_s
            gen_post(true, name, nil, date)
            idx += 1
        end
    end

    def gen_task(sample = true, index = 0, title = 'Thème exemple', intro = nil)

        name = format('%03d', index) + "-" + sanitizeFilename(title)
        taskFile = File.join(@@task_dir, name + '.md')
        assetDir = File.join( @@asset_dir, @@img_dir, @@task_asset, name)
        if !Dir.exist?(assetDir)
            Dir::mkdir(assetDir, 0777)
        end 

        file = File.open(taskFile, "w")
        if intro.nil?
            intro = "Le thème #{title} a été généré automatiquement (intro)"
        end
        
        head = [
            "---",
            "#--------------",
            "# Modèle page thème",
            "#--------------",
            "# Ne pas modifier cette section pour les débutants!",
            "layout: task",
            "# Ordre d",
            "index: #{index}",
            "# Titre du thème",
            "title: \"#{title}\"",
            "# Description du thème",
            "intro: \"#{intro}\"",
            "# Theme de couleur spécifique (couleur en fonction de l'ordre de la page)",
            "theme: 2",
            "# Gestion simplifée des ressources images, voir doc",
            "md-asset: true",
            "---",
        ].join("\n") + "\n"
        file << head
        if sample 
            file << "# " + LoremIpsum.lorem_ipsum(w: 4) + "\n"
            file << "![1.jpg]()" + "\n\n"
            file << LoremIpsum.lorem_ipsum(w: 100) + "\n\n"
            file << "![2.jpg]()" + "\n\n"
            file << ">" + LoremIpsum.lorem_ipsum(w: 30) + "\n"
            file << "\n"
            # copy images
            taskThumb = assetDir + "/thumb.jpg"
            taskImg1 = assetDir + "/1.jpg"
            taskImg2 = assetDir + "/2.jpg"
            gen_image(500, 400, 150, taskThumb, 'miniature', nil)
            gen_image(1000, 600, 150, taskImg1, title, nil)
            gen_image(400, 200, 72, taskImg2,  "autre", nil)
        end
    ensure
        file.close    
    end

    def gen_task_set(nb = 7, title = 'Thème exemple')       
        idx = 1
        nb.times do 
            name = title + ' ' + idx.to_s
            gen_task(true, idx * 100, name)
            idx += 1
        end
    end

    def gen_story(sample, idx, title = "Rubrique")     

        story_name = format('%02d-%s', idx, sanitizeFilename(title))
        story_file = File.join(@@story_dir, story_name + ".md")
        story_asset = File.join(@@asset_dir, @@img_dir, @@story_asset)
        story_img = story_name + ".jpg"
        content = [
            "---",
            "#--------------",
            "# Modèle section narration",
            "#--------------",
            "# Ordre d'aparition du chapitre",
            "index: #{idx}",
            "# Titre du thème",
            "title: #{idx}. #{title}",
            "---",
            "",
        ]
        if sample
            content.push([
                "## #{LoremIpsum.lorem_ipsum(w: 4)}\n",
                ">#{LoremIpsum.lorem_ipsum(w: 20)}\n",
                "",
                "![#{story_img}]()",
                "",
                "#{LoremIpsum.lorem_ipsum(w: 50)}\n",
                ""
            ])
            gen_image(400, 250, 150, File.join(story_asset, story_img), "section-image-#{idx}")
        end
        File.write(story_file, content.join("\n"))     
    end

    def gen_story_set(nb = 5, title = "Rubrique")
        nb.times do |idx|
            gen_story(true, idx, "#{idx+1} - Rubrique")
        end
    end

    def gen_album(sample=false, title="titre", intro="intro", date=DateTime.now)

        log "generating sample album: " + title
        name = sanitizeFilename title
        album_file = File.join(@@album_dir, name + ".md")
        album_asset = File.join(@@asset_dir, @@img_dir, @@album_asset,  name)
        nb = 0
        if(sample)
            nb = 20
        end
        if !Dir.exist?(album_asset)
            Dir::mkdir(album_asset, 0777)
        end   
        content = [
            "---",
            "#--------------",
            "# Modèle d'album",
            "#--------------",
            "# Ne pas modifier cette section pour les débutants!",
            "layout: album",
            "# Titre de l'album",
            "title: \"#{title}\"",
            "# Phrase d'introduction",
            "intro: \"#{intro}\"",
            "# Date de publication, format ISO 8601",
            "date: #{date.iso8601}",
            "# Image qui servira de miniature",
            "thumb: 1.jpg",
            "# Nombres d'images à afficher",
            "nbimg: #{nb}",
            "# Images du dossier à exclure",
            "exclude: ",
            "# Theme de couleur spécifique (couleur en fonction de l'ordre de la page)",
            "theme: 4",
            "---",
            "\n"
        ]
        if sample
            content.push([
                "## #{LoremIpsum.lorem_ipsum(w: 4)}\n",
                ">#{LoremIpsum.lorem_ipsum(w: 20)}\n",
                "\n"
            ])
            nb.times do |idx|
                img_file =  File.join(album_asset, "#{idx}.jpg")
                gen_image(1280, 800, 150, img_file, "album image #{idx}")
            end
        end
        File.write(album_file, content.join("\n"))
    end

    def gen_album_set(nb = 6)       
        nb.times do | idx |
            date = DateTime.now.prev_day(idx)
            gen_album(true,  "Album #{idx + 1}",  "Intro à l'album #{idx + 1}", date)
        end 
    end

    def gen_image(w = 1280, h = 800, dpi=72.0, out = "sample.jpg", msg = "message", src = nil)
        
        log "genImage to " + out
        size = "#{w}x#{h}"
        col1 = "%06x" % (rand * 0xffffff)
        col2 = "%06x" % (rand * 0xffffff)
        imgSpec = "plasma:##{col1}-##{col2}"
        #Load immage if src is nil
        sample = nil
        if src == nil
            sample = ImageList.new(imgSpec) { 
                self.size =  size
                self.density = "#{dpi}x#{dpi}"
            }            
        else
            sample = ImageList.new(src)
            sample.resize_to_fill!(w, h)
        end        
        #verbosity
        #sample.resize!(w, h)
        #resample at target dpi
        #sample = sample.resample(dpi);
        #sample.units = Magick::PixelsPerInchResolution
        #sample.density = "#{dpi}x#{dpi}"
        #log "Image #{sample.columns} X #{sample.rows}"
        dpiFactor = dpi / 72
        if !msg.nil?
            text = Draw.new
            text.font_family = 'DejaVu-Sans'

            text.pointsize = w / 20
            text.gravity = CenterGravity
            text.annotate(sample, 0,0,0, -w / 8, out) {
                self.fill = 'black'
            }
            text.pointsize = w / 17
            #text.gravity = NorthGravity
            text.annotate(sample, 0,0,0, w / 8,"#{size}@#{dpi}dpi") {
                self.fill = 'black'
            }
            text.pointsize = w / 10
            #text.gravity = CenterGravity
            text.annotate(sample, 0,0,0,0, msg) {
                self.fill = 'white'
            }
        end
        quality = 80
        if(dpi > 72)
            quality = 60 
        end
        if(dpi > 150)
            quality = 40
        end
        quality = 80
        #log "quality #{quality}"
        sample.write(out) {
            self.quality = quality
        }

    end

    # Generate a responsive image set
    def gen_image_set(sizes, dpis, dir = ".", name = sample, msg = nil, src = nil)
        sizes.each do |size|
            dpis.each do |dpi|
                outFile = dir + "/" + name + "-" + size['w'].to_s + "-" + dpi.round.to_s + ".jpg"
                gen_image(size['w'], size['h'], dpi, outFile, msg, src)
            end
        end
    end

    # Generate home images
    def gen_home_images(sample=true)
        const = Util.get_constant
        dpi = const['img-dpi']
        size = const['img-size'].values
        path = File.join(@@asset_dir, @@img_dir, @@home_asset)
        if sample
            gen_image_set(size, dpi, path, "parallax-1", "Image 1")
            gen_image_set(size, dpi, path, "parallax-2", "Image 2")
        else
            gen_image_set(size, dpi, path, "parallax-1", nil, "util/media/1.jpg")
            gen_image_set(size, dpi, path, "parallax-2", nil,  "util/media/2.jpg")
        end
    end

end


