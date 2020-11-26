#require "markd"
#require "./code-renderer"
require "./formatter"
require "./parser"

#options = Markd::Options.new
#document = Markd::Parser.parse(source, options)

formatter = MdCode::Formatter.new
formatter.context_filename = ARGV[0]

#renderer = MdCode::CodeRenderer.new(formatter, options)
#result = renderer.render(document)

result = String.build do |dest|
  File.open(ARGV[0], "r") do |source|
    MdCode::Parser.parse(source, dest, ->formatter.format(MdCode::CodeBlock, IO))
  rescue exc
    STDERR.puts "Error in #{formatter.context_filename}"
    exc.to_s(STDERR)
    STDERR.puts
  end
end

if ARGV[1]? == "-i"
  File.write(ARGV[0], result)
else
  puts result
end
