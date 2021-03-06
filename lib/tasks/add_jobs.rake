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

def self.add_single_job_write (options={})
  job=Job.new(:operation =>"Write",
              :reference_file =>options[:file],
              :storage_type=>options[:storage_type],
              :length =>options[:length],  
              :tag =>options[:tag], )
  job.save
  job.enqueue(job)
end

def self.add_single_full_read_job(options={})
  job=Job.new(:operation =>"Read",
              :reference_file =>options[:file],
              :length =>options[:length],
              :storage_type=>options[:storage_type],
              :object_identifier=>options[:object_identifier],
              :tag =>options[:tag], )
  job.save
  job.enqueue(job)
end

def self.add_single_partial_read_job(options={})
  job=Job.new(:operation =>"SeekRead",
              :reference_file =>options[:file],
              :size =>options[:size],
              :start =>options[:start],
              :storage_type=>options[:storage_type],
              :object_identifier=>options[:object_identifier],
              :tag =>options[:tag], )
  job.save
  job.enqueue(job)
end

def self.object_to_read(options={})
  timestamp=options[:timestamp] || Time.now.to_f.to_s
  tag=options[:tag]|| "Default_tag"
  jobs=Job.where( "work_ends < '#{timestamp}' and tag='#{tag}' and  object_identifier IS NOT NULL" )
  if jobs.nil? 
    raise "No objects to read 'work_ends < #{timestamp}' and tag='#{tag}'"
  end
  return jobs.sample
end

def self.choose_size(histogram)
  sum = 0
  histogram.each { |a| sum+=a }
  position=rand(1..sum)
  location=0
  #puts histogram.inspect
  while !histogram[location].nil? && position>histogram[location]
    position-=histogram[location]
    location+=1
  end
  #histogram[location]-=1
  return location,rand(10**location..10**(location+1))-1,histogram
end

def self.choose_work(workload)
  max=0
  workload.each { |a| max+=a }
  position=rand(1..max)
  location=0
  while !workload[location].nil? && position>workload[location]
    position-=workload[location]
    location+=1
  end
  workload[location]-=1
  case location
  when 0
    return :write,workload
  when 1
    return :read,workload
  when 2 
    return :partial_read,workload
  end
end

desc "Write workload generator, these can be used later for the mixed/read test,uses OBJECTBENCH_INITAL_DISTRIBUTION,OBJECTBENCH_INITAL_FILES,OBJECTBENCH_SYSTEM_UNDER_TEST,OBJECTBENCH_TAG"
task :add_initial_writes => :environment  do
  if ! ENV['OBJECTBENCH_SEED'].nil?
     srand  ENV['OBJECTBENCH_SEED'].to_i
  else
     srand
  end
  # Original histogram from irods storage
  # 7500,9000,6000,9898,51247,35313,12200,2536,11923,10232,267
  histogram=ENV['OBJECTBENCH_INITAL_DISTRIBUTION'] || "86, 103, 68, 113, 588, 405, 140, 29, 137, 117, 3" 
  distribution=histogram.split(",").map { |s| s.to_i }
  if ! ENV['OBJECTBENCH_INITAL_FILES'].nil?
    files=ENV['OBJECTBENCH_INITAL_FILES'].split(" ")
  end 
  tasks=0
  distribution.each { |a| tasks+=a }
  # create a write job foreach 
  puts "Generating writes"
  for itteration in 1..tasks
    position,length,distribution=choose_size(distribution)
    if ! files[position].nil?
      file=files[position]
      length=File.stat(file).size  
    else
      file=ENV['FILE'] || '/warehouse/isg_wh_scratch01/users/jb23/object_test/7231_1#146.bam'
    end
    add_single_job_write( :file =>file,
                          :storage_type=>ENV['OBJECTBENCH_SYSTEM_UNDER_TEST'] || "Null_Storage",
                          :length =>length,
                          :tag=>ENV['OBJECTBENCH_TAG'] || "Default_tag"  )
  end
end

desc "Mixed workload generator,uses OBJECTBENCH_TEST_WRITE_DISTRIBUTION,OBJECTBENCH_TEST_WORKLOAD_DISTRIBUTION,OBJECTBENCH_INITAL_FILES,OBJECTBENCH_SYSTEM_UNDER_TEST,OBJECTBENCH_TAG,OBJECTBENCH_TAG_READ"
task :load_tests=> :environment  do
  # We want all writes to be completed before now.
  if ! ENV['OBJECTBENCH_SEED'].nil?
    srand  ENV['OBJECTBENCH_SEED'].to_i
  else
    srand
  end
  timestamp=Time.now.to_f.to_s
  histogram_s=ENV['OBJECTBENCH_TEST_WRITE_DISTRIBUTION'] || "86, 103, 68, 113, 588, 405, 140, 29, 137, 117, 3"
  histogram=histogram_s.split(",").map { |s| s.to_i }
  workload_s=ENV['OBJECTBENCH_TEST_WORKLOAD_DISTRIBUTION'] || "60,30,10"
  workload=workload_s.split(",").map { |s| s.to_i }
  # There must be more wirtes to do than the number of writes specified in the workload otherwise the 
  # system will get stuck looking for a write to do when it doesn't knwo what size it would be.
  if ! ENV['OBJECTBENCH_INITAL_FILES'].nil?
    files=ENV['OBJECTBENCH_INITAL_FILES'].split(" ")
  end 
  tasks=0
  workload.each { |a| tasks+=a }
  for itteration in 1..tasks
    type_of_work,workload=choose_work(workload)
    case type_of_work
    when :write
      position,length,dispose=choose_size(histogram)
      if ! files[position].nil?
        file=files[position]
        length=File.stat(file).size  
      else
        file=ENV['FILE'] || '/warehouse/isg_wh_scratch01/users/jb23/object_test/7231_1#146.bam'
      end 
      add_single_job_write( :file =>file,
                            :storage_type=>ENV['OBJECTBENCH_SYSTEM_UNDER_TEST'] || "Null_Storage",
                            :length => length,
                            :tag=>ENV['OBJECTBENCH_TAG'] || "Default_tag"  )
    when :read
      object=object_to_read(:timestamp=>timestamp,:tag=>ENV['OBJECTBENCH_TAG_READ'] || "Default_tag" )
      add_single_full_read_job(  :object_identifier=>object.object_identifier,
                                 :storage_type=>ENV['OBJECTBENCH_SYSTEM_UNDER_TEST'] || "Null_Storage",
                                 :length =>object.length,
                                 :file =>object.reference_file,
                                 :tag=>ENV['OBJECTBENCH_TAG'] || "Default_tag"  )  
    when :partial_read
      object=object_to_read(:timestamp=>timestamp,:tag=>ENV['OBJECTBENCH_TAG_READ'] || "Default_tag" )
      length=object.length || 0
      size=rand(0..[length,16384].min)
      start=rand(0..[(length-size),0].max)
      add_single_partial_read_job(  :object_identifier=>object.object_identifier,
                                    :storage_type=>ENV['OBJECTBENCH_SYSTEM_UNDER_TEST'] || "Null_Storage",
                                    :size =>size,
				    :start =>start,
                                    :file =>object.reference_file,
                                    :tag=>ENV['OBJECTBENCH_TAG'] || "Default_tag"  )

    end
  end
end 
end
