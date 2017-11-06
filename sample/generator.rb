require 'fileutils'
require 'date'
require 'i18n'
require 'RMagick'
require 'lorem_ipsum_amet'
require 'jekyll'
require 'yaml'
require 'rainbow'
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
                        log "   ->Copy #{dest}"
                        FileUtils.cp(src, dest)
                    end
                end
            end
        end 
    end

    def copy_config(force = false)
        log ":copy_config"
        dest_config = '_config.yml'

        @cfg_url = ENV[@@env_url]
        @cfg_baseurl = ENV[@@env_baseurl]
        @cfg_gh_user = ENV[@@env_gh_user]
        @cfg_gh_pwd = ENV[@@env_gh_pwd]
        @cfg_gh_repo = ENV[@@env_gh_repo]

        if !File.exists?(dest_config) or force
            config = YAML.load_file('sample/_config-default.yml')
            config['url'] = @cfg_url
            config['baseurl'] = @cfg_baseurl 
            log "   ->Copy #{dest_config}"
            File.open(dest_config,'w') do |h| 
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
            src = File.join("sample", "scss", color_style)
            log "Write #{dest}"
            FileUtils.cp(src, dest)
        end
    end

    def gen_style(idx = 0)
        name = File.join(@@css_dir, "style-#{idx}.scss")
        file = File.open(name, "w")
        log "Write #{name}"
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

    def init(force = false) 
        checkdirs
        copy_config(force)
        copy_pages(force)
        copy_theme_color(force)
        gen_style_set
        
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

    def gen_album(nb = 6, imgs = 25)
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
    def gen_image_set(sizes, dpis, dir = ".", name = sample, verbose=false, msg = nil, src = nil)
        sizes.each do |size|
            dpis.each do |dpi|
                outFile = dir + "/" + name + "-" + size[0].to_s + "-" + dpi.round.to_s + ".jpg"
                genImage(size[0], size[1], dpi, outFile, verbose, msg, src)
            end
        end
    end

    # Generate home images
    def gen_home_images(sample)
        sizes = [[1200, 1000], [1000, 1000], [800, 800], [600, 800], [400, 600]]
        dpis = [72.0, 150.0, 200.0]
        path = File.join(@@asset_dir, @@img_dir, @@home_asset)
        gen_image_set(sizes, dpis, path, "parallax-1", true, "Image 1")
        gen_image_set(sizes, dpis, path, "parallax-2", true, "Image 2")
    end

end

yes = "oui"
no = "non"

help_cmd = "aide"
init_cmd = "init"
start_cmd = "--start"
verbose_cmd = "--verbeux"
force_cmd = "--force"
all_cmd = "--tout"
title_cmd = "--name"
upadte_cmd = "--maj"
sample_cmd = "--exemple"

create_cmd = "creer"
homeimg_cmd = "imagefond"
post_cmd = "article"
task_cmd = "sujet"
story_cmd = "section"
album_cmd = "album"
nb_cmd = "nombre"

empty_text = "Vous devez entrer une commande, par exemple " + Rainbow(help_cmd).magenta
unknown_text = "Commande inconnue, essayez " + Rainbow(help_cmd).magenta
logo_text = %Q{
  ==============================================================
  _____    _____   _____    _____   ____               ______   
  / ____|  / ____| |  __ \  |_   _| |  _ \      /\     |  ____| 
  | (___   | |      | |__) |   | |   | |_) |    /  \    | |__   
  \___ \  | |      |  _  /    | |   |  _ <    / /\ \   |  __|   
  ____) | | |____  | | \ \   _| |_  | |_) |  / ____ \  | |____  
  |_____/   \_____| |_|  \_\ |_____| |____/  /_/    \_\ |______|
  ==============================================================
}
help_text = [
"----------------------------",
"Aide de la ligne de commande",
"----------------------------",
"",
Rainbow(help_cmd).green + " >> affiche l'aide",
Rainbow(init_cmd).green + " >> initialise le site",
"    options " + Rainbow(force_cmd).green + " pour écraser les fichiers déjà crées",
"",
Rainbow(create_cmd).green + " >> pour créer une publication",
"",
"    suivi de " + Rainbow(post_cmd).green + " >> pour un article",
"              " + Rainbow(task_cmd).green + " >> pour un sujet",
"              " + Rainbow(story_cmd).green + " >> pour une section de la narration",
"              " + Rainbow(album_cmd).green + " >> pour une section de la narration",
"",
"    options " + Rainbow(force_cmd).green + " >> pour écraser les fichiers déjà crées",
"            " + Rainbow(sample_cmd).green + " >> exemple prédéfini",
"----------------------------",
"-------------",
"----",
"",
].join("\n")

#
cmd = ARGV
verbose = cmd.delete(verbose_cmd) == verbose_cmd 
#puts verbose
#puts Rainbow("Execution de la commande...").blue
generator = Generator.new(verbose)
case cmd.shift
when nil
    puts Rainbow(empty_text).red
    puts help_text
when help_cmd
    #puts Rainbow(logo_text).magenta
    puts help_text
when init_cmd
    force = force_cmd == cmd.shift
    if force
        puts Rainbow("Etes-vous certain d'écraser tous les fichier? oui | non").magenta
        
        case answer = gets.chomp
        when yes
            generator.init true
        else
            puts Rainbow("Abandon de la commande!").blue
        end
    else
        generator.init
    end

when create_cmd
    sample = cmd.delete(sample_cmd) == sample_cmd 
    case cmd.shift
    when homeimg_cmd
        puts Rainbow("Vous avez choisi de créer les images de fond").blue
        if !sample
        end
        generator.gen_home_images(sample)
    when post_cmd
        puts Rainbow("Vous avez choisi créer un article").blue
        puts Rainbow("Donnez le titre de l'article (vide pour abandonner):").magenta
        date_time = nil
        featured = false
        title = gets.chomp
        if title.empty?
            puts Rainbow("Titre vide, abandon").magenta
        else
            puts Rainbow("Donnez la date et l'heure").magenta
            puts Rainbow("La date s'écrit 01/01/2017 15:00 (vide choisir maintenant)").magenta
            date = gets.chomp
            unless date.empty?
                date_time = nil
            end
            puts Rainbow("Ecrire l'intro:").magenta
            intro = gets.chomp
            puts Rainbow("L'article doit-il être mis en avant? oui | non").magenta
            featured = gets.chomp == yes
            #sample = true, title = 'Article exemple', intro = nil, date = nil, featured = false
            generator.gen_post(sample, title, intro, date_time, featured)   
        end
    end
else
    puts Rainbow("Commande non prise en charge, abandon").magenta
end


#generator = Generator.new('/scribae')
#generator.genConfig()
#generator.genHomeImages()
#generator.copyPages(true)
#generator.gen_post(true, 'Premier article', nil, nil, true)
#generator.gen_post_set()
#generator.genTask(true, 100, 'Thème exemple', nil)
#generator.gen_task_set()
#generator.gen_story(
#generator.gen_style_set(5)