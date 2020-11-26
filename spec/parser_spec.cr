require "../src/parser"

private def parse_code(code)
  codes = [] of MdCode::CodeBlock
  MdCode::Parser.parse(IO::Memory.new(code), IO::Memory.new) do |codeblock|
    codes << codeblock
  end
  codes
end

describe MdCode::Parser do
  describe ".run" do
    describe "parse code block" do
      it "recognizes standard code block" do
        parse_code(<<-MD).map(&.source).should eq ["code\n"]
          Foo
          ```
          code
          ```
          Bar
          MD
      end

      it "recognizes multiple code blocks" do
        parse_code(<<-MD).map(&.source).should eq ["code1\n", "code2\n"]
          Foo
          ```
          code1
          ```

          ```
          code2
          ```
          Bar
          MD
      end

      it "recognizes long-fenced code block" do
        parse_code(<<-MD).map(&.source).should eq ["````\ncode\n"]
          Foo
          `````
          ````
          code
          `````
          Bar
          MD
      end

      it "errors when code is not closed" do
        expect_raises Exception, "Unexpected end" do
          parse_code(<<-MD)
            ```
            MD
        end
      end
    end

    describe "start_line" do
      it "recognizes start line number" do
        parse_code(<<-MD).should eq [MdCode::CodeBlock.new("code\n", start_line: 2)]
          Foo
          ```
          code
          ```
          MD
      end
    end

    describe "language" do
      it "recognizes language" do
        parse_code(<<-MD).should eq [MdCode::CodeBlock.new("code\n", "language", start_line: 1)]
          ```language
          code
          ```
          MD
      end
    end
  end
end
