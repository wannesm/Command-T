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

require 'vim'
require 'Open3'

module CommandT
  # Calls ctags for the current file.
  class ScannerTags
    class FileLimitExceeded < ::RuntimeError; end

    def initialize path = Dir.pwd, options = {}
      @path                 = path
      @max_depth            = options[:max_depth] || 15
      @max_files            = options[:max_files] || 10_000
      @scan_dot_directories = options[:scan_dot_directories] || false
      @ctags_options        = options[:ctags_options] || ""
	  #@ctags_defoptions     = "--tex-kinds=+s --fields=nks -u -f - "
	  @ctags_defoptions     = "-u -f - " # unordered and to stdout
      @ctags_cmd            = options[:ctags_cmd] || "ctags"
      @separator            = ">-->"
      @colwidth             = options[:ctags_colwidth] || 60
    end

    def paths
      return @paths unless @paths.nil?
      begin
        @paths = []
        @depth = 0
        @files = 0
        add_paths_for_directory @path, @paths
      rescue FileLimitExceeded
      end
      @paths
    end

    def flush
      @paths = nil
    end

    def path= str
      #if @path != str
        #@path = str
        #flush
      #end
      @path = str
      flush
    end

    def separator
      return @separator
    end

  private

    def add_paths_for_directory dir, accumulator
      if @path == nil || !File.exist?(@path)
        return
      end
      cmd = @ctags_cmd + ' ' + @ctags_defoptions + ' ' + @ctags_options + ' ' + @path + ' 2> /tmp/cmdt_ctags.log'
	  #print cmd
      tags = `#{cmd}`
	  #print tags
      if tags == nil
        return
      end
      tags.split("\n").each do |tag|
        #print "tag=#{tag}"
        endfield1 = tag.index("\t")
        field1 = tag[0..endfield1 - 1]
        endfield2 = tag.index("\t", endfield1 + 1)
        endfield3 = tag.index("/", endfield2 + 2)
        field3 = tag[endfield2 + 1..endfield3]
        width = @colwidth - field1.length
        accumulator << field1 + " "*(width > 0 ? width : 0) +  @separator + field3
      end
    end

  end # class ScannerTags
end # module CommandT
