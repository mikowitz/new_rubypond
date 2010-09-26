module Rubypond
  module Notes
    def method_missing(m, *a, &b)
      current_part << m.to_s 
    end
  end
end

module Rubypond
  include Notes

  attr_accessor :parts, :enums
  attr_accessor :current_part

  def clear_vars; @parts, @enums = [], {}; end

  def version_and_language; ["\\version \"2.13.16\"", "\\include \"english.ly\""].join("\n"); end

  def music_content
    return nil if parts.empty?
    parts.map do |p|
      @current_part = []
      ["#{p[0]} = {", "  #{p[1].call.join(" ")}", "}"].join("\n")
    end.join("\n\n")
  end

  def score_block
    return "\\score {\n}" if parts.empty?
    [
      "\\score {", "  <<",
      parts.map{|p| "    \\new Staff \\#{p[0]}"},
      "  >>", "}"
    ].flatten.join("\n")
  end

  def part_name_enumerator
    if RUBY_VERSION =~ /1.9/
      klass = Enumerator
    else
      require 'generator' unless ObjectSpace.each_object(Class).find {|o| o.name == "Generator"}
      klass = Generator
    end
    klass.new do |y|
      abc = Array('a'..'z').unshift("")
      count = 0
      loop do
        y.yield abc[count % abc.size]
        count += 1
      end
    end
  end

  def part(name, &block)
    enums[name] ||= part_name_enumerator
    parts << [name + enums[name].next, block]
  end

  def score(&block)
    clear_vars
    if block_given?
      begin
        yield
      rescue
        # nothing important needs to happen here
      ensure
        parts << ["music", block] if parts.empty?
      end
    end
    [
      version_and_language,
      music_content,
      score_block
    ].compact.join("\n\n")
  end

  def build(score_obj)
    File.open(Dir.pwd + "/test.ly", "w") do |f|
      f << score_obj
    end
    system "lilypond test.ly"
  end
end

