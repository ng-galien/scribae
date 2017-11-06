require 'fileutils'
require 'date'
require 'i18n'
require 'RMagick'
require 'lorem_ipsum_amet'
require 'jekyll'
require 'yaml'

include Magick

class Generator
    
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

    attr_reader :relative_url

    def initialize(relative_url)  
        I18n.config.available_locales = :en
        puts 'use locale: ' + I18n.locale.to_s
        @relative_url = relative_url
        checkdirs()
    end

    def loadYAML(path)

    end

    def writeYAML()
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
        puts 'Process in ' + Dir.pwd 
        if File.exists?('generator.rb')
            puts 'Switching to parent'
            Dir.chdir('..');
            puts 'Process in ' + Dir.pwd 
        end
        puts 'Check asset dir'
        path = File.join(@@asset_dir, @@img_dir)
        if !Dir.exist?(path)
            Dir::mkdir(path, 0777)
        end 
        [@@home_asset, @@post_asset, @@task_asset, @@story_asset, @@album_asset].each do |dir|
            path = File.join(@@asset_dir, @@img_dir, dir)
            if !Dir.exist?(path)
                Dir::mkdir(path, 0777)
            end  
        end 
        puts 'Check collections dir'

        [@@post_dir, @@task_dir, @@story_dir, @@album_dir].each do |dir|
            if !Dir.exist?(dir)
                Dir::mkdir(dir, 0777)
            end  
        end 
    end

    def copyPages(force = false) 
        puts 'Copy pages...'
        dir = 'sample/pages/'
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
                        puts 'copying '+ page
                        FileUtils.cp(src, dest)
                    end
                end
            end
        end 
    end

    def copyConfig()
        puts "Check Jekyll config file"
        config = '_config.yml'
        unless File.exists?(config)
            puts "Copy default config"
            FileUtils.cp('sample/_config-default.yml', '_config.yml')
        end 
    end
    #------------- STYLES -------------#
    # Copy main color definition
    def copy_theme_color(force = false)
        color_style = "colors.scss"
        dest = File.join(@@sass_dir, color_style)
        if not File.exist?(dest) or force
            src = File.join("sample", "scss", color_style)
            FileUtils.cp(src, dest)
        end
    end

    def gen_style(idx = 0)
        name = File.join(@@css_dir, "style-#{idx}.scss")
        file = File.open(name, "w")
        head = [
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
        file << head
    end

    def gen_style_set(nb = 5)
        idx = 0
        nb.times do
            gen_style(idx)
            idx += 1
        end
    end

    def gen_post(sample = true, title = 'Article exemple', intro = nil, date = nil, featured = false)
        
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
            FileUtils.cp('sample/model/sample.jpg', img)
            img = File.join(relative_url, img)
            file << "\n\n# " + LoremIpsum.lorem_ipsum(w: 4) 
            file << "\n\n"
            file << "![sample.jpg]()"
            file << "\n\n"
            file << ">" + LoremIpsum.lorem_ipsum(w: 20) + "\n"
            file << "\n"
            file << "\n"
            file << LoremIpsum.lorem_ipsum(w: 150) + "\n"
        end
    end


    def gen_post_set(nb = 10, title = 'Article généré automatiquement ')
        puts "gen posts set"
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
            genImage(500, 400, 150, taskThumb, true, 'miniature', nil)
            genImage(1000, 600, 150, taskImg1, true, title, nil)
            genImage(400, 200, 72, taskImg2, true, "autre", nil)
        end
        
    end

    def gen_task_set(nb = 7, title = 'Thème exemple')       
        idx = 1
        nb.times do 
            name = title + ' ' + idx.to_s
            gen_task(true, idx * 100, name)
            idx += 1
        end
    end

    def gen_story(nb = 5, title = "Rubrique")     
        idx = 1
        nb.times do 
            story_idx = idx * 10
            story_name = format('%02d-%s', story_idx, sanitizeFilename(title))
            story_file = File.join(@@story_dir, story_name + ".md")
            story_asset = File.join(@@asset_dir, @@img_dir, @@story_asset)
            story_img = story_name + ".jpg"
            head = [
                "---",
                "#--------------",
                "# Modèle section narration",
                "#--------------",
                "# Ordre d'aparition du chapitre",
                "index: #{story_idx}",
                "# Titre du thème",
                "title: #{story_idx}. #{title}",
                "---",
            ].join("\n") + "\n"
            file = File.open(story_file, "w")
            file << head
            file << "# " + LoremIpsum.lorem_ipsum(w: 4) + "\n\n"
            
            file << "![#{story_img}]()\n\n"
            file << LoremIpsum.lorem_ipsum(w: 500) + "\n"
            genImage(400, 250, 150, File.join(story_asset, story_img), true, 'section-image-'+ idx.to_s)
            idx += 1
        end
    end

    def gentAlbums(nb = 6, imgs = 25)
        idx = 1
        nb.times do 
            date = Date.new(2017,1,1).next_day(idx)
            dateTime = DateTime.new(2017,1,1).next_day(idx)
            albumName = "album-" + idx.to_s
            puts "generating sample album: " + albumName
            albumFile = @@album_dir + "/" + albumName + ".md"
            albumAsset = @@img_dir + "/" + @@album_dir + "/" + albumName
            if !Dir.exist?(albumAsset)
                Dir::mkdir(albumAsset, 0777)
            end   

            file = File.open(albumFile, "w")
            file << "---"  + "\n"
            file << "layout: album" + "\n"
            file << "date: " + dateTime.iso8601 + "\n"
            file << "title: Album " + idx.to_s + "\n"
            file << "intro: " + LoremIpsum.lorem_ipsum(w: 6) + "\n"
            file << "thumb: 1.jpg" + "\n"
            file << "auto_increment:" + "\n"
            file << "   size: " + imgs.to_s + "\n"
            file << "---" + "\n"
            file << "\n"
            file << "## " + LoremIpsum.lorem_ipsum(w: 4) + "\n\n"
            file << LoremIpsum.lorem_ipsum(w: 20) + "\n"
            imgIdx = 1
            imgs.times do
                imgPath =  albumAsset + "/" + imgIdx.to_s + ".jpg"
                genImage(1280, 800, "album"+ idx.to_s + "-img"+ imgIdx.to_s, imgPath)
                imgIdx += 1
            end
            idx += 1
        end
    end

    def genImage(w = 1280, h = 800, dpi=72.0, out = "sample.jpg", verbose = true,  msg = "message", src = nil)
        puts "genImage to " + out
        size = w.to_s + "x" + h.to_s
        col1 = "%06x" % (rand * 0xffffff)
        col2 = "%06x" % (rand * 0xffffff)
        imgSpec = "plasma:#" + col1 + "-#" + col2
        #Load immage
        sample = nil
        if src == nil
            sample = ImageList.new(imgSpec) { self.size =  size}
        else
            sample = ImageList.new(src)
        end
        #resample at target dpi
        sample = sample.resample(dpi);
        #verbosity
        dpiFactor = dpi / 72
        if verbose
            text = Draw.new
            text.font_family = 'tahoma'

            text.pointsize = w / 20 *  dpiFactor
            text.gravity = CenterGravity
            text.annotate(sample, 0,0,0, -w / 8 * dpiFactor, out) {
                self.fill = 'black'
            }
            text.pointsize = w / 17  * dpiFactor
            #text.gravity = NorthGravity
            text.annotate(sample, 0,0,0, w / 8 * dpiFactor, size.to_s+"@"+dpi.to_s+"dpi") {
                self.fill = 'black'
            }
            text.pointsize = w / 10  * dpiFactor
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
        puts "quality #{quality}"
        sample.write(out) {
            self.quality = quality
        }
    end

    # Generate a responsive image set
    def genImageSet(sizes, dpis, dir = ".", name = sample, verbose=false, msg = nil, src = nil)
        sizes.each do |size|
            dpis.each do |dpi|
                outFile = dir + "/" + name + "-" + size[0].to_s + "-" + dpi.round.to_s + ".jpg"
                genImage(size[0], size[1], dpi, outFile, verbose, msg, src)
            end
        end
    end

    # Generate home images
    def genHomeImages()
        sizes = [[1200, 1000], [1000, 1000], [800, 800], [600, 800], [400, 600]]
        dpis = [72.0, 150.0, 200.0]
        path = File.join(@@asset_dir, @@img_dir, @@home_asset)
        genImageSet(sizes, dpis, path, "parallax-1", true, "Image 1")
        genImageSet(sizes, dpis, path, "parallax-2", true, "Image 2")
    end

end

generator = Generator.new('/scribae')
#generator.genConfig()
#generator.genHomeImages()
#generator.copyPages(true)
#generator.gen_post(true, 'Premier article', nil, nil, true)
#generator.gen_post_set()
#generator.genTask(true, 100, 'Thème exemple', nil)
#generator.gen_task_set()
generator.gen_story()
#generator.gen_style_set(5)