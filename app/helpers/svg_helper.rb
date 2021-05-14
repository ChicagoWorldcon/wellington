module SvgHelper
  def show_svg(path)
    File.open("app/javascript/images/#{path}", "rb") do |file|
      raw file.read
    end
  end
end
