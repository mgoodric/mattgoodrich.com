---
title:  "Flickr.Net API"
categories: 
  - DotNet
tags:
  - flickr
  - asp.net
---

There is a great project on CodePlex called Flickr.Net. It gives a great API that interfaces with Flickr and is accessible from C#.NET.  You can find their page at <a href="http://www.codeplex.com/FlickrNet">http://www.codeplex.com/FlickrNet</a>.

First thing is you will need to download the latest release, which at the time of writing this is 2.2.0.

After downloading it, extract the files and drop the FlickrNet.dll file into your bin folder.

After that its simply a matter of creating a page that utilizes this code.

Here is mine:
```html
<h1>Photos</h1>
<p><asp:literal id="Literal1" runat="server"></asp:literal></p>
<asp:repeater id="PhotoRepeater" runat="server">
  <itemtemplate>
    <div class="comment" style="padding-left: 15px; width: 645px; text-align: left; margin-top: 7px; margin-bottom: 7px;">
	    <table width="100%">
		    <tbody>
			    <tr>
				    <td style="vertical-align: top;">
					    <div style="display: none; width: 550px; height: 300px;"></div>
					    <div style="text-align: right; width: 645px;">
						    <span style="font-size: 11px; color: rgb(42, 42, 42);"><%#Eval("DateTaken") %> </span>
              </div>
					    <div style="border: 1px solid rgb(221, 221, 221); padding: 10px; font-size: 12px; background-color: rgb(255, 255, 255);">
						    <a href="<%# Eval(" weburl="">"><img smallurl="" src="<%# Eval(" />" style="float: left; padding-right: 15px;"></a> <%# GetDescription(Eval("PhotoId").ToString()) %>
						    <div style="clear: both;"></div>
					    </div>
				    </td>
			    </tr>
		    </tbody>
	    </table>
    </div>
  </itemtemplate>
</asp:repeater>

<p><asp:literal id="Literal2" runat="server"></asp:literal></p>
```

This is a simple repeater that uses some of the items that can be retrieved from Flickr.

My backend code looks something like this:<
```csharp

  int count = 10;
  int page = 1;

  protected void Page_Load(object sender, EventArgs e)
  {  
    if (Request.QueryString["page"] != null)
    {
      try
      {
        page = Convert.ToInt32(Request.QueryString["page"]);
      }
      catch
      {
        page = 1;
      }
    }

    PhotoRepeater.DataSource = RecentPhotos(page, count);
    PhotoRepeater.DataBind(); 

    Literal1.Text = GetNav(page, count);
    Literal2.Text = Literal1.Text;

  }

  public static string GetNav(int page, int count)
  {
    //String to return
    string returnstring = "";

    //If on the first page
    if (page == 1)
    {
      //Only show NEXT
      returnstring += "<a href="\"/Photos/2\"">Next " + count + " >></a>";
    }
    //If not on the first page
    else
    {
      //Show PREVIOUS and NEXT
      returnstring += "<a -="" href="\"/Photos/""><< Previous " + count.ToString() + "</a>";

      //If the last page dont show NEXT
        if (page < GetNumPages(count))
        {
          returnstring += " | <a href="\"/Photos/"">Next " + count.ToString() + " >></a>";
        }
    }
        
    //return the string
    return returnstring;
  }
    
public static FlickrNet.PhotoCollection RecentPhotos(int page, int count)
{
  FlickrNet.Flickr flickr = new FlickrNet.Flickr();

  FlickrNet.PhotoSearchOptions options = new FlickrNet.PhotoSearchOptions();

  options.UserId = ConfigurationManager.AppSettings.Get("UserId");
  options.PerPage = count;
  options.Page = page;
  options.SortOrder = FlickrNet.PhotoSearchSortOrder.DatePostedDesc;
  options.Extras = PhotoSearchExtras.All;

  FlickrNet.Photos photos = flickr.PhotosSearch(options);
  
  if (photos.PhotoCollection == null)
    return new FlickrNet.Photo[0];
  else
    return photos.PhotoCollection;
}

public static string GetDescription(string id)
{
  Flickr flickr = new FlickrNet.Flickr();

  PhotoInfo p = flickr.PhotosGetInfo(id);

  return p.Description.ToString();
}

public static long GetNumPages(int count)
{
  FlickrNet.Flickr flickr = new FlickrNet.Flickr();

  FlickrNet.PhotoSearchOptions options = new FlickrNet.PhotoSearchOptions();

  options.UserId = ConfigurationManager.AppSettings.Get("UserId");
  options.PerPage = count;
  options.SortOrder = FlickrNet.PhotoSearchSortOrder.DatePostedDesc;
  options.Extras = PhotoSearchExtras.All;
  FlickrNet.Photos photos = flickr.PhotosSearch(options);

  return photos.TotalPages;
}  
```

Be sure to make sure you have "using FlickrNet;" at the top of the page.

I stored my Flickr UserId in my web.config in the appSettings section, but you can surely put it other places.

```xml
<add key="UserId" value="your user id goes here"/>
```

This code will yield something that looks like this:</p>
![image-center](/assets/images/flickr1.jpg){: .align-center}