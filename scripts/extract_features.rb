#!/usr/bin/env ruby

require 'bio'
require 'ostruct'
require 'optparse'
require 'pp'
require 'pathname'

options = OpenStruct.new
options.verbose = false
OptionParser.new do |opts|
  opts.banner = "Usage: extract_features.rb [options]"

  opts.on("-g", "--gff FILENAME", "GFF3 file to parse") do |filename|
    pn = Pathname.new(filename)
    if pn.exist?
      options.gff = filename
    else
      $stderr.puts opts.banner
      opts.abort "Could not find the file '#{filename}'"
    end
  end
  
  opts.on("-f", "--fasta FILENAME", "Fasta file to use for sequences") do |filename|
    pn = Pathname.new(filename)
    if pn.exist?
      options.fasta = Hash[Bio::FlatFile.open(filename).map{|entry| [entry.entry_id, entry.naseq]}]
    else
      $stderr.puts opts.banner
      opts.abort "Could not find the file '#{filename}'"
    end
  end

  opts.on("-t", "--[no-]translate", "Translate the CDS sequence") do |t|
    options.translate = t
  end
  
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options.verbose = v
  end
end.parse!

cds_features = Hash.new{|hash, key| hash[key] = []}
File.open(options.gff, 'r').each.find_all do |line|
  line =~ /\tCDS\t/
end.each do |line|
  split = line.chomp.split("\t")
  attributes = Hash[split[8].split(";").map{|pair| pair.split("=")}]
  cds_features[attributes["Parent"]] << split
end

cds_features.each do |key, value|
  a = value
    .sort_by{|split| split[3].to_i}
    .map{|split| options.fasta[split[0]].subseq(split[3].to_i, split[4].to_i)}

  seq = Bio::Sequence::NA.new(a.join)
  if value.first[6] == "+"
    prot = seq.translate
    ok = true
    if prot.composition["*"] <= 1
      puts options.translate ? prot[0..-2].to_fasta(key, 80) : seq.to_fasta(key,80)
    else
      $stderr.puts "Protein #{key} is invalid"
    end      
  else
    seq.reverse_complement!
    prot = seq.translate
    if prot.composition["*"] <= 1
      puts options.translate ? prot[0..-2].to_fasta(key, 80) : seq.to_fasta(key,80)
    else
      $stderr.puts "Protein #{key} is invalid"
    end      
  end
end
