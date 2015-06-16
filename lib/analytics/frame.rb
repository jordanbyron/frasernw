module Analytics
  module Frame
    def self.exec(options)
      Analytics::Frame::Default.new(options).exec
    end
  end
end
