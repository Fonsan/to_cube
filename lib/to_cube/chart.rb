require 'erubi'
require 'json'
class ToCube::Chart
  def initialize(reader)
    @reader = reader
  end
  def render
    eval(Erubi::Engine.new(File.read(chart_file_path)).src)
  end

  def chart_config
    @reader.config
  end

  def title
    @reader.title
  end

  def javascripts
    File.read(File.join(template_path, 'javascripts.html'))
  end

  def chart_file_path
    File.join(template_path, 'chart.html.erb')
  end

  def template_path
    File.expand_path(
      File.join(
        __FILE__,
        '..',
        '..',
        '..',
        'templates',
      )
    )
  end
end