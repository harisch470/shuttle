module Shuttle
  class Hook
    def initialize(deploy)
      @deploy = deploy
    end

    def run(commands, allow_failures=false)
      [commands].flatten.compact.uniq.each do |cmd|
        execute(cmd, allow_failures)
      end
    end

    private

    def execute(cmd, allow_failures)
      @deploy.log %{Executing "#{cmd.strip}"}

      command = cmd

      if @deploy.ssh.directory_exists?(@deploy.release_path)
        command = "cd #{@deploy.release_path} && #{command}"
      end

      result = @deploy.ssh.run(command)

      if result.failure? && allow_failures == false
        @deploy.error("Failed: #{result.output}")
      else
        if !result.output.empty?
          @deploy.stream_output(result.output)
        end
      end
    end
  end
end