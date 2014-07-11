objectbench
===========

Objectbench is a relatively simple benchmark/load generator for object stores. Before writing something ourselves we looked at <a href="https://github.com/intel-cloud/cosbench">cosbench</a> and <a href="http://basho.com/riak/">basho</a>, cosbench did not support systems which returned an object identifier. And basho's test system was writtern in Erlang so it would had a significant learning curve for us. Objectbench is written in ruby and uses ActiveRecord as an interface to a persistant store. Redis and resque are used to run worker code. 

Documentation can be found in the <a href="https://github.com/wtsi-ssg/objectbench/wiki">github wiki</a>


