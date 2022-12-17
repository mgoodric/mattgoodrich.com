---
title:  "Google Analytics .NET Integration"
categories: 
  - DotNet
tags:
  - google-analytics
  - asp.net
---

I have put together a page to display my Google Analytics information for my ASP.NET sites using some other help around the net and a little know-how.

I started by building this class, which I call GoogleAnalytics.cs:

```csharp
using System;
using System.Collections.Generic;
using System.Web;
using System.Net;
using System.IO;
using System.Text;
using System.Xml;
using System.Collections.Specialized;
using System.Diagnostics;

/// <summary>
/// Summary description for GoogleAnalytics
/// </summary>
public class GoogleAnalytics
{
    public enum mode { ClientLogin, AuthSub }
    
    //used when you want to manage email/pass from within your app
    public static string getSessionTokenClientLogin(string email, string password)
    { 
        //Google analytics requires certain variables to be POSTed
        string postData = "Email=" + email + "&Passwd=" + password;

        //defined - should not channge much
        postData = postData + "&accountType=HOSTED_OR_GOOGLE" + "&service=analytics" + "&source=ACNSSite";
        
        ASCIIEncoding encoding = new ASCIIEncoding();
        byte[] data = encoding.GetBytes(postData);

        HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create("https://www.google.com/accounts/ClientLogin");
        myRequest.Method = "POST";
        myRequest.ContentType = "application/x-www-form-urlencoded";
        myRequest.ContentLength = data.Length;
        Stream newStream = myRequest.GetRequestStream();

        // Send the data.
        newStream.Write(data, 0, data.Length);
        newStream.Close();

        HttpWebResponse myResponse = (HttpWebResponse)myRequest.GetResponse();
        Stream responseBody = myResponse.GetResponseStream();

        Encoding encode = System.Text.Encoding.GetEncoding("utf-8");
        StreamReader readStream = new StreamReader(responseBody, encode);

        //returned from Google Analytics API
        string response = readStream.ReadToEnd();

        //get the data we need
        string[] auth = response.Split(new string[] { "Auth=" }, StringSplitOptions.None);
        
        //return it (the authorization token)
        return auth[1];
    }

    //used when you have authenticated on Google (via AuthSub & query params) & have a temp token
    public static string getSessionTokenAuthSub(string tempToken)
    {
        string response = GArequestResponseHelper("https://www.google.com/accounts/AuthSubSessionToken", tempToken, mode.AuthSub);
        Debug.WriteLine("getting this far");
        Debug.WriteLine("perm token=" + response.Split('=')[1]);
        //temp (once off) token will have been exchanged for session token, return it
        return response.Split('=')[1];
    }

    public static NameValueCollection getAccountInfo(string sessionToken, mode mode)
    {
        string response = GArequestResponseHelper("https://www.google.com/analytics/feeds/accounts/default", sessionToken, mode);

        //response will contain an XML formatted string similar to
        //http://code.google.com/p/ga-api-http-samples/source/browse/trunk/src/v1/accountFeedResponse.xml

        //we need to convert it to proper XML for parsing
        XmlDocument accountinfoXML = new XmlDocument(); accountinfoXML.LoadXml(response);

        //each account/profile combo the current user is authorized for will an 'entry' element
        XmlNodeList entries = accountinfoXML.GetElementsByTagName("entry");

        NameValueCollection profiles = new NameValueCollection();
        for (int i = 0; i < entries.Count; i++)
        {
            //profile name, profile ID - profile ID is needed for ID what data you want from the API
            profiles.Add(entries.Item(i).ChildNodes[2].InnerText,entries.Item(i).ChildNodes[6].Attributes["value"].Value);
        }

        return profiles;
    }

    public static string getContentOverviewData(string sessionToken, string profileID, mode mode)
    {
        //we'll also want to pass in non hardcoded dates and report specifiers
        //month in format yyyy-mm-dd etc. 
        //At the moment we just getting pageview metric for our sites URLs
        //for the purposes of demostration

        string response = GArequestResponseHelper("https://www.google.com/analytics/feeds/data?ids=ga:" + profileID + "&dimensions=ga:pageTitle&metrics=ga:pageviews&sort=-ga:pageviews&start-date=" + DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd") + "&end-date=" + DateTime.Now.ToString("yyyy-MM-dd") + "&prettyprint=true&max-results=20", sessionToken, mode);

        //response will contain an XML formatted string similar to
        //http://code.google.com/p/ga-api-http-samples/source/browse/trunk/src/v1/dataFeedResponse.xml

        return response;
    }

    public static string getContentOverViewDataByTime(string sessionToken, string profileID, mode mode)
    {
        return "";
    }

    public static string getTrafficSourcesOverviewData(string sessionToken, string profileID, mode mode)
    {
        string response = GArequestResponseHelper("https://www.google.com/analytics/feeds/data?ids=ga:" + profileID + "&dimensions=ga:source&metrics=ga:pageviews&sort=-ga:pageviews&start-date=" + DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd") + "&end-date=" + DateTime.Now.ToString("yyyy-MM-dd") + "&prettyprint=true&max-results=10", sessionToken, mode);

        return response;
    }

    public static string getMapOverlayData(string sessionToken, string profileID, mode mode)
    {
        string response = GArequestResponseHelper("https://www.google.com/analytics/feeds/data?ids=ga:" + profileID + "&dimensions=ga:country&metrics=ga:pageviews&sort=-ga:pageviews&start-date=" + DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd") + "&end-date=" + DateTime.Now.ToString("yyyy-MM-dd") + "&prettyprint=true&max-results=100", sessionToken, mode);

        return response;
    }

    public static string getVisitsData(string sessionToken, string profileID, mode mode)
    {
        string response = GArequestResponseHelper("https://www.google.com/analytics/feeds/data?ids=ga:" + profileID + "&metrics=ga:visitors&start-date=" + DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd") + "&end-date=" + DateTime.Now.ToString("yyyy-MM-dd") + "&prettyprint=true&max-results=100", sessionToken, mode);

        return response;
    }

    public static string getPageViewsData(string sessionToken, string profileID, mode mode)
    {
        string response = GArequestResponseHelper("https://www.google.com/analytics/feeds/data?ids=ga:" + profileID + "&metrics=ga:pageviews&start-date=" + DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd") + "&end-date=" + DateTime.Now.ToString("yyyy-MM-dd") + "&prettyprint=true&max-results=100", sessionToken, mode);

        return response;
    }

    public static string getPagesPerVisitData(string sessionToken, string profileID, mode mode)
    {
        string response = GArequestResponseHelper("https://www.google.com/analytics/feeds/data?ids=ga:" + profileID + "&metrics=ga:uniquePageviews,ga:visits&start-date=" + DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd") + "&end-date=" + DateTime.Now.ToString("yyyy-MM-dd") + "&prettyprint=true&max-results=100", sessionToken, mode);

        return response;
    }

    public static string getBounceRateData(string sessionToken, string profileID, mode mode)
    {
        string response = GArequestResponseHelper("https://www.google.com/analytics/feeds/data?ids=ga:" + profileID + "&metrics=ga:bounces,ga:entrances&start-date=" + DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd") + "&end-date=" + DateTime.Now.ToString("yyyy-MM-dd") + "&prettyprint=true&max-results=100", sessionToken, mode);

        return response;
    }

    public static string getAvgTimeOnSiteData(string sessionToken, string profileID, mode mode)
    {
        string response = GArequestResponseHelper("https://www.google.com/analytics/feeds/data?ids=ga:" + profileID + "&metrics=ga:timeOnSite,ga:visits&start-date=" + DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd") + "&end-date=" + DateTime.Now.ToString("yyyy-MM-dd") + "&prettyprint=true&max-results=100", sessionToken, mode);

        return response;
    }

    public static string getNewVisitsData(string sessionToken, string profileID, mode mode)
    {
        string response = GArequestResponseHelper("https://www.google.com/analytics/feeds/data?ids=ga:" + profileID + "&metrics=ga:newVisits,ga:visits&start-date=" + DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd") + "&end-date=" + DateTime.Now.ToString("yyyy-MM-dd") + "&prettyprint=true&max-results=100", sessionToken, mode);

        return response;
    }

    public static string getVisitsPerDayData(string sessionToken, string profileID, mode mode)
    {
        string response = GArequestResponseHelper("https://www.google.com/analytics/feeds/data?ids=ga:" + profileID + "&dimensions=ga:day&metrics=ga:visits&start-date=" + DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd") + "&end-date=" + DateTime.Now.ToString("yyyy-MM-dd") + "&prettyprint=true&max-results=100", sessionToken, mode);

        return response;
    }

    public static string GArequestResponseHelper(string url, string token, mode mode)
    {
        HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create(url);
        
        //will always be a token of some sort required in the header but the format
        //it is passed in will depend on what type of authorization is being used
        if (mode == mode.ClientLogin)
        { 
            myRequest.Headers.Add("Authorization: GoogleLogin auth=" + token);
        }
        else if (mode == mode.AuthSub)
        { 
            myRequest.Headers.Add("Authorization: AuthSub token=" + token);
        }

        //obviously you need some kind of try/catch here
        //but OK to bubble auth/connection failures up for demo
        HttpWebResponse myResponse = (HttpWebResponse)myRequest.GetResponse();
        Stream responseBody = myResponse.GetResponseStream();

        Encoding encode = System.Text.Encoding.GetEncoding("utf-8");
        StreamReader readStream = new StreamReader(responseBody, encode);

        //return string itself (easier to work with)
        return readStream.ReadToEnd();
    }
}
```

