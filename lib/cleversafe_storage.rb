# -*- encoding : utf-8 -*-
module CleversafeStorage

  def cleversafe_write_operation
    cleversafe_init
    self.object_identifier= @vault.create_object(open(self.reference_file))
    logger.info  "cleversafe Write #{self.id} #{self.reference_file} #{self.object_identifier}"
    self.save
  end

  def cleversafe_read_operation
    # I can't get the read api to work so lets take the other approach
    url="#{ENV['OBJECTBENCH_CLEVERSAFE_ENDPOINT']}#{ENV['OBJECTBENCH_CLEVERSAFE_VAULT']}/#{self.object_identifier}"
    logger.info  "Clevesafe Read #{url}"
    resource = RestClient::Resource.new url,
                                        ENV['OBJECTBENCH_CLEVERSAFE_USERNAME'],
                                        ENV['OBJECTBENCH_CLEVERSAFE_PASSWORD']
    download=Tempfile.new('objectbench', ENV['OBJECTBENCH_TMPDIR'] || '/tmp',:encoding => 'ascii-8bit')

    if !self.start.nil?
      options={"Range" => "bytes=#{self.start}-#{self.start+self.size}"}
    else
      options={}
    end

    resource.get(options)  do |resp|
      download.write(resp)
      puts resp.length
    end
    #download.write(resource.get(options))
    # This flushes the io
    download.size
    verified=FileUtils.compare_file(self.reference_file,download.path)
    # And this deletes the file
    download.close
    logger.info  "Clevesafe Read #{self.id} #{self.object_identifier} #{verified}"
    if ! verified
      raise "File corruption error"
    end
  end

  def cleversafe_seek_read_operation
    logger.info  "Cleversafe Seek Read #{self.id}"
    self.cleversafe_read_operation
    #resource.get({"Range" => "bytes=0-3"})
  end

  def cleversafe_init
    if @vault.nil?
      logger.info  "Null Init"
      @request=Cleversafe::Connection.new(ENV['OBJECTBENCH_CLEVERSAFE_ENDPOINT'],
                                          :user => ENV['OBJECTBENCH_CLEVERSAFE_USERNAME'],
                                          :password=>ENV['OBJECTBENCH_CLEVERSAFE_PASSWORD'] )
      @vault=@request.vault(ENV['OBJECTBENCH_CLEVERSAFE_VAULT'])
    end
  end

end
