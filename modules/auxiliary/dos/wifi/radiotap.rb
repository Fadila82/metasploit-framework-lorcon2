class RadioTap
  def initialize(content_as_string = "")
    @content_as_string = content_as_string
    # radiotap header format:
    # - header revision: 2
    # - header pad: 2
    # - header length: 4
    tab = @content_as_string.unpack('CCSa*')
    @header_revision = tab[0]
    @header_pad = tab[1]
    @header_length = tab[2]
    # compute payload from the retrieved header length
    tab = @content_as_string.unpack('x' + @header_length.to_s + 'a*')
    @payload = tab[0]
  end
  attr_accessor :header_length
  attr_accessor :payload
end
