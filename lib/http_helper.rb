# -*- encoding : utf-8 -*-
module HttpHelper
  def parse_headers(headers)
    # We may migrate this in to a helper
    # Transform a sting with a set of key pair values ( each pair delimited by \r\n ) and each pair of numbers delimited by a :
    results = Hash.new
    headers.split(/\r\n/).inject(Hash.new{|h,k|h[k]=[]}) do |h, s|
      k,v = s.split(/: /)
      # The first line is the return code eg 200, we can get a t this in other ways so skip it as we have no key to store it in
      next if v.nil?  or k.nil?
      results[k] = v
    end
   return results
  end
end
