---
title:  "Short URLs from Bit.ly using C#"
categories: 
  - DotNet
tags:
  - bit.ly
  - asp.net
---

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
