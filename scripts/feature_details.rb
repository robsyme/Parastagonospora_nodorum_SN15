#!/usr/bin/env ruby
require 'bio'

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

intron_lengths = gff
  .records
  .find_all{ |record| record.feature == "CDS" }
  .group_by{ |record| Hash[record.attributes]["Parent"] }
  .values
  .flat_map do |records|
  records
    .sort_by{ |record| record.start }
    .each_cons(2)
    .map{ |a, b| b.start - a.end - 1 }
end
$stderr.puts "Intron length mean: #{intron_lengths.mean}"
$stderr.puts "Intron length stddev: #{intron_lengths.standard_deviation}"

cds_lengths = gff
  .records
  .find_all{ |record| record.feature == "CDS" }
  .group_by{ |record| Hash[record.attributes]["Parent"] }
  .values
  .flat_map do |records|
  records.inject(0){ |mem, record| mem += record.end - record.start + 1 }
end
$stderr.puts "CDS length mean: #{cds_lengths.mean} bp"
$stderr.puts "CDS length stddev: #{cds_lengths.standard_deviation} bp"
$stderr.puts "CDS count: #{cds_lengths.count}"

cds_per_gene = gff
  .records
  .find_all{ |record| record.feature == "CDS" }
  .group_by{ |record| Hash[record.attributes]["Parent"] }
  .values
  .flat_map do |records|
  records.length
end
$stderr.puts "CDS counts per gene mean: #{cds_per_gene.mean}"
$stderr.puts "CDS counts per gene stddev: #{cds_per_gene.standard_deviation}"

intergenic_lengths = gff
  .records
  .find_all{ |record| record.feature == "gene" }
  .group_by{ |record| record.seqname }
  .flat_map do |seqname, records|
  records
    .sort_by{ |record| record.start }
    .each_cons(2)
    .map{ |a, b| b.start - a.end - 1 }
end

$stderr.puts "Intergenic length mean: #{intergenic_lengths.mean}"
$stderr.puts "Intergenic length stddev: #{intergenic_lengths.standard_deviation}"

gene_count = gff
  .records
  .find_all{ |record| record.feature == "gene" }
  .count

puts "Gene count = #{gff.records.count{|r| r.feature == 'gene'}}"
