module Metrics
  class EntityMetrics
    attr_accessor :table
    def initialize(divisions = [])
      @divisions = Array.wrap(divisions)

      if @divisions.any? && (@divisions != Division.all)
        @division_label = @divisions.map{|d| d.name.gsub(/\s+/, "")}.join("_").gsub(/\W/, '-')
        @specialists = Specialist.in_divisions(@divisions)
        @clinics = Clinic.in_divisions(@divisions)
        @procedures = [@specialists + @clinics].flatten.inject([]){ |memo, s| memo.concat( s.procedures ) }.uniq
        @specializations = Specialization.all.reject{ |s| [s.specialists.in_divisions(@divisions) + s.clinics.in_divisions(@divisions)].flatten.length == 0 }
        @hospitals = Hospital.in_divisions(@divisions)
      else
        @division_label = "All-Divisions"
        @specialists = Specialist.all
        @clinics = Clinic.all
        @procedures = Procedure.all
        @specializations = Specialization.all
        @hospitals = Hospital.all
      end
    end

    def csv_stamp
  [[@division_label],
  ["Pathways Entity Statistics"],
  ["Generated on #{DateTime.now}"]]
    end

    def data


      [
        [
          "",
          "Total"
        ],
        [
          "Specialties",
          @specializations.length
        ],
        [
          ""
        ],
        [
          "",
          "Total Focused & Non Focused",
          "Focused",
          "Non Focused",
          "Assumed for Specialists",
          "Assumed for Clinics"
        ],
        [
          "Areas of practice",
          @procedures.length,
          @procedures.reject{|p| !p.procedure_specializations.first.focused?}.length,
          @procedures.reject{|p| !p.procedure_specializations.first.nonfocused?}.length,
          Procedure.all.reject{|p| !p.procedure_specializations.first.assumed_specialist?}.length,
          Procedure.all.reject{|p| !p.procedure_specializations.first.assumed_clinic?}.length
        ],
        [
          ""
        ],
        [
          "",
          "Total",
          "Completed Survey",
          "Not Completed Survey",
          "Purposely Not Yet Surveyed",
          "Hospital/Clinic Only",
          "Moved Away",
          "Retired"
        ],
        [
          "Specialists",
          @specialists.length,
          @specialists.reject{|s| !s.responded?}.length,
          @specialists.reject{|s| !s.not_responded?}.length,
          @specialists.reject{|s| !s.purposely_not_yet_surveyed?}.length,
          @specialists.reject{|s| !s.hospital_or_clinic_only?}.length,
          @specialists.reject{|s| !s.moved_away?}.length,
          @specialists.reject{|s| !s.retired?}.length
        ],
        [
          ""
        ],
        [
          "",
          "Total",
          "Completed Survey",
          "Not Completed Survey",
          "Purposely Not Yet Surveyed"
        ],
        [
          "Clinics",
          @clinics.length ,
          @clinics.reject{|s| !s.responded?}.length,
          @clinics.reject{|s| !s.not_responded?}.length,
          @clinics.reject{|s| !s.purposely_not_yet_surveyed?}.length
        ],
        [
          ""
        ],
        [
          "",
          "Total"
        ],
        [
          "Hospitals",
          @hospitals.length
        ],
        [
          ""
        ],
        [
          "Specialists by Specialty"
        ],
        [
          "",
          "Total",
          "Completed Survey",
          "Not Completed Survey",
          "Purposely Not Yet Surveyed",
          "Hospital/Clinic Only",
          "Moved Away",
          "Retired"
        ]
      ] + @specializations.inject([]) do |memo, specialization|
        @specialization_specialists = specialization.specialists & @specialists
        memo  << [
          specialization.name,
          @specialization_specialists.length,
          @specialization_specialists.reject{|s| !s.responded?}.length,
          @specialization_specialists.reject{|s| !s.not_responded?}.length,
          @specialization_specialists.reject{|s| !s.purposely_not_yet_surveyed?}.length,
          @specialization_specialists.reject{|s| !s.hospital_or_clinic_only?}.length,
          @specialization_specialists.reject{|s| !s.moved_away?}.length,
          @specialization_specialists.reject{|s| !s.retired?}.length
        ]
      end

    end

    def to_csv_file
      CSVReport::Service.new("reports/dialogue/entitymetrics/#{@division_label}_entity_metrics.csv", (self.csv_stamp + self.data)).exec
    end

  end
end