# -*- encoding : utf-8 -*-
module WosStorage

  def wos_write_operation
    self.object_identifier=SecureRandom.uuid 
    self.save
  end

  def wos_read_operation(ignore)
  end

  def wos_seek_read_operation
  end

  def wos_init
    logger.info  "Wos Init"
  end

end
