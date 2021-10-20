#!/usr/bin/ruby

#
# Original filename: diff2html.rb
#
# Description: Transform a unified recursive diff from STDIN to a
#              coloured side-by-side HTML page on STDOUT.
#
# Author: Dave Burt <dave (at) burt.id.au>
#
# Created: 15 Oct 2004
#
# Last modified: 24 Nov 2004
#
# Legal: Provided as is. Use at your own risk.
#        Unauthorized copying not disallowed. Credit's appreciated if you use my code.
#        I'd appreciate seeing any modifications you make to it.
#



#
# A unified diff comparison between two files (two versions of a file)
# A FileDiff can have many Hunks
#
class FileDiff
	attr_reader :left_file, :right_file, :hunks, :left_date, :right_date, :diff_command
	
	def initialize(diff_string)
		line = diff_string.shift
		if /^diff / === line
			@diff_command = line
			line = diff_string.shift
		end
		case line
		when /^Binary files (.+) and (.+) differ/
			@left_file = $1
			@right_file = $2
		when /^--- /
			#--- backups\20040818p\_db\supervisor_.mdb.txt	Mon Sep 27 16:38:54 2004
			#+++ .\pay\_db\supervisor_.mdb.txt	Wed Oct 13 09:57:02 2004
			lines = [line, diff_string.shift]
			lines = lines.map {|ln| ln.split(' ', 3)}
			@left_file = lines[0][1]
			@left_date = lines[0][2]
			@right_file = lines[1][1]
			@right_date = lines[1][2]
			@hunks = []
			while /^@@ / === diff_string[0]
				hunks << Hunk.new(diff_string)
			end
		else
			raise ArgumentError.new('Unrecognized diff. Currently handles only unified (diff -u) format.' +
				"\nGot: #{line}Expected: Binary files... or ---...")
		end
	end
	
	def to_s(style = :diff)
		case style
		when :diff
			(diff_command ? diff_command : '') +
			case binary?
				when true
					"Binary files #{left_file} and #{right_file} differ"
				else
					"--- #{left_file}\t#{left_date}" +
					"+++ #{right_file}\t#{right_date}" +
					hunks.map{|h| h.to_s(:diff) }.join
			end
		when :html
			"<tr><th colspan='2'>#{left_file}</th><th colspan='2'>#{right_file}</th></tr>\n" +
			case binary?
				when true
					'<tr><td colspan="4" class="misc">Binary files differ</td></tr>'
				else
					"<tr><td colspan='2' class='misc'>#{left_date}</td><td colspan='2' class='misc'>#{right_date}</td></tr>\n" +
					hunks.map{|h| h.to_s(:html) }.join('<tr class="separator"><td>&nbsp;</td><td>...</td><td>&nbsp;</td><td>...</td></tr>')
			end
		else
			raise ArgumentError.new('Unrecognized style')
		end
	end
	
	def binary?
		@hunks.nil?
	end
end


#
# A hunk of a FileDiff. Each Hunk compares a set of consecutive lines in the two sides of its parent FileDiff.
#
class Hunk
	attr_reader :left_line_numbers, :right_line_numbers, :lines, :chunks

	def initialize(diff_string)
		matches = /@@ -(\d+),?(\d*) \+(\d+),?(\d*) @@/.match(diff_string[0])
		if matches
			diff_string.shift
			@left_line_numbers = matches[1].to_i...(matches[1].to_i + (matches[2] || 1).to_i)
			@right_line_numbers = matches[3].to_i...(matches[3].to_i + (matches[4] || 1).to_i)
			
			@lines = []
			while /^[ +\\-]/ === diff_string[0]
				@lines << Line.new(diff_string.shift)
			end
			
			left_counter = @left_line_numbers.first
			right_counter = @right_line_numbers.first
			last_line = nil
			@chunks = []
			@lines.each do |line|
				if !line.added? && !line.deleted? && !line.comment? || last_line.nil? || !last_line.added? && !last_line.deleted? && !last_line.comment?
					@chunks << [[],[]]
				end
				if line.in_left?
					@chunks[-1][0] << [left_counter, line]
					left_counter += 1
				end
				if line.in_right?
					@chunks[-1][1] << [right_counter, line]
					right_counter += 1
				end
				if line.comment?
					# \ No newline
					@chunks[-1][last_line.in_left? ? 0 : 1] << ['\\', line]
				end
				last_line = line
			end
			
			@chunks.each do |chunk|
				chunk[2] =
					if chunk[0].empty?
						'added'
					elsif chunk[1].empty?
						'deleted'
					elsif chunk[0].map{|ln|ln[1]} != chunk[1].map{|ln|ln[1]}
						'changed'
					else
						'unmodified'
					end
			end
		else
			raise ArgumentError.new('Unrecognized hunk header. Currently handles only unified (diff -u) format.')
		end
	end
	
	def to_a
		@lines.dup
	end
	
	def to_s(style = :diff)
		case style
		when :diff
			sprintf("@@ -%d,%d +%d,%d @@\n%s",
				left_line_numbers.first,
				left_line_numbers.last - left_line_numbers.first,
				right_line_numbers.first,
				right_line_numbers.last - right_line_numbers.first,
				@lines.map{|ln| ln.to_s(:diff) }.join)
		when :html
			chunks.inject('') do |acc, chunk|
				line_count = [chunk[0].size, chunk[1].size].max  
				(0...line_count).each do |i|
					acc << '<tr class="' << chunk[2] << '">'
					[0, 1].each do |side|
						if chunk[side][i]
							acc << '<td>' << chunk[side][i][0].to_s << '</td><td>' << chunk[side][i][1].to_s(:html)  << '</td>'
						else
							acc << '<td>&nbsp;</td><td>&nbsp;</td>'
						end
					end
					acc << '</tr>'
				end
				acc
			end
		else
			raise ArgumentError.new('Unrecognized style')
		end
	end
	
	def method_missing(*missing_method)
		@lines.send(*missing_method)
	end
