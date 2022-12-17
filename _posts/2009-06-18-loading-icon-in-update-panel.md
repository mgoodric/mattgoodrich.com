---
title:  "Loading Icon in Update Panel"
categories: 
  - DotNet
tags:
  - loading-icon
  - update-panel
  - asp.net
---

I was recently having problems getting the loading GIF to show up when I was updating my UpdatePanel.  This is the solution I came up with to get it working.

```javascript
<rts:realtimesearchmonitor runat="server" ID="RealTimeReleaseSearch" Interval="700" AssociatedUpdatePanelID="ResultsUpdatePanel">
  <ControlsToMonitor>
    <rts:ControlMonitorParameter TargetId="TextBox1" EventName="TextChanged" />
  </ControlsToMonitor>
</rts:realtimesearchmonitor>
<asp:UpdatePanel ID="ResultsUpdatePanel" runat="server">
  <ContentTemplate>
    <div style="text-align:center;">
      <asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="ResultsUpdatePanel" DynamicLayout="true">
        <ProgressTemplate>
          <img src="support/images/loading.gif" />
        </ProgressTemplate>
      </asp:UpdateProgress>
    </div>
    <div id="releases">
      <MC:CustomRepeater id="Repeater1" runat="server">
        <HeaderTemplate>
          <ul>
        </HeaderTemplate>
        <ItemTemplate>
          <li>
            HTML HERE
          </li>
        </ItemTemplate>
        <EmptyTemplate>
          <li>No results matched your query.</li>
        </EmptyTemplate>
        <FooterTemplate>
          </ul>
        </FooterTemplate>
      </MC:CustomRepeater>
    </div>
  </ContentTemplate>
</asp:UpdatePanel>
<script type="text/javascript">
  Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(BeginRequestHandler);
  Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);

  var prm = Sys.WebForms.PageRequestManager.getInstance();
  function BeginRequestHandler(sender, args) {
    var elem = args.get_postBackElement();
    var prm = Sys.WebForms.PageRequestManager.getInstance();

    // First set associatedUpdatePanelId to non existant control
    // this will force the updateprogress not to try and show itself.

    var o = $find('<%= UpdateProgress1.ClientID %>');
    o.set_associatedUpdatePanelId('Non_Existant_Control_Id');

    // Then based on the control ID, show the updateprogress
    //if (elem.id == '<%= TextBox1.ClientID %>')
    // {
    document.getElementById("releases").style.display = "none";

    var updateProgress1 = $get('<%= UpdateProgress1.ClientID %>');
    updateProgress1.style.display = '';

    //}
  }
  
  function EndRequestHandler(sender, args) {
    var updateProgress1 = $get('<%= UpdateProgress1.ClientID %>');

    updateProgress1.style.display = (updateProgress1.style.display == '') ? 'none' : '';
  }
</script> 
```

The javascript at the bottom determines when the updatepanel is being refreshed, and uses two handlers to change the css of the page to show my loading gif.
