require "log4r"
require 'vagrant/util/experimental'
require 'vagrant/action/builtin/before_trigger'
require 'vagrant/action/builtin/after_trigger'

module Vagrant
  module Action
    # The action warden is a middleware which injects itself between
    # every other middleware, watching for exceptions which are raised
    # and performing proper cleanup on every action by calling the `recover`
    # method. The warden therefore allows middlewares to not worry about
    # exceptional events, and by providing a simple callback, can clean up
    # in any erroneous case.
    #
    # Warden will "just work" behind the scenes, and is not of particular
    # interest except to those who are curious about the internal workings
    # of Vagrant.
    class Warden
      attr_accessor :actions, :stack

      def initialize(actions, env)
        if Vagrant::Util::Experimental.feature_enabled?("typed_triggers")
          if env[:trigger_env]
            @env = env[:trigger_env]
          else
            @env = env[:env]
          end

          ui = Vagrant::UI::Prefixed.new(@env.ui, "vargant")
          @triggers = Vagrant::Plugin::V2::Trigger.new(@env, @env.vagrantfile.config.trigger, nil, ui)
        end

        @stack      = []
        @actions    = actions.map { |m| finalize_action(m, env) }.flatten
        @logger     = Log4r::Logger.new("vagrant::action::warden")
        @last_error = nil
      end

      def call(env)
        return if @actions.empty?

        begin
          # Call the next middleware in the sequence, appending to the stack
          # of "recoverable" middlewares in case something goes wrong!
          raise Errors::VagrantInterrupt if env[:interrupted]
          action = @actions.shift
          @logger.info("Calling IN action: #{action}")
          @stack.unshift(action).first.call(env)
          raise Errors::VagrantInterrupt if env[:interrupted]
          @logger.info("Calling OUT action: #{action}")
        rescue SystemExit
          # This means that an "exit" or "abort" was called. In these cases,
          # we just exit immediately.
          raise
        rescue Exception => e
          # We guard this so that the Warden only outputs this once for
          # an exception that bubbles up.
          if e != @last_error
            @logger.error("Error occurred: #{e}")
            @last_error = e
          end

          env["vagrant.error"] = e

          # Something went horribly wrong. Start the rescue chain then
          # reraise the exception to properly kick us out of limbo here.
          recover(env)
          raise
        end
      end

      # We implement the recover method ourselves in case a Warden is
      # embedded within another Warden. To recover, we just do our own
      # recovery process on our stack.
      def recover(env)
        @logger.info("Beginning recovery process...")

        @stack.each do |act|
          if act.respond_to?(:recover)
            @logger.info("Calling recover: #{act}")
            act.recover(env)
          end
        end

        @logger.info("Recovery complete.")

        # Clear stack so that warden down the middleware chain doesn't
        # rescue again.
        @stack.clear
      end

      # A somewhat confusing function which simply initializes each
      # middleware properly to call the next middleware in the sequence.
      def finalize_action(action, env)
        klass, args, block = action

        # Default the arguments to an empty array. Otherwise in Ruby 1.8
        # a `nil` args will actually pass `nil` into the class.
        args ||= []

        if klass.is_a?(Class)
          # A action klass which is to be instantiated with the
          # app, env, and any arguments given

          # We wrap the action class in two Trigger method calls so that
          # action triggers can fire before and after each given action in the stack.
          klass_name = klass.name.to_sym
          [Vagrant::Action::Builtin::BeforeTriggerAction.new(self, env,
                                                             klass_name,
                                                             @triggers),
           klass.new(self, env, *args, &block),
           Vagrant::Action::Builtin::AfterTriggerAction.new(self, env,
                                                            klass_name,
                                                            @triggers)]
        elsif klass.respond_to?(:call)
          # Make it a lambda which calls the item then forwards
          # up the chain
          lambda do |e|
            klass.call(e)
            self.call(e)
          end
        else
          raise "Invalid action: #{action.inspect}"
        end
      end
    end
  end
end
