require 'spec'
require File.dirname(__FILE__) + "/rubypond"
include Rubypond

describe "an empty score" do
  before do
    @expected = (
<<-LILYPOND
\\version "2.13.16"
\\include "english.ly"

\\score {
}
LILYPOND
    ).strip
  end
  it "should contain version and include statements, and an empty score block" do
    score().should == @expected
  end
end

describe "a score with one staff" do
  before do
    @expected = (
<<-LILYPOND
\\version "2.13.16"
\\include "english.ly"

music = {
  c d e f
}

\\score {
  <<
    \\new Staff \\music
  >>
}
LILYPOND
    ).strip
  end
  it "should contain version and include statements, and one staff line" do
    score { c; d; e; f }.should == @expected
  end
end

describe "a score with two staves" do
  before do
    @expected = (
<<-LILYPOND
\\version "2.13.16"
\\include "english.ly"

violin = {
  c d e f
}

cello = {
  g a b c
}

\\score {
  <<
    \\new Staff \\violin
    \\new Staff \\cello
  >>
}
LILYPOND
    ).strip
  end
  it "should contain version and include statements, and two staves" do
    s = score do
      part("violin") { c; d; e; f; }
      part("cello") { g; a; b; c; }
    end
    s.should == @expected
  end
end

describe "a score with three staves of the same instrument" do
  before do
    @expected = (
<<-LILYPOND
\\version "2.13.16"
\\include "english.ly"

violin = {
  c d e f
}

violina = {
  g a b c
}

violinb = {
  e f g a
}

\\score {
  <<
    \\new Staff \\violin
    \\new Staff \\violina
    \\new Staff \\violinb
  >>
}
LILYPOND
    ).strip
  end
  it "should contain version and include statements, and three correctly named staves" do
    s = score do
      part("violin") { c; d; e; f }
      part("violin") { g; a; b; c }
      part("violin") { e; f; g; a }
    end
    s.should == @expected
  end
end

describe "a score with two doubled instrument parts" do
  before do
    @expected = (
<<-LILYPOND
\\version "2.13.16"
\\include "english.ly"

violin = {
  c d e f
}

viola = {
  g as b c
}

violina = {
  e f g a
}

violaa = {
  bf a g ef
}

\\score {
  <<
    \\new Staff \\violin
    \\new Staff \\viola
    \\new Staff \\violina
    \\new Staff \\violaa
  >>
}
LILYPOND
    ).strip
  end
  it "should contain two instruments with correct name enumeration" do
    s = score do
      part("violin") { c; d; e; f }
      part("viola") { g; as; b; c }
      part("violin") { e; f; g; a }
      part("viola") { bf; a; g; ef }
    end
    s.should == @expected
  end
end
