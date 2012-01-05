class AddProcedureSpecializations < ActiveRecord::Migration
  def change
    create_table :procedure_specializations do |t|
      t.integer :procedure_id
      t.integer :specialization_id
      t.string :ancestry
      t.boolean :mapped, :default => false
      
      t.timestamps
    end
    
    add_index :procedure_specializations, :ancestry
    
    add_column :capacities, :procedure_specialization_id, :integer
    
    add_column :focuses, :procedure_specialization_id, :integer
    
    #migrate the current procedures specialization to the new join table
    Procedure.all.each { 
      |p| ProcedureSpecialization.create(:procedure_id => p.id,
                                         :specialization_id => p.specialization_id,
                                         :mapped => true)
    }
    
    #migrate the current procedures parent to the new join table
    Procedure.all.each {
      |p|
      next if not p.parent
      ps = ProcedureSpecialization.find_by_procedure_id_and_specialization_id( p.id, p.specialization_id )
      parent_ps = ProcedureSpecialization.find_by_procedure_id_and_specialization_id(p.parent.id, p.specialization_id)
      ps.parent = parent_ps
      ps.save
    }
    
    #migrate capacities to point at a procedure_specialization, not procedure (as a capacities specialization can be ambigious otherwise)
    Capacity.all.each {
      |c|
      next if not Procedure.find_by_id(c.procedure_id)
      specialization_id = Procedure.find(c.procedure_id).specialization_id
      ps = ProcedureSpecialization.find_by_procedure_id_and_specialization_id(c.procedure_id, specialization_id)
      c.procedure_specialization_id = ps.id
      c.save
    }
    
    #migrate focuses to point at a procedure_specialization, not procedure (as a focuses specialization can be ambigious otherwise)
    Focus.all.each {
      |f|
      next if not Procedure.find_by_id(f.procedure_id)
      specialization_id = Procedure.find(f.procedure_id).specialization_id
      ps = ProcedureSpecialization.find_by_procedure_id_and_specialization_id(f.procedure_id, specialization_id)
      f.procedure_specialization_id = ps.id
      f.save
    }
    
    #TODO when it all works
    #remove_column :procedures, :specialization_id
    #remove_column :procedures, :ancestry
    #remove_column :capacities, :procedure_id
    #remove_column :focuses, :procedure_id
  end
end
