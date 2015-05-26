module Analytics
  module Frame
    DEFAULT_FRAME = Analytics::Frame::Default
    SPECIALIZED_FRAMES = {
      users: Analytics::Frame::Users
    }

    def self.exec(options)
      klass_for(options[:metric]).new(options).exec
    end

    def self.klass_for(metric)
      SPECIALIZED_FRAMES[metric] || DEFAULT_FRAME
    end
  end
end
