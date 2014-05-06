module CleversafeStorage

  def cleversafe_write_operation
    if @vault.nil?
      cleversafe_init
    end
    self.object_id= @vault.create_object(open('/etc/issue'))
    logger.info  "cleversafe Write #{self.id} #{self.object_id}"
    self.save
  end

  def cleversafe_read_operation
    logger.info  "Clevesafe Read #{self.id}"
  end

  def cleversafe_seek_read_operation
    logger.info  "Cleversafe Seek Read #{self.id}"
  end

  def cleversafe_init
    logger.info  "Null Init"
    @request=Cleversafe::Connection.new("http://216.149.186.77/soh/" , :user => "JM042114", :password=>"JhcyGh41" )
    @vault=@request.vault('JM042114')
  end

end
