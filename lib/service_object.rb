class ServiceObject
  def self.exec_with_args(*generator_args)
    Module.new do
      def initialize(args)
        args.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end

      def exec
        raise NotImplementedError
      end

      private

      attr_reader *generator_args

      def self.included(receiver)
        class_methods = Module.new do
          def exec(options = {})
            new(options).exec
          end
        end

        receiver.extend(class_methods)
      end
    end
  end
end
