+++
date = '2010-07-02T12:00:00-07:00'
draft = false
title = 'Creating a Simple Function to Get a Short URL with Bit.ly API'
aliases = ['/dotnet/short-urls-bitly-csharp/']
summary = "I wanted a quick and easy way to get a short URL for my blog posts, so I used the bit.ly API and created a simple function in C# to handle it. With this function, you can easily shorten any URL by passing it as an argument."
genres = ['Development']
tags = ['bitly', 'api', 'c-sharp', 'url-shortener']
[params]
  author = 'Matt Goodrich'
+++

I wanted a simple function to get a short URL for anytime I created a new blog post. I went with bit.ly because it seems to be the most widely used, and their API seems to be well documented.

To use the bit.ly API, you will need authentication credentials. These will be supplied as query arguments. If you do not have a free bit.ly user account, you can sign up at [http://bit.ly/account/register](http://bit.ly/account/register). After you have your account created you will need to get an API key. You should be able to get a key at [http://bit.ly/a/your_api_key](http://bit.ly/a/your_api_key).

After you have these things, its time to start coding. I have only created a single function to do this, as I do not require any additional functionality.

```csharp
public class Bitly
{
	public static String GetShortenedURL(String inURL)
    {
        String shortURL = "";
        String queryURL = "http://api.bit.ly/shorten?version=2.0.1&longUrl=" + inURL + "&login=usernamehere&apiKey=keyhere";

        HttpWebRequest request = WebRequest.Create(queryURL) as HttpWebRequest;

        using (HttpWebResponse response = request.GetResponse() as HttpWebResponse)
        {
            StreamReader reader = new StreamReader(response.GetResponseStream());
            String jsonResults = reader.ReadToEnd();
            int indexOfBefore = jsonResults.IndexOf("shortUrl\": \"") + 12;
            int indexOfAfter = jsonResults.IndexOf("\"", indexOfBefore);
            shortURL = jsonResults.Substring(indexOfBefore, indexOfAfter - indexOfBefore);
        }

        return shortURL;
    }
}
```

You will just need to change the "usernamehere" and "keyhere" in the queryURL function with your username and API Key. Additionally you can put them in your AppSettings in your web.config and load them that way.