This library is for automating the resolution of DNS records, allowing you to 
hit arbitrary name servers, and your own local DNS. If you have to migrate
a boatload of DNS, this library will allow you to verify your migration has
completed successfully and nothing has been left behind (something that is
very easy to do in these kinds of jobs).

NOTE: This requires that you have the *nix <code>dig</code> utility installed,
so it's probably safe to say that this library only work on linux/unix. It 
hasn't been tested on Windows, so there!

If you're like me and you're fickle about hosting providers, you'd have done
this a few times. On the last migration I performed this saved me hours of
manual checking, and saved me from the embarressment of services disappearing
or whatnot. So let's walk through how you'd use that (full example source is
in example.rb).

First, you need to require the DNS library:

    require 'dns'

We'll set up some instance variables for the name servers we're going to check
against:

    @local_dns = [nil]
    @slicehost_dns = %w(ns1.slicehost.net ns2.slicehost.net)

To prevent name servers from blocking our dig requests, we'll put a delay of
one second in so that they don't start ignoring us (this happened to me a few
times, sometimes you can remove it, sometimes you can set it to a lower 
threshold, experiment would you already!):

    DNS.delay = 1

And the rest should be self-explainitory. The API is pretty damn intuitive if
you ask me (after all, I wrote the damn thing). You can check A records, MX
records, CNAME records and even NS authority! Fwoar!

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

And this is the output the script will produce if everything works. If it fails
it'll say FAIL and print the dig output as well (this output is not shown here):

    PASS: yeahnah.org A 208.78.102.114  
    PASS: yeahnah.org MX ASPMX.L.GOOGLE.COM  {:priority=>10}
    PASS: yeahnah.org MX ALT1.ASPMX.L.GOOGLE.COM  {:priority=>20}
    PASS: yeahnah.org MX ALT2.ASPMX.L.GOOGLE.COM  {:priority=>30}
    PASS: www.yeahnah.org CNAME yeahnah.org  
    PASS: tumble.yeahnah.org A 72.32.231.8  
    PASS: yeahnah.org A 208.78.102.114 @ns1.slicehost.net 
    PASS: yeahnah.org MX ASPMX.L.GOOGLE.COM @ns1.slicehost.net {:priority=>10}
    PASS: yeahnah.org MX ALT1.ASPMX.L.GOOGLE.COM @ns1.slicehost.net {:priority=>20}
    PASS: yeahnah.org MX ALT2.ASPMX.L.GOOGLE.COM @ns1.slicehost.net {:priority=>30}
    PASS: www.yeahnah.org CNAME yeahnah.org @ns1.slicehost.net 
    PASS: tumble.yeahnah.org A 72.32.231.8 @ns1.slicehost.net 
    PASS: yeahnah.org A 208.78.102.114 @ns2.slicehost.net 
    PASS: yeahnah.org MX ASPMX.L.GOOGLE.COM @ns2.slicehost.net {:priority=>10}
    PASS: yeahnah.org MX ALT1.ASPMX.L.GOOGLE.COM @ns2.slicehost.net {:priority=>20}
    PASS: yeahnah.org MX ALT2.ASPMX.L.GOOGLE.COM @ns2.slicehost.net {:priority=>30}
    PASS: www.yeahnah.org CNAME yeahnah.org @ns2.slicehost.net 
    PASS: tumble.yeahnah.org A 72.32.231.8 @ns2.slicehost.net 
    PASS: yeahnah.org A 208.78.102.114  
    PASS: tumble.yeahnah.org A 72.32.231.8  
    PASS: yeahnah.org NS ns1.slicehost.net
    PASS: yeahnah.org NS ns2.slicehost.net

And that's about it! If you're using this library and enjoying it, please drop
me a line and let me know!
