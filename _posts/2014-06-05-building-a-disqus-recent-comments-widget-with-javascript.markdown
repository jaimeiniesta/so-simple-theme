---
layout: post
title: "Building a Disqus Recent Comments Widget with JavaScript"
date: 2014-06-05 22:17:52 +0200
comments: true
categories: blog javascript how-to
image:
  feature: building-a-disqus-recent-comments-widget-with-javascript.jpg
  credit: Jaime Iniesta Alemán
  creditlink: http://jaimeiniesta.com/
share: true
---

Recently, I was interested in adding a widget to show the recent Disqus comments on a site. Back in the early days of Disqus they provided an official JavaScript widget but, although it's still available, it's [officially deprecated](https://help.disqus.com/customer/portal/articles/1179651-widgets).

The proposed way to do this now is using the [Disqus API](https://disqus.com/api/docs/) to get the raw data, and painting this yourself on your site. That's a bit of extra work (and fun!) for us web developers, but it's really worth it as this way you can tailor it exactly to your needs.

The only thing that I didn't like about this approach is the suggestion to set up a cron task on your server to periodically pull the data and store it on the database.

I didn't like this approach because in my opinion, adding more tables to the database and a cron job is overkill when you just need a widget on your site. Also, what happens when a comment is edited or deleted on Disqus after we've already imported it? Should we care about synchronization? And, if we're loading this data on our database, should we consider relating the stored comments to our commented pages and users also in the database, etc.?

No, for a widget I wanted something simpler, so I decided to stay on the client side. Follow me along as we build our widget.

### Ingredients

* **[A public Disqus API key](https://disqus.com/api/applications/)**. You'll need it to be able to use the API. To get it, login to your Disqus account and create an application. You won't need the API secret for the widget, only the API key, which can be publicly exposed on the client side. Remember to review the application settings, you'll want to enter the domains from where you'll allow this API key to be used.


* **[jQuery](http://jquery.com)**. Are there any pages out there that don't yet use this great library for DOM manipulation? You're surely using it already on your site.


* **[Handlebars](http://handlebarsjs.com)**, a templating library that lets us separate the presentation from the logic in our JS apps. That helps keeping our code cleaner, and much easier to understand.


* **[Timeago](http://timeago.yarp.com)**, a jQuery plugin that makes it easy to support automatically updating fuzzy timestamps (e.g. "4 minutes ago" or "about 1 day ago"). We'll use it to show the dates of the comments in a relative way, just like Disqus does.

### Live demo

You can see how I put all this together to build the [comments widget](http://codepen.io/jaimeiniesta/pen/DhKrd):

<p data-height="600" data-theme-id="0" data-slug-hash="DhKrd" data-default-tab="result" class='codepen'>See the Pen <a href='http://codepen.io/jaimeiniesta/pen/DhKrd/'>DhKrd</a> by Jaime Iniesta (<a href='http://codepen.io/jaimeiniesta'>@jaimeiniesta</a>) on <a href='http://codepen.io'>CodePen</a>.</p>
<script async src="//codepen.io/assets/embed/ei.js"></script>

As you can see, it's as simple as it gets. The HTML/CSS is a simple layout where we render the comments using a list (thanks [Almudena](http://murtra.net) for helping me with the CSS!). The Handlebars template has been placed right into its context, this is not needed but it helps to understand it better. All the attributes marked with double braces will be populated with the data we get from the API.

Finally, we define on JavaScript a `DisqusRecent` object that can be initialized passing some parameters to its `init` method, so that it's configurable. See at the end of the file how it's used: we pass it the public API key, the name of the forum (the site) that we're interested in getting the comments from, and the CSS selectors for the Handlebars template and the container.

After initialization, it will invoke its `fetchRecentComments` method, that will make an AJAX call to query the Disqus API. Notice how it includes the _related=thread_ option to include data about the commented pages so we can link to them.

Notice as well that we're making this request using the [JSONP](http://en.wikipedia.org/wiki/JSONP) data type, so we're allowed to request data from a server in a different domain, something prohibited by typical web browsers because of the same-origin policy.

When the AJAX request succeeds, we pass the results to Handlebars so it can paint the template with them. We do it in 3 lines: first we get the contents of the Handlebars template, second we ask Handlebars to compile the template, and third we pass the results of the API request to the Handlebars template, and we ask jQuery to place them on the container element.

For performance reasons, you might want to learn [how to precompile your Handlebars templates](http://handlebarsjs.com/precompilation.html). If you precompile them, they won't need to be compiled by the browser (which will save time), and you can require the runtime version of the Handlebars library, which is considerably smaller.

### API usage limits

Disqus imposes a limit of 1000 requests per hour to their API, which can be an important limitation for a site with high traffic. If that's your case, you should consider caching the results of the API requests so you reduce them. One attempt can be using [jquery-ajax-localstorage](https://github.com/paulirish/jquery-ajax-localstorage-cache) so you can cache the requests on the client side. This way, if a visitor of your site sees the widget 10 times, only 1 request will be done and the rest will be cached.

This won't reduce the number of requests you get from unique visitors, so it's a better idea to cache the requests on your server with, for example, [memcached](http://memcached.org/), so you can control how many requests per hour are done. For example, you can set a cache expiration of 4 seconds and you'll be making 900 requests per hour at a maximum, although probably 1 minute is good enough.

Now, if you're going to cache this on your server, you might also consider rendering the comments on the server, and entirely remove the JS dependencies, which is what I finally ended up doing.

But hey, isn't it nice to play with JavaScript for a change? :D
