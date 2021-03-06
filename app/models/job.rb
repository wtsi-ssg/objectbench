#License
#=======
#  Copyright (c) 2014 Genome Research Ltd. 
#
#    Author: James Beal <James.Beal@sanger.ac.uk>
#
#    This file is part of Objectbench. 
#
#      Objectbench is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version. 
#        This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
#          You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>. 
#
# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: jobs
#
#  id                :integer          not null, primary key
#  size              :integer
#  start             :integer
#  length            :integer
#  reference_file    :string(255)
#  operation         :string(255)
#  storage_type      :string(255)
#  start_time        :datetime
#  end_time          :datetime
#  aasm_state        :string(255)
#  tag               :string(255)
#  object_identifier :string(255)
#  work_starts       :string(255)
#  work_ends         :string(255)
#

class Job < ActiveRecord::Base
  has_one :error
  include AASM
  include GenericOperations

  @redis = redis = Redis.new(:host =>ENV["OBJECTBENCH_REDIS_HOST"] , :port =>ENV["OBJECTBENCH_REDIS_PORT"] )
  @queue = :job

      aasm do
        state :pending, :initial => true
        state :starting  # We have attempted to start
        state :complete  # We have finished
        state :error     # Something is amiss :(

        # This happens right before we attempt to work
        event :work_attempted do
          transitions :from => :pending,  :to => :starting
        end

        # We take this transition if an exception occurs
        event :work_error do
          transitions :from => [:starting,:pending], :to => :error
        end

        # When everything goes to plan, we take this transition
        event :work_done do
          transitions :from => :starting,  :to => :complete
        end

      end


  def self.perform(id)
     job=Job.find_by_id(id)
     wait_until_floodgates_open
     case job.operation
      when "Write"
        job.write_operation
      when "Read"
        job.read_operation
      when "SeekRead"
        job.seek_read_operation
      else
       raise "Unknown operation: #{job.operation}, jobid #{id}"
     end
  end

  def self.open_floodgate
    @redis.set(:floodgate, "open")
  end

  def self.close_floodgate
    @redis.set(:floodgate, "closed")
  end

  def self.floodgate
    return @redis.get(:floodgate)
  end

  def self.wait_until_floodgates_open
    while @redis.get(:floodgate) == "closed"
      sleep 1
    end
  end
end

