def self.add_single_job_write (options={})
  job=Job.new(:operation =>"Write",
              :reference_file =>options[:file],
              :storage_type=>options[:storage_type],
              :length =>options[:length],  
              :tag =>options[:tag], )
  job.save
  Resque.enqueue(Job, job.id)
end

def self.choose_size(histogram)
  sum = 0
  histogram.each { |a| sum+=a }
  position=rand(1..sum)
  location=0
  while !histogram[location].nil? && position>histogram[location]
    position-=histogram[location]
    location+=1
  end
  histogram[location]-=1
  return rand(10**location..10**(location+1))-1,histogram
end


task :add_writes => :environment  do
  # Original histogram from irods storage
  histogram=[7500,9000,6000,9898,51247,35313,12200,2536,11923,10232,267];
  # scale hitsogram
  scaled=histogram.map {|a| a/87 }
  tasks=0
  scaled.each { |a| tasks+=a }
  file=ENV['FILE'] || '/warehouse/isg_wh_scratch01/users/jb23/object_test/7231_1#146.bam'
  # create a write job foreach 
  puts "Generating writes"
  for itteration in 1..tasks
    length,scaled=choose_size(scaled)
    add_single_job_write( :file =>file,
                          :storage_type=>ENV['FILE_TEST'] || "Null_Storage",
                          :length =>ENV['FILE_SIZE'] || length,
                          :tag=>ENV['OBJECTBENCH_TAG'] || "Default_tag"  )
    puts scaled.inspect
  end
end
