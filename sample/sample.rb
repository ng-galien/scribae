require 'date'
require 'RMagick'
require 'lorem_ipsum_amet'

include Magick

class Sample
     
    @@asset_dir = "asset"
    @@img_dir = "img"
    @@post_dir = "posts"
    @@task_dir = "tasks"
    @@story_dir = "story"
    @@album_dir = "albums"

    def initialize()  

        if !Dir.exist?(@@img_dir)
            Dir::mkdir(@@img_dir, 0777)
        end     
        [@@img_dir, @@post_dir, @@task_dir, @@story_dir, @@album_dir].each do |dir|
            if !Dir.exist?(dir)
                Dir::mkdir(dir, 0777)
            end  
        end 
        [@@post_dir, @@task_dir, @@story_dir, @@album_dir].each do |dir|
            path = @@img_dir + "/" + dir
            if !Dir.exist?(path)
                Dir::mkdir(path, 0777)
            end  
        end     
    end

    def checkdirs ()
        puts 'process in ' Dir.pwd
        Dir.chdir('..');

        if !Dir.exist?(@@img_dir)
            Dir::mkdir(@@img_dir, 0777)
        end 
    end

    def genPosts(nb = 10)

        if  !Dir.exist?(@@post_dir)
            Dir::mkdir(@@post_dir, 0777)
        end        
        idx = 1
        nb.times do 
            date = Date.new(2017,1,1).next_day(idx)
            dateTime = DateTime.new(2017,1,1).next_day(idx)
            postName = date.to_s + "-exemple-article-" + idx.to_s + ".md"
            postFile = @@post_dir + "/" + postName
            puts postFile
            puts dateTime.iso8601
            if !File.exist?(postFile)
                file = File.open(postFile, "w")
                file << "---"  + "\n"
                file << "layout: post" + "\n"
                file << "title: Exemple d'article " + idx.to_s + "\n"
                file << "date: " + dateTime.iso8601 + "\n"
                file << "categories: sample test" + "\n"
                file << "intro: Introduction à l'article exemple " + idx.to_s + "\n"
                file << "---" + "\n"
                file << "\n"
                file << "# " + LoremIpsum.lorem_ipsum(w: 4) + "\n"
                file << "![](/jekyll-site/assets/img/posts/sample/sample.jpg)\n\n"
                file << ">" + LoremIpsum.lorem_ipsum(w: 40) + "\n"
                file << "\n"
                file << "\n"
                file << LoremIpsum.lorem_ipsum(w: 250) + "\n"
            end
            idx += 1
        end
    end

    def genTasks(nb = 7)
        if  !Dir.exist?(@@task_dir)
            Dir::mkdir(@@task_dir, 0777)
        end        
        idx = 1
        nb.times do 
            taskIdx = idx * 10
            taskName = taskIdx.to_s + "-activity-" + idx.to_s
            taskFile = @@task_dir + "/" + taskName + ".md"
            taskAsset = @@img_dir + "/" + @@task_dir + "/" + taskName
            if !Dir.exist?(taskAsset)
                Dir::mkdir(taskAsset, 0777)
            end   
            taskThumb = taskAsset + "/thumb.jpg"
            puts "generating sample task: " + taskName
            taskImg1 = taskAsset + "/1.jpg"
            taskImg2 = taskAsset + "/2.jpg"

            file = File.open(taskFile, "w")
            file << "---"  + "\n"
            file << "layout: task" + "\n"
            file << "title: Activité " + idx.to_s + "\n"
            file << "description: | \n"
            file << "   " + LoremIpsum.lorem_ipsum(w: 40) + "\n"
            file << "---" + "\n\n"
            file << "# " + LoremIpsum.lorem_ipsum(w: 4) + "\n"
            
            file << "![](/jekyll-site/assets/" + taskImg1 + ")" + "\n\n"
            file << LoremIpsum.lorem_ipsum(w: 100) + "\n\n"
            file << "![](/jekyll-site/assets/" + taskImg2 + ")" + "\n\n"
            file << ">" + LoremIpsum.lorem_ipsum(w: 30) + "\n"
            file << "\n"
            genImage(550, 450, taskName, taskThumb)
            genImage(640, 480, 'task-image-1', taskImg1)
            genImage(200, 200, 'task-image-1', taskImg2)
            idx += 1
        end
    end

    def genStory(nb = 5)     
        idx = 1
        nb.times do 
            storyIdx = idx * 10
            storyName = storyIdx.to_s + "-story-" + idx.to_s
            puts "generating sample story: " + storyName
            storyFile = @@story_dir + "/" + storyName + ".md"
            storyAsset = @@img_dir + "/" + @@story_dir + "/" + storyName
            storyImg = @@img_dir + "/" + @@story_dir + "/" + storyName + ".jpg"

            file = File.open(storyFile, "w")
            file << "---"  + "\n"
            file << "title: Section " + idx.to_s + "\n"
            file << "---" + "\n"
            file << "\n"
            file << "# " + LoremIpsum.lorem_ipsum(w: 4) + "\n\n"
            
            file << "![](/jekyll-site/assets/" + storyImg + ")" + "\n\n"
            file << LoremIpsum.lorem_ipsum(w: 500) + "\n"
            genImage(640, 480, 'section-image-'+ idx.to_s, storyImg)
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
        dpiFactor = dpi / 100
        if verbose
            text = Draw.new
            text.font_family = 'tahoma'

            text.pointsize = w / 17 *  dpiFactor
            text.gravity = CenterGravity
            text.annotate(sample, 0,0,0, -w / 8 * dpiFactor, "/assets/"+out) {
                self.fill = 'black'
            }
            text.pointsize = w / 17  * dpiFactor
            #text.gravity = NorthGravity
            text.annotate(sample, 0,0,0, w / 8 * dpiFactor, "Taille: "+size) {
                self.fill = 'black'
            }
            text.pointsize = w / 10  * dpiFactor
            #text.gravity = CenterGravity
            text.annotate(sample, 0,0,0,0, msg) {
                self.fill = 'black'
            }
        end
        sample.write(out) {
            self.quality = 75
            self.compression = JPEG2000Compression
        }
    end

    def genImageSet(sizes, dpis, dir = ".", name = sample, verbose=false, msg = nil, src = nil)
        sizes.each do |size|
            dpis.each do |dpi|
                outFile = dir + "/" + name + "-" + size[0].to_s + "-" + dpi.round.to_s + ".jpg"
                genImage(size[0], size[1], dpi, outFile, verbose, msg, src)
            end
        end
    end

    def genHomeImages()
        sizes = [[1200, 1000], [1000, 1000], [800, 800], [600, 800], [400, 600]]
        dpis = [100.0, 200.0, 300.0]
        genImageSet(sizes, dpis, "img/home", "parallax-1", true, "Image 1")
        genImageSet(sizes, dpis, "img/home", "parallax-2", true, "Image 2")
    end

end

sample = Sample.new

sample.genHomeImages()
#sample.genPosts(22)
#sample.genTasks
#sample.genStory
#sample.gentAlbums()