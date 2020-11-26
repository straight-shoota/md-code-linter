class MdCode::Formatter

  class Config
    # include YAML::Serializable

    property default_language : String? = nil
    property languages = Array(LanguageConfig).new
  end

  class LanguageConfig
    # include YAML::Serializable

    property identifiers : Array(String)
    property formatter : String
    property formats_output : Bool

    def initialize(@identifiers, @formatter, @formats_output)
    end
  end

  getter config : Config

  property context_filename : String = "unknown"

  def initialize
    @config = Config.new.tap do |config|
      config.languages << LanguageConfig.new ["crystal", "cr"], "crystal tool format -", true
      config.languages << LanguageConfig.new ["bash", "shell", "sh"], "shellcheck -e SC2148 -", false
      config.languages << LanguageConfig.new ["yaml", "YAML"], "yamllint -", false 
    end
  end

  def format(codeblock : CodeBlock, dest : IO)
    language = codeblock.language || config.default_language

    unless language
      dest << codeblock.source
      return
    end

    config = begin
      config_for(codeblock.language)
    rescue exc
      exc.to_s(STDERR)
      STDERR.puts " at #{context_filename}:#{codeblock.start_line}"
      dest << codeblock.source
      return
    end

    if config.formats_output
      stdout = dest
    else
      stdout = IO::Memory.new
    end

    begin
      run_command(config, codeblock.source, stdout)
      success = true
    rescue err : Error
      STDERR.puts "Error while formatting code block in #{context_filename}:#{codeblock.start_line}"
      err.to_s(STDERR)
      success = false
    end

    if !config.formats_output || !success
      dest << codeblock.source
      STDERR << stdout.to_s if stdout != dest
    end
  end

  def run_command(config, code, dest)
    cmd = config.formatter
    error = IO::Memory.new
    status = Process.run(cmd, shell: true, input: IO::Memory.new(code), output: dest, error: error)
    unless status.success?
      raise Error.new command: cmd, exit_code: status.exit_code, error: error.to_s
    end
  end

  class Error < Exception
    def initialize(@command : String, @exit_code : Int32, @error : String)
    end

    def to_s(io : IO)
      io.puts "formatter #{@command} failed with exit code #{@exit_code}:"
      io << @error
    end
  end

  def config_for(language)
    config.languages.each do |entry|
      if entry.identifiers.includes?(language)
        return entry
      end
    end

    raise "No config for language #{language}"
  end
end
