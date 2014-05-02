module NullStorage
  # Null storage has a default read and write speed of 600MB/s
  default_read=629145600
  default_write=629145600

  def null_write_operation
    logger.info  "Null Write #{self.id}"
    sleep_time=self.length/( ENV['OBJECTBENCH_NULL_DRIVER_WRITE'].to_i || default_write )
  end

  def null_read_operation
    puts "Read"
  end

  def null_seek_read_operation
    puts "Seek Read"
  end

end
