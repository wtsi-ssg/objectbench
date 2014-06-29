# -*- encoding : utf-8 -*-
module IrodsStorage


  def run_cmd(cmd)
    logger.info "running #{cmd}"
    run= IO.popen("#{cmd} 2>&1")
    output=run.readlines
    if !output.empty? 
       logger.info "Result #{run.readlines}"
       self.resubmit_error( error: 'No output' , exception_message: 'Cmd_failed' )
    end
  end

  def irods_write_operation
    irods_init
    logger.info  "Irods Write #{self.id}"
    self.object_identifier="#{ENV['OBJECTBENCH_IRODS_PREFIX']}#{SecureRandom.uuid}"
    run_cmd("iput -R #{ENV['OBJECTBENCH_IRODS_RESOURCE']} #{self.reference_file} #{self.object_identifier}")
    self.save
    
  end

  def irods_read_operation(download)
    irods_init
    # We steal the path here which is evil however...
    path=download.path
    download.close
    download.unlink   # deletes the temp file
    run_cmd("iget  #{self.object_identifier} #{path}")
    logger.info  "Irods Read #{self.id}"
  end

  def irods_seek_read_operation
    irods_init
    logger.info  "Irods Seek Read #{self.id}"
  end

  def irods_init
    if @irods_init.nil?
      logger.info  "Irods Init"
      #run_cmd("imkdir -p #{ENV['OBJECTBENCH_IRODS_PREFIX']}")
      @irods_init="done"
    end
  end

end
