objectbench
===========

Objectbench is a relatively simple benchmark/load generator for object stores. Before writing something ourselves we looked at <a href="https://github.com/intel-cloud/cosbench">cosbench</a> and <a href="http://basho.com/riak/">basho</a>, cosbench did not support systems which returned an object identifier. And basho's test system was writtern in Erlang so it would had a significant learning curve for us. Objectbench is written in ruby and uses ActiveRecord as an interface to a persistant store. Redis and resque are used to run worker code. 

Documentation can be found in the <a href="https://github.com/wtsi-ssg/objectbench/wiki">github wiki</a>

License
=======
Copyright (c) 2014 Genome Research Ltd. 

Author: James Beal <James.Beal@sanger.ac.uk>

This file is part of Objectbench. 

Objectbench is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 

You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>. 
