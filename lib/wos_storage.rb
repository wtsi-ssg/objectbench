# -*- encoding : utf-8 -*-
require 'json'
module WosStorage

  def wos_write_operation
    # After lots of swearing, the fact that the wos does not support
    # mutlipart uploads defeats me, I take refuge in the idea that
    # doing the right thing the majority of the time is good enough
    # 268435456 is 2GB in bytes btw
    if self.length > (ENV['OBJECTBENCH_WOS_MAX_IN_MEM'] || 268435456 ) then
      cmd ="curl   --noproxy '*' -X POST --data-binary @#{self.reference_file} -H x-ddn-policy:#{ENV['OBJECTBENCH_WOS_POLICY']} #{ENV['OBJECTBENCH_WOS_ENDPOINT']}cmd/put  -v 2>&1  | sed -n 's/< x-ddn-oid: //p'"
      logger.info "Large file $cmd"
      run= IO.popen(cmd)
      ident=run.readlines[0] 
      if ident == "" then
        raise "Large wos write failed, #{Time.now.to_f}"
      end
      # this gives us for example
      # "MCNB2oifBiGYrlCRLc-lRlvZuIi_ORa3F6sMCfBE\r\n"
      self.object_identifier=ident
      self.save
      return ;
    end
    wos_init
    @http_put.post(File.read(self.reference_file))
    headers=parse_headers(@http_put.header_str)
    self.object_identifier=headers["x-ddn-oid"]
    self.save
    if headers["x-ddn-status"]!="0 ok" then
      raise "Wos system error , #{Time.now.to_f},#{JSON.pretty_generate(headers)}"
    end
  end

  def wos_read_operation(download)
    wos_init
    @http_get.headers["x-ddn-oid"]=self.object_identifier;
    old_on_body = @http_get.on_body do |data|
                         result = old_on_body ?  old_on_body.call(data) : data.length
                         download << data if result == data.length
                         result
                  end
    @http_get.perform
    if @http_get.header_str.nil? then
       raise "Wos system error perform failed, #{Time.now.to_f}"
    end
    headers=parse_headers(@http_get.header_str)
    if headers["x-ddn-status"]!="0 ok" then
       raise "Wos system error, #{Time.now.to_f}, #{JSON.pretty_generate(headers)}"
    end
    
  end

  def wos_seek_read_operation
    raise "wos_seek_read_operation not implemented, #{Time.now.to_f}"
  end

  def wos_init
    if @http_put.nil? then
      logger.info  "Wos Init"
      @http_put=Curl::Easy.new("#{ENV['OBJECTBENCH_WOS_ENDPOINT']}cmd/put")
      @http_put.headers["x-ddn-policy"]=ENV['OBJECTBENCH_WOS_POLICY']
    end
    if @http_get.nil? then
      @http_get=Curl::Easy.new("#{ENV['OBJECTBENCH_WOS_ENDPOINT']}cmd/get")
      @http_get.headers["x-ddn-policy"]=ENV['OBJECTBENCH_WOS_POLICY']
    end
  end

end
