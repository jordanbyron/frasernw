# Returns stats about total number of Specialists/Clinics/AreasofPractice/by specialty
# e.g. Metrics::EntityMetrics.new(Division.all, "reports/dialogue").to_csv_file
module Metrics
  class EntityMetrics
    attr_accessor :table
    attr_reader   :folder_path

    def initialize(divisions = [], folder_path)
      @divisions = Array.wrap(divisions)
      @folder_path = folder_path

      if @divisions.any? && (@divisions != Division.all)
        @division_label =
          @divisions.map{|d| d.name.gsub(/\s+/, "")}.join("_").gsub(/\W/, '-')
        @specialists = Specialist.in_divisions(@divisions)
        @clinics = Clinic.in_divisions(@divisions)
        @procedures =
          [@specialists + @clinics].
            flatten.
            inject([]){ |memo, s| memo.concat( s.procedures ) }.
            uniq
        @specializations =
          Specialization.
            all.
            reject{ |s|
              [
                s.specialists.in_divisions(@divisions) +
                s.clinics.in_divisions(@divisions)
              ].
              flatten.
              length == 0
            }
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
          @procedures.reject{ |p|
            !p.procedure_specializations.first.focused?
          }.length,
          @procedures.reject{ |p|
            !p.procedure_specializations.first.nonfocused?
          }.length,
          Procedure.all.reject{ |p|
            !p.procedure_specializations.first.assumed_specialist?
          }.length,
          Procedure.all.reject{ |p|
            !p.procedure_specializations.first.assumed_clinic?
          }.length
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
          "Retired",
          "Deceased"
        ],
        [
          "Specialists",
          @specialists.length,
          @specialists.select{|s| s.responded_to_survey?}.length,
          @specialists.select{|s| s.surveyed && !s.responded_to_survey?}.length,
          @specialists.reject{|s| s.completed_survey? }.length,
          @specialists.select{|s| s.available? && !s.has_offices? }.length,
          @specialists.reject{|s| !s.moved_away?}.length,
          @specialists.reject{|s| !s.retired?}.length,
          @specialists.reject{|s| !s.deceased?}.length
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
          @clinics.select{|s| s.responded_to_survey?}.length,
          @clinics.select{|s| s.surveyed && !s.responded_to_survey?}.length,
          @clinics.reject{|s| s.completed_survey? }.length
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
          "Retired",
          "Deceased"
        ]
      ] + @specializations.inject([]) do |memo, specialization|
        @specialization_specialists = specialization.specialists & @specialists
        memo  << [
          specialization.name,
          @specialization_specialists.length,
          @specialization_specialists.select{|s| s.responded_to_survey?}.length,
          @specialization_specialists.select{|s| s.surveyed && !s.responded_to_survey?}.length,
          @specialization_specialists.reject{|s| s.completed_survey? }.length,
          @specialization_specialists.select{|s| s.available? && !s.has_offices? }.length,
          @specialization_specialists.reject{|s| !s.moved_away?}.length,
          @specialization_specialists.reject{|s| !s.retired?}.length,
          @specialization_specialists.reject{|s| !s.deceased?}.length
        ]
      end

    end

    def to_csv_file
      FileUtils.ensure_folder_exists("#{folder_path}/entitymetrics")
      CSVReport::Service.new(
        "#{folder_path}/entitymetrics/#{@division_label}_entity_metrics-"\
        "#{DateTime.now.to_date.iso8601}.csv",
        (self.csv_stamp + self.data)
      ).exec
    end

  end
end
