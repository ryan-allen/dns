#
# this will print results to $stdout, so to see it working, run this file.
#
require 'dns'

# the nameservers we want to check against
@local_dns = [nil]
@slicehost_dns = %w(ns1.slicehost.net ns2.slicehost.net)

# 1 second between dig requests so nameservers don't block us (this default to 
# no delay, and it's super fast, good for local queries)
DNS.delay = 1

(@local_dns + @slicehost_dns).each do |server|
  
  DNS.verify('yeahnah.org').with_server(server) do |it|
    # checks A records
    it.resolves_to('208.78.102.114')
    # checks MX records
    it.maps_mail_to('ASPMX.L.GOOGLE.COM', :priority => 10)
    it.maps_mail_to('ALT1.ASPMX.L.GOOGLE.COM', :priority => 20)
    it.maps_mail_to('ALT2.ASPMX.L.GOOGLE.COM', :priority => 30)
  end
  
  DNS.verify('www.yeahnah.org').with_server(server) do |it|
    # checks CNAME records
    it.is_aliased_to('yeahnah.org')
  end
  
  DNS.verify('tumble.yeahnah.org').with_server(server) do |it|
    it.resolves_to('72.32.231.8') # tumblr :)
  end
  
end

# shorthand that checks against your local dns
DNS.verify('yeahnah.org').resolves_to('208.78.102.114')
DNS.verify('tumble.yeahnah.org').resolves_to('72.32.231.8')

# oh, and check authorative ns :)
DNS.verify('yeahnah.org').has_authorative_nameserver_of('ns1.slicehost.net')
DNS.verify('yeahnah.org').has_authorative_nameserver_of('ns2.slicehost.net')

# and FYI this is the output of the script, will display dig output on failures
# PASS: yeahnah.org A 208.78.102.114  
# PASS: yeahnah.org MX ASPMX.L.GOOGLE.COM  {:priority=>10}
# PASS: yeahnah.org MX ALT1.ASPMX.L.GOOGLE.COM  {:priority=>20}
# PASS: yeahnah.org MX ALT2.ASPMX.L.GOOGLE.COM  {:priority=>30}
# PASS: www.yeahnah.org CNAME yeahnah.org  
# PASS: tumble.yeahnah.org A 72.32.231.8  
# PASS: yeahnah.org A 208.78.102.114 @ns1.slicehost.net 
# PASS: yeahnah.org MX ASPMX.L.GOOGLE.COM @ns1.slicehost.net {:priority=>10}
# PASS: yeahnah.org MX ALT1.ASPMX.L.GOOGLE.COM @ns1.slicehost.net {:priority=>20}
# PASS: yeahnah.org MX ALT2.ASPMX.L.GOOGLE.COM @ns1.slicehost.net {:priority=>30}
# PASS: www.yeahnah.org CNAME yeahnah.org @ns1.slicehost.net 
# PASS: tumble.yeahnah.org A 72.32.231.8 @ns1.slicehost.net 
# PASS: yeahnah.org A 208.78.102.114 @ns2.slicehost.net 
# PASS: yeahnah.org MX ASPMX.L.GOOGLE.COM @ns2.slicehost.net {:priority=>10}
# PASS: yeahnah.org MX ALT1.ASPMX.L.GOOGLE.COM @ns2.slicehost.net {:priority=>20}
# PASS: yeahnah.org MX ALT2.ASPMX.L.GOOGLE.COM @ns2.slicehost.net {:priority=>30}
# PASS: www.yeahnah.org CNAME yeahnah.org @ns2.slicehost.net 
# PASS: tumble.yeahnah.org A 72.32.231.8 @ns2.slicehost.net 
# PASS: yeahnah.org A 208.78.102.114  
# PASS: tumble.yeahnah.org A 72.32.231.8  
# PASS: yeahnah.org NS ns1.slicehost.net
# PASS: yeahnah.org NS ns2.slicehost.net