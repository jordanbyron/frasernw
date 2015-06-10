module ClinicsActions
  class Base < ApplicationController
  end

  module GenerateFocus
    def generate_focus(clinic, procedure_specialization, offset)
      focus = clinic.present? ? Focus.find_by_clinic_id_and_procedure_specialization_id(clinic.id, procedure_specialization.id) : nil
      return {
        :mapped => focus.present?,
        :name => procedure_specialization.procedure.name,
        :id => procedure_specialization.id,
        :investigations => focus.present? ? focus.investigation : "",
        :custom_wait_time => procedure_specialization.clinic_wait_time?,
        :waittime => focus.present? ? focus.waittime_mask : 0,
        :lagtime => focus.present? ? focus.lagtime_mask : 0,
        :offset => offset
      }
    end
  end

  # include form metadata
  # include specialist form modifying
  class Edit < Base
    include GenerateFocus

    def call
      def edit
        @is_review = false
        @is_rereview = false
        @clinic = Clinic.find(params[:id])
        while @clinic.clinic_locations.length < Clinic::MAX_LOCATIONS
          puts "location #{@clinic.clinic_locations.length}"
          cl = @clinic.clinic_locations.build
          s = cl.build_schedule
          s.build_monday
          s.build_tuesday
          s.build_wednesday
          s.build_thursday
          s.build_friday
          s.build_saturday
          s.build_sunday
          l = cl.build_location
          l.build_address
          puts "locations #{@clinic.locations.length}"
        end
        @clinic_procedures = []
        @clinic.specializations.each { |specialization|
          @clinic_procedures << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations.count > 1
          @clinic_procedures += ancestry_options( specialization.non_assumed_procedure_specializations_arranged )
        }
        @clinic_specialists = []
        procedure_specializations = {}
        @clinic.specializations.each { |specialization|
          @clinic_specialists << [ "----- #{specialization.name} -----", nil ] if @clinic.specializations.count > 1
          @clinic_specialists += specialization.specialists.collect { |s| [s.name, s.id] }
          procedure_specializations.merge!(specialization.non_assumed_procedure_specializations_arranged)
        }
        focuses_procedure_list = []
        @focuses = []
        procedure_specializations.each { |ps, children|
          if !focuses_procedure_list.include?(ps.procedure.id)
            @focuses << generate_focus(@clinic, ps, 0)
            focuses_procedure_list << ps.procedure.id
          end
          children.each { |child_ps, grandchildren|
            if !focuses_procedure_list.include?(child_ps.procedure.id)
              @focuses << generate_focus(@clinic, child_ps, 1)
              focuses_procedure_list << child_ps.procedure.id
            end
            grandchildren.each { |grandchild_ps, greatgrandchildren|
              if !focuses_procedure_list.include?(grandchild_ps.procedure.id)
                @focuses << generate_focus(@clinic, grandchild_ps, 2)
                focuses_procedure_list << grandchild_ps.procedure.id
              end
            }
          }
        }
        render :layout => 'ajax' if request.headers['X-PJAX']
      end
    end
  end
end
