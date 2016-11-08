class ProcedureAncestryOptions < ServiceObject
  attribute :procedure_specialization

  def call
    from_tree(procedure_specialization.specialization.arranged_procedure_specializations).
      unshift(["~ No ancestors ~", nil])
  end

  private

  def from_tree(tree)
    tree.inject([]) do |memo, (node, children)|
      if excluded_nodes.include?(node)
        memo
      else
        (memo << [ label(node), node.id ]) + from_tree(children)
      end
    end
  end

  def excluded_nodes
    @excluded_nodes ||=
      if procedure_specialization.new_record?
        []
      else
        procedure_specialization.subtree
      end
  end

  def label(procedure_specialization)
    (procedure_specialization.ancestors << procedure_specialization).
      map(&:procedure_name).
      join(" -> ")
  end
end
