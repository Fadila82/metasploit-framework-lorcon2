require_relative 'radiotap'


class FrameControlField
  def initialize(content_as_string = "")
    tab = content_as_string.unpack('B8B8')
    @type = tab[0][4,6].to_i(2)
    @version = tab[0][4,8].to_i(2)
    @subtype = tab[0][0,4].to_i(2)
    @flags = tab[1]
    @to_ds = (@flags[0].to_i() == 1)
    @from_ds = (@flags[1].to_i() == 1)
    @more_frag = (@flags[2].to_i() == 1)
    @retry = (@flags[3] == 1)
    @pwr_mgt = (@flags[4] == 1)
    @more_data = (@flags[5] == 1)
    @protected_frame = (@flags[6] == 1)
    @order = (@flags[7] == 1)
  end
  attr_accessor :type
  attr_accessor :version
  attr_accessor :subtype
  attr_accessor :to_ds
  attr_accessor :from_ds
  attr_accessor :more_frag
  attr_accessor :retry
  attr_accessor :pwr_mgt
  attr_accessor :more_data
  attr_accessor :protected_frame
  attr_accessor :order
end

#
# TODO: allow to payload directly (without radiotap header)
###
class Frame80211
  def initialize(content_as_string = "")
    @content_as_string = content_as_string
    radiotap = RadioTap.new(@content_as_string)

    tab = radiotap.payload.unpack('a2H4H12H12H12H4H12H12a*')
    @fcf = FrameControlField.new(tab[0])
    @duration = tab[1]
    @addr1 = tab[2].scan(/\w{2}/).join(':')
    @addr2 = tab[3].scan(/\w{2}/).join(':')
    @addr3 = tab[4].scan(/\w{2}/).join(':')
#    print "PAYLOAD: "
#    print tab
#    print "\n"
    @payload = tab[8]
  end
  attr_accessor :fcf
  attr_accessor :duration
  attr_accessor :addr1
  attr_accessor :addr2
  attr_accessor :addr3
  attr_accessor :payload
  attr_accessor :radiotap
end

#
# Management frame information elements format:
#
#  |   ID   | length |    value        |
#  |   1    |    1   | variable length |
#
class InformationElement
  def initialize(content_as_string = "")
    @content_as_string = content_as_string
    tab = @content_as_string.unpack('CCa*')
    if tab.length == 3
      @id = tab[0].to_i()
      @length = tab[1].to_i()
      tab2 = tab[2].unpack('a'+ @length.to_s() + 'a*')
      if tab2.length > 0
        @value = tab2[0]
      end
    end # TODO: raise error 
  end

  def self.extractInformationElements(content_as_string)
    info_element_list = []
    to_be_parsed = content_as_string

    while to_be_parsed != nil
      infoElement = InformationElement.new(to_be_parsed)
      info_element_list.push(infoElement)
      # skip the info element and go to the next one
      infoElementTotalLength = infoElement.length + 2 # id and length fields 
      to_be_parsed_exploded = to_be_parsed.unpack('x' + infoElementTotalLength.to_s() + 'a*')
      if to_be_parsed_exploded.length == 2
        to_be_parsed = to_be_parsed_exploded[1]
      else
        to_be_parsed = nil
      end
    end

    return info_element_list
  end

  def print_element
    print "IE :=== ID: "
    print @id
    print " - length: "
    print @length
    print " - Value "
    print @value
    print "\n"
  end

  attr_accessor :id
  attr_accessor :length
  attr_accessor :value
end


# A management has in its payload a list
# of Information Elements
class ManagementFrame
  def initialize(content_as_string = "")
    @content_as_string = content_as_string
    @frame80211 = Frame80211.new(@content_as_string)
    # TODO: error if not management type
    @informationElements = InformationElement.extractInformationElements(@frame80211.payload)
  end

  attr_accessor :frame80211
  attr_accessor :informationElements
end


