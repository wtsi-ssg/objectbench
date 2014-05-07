# -*- encoding : utf-8 -*-
module GenericOperations
  #require 'digest/md5'
  include NullStorage
  include CleversafeStorage

  def start_work
    self.work_starts=Time.now.to_f.to_s
    self.work_attempted
    self.save
  end

  def stop_work
    self.work_ends=Time.now.to_f.to_s
    self.work_done
    self.save
  end

  def write_operation
    #Skip over generating the md5sums and compare file to original on way out.
    #digest = Digest::MD5.file(self.reference_file)
    logger.info  "Write #{self.id}"
    self.start_work
    case self.storage_type
    when "Null_Storage"
      self.null_write_operation
    when "Woz"
      self.wos_write_operation
    when "CleverSafe"
      self.cleversafe_write_operation
    else
      raise "Unknown storage type: #{job.storage_type}, jobid #{id}"
    end
    self.stop_work
  end

  def read_operation
    logger.info  "SeekRead #{self.id}"
    self.start_work
    case self.storage_type
    when "Null_Storage"
      self.null_read_operation
    when "Woz"
      self.wos_read_operation
    when "CleverSafe"
      self.cleversafe_read_operation
    else
      raise "Unknown storage type: #{job.storage_type}, jobid #{id}"
    end
    self.stop_work
  end

  def seek_read_operation
    self.start_work
    case self.storage_type
    when "Null_Storage"
      self.null_seek_read_operation
    when "Woz"
      self.wos_seek_read_operation
    when "CleverSafe"
      self.cleversafe_seek_read_operation
    else
      raise "Unknown storage type: #{job.storage_type}, jobid #{id}"
    end
    self.stop_work
  end

  def init
    case self.storage_type
    when "Null_Storage"
      self.null_init
    when "Woz"
      self.wos_init
    when "CleverSafe"
      self.cleversafe_init
    else
      raise "Unknown storage type: #{job.storage_type}, jobid #{id}"
    end
  end

end
