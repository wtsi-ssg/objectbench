#License
#=======
#  Copyright (c) 2014 Genome Research Ltd. 
#
#  Author: James Beal <James.Beal@sanger.ac.uk>
#
#This file is part of Objectbench. 
#
#  Objectbench is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version. 
#  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
#  You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>. 
#
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
