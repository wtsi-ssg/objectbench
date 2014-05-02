module GenericOperations
  #require 'digest/md5'
  include NullStorage

  def write_operation
    #Skip over generating the md5sums and compare file to original on way out.
    #digest = Digest::MD5.file(self.reference_file)
    logger.info  "Write #{self.id}"
    self.work_starts=Time.now.to_f
    self.work_attempted
    self.save
    puts self.storage_type
    case self.storage_type
    when "Null_Storage"
      self.null_write_operation
    when "Woz"
      self.Wos_write_operation
    when "CleverSafe"
      self.Cleversafe_write_operation
    else
      raise "Unknown storage type: #{job.storage_type}, jobid #{id}"
    end
    self.work_ends=Time.now.to_f
    self.work_done
    self.save
  end

  def read_operation
    puts "Read"
  end

  def seek_read_operation
    puts "Seek Read"
  end

end
