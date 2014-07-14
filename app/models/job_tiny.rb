#License
#=======
#  Copyright (c) 2014 Genome Research Ltd. 
#
#    Author: James Beal <James.Beal@sanger.ac.uk>
#
#    This file is part of Objectbench. 
#
#      Objectbench is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version. 
#        This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
#          You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>. 
#
class Job_Tiny < Job
    @queue = :job_tiny
    @redis = redis = Redis.new(:host =>ENV["OBJECTBENCH_REDIS_HOST"] , :port =>ENV["OBJECTBENCH_REDIS_PORT"] )
end
