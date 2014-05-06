module NullStorage
  # Null storage has a default read and write speed of 600MB/s
  default_read=629145600
  default_write=629145600

  def null_write_operation
    sleep_time=self.length/( ENV['OBJECTBENCH_NULL_DRIVER_WRITE'].to_i || default_write )
    logger.info  "Null Write #{self.id} waiting #{sleep_time}"
    sleep(sleep_time)
    self.object_id=SecureRandom.uuid 
    self.save
  end

  def null_read_operation
    sleep_time=self.length/( ENV['OBJECTBENCH_NULL_DRIVER_READ'].to_i || default_read )
    logger.info  "Null Read #{self.id} waiting #{sleep_time}"
    sleep(sleep_time)
  end

  def null_seek_read_operation
    sleep_time=self.size/( ENV['OBJECTBENCH_NULL_DRIVER_READ'].to_i || default_read )
    logger.info  "Null Seek Read #{self.id} waiting #{sleep_time}"
    sleep(sleep_time)
  end

end
