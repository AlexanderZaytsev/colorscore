module Colorscore
  class Histogram
    def initialize(image_path, colors=16, quantize = '-quantize YUV')
      output = `convert #{image_path} -format %c -dither None #{quantize} -colors #{colors} -depth 8 -alpha on histogram:info:-`
      @lines = output.lines.sort.reverse.map(&:strip).reject(&:empty?).reject do |line|
        line =~ /srgba\([0-9]+,[0-9]+,[0-9]+,0\)/
      end
    end

    # Returns an array of colors in descending order of occurances.
    def colors
      hex_values = @lines.map { |line| line[/#([0-9A-F]{6})/, 1] }.compact
      hex_values.map { |hex| Colour::RGB.from_html(hex) }
    end

    def color_counts
      @lines.map { |line| line.split(':')[0].to_i }
    end

    def scores
      total = color_counts.inject(:+).to_f
      scores = color_counts.map { |count| count / total }
      scores.zip(colors)
    end
  end
end
