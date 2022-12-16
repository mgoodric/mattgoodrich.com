---
title:  "UrlRewriter.Net"
categories: 
  - .NET
  - SEO
tags:
  - Intelligencia
  - SEO
  - URL rewriting
  - IIS7
---

This is my first tutorial. I will be going over how to use the extensionless Url Rewriter with ASP.NET. There is a lot you can do with this component, and I will only be scratching the surface here.

Url rewriting also known as dymanic URL's can be very useful. Instead of having a long nasty looking URL like http://www.mattgoodrich.com/blog.aspx?blog_id=115532633, you could instead have a Url that looks something like http://www.mattgoodrich.com/Blog/HowToBeAwesome. This will also help with search engine optimization.

Another potential use could be that if you are editing a live site, and are re-developing a page, you could create a second version of that page that is not known to the public, make the changes you desire, then change the rewrite in the Web.Config to point to the new page and that would be the only code change needed. This also helps if people have that page bookmarked.

Alright, lets get started. Please note that IIS7 is required for this to work.

**Note:** I have not been able to get this working in a medium-trust environment (GoDaddy).

The first thing to do is to download the binary. You can also download the source, as this is an open source component. You can download from <a href="http://urlrewriter.net/index.php/download">here</a>.

Next you will need to drop the file named Intelligencia.UrlRewriter.dll into the bin folder in your web application. Alternatively in Microsoft Visual Web Developer or Visual Studio you could go to Website - Add Reference - then click the Browse Tab and locate the DLL file.

Now we need to set this up in the Web.Config file for your web application.

First thing we need to add is a new section to the `configSections` area of your Web.Config.

Add the following line:

```xml
<section name="rewriter" requirePermission="false" type= "Intelligencia.UrlRewriter.Configuration.RewriterConfigurationSectionHandler, Intelligencia.UrlRewriter" />
```

The next thing we need to do is add a module to the `httpModules` section.

We will add the following line:
```xml
<add name="UrlRewriter" type="Intelligencia.UrlRewriter.RewriterHttpModule, Intelligencia.UrlRewriter" />
```

Now we need to add a module to the modules section in the system.webServer section. NOTE: This section is specific to IIS7, so if you do not have IIS7 or an IIS7 Web.Config, you will need to make changes before this will work.

The module we are adding is:
```xml
<add name="UrlRewriter" type="Intelligencia.UrlRewriter.RewriterHttpModule" />
```

Now we can finally start to configure the rewrites. This can be either done in the Web.Config (how we will do it here), or it can be done in a seperate file.

Back in the `configuration` section we will need to have a pair of rewriter tags. In those tags is where we will do our rewrites. You can map each page specifically or you can use regular expressions. This is a very basic example, and with a little creativity you may be able to minimize the number of lines in this section.
```xml
<rewriter>
	<rewrite url="^/Home$" to="~/Default.aspx"></rewrite>
	<rewrite url="^/About$" to="~/about.aspx"></rewrite>
	<rewrite url="^/Blog$" to="~/blog.aspx"></rewrite>
	<rewrite url="~/Blog/(.+)" to="~/blog.aspx?id=$1" processing="stop"></rewrite>
	<if url="^/Tutorials/(.+)$">
		<rewrite to="/tutorial.aspx?id=$1" processing="stop" ></rewrite>
	</if>
	<rewrite url="^/Tutorials$" to="~/tutorial.aspx" ></rewrite>
	<rewrite url="^/Tutorials/(.+)$" to="~/tutorial.aspx?id=$1" processing="stop"></rewrite>
	<rewrite url="^/Contact$" to="~/contact.aspx"></rewrite>
</rewriter>
```

If all these steps were performed successfully, you should be ready to go.
