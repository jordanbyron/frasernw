module GenerateHistory
  class ScItem
    include Annotations
    include AnonymousCreation

    def exec
      [ creation ] + annotations
    end
  end
end
