class RemovePediatricFromSubSpecialties < ActiveRecord::Migration
  def change
    Procedure.all.reject{ |p| !p.name.starts_with? 'Pediatric ' }.reject{ |p| p.procedure_specializations.map{ |ps| ps.parent.blank? }.include? true}.each do |procedure|
      procedure.update_attributes( :name => procedure.name.sub('Pediatric ', '').capitalize_first_letter )
    end
  end
end
