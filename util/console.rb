require_relative "util"
require_relative "generator"



class Console

    @@yes = "oui"
    @@no = "non"
    #Here the main command
    @@exit_cmd = "fin"
    @@help_cmd = "aide"
    @@init_cmd = "init"
    @@save_cmd = "enregistrer"
    @@create_cmd = "creer"
    @@publish_cmd = "publier"
    @@start_cmd = "start"
    @@img_cmd = "image"
    #Here the options
    @@no_interractive_opt = "--no-interactive"
    @@verbose_opt = "--verbeux"
    @@force_opt = "--force"
    @@all_opt = "--tout"
    @@sample_opt = "--exemple"
    @@source_opt = "--source"
    @@title_opt = "--titre"
    @@intro_opt = "--intro"
    #Here the prop
    @@title_prop = "--titre"
    @@intro_prop = "--intro"
    @@date_prop = "-- date"
    @@nb_prop = "--nb"
    #Here the cat
    @@sample_cat = "exemple"
    @@post_cat = "article"
    @@task_cat = "sujet"
    @@story_cat = "section"
    @@album_cat = "album"
    @@map_cat = "carte"
    
    @@empty_text = "Vous devez entrer une commande, par exemple " + Rainbow(@@help_cmd).green
    @@unknown_text = "Commande inconnue"
    @@empty_cmd_text = "Voulez-vous quitter? (" + Rainbow(@@exit_cmd).green + " pour quitter)"
    @@quit_text = Rainbow("Vous quittez le programme, à bientot!").red
    @@prompt_text = "Que voulez vous faire? (astuce: " + Rainbow(@@help_cmd).green + ")"
    @@confirm_text = "Voulez vous confirmer l'opération? " + Rainbow(@@yes).green + " | " + Rainbow(@@no).green
    @@init_help_text = ""
    @@create_help_text = ""
    @@store_help_text = ""
    
    @@logo_text = File.read('util/banner.ascii')
    @@help_text = [
    "----------------------------",
    "Aide de la ligne de commande",
    "----------------------------",
    "",
    Rainbow(@@exit_cmd).green + " >> quitter la console",
    Rainbow(@@help_cmd).green + " >> affiche l'aide",
    #Rainbow(@@init_cmd).green + " >> initialise le site",
    #"    options " + Rainbow(@@force_opt).green + " pour écraser les fichiers déjà crées",
    #"",
    Rainbow(@@create_cmd).green + " >> pour créer une publication",
    "",
    "    suivi de " + Rainbow(@@post_cat).green + " >> pour un article",
    "              " + Rainbow(@@task_cat).green + " >> pour un sujet",
    "              " + Rainbow(@@story_cat).green + " >> pour une section de la narration",
    "              " + Rainbow(@@album_cat).green + " >> pour une section de la narration",
    "              " + Rainbow(@@sample_cat).green + " >> pour un jeux d'exemples complet",
    "",
    "    options " + Rainbow(@@force_opt).green + " >> pour écraser les fichiers déjà crées",
    "            " + Rainbow(@@sample_opt).green + " >> exemple prédéfini",
    "----------------------------",
    "",
    ].join("\n")

    def initialize()  
        Util.set_path
        puts Rainbow(@@logo_text).orange
        
    end

    def init(verbose=false, silent=false, cmd=nil)
        gen = Generator.new(verbose)
        force = cmd.delete(@@force_opt) == @@force_opt
        do_task = true
        if force
            puts Rainbow("Attention, vous allez écraser tous les fichier").red
            do_task = silent || confirm()                    
        end
        if do_task
            gen.init(force)
            puts Rainbow("Initialisation terminée").blue
        end
    end

    def background(verbose=false, cmd=nil)
        puts Rainbow("Vous avez choisi de créer les images de fond").blue
        cmd = cmd || []
        sample = cmd.delete(@@sample_opt) == @@sample_opt
        imgs = nil
        if !sample
            origin = Dir.pwd
            Dir.chdir(File.join("util", "media"))
            imgs = Dir.glob("{1,2}.{jpg}")
            Dir.chdir(origin)            
        end
        if (imgs.size == 2 and !sample)# and confirm
            gen = Generator.new(verbose)
            gen.gen_home_images(sample)
            puts Rainbow("Création des image terminée").blue
        end
    end

    def create_post(verbose=false, cmd=nil)
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
            featured = gets.chomp == @@yes
            #sample = true, title = 'Article exemple', intro = nil, date = nil, featured = false
            generator.gen_post(sample, title, intro, date_time, featured)
        end
    end

    def create_task(verbose=false, cmd=nil)
    end

    def create_section(verbose=false, cmd=nil)
    end

    def create_album(verbose=false, cmd=nil)
    end

    def create_sample(verbose=false, cmd=nil)
        gen = Generator.new(true)
        gen.gen_home_images true
        gen.gen_post_set(28, 'Article exemple ')
        gen.gen_task_set(5, 'Sujet principal ')
        gen.gen_story()
        gen.gen_album()
    end

    def confirm(msg = @@confirm_text)
        puts msg
        cmd = gets.chomp.split(" ")
        return cmd.delete(@@yes) == @@yes
    end

    def put_images(src, dest)
        
    end

    def handle_command(argv)
        finish = false
        silent = false
        
        while !finish do
            if (cmd.delete(@@no_interractive_opt) == @@no_interractive_opt)
                finish = true
                silent = true
            end
            puts  @@prompt_text
            cmd = gets.chomp.split(" ")
            verbose = cmd.delete(@@verbose_opt) == @@verbose_opt
            case cmd.shift
            when nil
                puts @@empty_cmd_text
            when @@exit_cmd
                puts @@quit_text
                finish = true
            when @@help_cmd
                puts @@help_text
            when @@init_cmd
                init(verbose, silent, cmd)
            when @@img_cmd
                background(verbose, cmd)
            when @@create_cmd
                case cmd.shift
                when @@post_cat
                    create_post(verbose, cmd)
                when @@task_cat
                    create_task(verbose, cmd)
                when @@story_cat
                    create_section(verbose, cmd)
                when @@album_cat
                    create_album(verbose, cmd)
                when @@sample_cat
                    create_sample(verbose, cmd)
                else
                    puts unknown_text
                    puts
                end
            else
                puts @@unknown_text
            end
        end
    end
end

Util.set_path
cons = Console.new
cons.handle_command()
