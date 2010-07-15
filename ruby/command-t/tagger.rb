# Copyright 2010 Wincent Colaiuta. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'command-t/ext' # CommandT::Matcher
require 'command-t/scanner_tags'

module CommandT
  # Encapsulates a call to ctags (which builds up a list of available tags
  # in the given file) and a Matcher instance (which selects from that list
  # based on a search string).
  class Tagger

    def initialize path = Dir.pwd, options = {}
      # for tags, starting with a dot doesn't mean 'hidden'
      options[:always_show_dot_files] = true
      @scanner = ScannerTags.new path, options
      @matcher = Matcher.new @scanner, options
      # default action is not to sort tags, to have a TOC-like view
      @sort    = options[:ctags_sort] || false
    end

    # Options:
    #   :limit (integer): limit the number of returned matches
    def sorted_matches_for str, options = {}
      options[:sort] = @sort
      @matcher.sorted_matches_for str, options
    end

    def flush
      @scanner.flush
    end

    def path= path
      @scanner.path = path
    end

    def separator
      return @scanner.separator
    end

  end # class Tagger
end # CommandT
