# coding: utf-8


##
# This module requires Metasploit: http//metasploit.com/download

# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'
require_relative 'ieee80211'




class MetasploitModule < Msf::Auxiliary

    
  include Msf::Exploit::Lorcon2
  include Msf::Auxiliary::Dos

  def initialize(info ={})
    super(update_info(info,
      'Name'		=> 'Wireless Listener',
      'Description' 	=> %q{
          Print sender mac addresses of received probe requests and probe requests count 
      },
       'Author'	=> [ 'Fadila Khadar' ],
      'License'	=> MSF_LICENSE
    ))

    register_options(
      [
      ],self.class)
  end

  
  def run
    print_status("Open wireless interface")

    open_wifi
    devices = Hash.new(0)
    
    # pcap filter to only capture probe requests
    set_filter("type mgt subtype probe-req")
    clear_screen
    print_tab_header
    each_packet { | pkt | process_packet(pkt,devices) }
  end

  def process_packet(pkt,devices)
    # Parse pkt as 802.11 management frame
    managementFrame = ManagementFrame.new("#{pkt.rawdata}")
    #update packet count for this device
    devices[managementFrame.frame80211.addr2] = devices[managementFrame.frame80211.addr2] + 1
    clear_screen
    print_tab_header
    devices.each{|mac,count| print " #{mac} \t\t #{count}\n"}
  end

  def clear_screen
    printf("\x1B[2J")
    printf("\n")
  end
  def print_tab_header
    print "\tMAC\t\t\tcount\n"
    print " ----------------------------------------\n"

  end
end
