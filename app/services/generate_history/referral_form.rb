module GenerateHistory
  class ReferralForm
    include Annotations
    include AnonymousCreation

    def exec
      [ creation ] + annotations
    end
  end
end
