#!/usr/bin/env ruby
require 'bio'
require 'set'

module Enumerable
  def sum
    self.inject(0){|accum, i| accum + i }
  end

  def mean
    self.sum/self.length.to_f
  end

  def sample_variance
    m = self.mean
    sum = self.inject(0){|accum, i| accum +(i-m)**2 }
    sum/(self.length - 1).to_f
  end

  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end
end

gff = Bio::GFF::GFF3.new(File.read(ARGV.shift))
count = Hash.new(0)
gff.records
  .find_all{ |record| record.feature == "CDS"}
  .map{ |record| attr = Hash[record.attributes]["Parent"] }
  .each{ |parent| count[parent] += 1 }
puts "Average exon count = #{count.values.mean}"

scaffolds = gff.records.map{ |record| record.seqname }.compact.to_set

intergenic_distances = scaffolds.flat_map do |scaffold|
  gff.records
    .find_all{ |record| record.seqname == scaffold && record.feature == "gene"}
    .each_cons(2)
    .map{ |a, b| b.start - a.end - 1 }
end

puts "Gene count = #{gff.records.count{|r| r.feature == 'gene'}}"
puts "Mean intergenic distance = #{intergenic_distances.mean}"
puts "Stdev intergenic distance = #{intergenic_distances.standard_deviation}"

