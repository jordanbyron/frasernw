class ProcedureSweeper < PathwaysSweeper
  observe Procedure

  def expire_self(entity)
    expire_fragment procedure_path(entity)
  end
end