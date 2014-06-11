# -*- encoding : utf-8 -*-
module IrodsStorage

  def irods_write_operation
    logger.info  "Irods Write #{self.id}"
    self.object_identifier=SecureRandom.uuid 
    self.save
  end

  def irods_read_operation(ignore)
    logger.info  "Irods Read #{self.id}"
  end

  def irods_seek_read_operation
    logger.info  "Irods Seek Read #{self.id}"
  end

  def irods_init
    logger.info  "Irods Init"
  end

end
