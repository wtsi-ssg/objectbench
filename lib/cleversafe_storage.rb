# -*- encoding : utf-8 -*-
module CleversafeStorage

  def cleversafe_write_operation
    cleversafe_init
    self.object_identifier= @vault.create_object(open(self.reference_file))
    logger.info  "cleversafe Write #{self.id} #{self.reference_file} #{self.object_identifier}"
    self.save
  end

  def cleversafe_read_operation(download)
    # I can't get the read api to work so lets take the other approach
    # And another as this doesn't buffer, but pulls it all in to memory
    url="#{ENV['OBJECTBENCH_CLEVERSAFE_ENDPOINT']}#{ENV['OBJECTBENCH_CLEVERSAFE_VAULT']}/#{self.object_identifier}"
    http_get=Curl::Easy.new("#{url}")
    http_get.http_auth_types = :basic
    http_get.username = ENV['OBJECTBENCH_CLEVERSAFE_USERNAME']
    http_get.password = ENV['OBJECTBENCH_CLEVERSAFE_PASSWORD']

    logger.info  "Clevesafe Read #{url}"
    if !self.start.nil?
      http_get.headers["Range"]= "bytes=#{self.start}-#{self.start+self.size-1}"
    end
    old_on_body = http_get.on_body do |data|
                       result = old_on_body ?  old_on_body.call(data) : data.length
                       download << data if result == data.length
                       result
                  end
    http_get.on_failure { self.resubmit_error( error: "Cleversafe general failure error NOT ok , #{Time.now.to_f}" , exception_message: 'Read_failed' ) }
    http_get.perform
    if http_get.header_str.nil? then
       self.resubmit_error( error: "Cleversafe system error perform failed , #{Time.now.to_f}" , exception_message: 'Read_failed' )
    end
  end

  def cleversafe_seek_read_operation(download)
    logger.info  "Cleversafe Seek Read #{self.id}"
    self.cleversafe_read_operation(download)
  end

  def cleversafe_init
    if @vault.nil?
      logger.info  "Cleversafe Init"
      @request=Cleversafe::Connection.new(ENV['OBJECTBENCH_CLEVERSAFE_ENDPOINT'],
                                          :user => ENV['OBJECTBENCH_CLEVERSAFE_USERNAME'],
                                          :password=>ENV['OBJECTBENCH_CLEVERSAFE_PASSWORD'] )
      @vault=@request.vault(ENV['OBJECTBENCH_CLEVERSAFE_VAULT'])
    end
  end

end