I then created a page to display the data. The markup is as follows:

```html
<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <link href="<%=ResolveClientUrl("~/_support/css/table.css") %>" rel="stylesheet" type="text/css" />
    <script src="http://www.google.com/jsapi" type="text/javascript"></script>
    <script type="text/javascript">
        google.load("visualization", "1", { packages: ["corechart"] });
        google.setOnLoadCallback(drawChart);
        function drawChart() {
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Source');
            data.addColumn('number', 'Visits');
            <%=ChartData %>

            var chart = new google.visualization.PieChart(document.getElementById('traffic_chart_div'));
            chart.draw(data, { width: 550, height: 400, title: 'Traffic Sources' });
        }
    </script>
    <script type='text/javascript'>
        google.load('visualization', '1', { 'packages': ['geomap'] });
        google.setOnLoadCallback(drawMap);

        function drawMap() {
            var data = new google.visualization.DataTable();
            data.addRows(<%=MapCount %>);
            data.addColumn('string', 'Country');
            data.addColumn('number', 'Visits');
            <%=MapOverlay %>

            var options = {};
            options['dataMode'] = 'regions';

            var container = document.getElementById('map_canvas');
            var geomap = new google.visualization.GeoMap(container);
            geomap.draw(data, options);
        };
  </script>
  <script type="text/javascript">
      google.load("visualization", "1", { packages: ["corechart"] });
      google.setOnLoadCallback(drawChart);
      function drawChart() {
          var data = new google.visualization.DataTable();
          data.addColumn('string', 'Day');
          data.addColumn('number', 'Visits');
          <%=VisitsData %>

          var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
          chart.draw(data, { width: 600, height: 350, title: 'Visits per Day' });
      }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<h2 id="page-heading">Google Analytics</h2>
<div class="grid_16">
    <p><a href="/Admin">Back to Admin</a></p>
    <p>This is an overview of analytic data from Google Analytics from the past 30 days.  If you would like to view the full reports visit <a href="http://google.com/analytics" rel="external">Google Analytics</a>.</p>
    <div class="box">
        <h2>Visits</h2>
        <div class="block">
            <div id="chart_div" style="margin-left:150px"></div>
        </div>
    </div>
    <div class="box">
        <h2>Site Usage</h2>
        <table>
            <thead>
                <tr>
                    <th scope="col">Metric</th>
                    <th scope="col">Value</th>
                </tr>
            </thead>
            <tbody>
            <tr><td>Visits</td><td><asp:Literal ID="Literal1" runat="server"></asp:Literal></td></tr>
            <tr><td>Pageviews</td><td><asp:Literal ID="Literal2" runat="server"></asp:Literal></td></tr>
            <tr><td>Pages/Visit</td><td><asp:Literal ID="Literal3" runat="server"></asp:Literal></td></tr>
            <tr><td>Bounce Rate</td><td><asp:Literal ID="Literal4" runat="server"></asp:Literal></td></tr>
            <tr><td>Average Time on Site</td><td><asp:Literal ID="Literal5" runat="server"></asp:Literal></td></tr>
            <tr><td>New Visits</td><td><asp:Literal ID="Literal6" runat="server"></asp:Literal></td></tr>
            </tbody>
        </table>
    </div>
    <div class="box">
        <h2>Map Overlay</h2>
        <div class="block">
            <div id='map_canvas' style="margin-left:150px;"></div>
        </div>
    </div>
    <div class="box">
        <h2>Traffic Sources Overview</h2>
        <div class="block">
            <div id="traffic_chart_div" style="margin-left:150px;"></div>
        </div>
    </div>
    <div class="box">
        <h2>Content Overview</h2>
            <asp:GridView ID="GridView1" runat="server" DataKeyNames="id" AutoGenerateColumns="false">
                <Columns>
                    <asp:BoundField HeaderText="Page Title" DataField="pageTitle" />
                    <asp:BoundField HeaderText="Page Views" DataField="pageViews" />
                </Columns>
            </asp:GridView>
    </div>
</div>
</asp:Content>
```

