#License
#=======
#  Copyright (c) 2014 Genome Research Ltd. 
#
#  Author: James Beal <James.Beal@sanger.ac.uk>
#
#This file is part of Objectbench. 
#
#  Objectbench is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version. 
#  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
#  You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>. 
#
namespace :object_bench do
desc "Ouputs a CSV, Define OBJECTBENCH_TAG to select the run to display, Define OBJECTBENCH_INTERVAL to override the default time interval sampled"
task :display_report => :environment  do
  tag=ENV['OBJECTBENCH_TAG'] || "Default_tag" 
  interval_s=ENV['OBJECTBENCH_INTERVAL'] || "10"
  interval=interval_s.to_i
  start_time=Job.where("tag like '#{tag}'").minimum(:work_starts).to_f
  end_time=Job.where("tag like '#{tag}'").maximum(:work_ends).to_f
  start_sample=start_time.to_i
  end_sample=start_sample+interval
  bytes_per_second={}
  #compute the bytes per second for each task
  work_to_consider=Job.where("tag  like ? and  error_id is NULL", tag )
  work_to_consider.each do
    |task|
    duration=task.work_ends.to_f - task.work_starts.to_f
    #Seek reads have a size not a lenght
    size=task.length||task.size
    #puts "duration #{duration} ,id #{task.id},length #{size}"
    bytes_per_second[task.id]=size/duration
  end
  # Print header
  puts "tag,start_time,end_time,operation,errors,IOPB,bytes,duration"
  operations=Job.where("tag like '#{tag}'").select(:operation).map(&:operation).uniq
  # find the relevant errors
  while start_sample < end_time do
    operations.each do 
      |operation| 
      # Let us start to move the sliding window
      # the tag makes sure we are only looking at the right run.
      # Start or end of job within window.
      #  ( work_starts >= ? and work_starts < ?) work starts in the window
      #  ( work_ends >= ? and work_ends < ?) work ends in the window
      #  ( work_starts <? and work_ends > ?) work is running all in the window
      work_to_consider=Job.where("tag like ? and operation=?  and error_id is NULL and ( ( work_starts >= ? and work_starts < ?) or ( work_ends >= ? and work_ends < ?) or ( work_starts <? and work_ends > ? ) )" , tag ,operation,start_sample ,end_sample,start_sample,end_sample,start_sample,end_sample )
      failed_jobs=Job.where("tag like ? and operation=?  and error_id is NOT NULL and ( ( work_starts >= ? and work_starts < ?) or ( work_ends >= ? and work_ends < ?) or ( work_starts <? and work_ends > ? ) )" , tag ,operation,start_sample ,end_sample,start_sample,end_sample,start_sample,end_sample ) 
      unknown_failure=0
      # Now some fun for each chunk of work we need to calculate the amount of bytes moved per second for the task
      # Later we can multiple this by how long the task was running in the window
      bytes=0
      total_duration=0
      work_to_consider.each do |task|
        if task.work_ends.nil?
          unknown_failure=unknown_failure+1
          next
        end
        if task.work_starts.nil?
          unknown_failure=unknown_failure+1
          next
        end
        duration=[task.work_ends.to_f,end_sample].min - [task.work_starts.to_f,start_sample].max
        total_duration=total_duration+duration
        if task.work_ends.to_f < end_sample and task.work_starts.to_f > start_sample 
          bytes+=task.length||task.size
        else
          bytes+=(bytes_per_second[task.id]*duration)
        end
      end 
      # And now condsider the errors
      # I have a deep suspicon that if I knew what I was doing there is a good active record way to do this.
      #
      # Unknown failures appear everywhere.
      number_of_errrors=unknown_failure
      failed_jobs.each do |task|
        error=Error.find(task.error_id)
        if error.reported_at.to_i >= start_sample and  error.reported_at.to_i < end_sample 
          number_of_errrors=number_of_errrors+1
        end
      end
      puts "#{tag},#{start_sample},#{end_sample},#{operation},#{number_of_errrors},#{work_to_consider.size},#{bytes.to_i},#{total_duration}"
    end 
    start_sample+=interval
    end_sample+=interval
  end
end

desc "Display historic errors"
task :display_historic_errors =>  :environment  do
  tag=ENV['OBJECTBENCH_TAG'] || "Default_tag"
  puts "Searching #{tag}"
  puts"failed_at,job_id,exception,error,backtrace,worker,reference_file,operation,length,work_starts"
  errored_jobs=Job.where("tag like '#{tag}' and error_id is not NULL")
  errored_jobs.each do |job|
    error=Error.find(job.error_id)
    puts "#{error.reported_at},#{job.id},#{error.exception},#{error.error},#{error.backtrace},#{error.worker},#{job.reference_file},#{job.operation},#{job.length},#{job.work_starts}".gsub!(/\n/,' ')
  end
end

desc "Ouputs statistics, Define OBJECTBENCH_TAG to select the run to display"
task :stats_report => :environment  do
  puts "operation,size,errors,n,mean,standard deviation\n" 
  tag=ENV['OBJECTBENCH_TAG'] || "Default_tag" 
  operations=Job.where("tag like '#{tag}'").select(:operation).map(&:operation).uniq
  operations.each do
    |operation|
    sizes=Job.where("tag  like ? AND operation= ?", tag , operation ).select(:length).map(&:length).uniq
    sizes.each do 
      |size|
      errors = Job.where("tag  like ? and  error_id is NOT NULL AND operation= ? and length= ?", tag , operation, size )
      sum=0
      sq_sum=0
      work_to_consider=Job.where("tag  like ? and  error_id is NULL AND operation= ? and length =? and work_ends>work_starts", tag ,operation, size )
      n=work_to_consider.count
      work_to_consider.each do
        |task|
        sum=sum+(task.work_ends.to_f - task.work_starts.to_f)
        sq_sum=sq_sum+((task.work_ends.to_f - task.work_starts.to_f)**2)
      end
      mean=sum/n
      puts "#{operation},#{size},#{errors.count}, #{n},  #{mean}, #{ ((sq_sum/n)-(mean**2))**0.5 }"
    end
  end
end

end

