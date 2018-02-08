class ToCube::DataReader
  def initialize(pipe)
    @lines = pipe.each_line.lazy.map do |line|
      line.chomp.split(',', -1)
    end
  end

  def parse!
    input = @lines.first.zip(@lines.to_a.transpose)
    time_strings = nil
    input.delete_if {|name, series| name == 'time' && time_strings = series }
    times = time_strings.map {|s| Integer(s) }
    @start_time, @end_time = times.minmax
    time_diffs = times.each_cons(2).each_with_object(Hash.new(0)) do |(t1, t2), acc|
      acc[t2 - t1] += 1
    end
    guessed_rollup = time_diffs.to_a.sort_by(&:last).last.first
    @rollup ||= guessed_rollup
    @series = input.map do |name, series|
      values = series.map(&:to_f)
      by_time = times.zip(values).each_with_object({}) do |(time, value), acc|
        acc[time] = value
      end
      {
        name: name,
        data: (@start_time..@end_time).step(@rollup).map {|time| by_time[time]}
      }
    end
  end

  def config
    {
      startTime: @start_time,
      endTime: @end_time,
      rollup: @rollup,
      series: @series
    }
  end

  def title
    'cubism'
  end
end