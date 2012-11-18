module VocalendarCore
  module ModelLogUtils
    def log(level, *args, &block)
      if block_given?
        logger.__send__(level, *args, &block)
      else
        objinfo = "#{self.class.name} "
        objinfo += new_record? ? "(new)" : "##{id}"
        respond_to?(:name) and objinfo << " (#{name})"
        args[0] = "[#{objinfo}] #{args[0].to_s}"
        logger.__send__(level, *args)
      end
    end
  end
end
