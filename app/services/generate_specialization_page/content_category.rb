class GenerateSpecializationPage
  class ContentCategory
    include ServiceObject.exec_with_args(
      :specialization,
      :category,
      :items
    )

    def exec
      if category.filterable_on_specialty_pages?
        Filterable.exec(
          specialization: specialization,
          category: category,
          items: items
        )
      else
        Inline.exec(
          specialization: specialization,
          category: category,
          items: items
        )
      end
    end

    class Inline
      include ServiceObject.exec_with_args(
        :specialization,
        :category,
        :items
      )

      def exec
        {
          contentClass: "InlineSpecializationResources",
          props: {
            records: resources
          }
        }
      end

      def resources
        items.map do |resource|
          {
            title: resource.title,
            content: BlueCloth.new(resource.markdown_content).to_html,
            collectionName: resource.sc_category.name.downcase.pluralize,
            id: resource.id
          }
        end
      end
    end

    class Filterable
      include ServiceObject.exec_with_args(
        :specialization,
        :category,
        :items
      )

      def exec
        {
          contentClass: "FilterableSpecializationResources",
          props: {
            records: resources,
            labels: {
              filterSection: "Filter #{category.name.downcase.pluralize}"
            },
            filterValues: {
              subcategories: category.descendants.id_hash{ false }
            },
            filterArrangements: {
              subcategories: category.descendants.order(:name).map(&:id)
            },
            tableHeadings: [
              { label: "Title", key: "TITLE" },
              { label: "Subcategory", key: "SUBCATEGORY" },
              { label: "", key: "FAVOURITE" },
              { label: "", key: "EMAIL_TO_PATIENT" },
              { label: "", key: "PROVIDE_FEEDBACK" }
            ],
            sortConfig: {
              column: "NAME",
              order: "ASC"
            },
            filterVisibility: {
              subcategories: true
            },
            collectionName: category.name.downcase.pluralize
          }
        }
      end

      def resources
        items.map do |resource|
          {
            title: resource.title,
            scCategoryId: resource.sc_category.id,
            collectionName: resource.sc_category.name.downcase.pluralize,
            id: resource.id
          }
        end
      end
    end
  end
end
