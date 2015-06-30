module GenerateHistory
  class ScItem
    include Annotations
    include AnonymousCreation
    include LastUpdated

    def exec
      [ creation, last_updated ] + annotations
    end
  end
end
