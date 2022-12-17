---
title:  "Ajax Popup Control Extender"
categories: 
  - DotNet
tags:
  - ajax
  - popup-control
  - extender
  - asp.net
---

In this post I will explain how to use the Ajax Popup Control Extender.

Recently, I had a need to have a radio button list of images of news outlets for a news system I was writing for Colorado State University. On the backend, the user needed to be able to select a logo for each news outlet out of a list.

In this example I am using a SqlDataSource to store the news outlets, and binding it to an editable GridView, but there are hundreds of ways this could work.

The basic setup was as follows:
```html
<h2>Manage Media Sources</h2>
<asp:GridView ID="GridView1" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" PageSize="10" DataKeyNames="csuinnews_media_id" DataSourceID="SqlDataSource1" OnRowDataBound="GridView1_OnRowDataBound" OnRowDeleting="GridView1_OnRowDeleting" OnRowEditing="GridView1_OnRowEditing">
  <Columns>
    <asp:TemplateField ShowHeader="False" ItemStyle-Width="100px">
      <ItemTemplate>
        <asp:ImageButton ID="LinkButton1" runat="server" CausesValidation="False" CommandName="Edit"ImageUrl="support/images/16-tool-a.png" Text="Edit"></asp:ImageButton>
        <asp:ImageButton ID="LinkButton3" runat="server" CausesValidation="False" CommandName="Delete"ImageUrl="support/images/16-em-cross.png" Text="Delete"></asp:ImageButton>
      </ItemTemplate>
      
      <EditItemTemplate>
        <asp:ImageButton ID="LinkButton1" runat="server" CausesValidation="True" CommandName="Update"ImageUrl="support/images/16-floppy.png" Text="Update"></asp:ImageButton>
        <asp:ImageButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Cancel"ImageUrl="support/images/Cancel.png" Width="16" Height="16" Text="Cancel"></asp:ImageButton>
      </EditItemTemplate>
      
      <ItemStyle Width="75px" />
    </asp:TemplateField>
    
    <asp:BoundField DataField="media_name" HeaderText="Media Name" SortExpression="media_name" />
    
    <asp:BoundField DataField="media_name_display" HeaderText="Media Name (Display)" SortExpression="media_name_display" />
    
    <asp:TemplateField HeaderText="Logo">
      <ItemTemplate>
        <asp:Image ID="Image1" runat="server" ImageUrl='<%#(Eval("media_logo_name")!="" ? Eval("media_logo_name", "~/images/csunews/{0}") : "~/images/csunews/noimg.png")%>' />
      </ItemTemplate>
      <EditItemTemplate>
        <asp:Label ID="Label1" runat="server" Text="Logo"></asp:Label><br />
        <asp:TextBox ID="TextBox1" runat="server" Text='<%#Bind("media_logo_name")%>'></asp:TextBox>

        <br /><br />
         
        <asp:Panel ID="Panel1" runat="server" CssClass="popupControl">
          <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
              <asp:RadioButtonList ID="RadioButtonList1" runat="server" AutoPostBack="true" OnSelectedIndexChanged="RadioButtonList1_OnSelectedIndexChanged" OnSelectedIndexChanged="RadioButtonList1_OnSelectedIndexChanged" RepeatDirection="Horizontal" RepeatColumns="3">
               </asp:RadioButtonList>
             </ContentTemplate>
           </asp:UpdatePanel>
         </asp:Panel>
         <ajaxtoolkit:popupcontrolextender runat="server" TargetControlID="TextBox1" PopupControlID="Panel1" Position="Left" CommitProperty="value" CommitScript="e.value;" ></ajaxtoolkit:popupcontrolextender>
       </EditItemTemplate>
     </asp:TemplateField>
   </Columns>
 </asp:GridView></pre>
```
	
As you can see its very basic to setup. In the EditItemTemplate of the GridView I have a TextBox, a Panel with CssClass of "popupControl", with and update panel inside if it. Inside the update panel is whatever you would like to popup. After the Panel is the line for the PopupControlExtender.

There is some backend code for this control as well.

```csharp
protected void GridView1_OnRowDataBound(object sender, GridViewRowEventArgs e)
{
  if (((e.Row.RowState & DataControlRowState.Edit)>0)&&(e.Row.RowType==DataControlRowType.DataRow))
  {
    string imageBankFolder = "/images/csunews/";
    string[] files = Directory.GetFiles("e:\\users\\path\\wwwroot\\news\\images\\csunews\\");
    RadioButtonList li = (RadioButtonList)e.Row.FindControl("RadioButtonList1");
    if (files != null)
    {
      foreach (string file in files)
      {
        FileInfo f = new FileInfo(file);
        li.Items.Add(new ListItem(String.Format("<img src='{0}'>", imageBankFolder + f.Name), f.Name));
      }
    }
  }
   
  if (e.Row.RowType == DataControlRowType.DataRow)
  {
    // reference the Delete LinkButton
    ImageButton db = (ImageButton)e.Row.FindControl("LinkButton3");
    if (db != null)
      db.OnClientClick = String.Format("return confirm('Are you sure?');");
  }
 }
 protected void RadioButtonList1_OnSelectedIndexChanged(object sender, EventArgs e)
 {
  if (!String.IsNullOrEmpty(RadioButtonList1.SelectedValue))
  {
    PopupControlExtender.GetProxyForCurrentPopup(this.Page).Commit(RadioButtonList1.SelectedValue);
  }
  RadioButtonList1.ClearSelection();
} 
```

Upon clicking edit, it looks just like a normal edit view for a GridView.

![image-center](/assets/images/ajax1.jpg){: .align-center}

However upon clicking the logo textbox, the control becomes visible.

![image-center](/assets/images/ajax2.jpg){: .align-center}

Upon selecting a radio button the filename is displayed in the box, after saving the row changes everything is updated in the database.

![image-center](/assets/images/ajax3.jpg){: .align-center}
