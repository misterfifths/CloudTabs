#!/usr/bin/env ruby

require 'nokogiri'

xml_path = 'build/installer/distribution.xml'

doc = Nokogiri::XML(File.read(xml_path))

doc.root.add_child '<title>CloudTabs Native Host</title>'
doc.root.add_child '<welcome mime-type="text/html" file="welcome.html" />'
doc.root.add_child '<conclusion mime-type="text/html" file="conclusion.html" />'
doc.root.add_child '<options hostArchitectures="x86_64" />'
doc.root.add_child '<os-ver min="10.12.0" />'
doc.root.add_child '<must-close><app id="com.google.Chrome" /></must-close>'

File.write(xml_path, doc.to_xml)