end



#
# A line in a unified diff.
# A line exists in either the left, the right, or both sides of a FileDiff;
# it represents a new, deleted, or changed line.
#
class Line
	attr_reader :leading_char, :s
	
	def initialize(s = '\0')
		@s = s[1..-1]
		@leading_char = s[0] 
	end
	
	def to_s(style = :diff)
		case style
		when :diff
			leading_char.chr + @s
		when :html
			Line.html_encode(@s)
		when nil
			@s
		else
			raise ArgumentError.new('Unrecognized style')
		end
	end
	
	def inspect
		to_s(:diff).inspect
	end

	def method_missing(*missing_method)
		s.send(*missing_method)
	end

	def type
		case leading_char
		when ?-
			'deleted'
		when ?+
			'added'
		when ?\  #space
			'unmodified'
		when ?\\ #backslash
			'comment'
		else
			'unknown'
		end
	end
	
	def in_left?
		leading_char == ?- || @leading_char == ?\  #(space)
	end
	def in_right?
		leading_char == ?+ || @leading_char == ?\  #(space)
	end
	def added?
		!in_left? && in_right?
	end
	def deleted?
		in_left? && !in_right?
	end
	def unchanged?
		in_left? && in_right?
	end
	def comment?
		leading_char == ?\\ #backslash
	end

	#
	# Encode a string to display as-is when rendered as HTML,
	# and try to preserve whitespace a bit.
	#
	def self.html_encode(s)
		result = s.dup
		result.gsub!('&', '&amp;')
		result.gsub!('<', '&lt;')
		result.gsub!('>', '&gt;')
		result.gsub!('  ', ' &nbsp;')
		result.gsub!("\t", ' &nbsp;')
		result
	end
end



#
# Read diffs from ARGF and output them as a nicely formatted HTML page
#
def diff2html(diff_string)
	#
	# Parse diff string
	#
	diffs = []
	diff_string = diff_string.split("\n")
	while (diff_string.length > 0)
		diffs << FileDiff.new(diff_string)
	end
	
	#
	# Sort diffs
	#
	diffs.sort! {|a, b| a.left_file.downcase <=> b.left_file.downcase }
	
	#
	# dirs[0] and dirs[1] are the left and right directories being compared;
	# the common parts of all diff.left_file and all diff.right_file, respectively
	#
	dirs = diffs.inject([nil, nil]) do |acc, diff|
		file = [diff.left_file, diff.right_file]
		[0, 1].each do |side|
			if acc[side].nil?
				acc[side] = file[side]
			elsif acc != file[0...acc.length]
				i = 0
				while acc[side][i] == file[side][i]
					i += 1
				end
				acc[side] = acc[side][0...i]
			end
		end
		acc
	end

	#
	# Create index (hyperlinks to each file)
	#
	index_html = diffs.map { |diff|
		'<a href="#' +
		diff.left_file[dirs[0].length..-1] + '">' +
		diff.left_file[dirs[0].length..-1] + '</a><br />'
	}
	
	#
	# Output html - hard-coded header first
	#
	result = ''
	result << <<-end
		<html>
		<head>
		<meta name="generator" content="diff2html.rb" />
		<title>HTML Diff - #{dirs[0]} vs. #{dirs[1]}</title>
		<style>
			table { width: 100% }
			td { font-family: Lucida Console, monospace; font-size: smaller }
			th { background: black; color: white }
			tr.unmodified td { background: #CCCCFF }
			tr.added td { background: #CCFFCC }
			tr.deleted td { background: #FFCCCC }
			tr.changed td { background: #FFFF99 }
			tr.misc td {}
			tr.separator td {}
		</style>
		</head>
		<body>
		<h1>Comparing directories</h1>
		<table>
		<tr>
			<th colspan="2">Left: #{dirs[0]}</th>
			<th colspan="2">Right: #{dirs[1]}</th>
		</tr>
		<tr>
			<td colspan="4">#{index_html}</td>
		</tr>
	end
	
	#
	# Output diffs as html (table rows), adding a <a name="..."> row before each file
	#
	diffs.each do |diff|
		result <<
			'<tr><td colspan="4"><a name="' +
			diff.left_file[dirs[0].length..-1] +
			'">&nbsp;</a></td></tr>' +
			diff.to_s(:html) +
			"\n"
	end
	
	#
	# Output tail
	#
	result << '</table></body></html>'
end



if $0 == __FILE__
	print diff2html(ARGF.readlines.join)
end

