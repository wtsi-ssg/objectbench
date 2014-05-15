# -*- encoding : utf-8 -*-
require 'json'
module WosStorage

  def wos_write_operation
    wos_init
    @http_put.post(File.read(self.reference_file))
    headers=parse_headers(@http_put.header_str)
    self.object_identifier=headers["x-ddn-oid"]
    self.save
    if headers["x-ddn-status"]!="0 ok" then
      raise "Wos system error #{JSON.pretty_generate(headers)}"
    end
  end

  def wos_read_operation(download)
    wos_init
    @http_get.headers["x-ddn-oid"]=self.object_identifier;
    @http_get.perform
    if @http_get.header_str.nil? then
       raise "Wos system error perform failed."
    end
    headers=parse_headers(@http_get.header_str)
    if headers["x-ddn-status"]!="0 ok" then
       raise "Wos system error #{JSON.pretty_generate(headers)}"
    end
    download.write(@http_get.body_str)
  end

  def wos_seek_read_operation
    raise "wos_seek_read_operation not implemented"
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
