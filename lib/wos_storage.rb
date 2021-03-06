#License
#=======
#  Copyright (c) 2014 Genome Research Ltd. 
#
#    Author: James Beal <James.Beal@sanger.ac.uk>
#
#This file is part of Objectbench. 
#
#   Objectbench is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version. 
#   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
#   You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>. 
#
# -*- encoding : utf-8 -*-
require 'json'
module WosStorage

  def wos_write_operation
    # After lots of swearing, the fact that the wos does not support
    # mutlipart uploads defeats me, I take refuge in the idea that
    # doing the right thing the majority of the time is good enough
    # 268435456 is 2GB in bytes btw
    if self.length > (ENV['OBJECTBENCH_WOS_MAX_IN_MEM'].to_i || 268435456 ) then
      cmd ="curl   --noproxy '*' -X POST --data-binary @#{self.reference_file} -H x-ddn-policy:#{ENV['OBJECTBENCH_WOS_POLICY']} #{ENV['OBJECTBENCH_WOS_ENDPOINT']}cmd/put  -v 2>&1 | grep '< ' | cut -c 3-"
      logger.info "Large file #{cmd}"
      run= IO.popen(cmd)
      headers=parse_headers(run.read)
      logger.info " #{JSON.pretty_generate(headers)}"
    else
      wos_init
      @http_put.post(File.read(self.reference_file))
      headers=parse_headers(@http_put.header_str)
    end
    self.object_identifier=headers["x-ddn-oid"]
    if self.object_identifier.nil? 
       self.resubmit_error( error: "No object_identifier recorded, #{JSON.pretty_generate(headers)}" , exception_message: 'Write_failed' )
    end
    self.save
    if headers["x-ddn-status"]!="0 ok" then
      self.resubmit_error( error: "Wos system error , #{Time.now.to_f},#{JSON.pretty_generate(headers)}" , exception_message: 'Write_failed' )
    end
  end

  def wos_read_operation(download)
    wos_init
    @http_get.headers["x-ddn-oid"]=self.object_identifier;
    if !self.start.nil?
       @http_get.headers["Range"]= "bytes=#{self.start}-#{self.start+self.size-1}"
    else
      @http_get.headers["Range"]= ""
    end

    old_on_body = @http_get.on_body do |data|
                         result = old_on_body ?  old_on_body.call(data) : data.length
                         download << data if result == data.length
                         result
                  end
    @http_get.perform
    if @http_get.header_str.nil? then
       self.resubmit_error( error: "Wos system error perform failed , #{Time.now.to_f}" , exception_message: 'Read_failed' )
    end
    headers=parse_headers(@http_get.header_str)
    if headers["x-ddn-status"]!="0 ok" then
       self.resubmit_error( error: "Wos system error NOT ok , #{Time.now.to_f}" , exception_message: 'Read_failed' )
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
