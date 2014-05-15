task :display_report => :environment  do
  tag=ENV['OBJECTBENCH_TAG'] || "Default_tag" 
  interval_s=ENV['OBJECTBENCH_INTERVAL'] || "10"
  interval=interval_s.to_i
  start_time=Job.where("tag='#{tag}'").minimum(:work_starts)
  end_time=Job.where("tag='#{tag}'").maximum(:work_ends).to_f
  start_sample=start_time.to_i
  end_sample=start_sample+interval
  bytes_per_second={}
  #compute the bytes per second for each task
  work_to_consider=Job.where("tag =?", tag )
  work_to_consider.each do
    |task|
    duration=task.work_ends.to_f-task.work_starts.to_f
    #Seek reads have a size not a lenght
    size=task.length||task.size
    #puts "duration #{duration} ,id #{task.id},length #{size}"
    bytes_per_second[task.id]=size/duration
  end
  while start_sample < end_time do
    ["Read","Write","SeekRead"].each do
      |operation| 
      # Let us start to move the sliding window
      # the tag makes sure we are only looking at the right run.
      # Start or end of job within window.
      #  ( work_starts >= ? and work_starts < ?) work starts in the window
      #  ( work_ends >= ? and work_ends < ?) work ends in the window
      #  ( work_starts <? and work_ends > ?) work is running all in the window
      work_to_consider=Job.where("tag =? and operation=?  and ( ( work_starts >= ? and work_starts < ?) or ( work_ends >= ? and work_ends < ?) or ( work_starts <? and work_ends > ? ) )" , tag ,operation,start_sample ,end_sample,start_sample,end_sample,start_sample,end_sample )
      # Now some fun for each chunk of work we need to calculate the amount of bytes moved per second for the task
      # Later we can multiple this by how long the task was running in the window
      bytes=0
      work_to_consider.each do
        |task|
        duration=[task.work_ends.to_f,end_sample].min-[task.work_starts.to_f,start_sample].max
        bytes+=(bytes_per_second[task.id]*duration)
      end 
      puts "#{start_sample},#{end_sample},#{operation},#{work_to_consider.size},#{bytes.to_i}"
    end 
    start_sample+=interval
    end_sample+=interval
  end
end
