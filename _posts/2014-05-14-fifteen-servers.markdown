---
layout: post
title: "Fifteen Servers"
date: 2014-05-14 15:37:08 +0200
comments: true
categories: blog servers
image:
  feature: fifteen-servers-01-real.jpg
  credit: Jaime Iniesta Alemán
  creditlink: http://jaimeiniesta.com/
share: true
---

I've always been fascinated by the amount of complexity that can be beautifully hidden on software.

Take, for example, the [Site Validator](https://sitevalidator.com) project. Seen from the outside, it's a simple app: you enter an URL and it scrapes the site and gives you back a report with the HTML and CSS validation errors. But internally, it involves the collaboration of (at least) fifteen servers.

At its core, Site Validator is a monolithic rails application. While everything could run on a single server instance, to be prepared to scale a better approach is separating it on different servers so you're able to manage every part of the system independently.

### Rails / PostgreSQL / Redis

The rails application itself runs on a 1 Gb server instance on [Digital Ocean](https://www.digitalocean.com/?refcode=55fd4e532426). Inside it, we've got the web server and a [sidekiq](http://sidekiq.org/) process with 5 concurrent workers for the background queue. By now, that's all we need to handle our current load, but we could easily scale by adding more server instances and putting a load balancer on front of them.

For the PostgreSQL database, we've set up a 512 Mb server instance also on DO. Also, we needed a Redis store for our sidekiq background processing, so there goes another 512 Mb server instance just for that. Nothing out of the ordinary.

### Orchestrating deployments with Cloud 66

We're using Digital Ocean to host all those server instances, but we didn't set up any of them. Instead, we let [Cloud 66](http://www.cloud66.com/) set them up for us. You just need to give them access to your git repository (ours is at Bitbucket) and permission to manage your cloud servers (Digital Ocean in our case), and they set up all the needed servers, with security, metrics, backups and scaling. You can also set up a web hook so you can deploy just by doing a `git push`.

### W3C validation software

While the site scraping is done by the rails application, the validation of the pages is done using the same open source software that the W3C uses. So, we have a server instance that is just in charge of doing [HTML validation](https://github.com/tlvince/w3c-validator-guide), and another server instance for the [CSS validation software](https://github.com/tlvince/w3c-css-validator-guide). The rails app will query them using their APIs, get the results of the validations and process them.

As page validation is a slow process (the validation software needs to get the page to be validated and its stylesheets, process them and return the results), we have several server instances running the same validation software. We're using 5 server instances for the HTML validation, and 5 server instances for CSS validation. So that's 10 server instances; they're easy to set up thanks to the possibility on Digital Ocean to clone servers from their snapshots.

On front of those 10 server instances we've put a load balancer server, so our rails application only needs to talk to an IP, the load balancer will transparently manage all the traffic. The load balancer was surprisingly [easy to set up](https://www.digitalocean.com/community/articles/how-to-set-up-nginx-load-balancing) using nginx.

### Forum

And finally, we've got a 2 Gb server instance to host the forum, based on [discourse](http://www.discourse.org/). In this case, this server instance holds everything it needs: rails app, postgresql, redis, memcached... We went with the [basic setup of discourse](https://github.com/discourse/discourse/blob/master/docs/INSTALL-digital-ocean.md) that contains everything it needs on a [docker](https://www.docker.io/) image, and it works great out of the box.

### External services

So currently we're using 15 servers for our application, but life would be much harder without the external help we get from:

* [Bitbucket](https://bitbucket.org/) to host the git repository.
* [RubyGems](http://rubygems.org/) to host the ruby gems.
* [Source Viewer](https://github.com/jaimeiniesta/sourceviewer) to show the source of the validated pages.
* [New Relic](http://newrelic.com/) to measure the application performance.
* [Pingdom](https://www.pingdom.com/) for uptime monitoring.
* [Sentry](https://getsentry.com/welcome/) to be notified about exceptions.
* [Olark](http://www.olark.com/) for customer support.
* [AddThis](http://www.addthis.com/) for social sharing.
* [Google Analytics](http://www.google.com/analytics/) for traffic stats.
* [Amazon S3](http://s3.amazonaws.com) to store images for the posts and backups.
* [Mandrill](http://mandrillapp.com) to send emails.
* [Mailchimp](http://mailchimp.com/) for the newsletter.

Thank you everyone!
