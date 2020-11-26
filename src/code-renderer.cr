class MdCode::CodeRenderer < Markd::Renderer
  @output_io = String::Builder.new
  @last_output = "\n"

  def initialize(@formatter : Formatter, @options : Markd::Options)
  end

  def render(document : Markd::Node)
    walker = document.walker

    while event = walker.next
      node, entering = event
      case node.type
      when Markd::Node::Type::CodeBlock
        code_block(node, entering)
      else
        # only interested in code blocks
      end
    end
  end

  def code_block(node : Markd::Node, entering : Bool)
    languages = node.fence_language ? node.fence_language.split : [] of String

    lang = languages.first?.presence

    @formatter.format(node.text, lang)
  end
end