I use a very hack-ish method of injecting data into my javascript functions, there is no doubt a better way of doing this (AJAX), but I wrote this a good amount of time ago before I knew better.

Now for the meat and bones that really make all of this work together. Here is the code behind:

```csharp
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Xml;
using System.Data;
using System.Globalization;

public partial class admin_Analytics : System.Web.UI.Page
{
    public string ChartData;
    public string MapOverlay;
    public int MapCount;
    public string VisitsData;

    protected void Page_Load(object sender, EventArgs e)
    {
        //resultsXML.Save(Server.MapPath("../") + "\\files\\test.xml");
        string token = GoogleAnalytics.getSessionTokenClientLogin(ConfigurationManager.AppSettings["AnalyticsLogin"], ConfigurationManager.AppSettings["AnalyticsPassword"]);
        Session["token"] = token;

        LoadVisits();
        LoadSiteUsage();
        LoadMapOverlay();
        LoadTrafficSourcesOverview();
        LoadContentOverview();
    }

    protected void LoadVisits()
    {
        string results = GoogleAnalytics.getVisitsPerDayData(Session["token"].ToString(), ConfigurationManager.AppSettings["AnalyticsProfileID"], GoogleAnalytics.mode.ClientLogin);
        //we need to convert it to proper XML for parsing
        XmlDocument resultsXML = new XmlDocument(); resultsXML.LoadXml(results);

        //each line/record return from the API will be contained in an 'entry' element
        XmlNodeList entries = resultsXML.GetElementsByTagName("entry");

        VisitsData += "data.addRows(" + entries.Count + ");";

        int i = 0;
        foreach (XmlNode node in entries)
        {
            DateTime time = DateTime.Now.AddDays(-31 + Convert.ToInt32(node.ChildNodes[4].Attributes["value"].Value));
            VisitsData += "data.setValue(" + i + ", 0, '" + time.ToShortDateString() + "');";
            VisitsData += "data.setValue(" + i + ", 1, " + node.ChildNodes[5].Attributes["value"].Value + ");";
            i++;
        }
    }

    protected void LoadSiteUsage()
    {
        string results = GoogleAnalytics.getVisitsData(Session["token"].ToString(), ConfigurationManager.AppSettings["AnalyticsProfileID"], GoogleAnalytics.mode.ClientLogin);
        //we need to convert it to proper XML for parsing
        XmlDocument resultsXML = new XmlDocument(); resultsXML.LoadXml(results);

        //each line/record return from the API will be contained in an 'entry' element
        XmlNodeList entries = resultsXML.GetElementsByTagName("entry");

        Literal1.Text = entries[0].ChildNodes[4].Attributes["value"].Value;

        results = GoogleAnalytics.getPageViewsData(Session["token"].ToString(), ConfigurationManager.AppSettings["AnalyticsProfileID"], GoogleAnalytics.mode.ClientLogin);
        resultsXML = new XmlDocument(); resultsXML.LoadXml(results);
        entries = resultsXML.GetElementsByTagName("entry");

        Literal2.Text = entries[0].ChildNodes[4].Attributes["value"].Value;

        results = GoogleAnalytics.getPagesPerVisitData(Session["token"].ToString(), ConfigurationManager.AppSettings["AnalyticsProfileID"], GoogleAnalytics.mode.ClientLogin);
        resultsXML = new XmlDocument(); resultsXML.LoadXml(results);
        entries = resultsXML.GetElementsByTagName("entry");

        Literal3.Text = (Convert.ToDouble(entries[0].ChildNodes[4].Attributes["value"].Value) / Convert.ToDouble(entries[0].ChildNodes[5].Attributes["value"].Value)).ToString();

        results = GoogleAnalytics.getBounceRateData(Session["token"].ToString(), ConfigurationManager.AppSettings["AnalyticsProfileID"], GoogleAnalytics.mode.ClientLogin);
        resultsXML = new XmlDocument(); resultsXML.LoadXml(results);
        entries = resultsXML.GetElementsByTagName("entry");

        Literal4.Text = (Convert.ToDouble(entries[0].ChildNodes[4].Attributes["value"].Value) / Convert.ToDouble(entries[0].ChildNodes[5].Attributes["value"].Value)).ToString("0.##%", CultureInfo.CurrentCulture);

        results = GoogleAnalytics.getAvgTimeOnSiteData(Session["token"].ToString(), ConfigurationManager.AppSettings["AnalyticsProfileID"], GoogleAnalytics.mode.ClientLogin);
        resultsXML = new XmlDocument(); resultsXML.LoadXml(results);
        entries = resultsXML.GetElementsByTagName("entry");

        TimeSpan t = TimeSpan.FromSeconds(Convert.ToDouble(entries[0].ChildNodes[4].Attributes["value"].Value) / Convert.ToDouble(entries[0].ChildNodes[5].Attributes["value"].Value));

        Literal5.Text = string.Format("{0:D2}:{1:D2}:{2:D2}", t.Hours, t.Minutes, t.Seconds);

        results = GoogleAnalytics.getNewVisitsData(Session["token"].ToString(), ConfigurationManager.AppSettings["AnalyticsProfileID"], GoogleAnalytics.mode.ClientLogin);
        resultsXML = new XmlDocument(); resultsXML.LoadXml(results);
        entries = resultsXML.GetElementsByTagName("entry");

        Literal6.Text = (Convert.ToDouble(entries[0].ChildNodes[4].Attributes["value"].Value) / Convert.ToDouble(entries[0].ChildNodes[5].Attributes["value"].Value)).ToString("0.##%", CultureInfo.CurrentCulture);
    }

    protected void LoadMapOverlay()
    {
        string results = GoogleAnalytics.getMapOverlayData(Session["token"].ToString(), ConfigurationManager.AppSettings["AnalyticsProfileID"], GoogleAnalytics.mode.ClientLogin);
        //we need to convert it to proper XML for parsing
        XmlDocument resultsXML = new XmlDocument(); resultsXML.LoadXml(results);

        //each line/record return from the API will be contained in an 'entry' element
        XmlNodeList entries = resultsXML.GetElementsByTagName("entry");

        MapCount = entries.Count;

        int i = 0;
        foreach (XmlNode node in entries)
        {
            MapOverlay += "data.setValue(" + i + ", 0, '" + node.ChildNodes[4].Attributes["value"].Value + "');";
            MapOverlay += "data.setValue(" + i + ", 1, " + node.ChildNodes[5].Attributes["value"].Value + ");";
            i++;
        }
    }

    protected void LoadTrafficSourcesOverview()
    {
        string results = GoogleAnalytics.getTrafficSourcesOverviewData(Session["token"].ToString(), ConfigurationManager.AppSettings["AnalyticsProfileID"], GoogleAnalytics.mode.ClientLogin);
        //we need to convert it to proper XML for parsing
        XmlDocument resultsXML = new XmlDocument(); resultsXML.LoadXml(results);

        //each line/record return from the API will be contained in an 'entry' element
        XmlNodeList entries = resultsXML.GetElementsByTagName("entry");

        ChartData += "data.addRows(" + entries.Count + ");";

        int i = 0;
        foreach (XmlNode node in entries)
        {
            ChartData += "data.setValue(" + i + ", 0, '" + node.ChildNodes[4].Attributes["value"].Value + "');";
            ChartData += "data.setValue(" + i + ", 1, " + node.ChildNodes[5].Attributes["value"].Value + ");";
            i++;
        }
    }

    protected void LoadContentOverview()
    {
        string results = GoogleAnalytics.getContentOverviewData(Session["token"].ToString(), ConfigurationManager.AppSettings["AnalyticsProfileID"], GoogleAnalytics.mode.ClientLogin);
        //we need to convert it to proper XML for parsing
        XmlDocument resultsXML = new XmlDocument(); resultsXML.LoadXml(results);

        //each line/record return from the API will be contained in an 'entry' element
        XmlNodeList entries = resultsXML.GetElementsByTagName("entry");

        DataTable table;
        table = MakeContentOverviewTable();

        foreach (XmlNode node in entries)
        {
            DataRow row = table.NewRow();

            row["pageTitle"] = node.ChildNodes[4].Attributes["value"].Value;
            row["pageViews"] = node.ChildNodes[5].Attributes["value"].Value;

            table.Rows.Add(row);
        }

        GridView1.DataSource = table;
        GridView1.DataBind();
    }

    private DataTable MakeContentOverviewTable()
    {
        DataTable ContentOverview = new DataTable("ContentOverview");

        DataColumn idColumn = new DataColumn();
        idColumn.DataType = System.Type.GetType("System.Int32");
        idColumn.ColumnName = "id";
        idColumn.AutoIncrement = true;
        ContentOverview.Columns.Add(idColumn);

        DataColumn pageTitle = new DataColumn();
        pageTitle.DataType = System.Type.GetType("System.String");
        pageTitle.ColumnName = "pageTitle";
        ContentOverview.Columns.Add(pageTitle);

        DataColumn pageViews = new DataColumn();
        pageViews.DataType = System.Type.GetType("System.Int32");
        pageViews.ColumnName = "pageViews";
        ContentOverview.Columns.Add(pageViews);

        return ContentOverview;
    }
}
```

All you need to do at this point is make sure that you have the following lines in the Web.Config:

```xml
<appSettings>
	<add key="AnalyticsLogin" value="login@goeshere.com"/>
	<add key="AnalyticsPassword" value="1337P4ssw0rdH3r3"/>
	<add key="AnalyticsProfileID" value="123456789"/>
</appSettings>
```