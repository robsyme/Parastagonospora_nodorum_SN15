#!/usr/bin/env ruby

gene_versions = Hash.new(nil)

File.open(ARGV.shift).each do |line|
  next if $. == 1
  split = line.split(".")
  id = split.shift
  version = split.shift
  gene_versions[id] = version
end

File.open("Error_lines.txt",'w') do |errors|
  File.open(ARGV.shift).each do |line|
    next if line.match(/^#/)
    locus, version =  gene_versions.find{|locus,version| line[locus]}
    if version
      puts line.gsub(/#{locus}\.\d/, "#{locus}.#{version.strip}")
    elsif line.match("mito")
      puts line
    else
      errors.puts line
    end
  end
end
