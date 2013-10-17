module MessageAnalyzer
  SKIP_REVIEW_PATTERNS = [
    /#?(skip|no)\s?(code\s?)?review/i,
    /\AMerge/
  ]

  ACCEPT_PATTERN = /accepts?:?(.+)/i

  SHA_PATTERN = /[a-f\d]{6,40}/i

  def skip_review?
    SKIP_REVIEW_PATTERNS.any? { |pattern| message =~ pattern }
  end

  def accepted_shas
    if accept_string = message[ACCEPT_PATTERN]
      tokens = accept_string.split(/[\s;,]+/)
      tokens.uniq.select { |token| token =~ SHA_PATTERN }
    else
      []
    end
  end
end

class C
  def message
    <<-MSG
    Test
    no code review
    accepts: foo,2421451,bbabcb66 bbbc; 71763126
    MSG
  end

  include MessageAnalyzer
end

a = C.new
a.accepted_shas
