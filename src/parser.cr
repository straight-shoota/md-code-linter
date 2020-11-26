module MdCode::Parser
  def self.parse(source, dest, &formatter : (CodeBlock, IO) ->)
    parse(source, dest, formatter)
  end

  def self.parse(source, dest, formatter)
    expected_end : String? = nil
    language : String? = nil
    metadata : String? = nil
    start_line = 0
    buffer = String::Builder.new
    line_number = 0
    source.each_line(chomp: false) do |line|
      line_number += 1
      if expected_end
        if line.rstrip == expected_end
          code_block = CodeBlock.new(buffer.to_s, language, metadata, start_line)
          formatter.call(code_block, dest)
          buffer = String::Builder.new
          expected_end = nil
          language = nil
          metadata = nil
          dest << line
        else
          buffer << line
        end
      elsif line.starts_with?(/([ \t]*`{3,})/)
        dest << line
        expected_end = $1
        start_line = line_number
        if line.size > expected_end.size + 1
          line = line[expected_end.size..].strip
          language, _, metadata = line.partition /\s+/
          language = language.presence
          metadata = metadata.presence
        end
      else
        dest << line
      end
    end

    unless expected_end.nil?
      dest << buffer.to_s
      raise "Unexpected end at #{line_number} for code block started at #{start_line}"
    end
  end
end

struct MdCode::CodeBlock
  getter start_line
  getter source
  getter language
  getter metadata

  def initialize(@source : String, @language : String? = nil, @metadata : String? = nil, @start_line : Int32? = nil)
  end
end
