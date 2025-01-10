+++
date = '2009-04-05T12:00:00-07:00'
draft = false
title = 'Implementing a Custom Repeater Control with Empty Data Handling in ASP.NET'
aliases = ['/dotnet/empty-item-template-for-asp-repeater/']
summary = "I was looking for a way to handle empty data in my repeater control, and I found that creating a custom repeater class with an EmptyTemplate property achieves this. With this solution, I can now easily display a custom message when the data source is null or empty."
genres = ['Development', '.NET Framework']
tags = ['repeatercontrol', 'emptydatatemplate', 'customclass', 'aspnet']
[params]
  author = 'Matt Goodrich'
+++

The default repeater control does not come with a case for when the data source is null or empty.  This presented somewhat of a problem for me, so I figured I would post my solution so that others could make this change as well. 
	 
```csharp
[ToolboxData("<{0}:CustomRepeater runat=server></{0}:CustomRepeater>")]
public class CustomRepeater : Repeater
{
	    #region Public Properties

	    [Category("Data")]
	    [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
	    [PersistenceMode(PersistenceMode.InnerProperty)]

	    public ITemplate EmptyTemplate
	    {
	        get;
	        set;    
	    }
	
	    #endregion
	
        #region Protected Overrides Methods
    
        protected override void CreateChildControls()
        {
            base.CreateChildControls();
            HandleEmptyData();
        }
        protected override void  OnDataBinding(EventArgs e)
        {
            base.OnDataBinding(e);
            HandleEmptyData();
        }
    
        #endregion

        #region Private Methods

        private void HandleEmptyData()
        {
            if (this.Items.Count <= 0 && EmptyTemplate != null)
            {
               this.Controls.Clear();
                HeaderTemplate.InstantiateIn(this);
                EmptyTemplate.InstantiateIn(this);
                FooterTemplate.InstantiateIn(this);
            }
        }

        #endregion
}
```

After compiling this into a bin it can be implemented in the following way:

```html
<%@ Register TagPrefix="MC" Namespace="MyControls" Assembly="MyControls" %>

<!--HTML Goes here-->

<form runat=”server”>
    <MC:CustomRepeater id="Repeater1" runat="server">
        <HeaderTemplate>
            <!--Stuff Here - Maybe a ul-->
        </HeaderTemplate>
        <ItemTemplate>
            <li>
                Normal stuff here
            </li>
        </ItemTemplate>
        <EmptyTemplate>
            <li>No results matched your query.</li>
        </EmptyTemplate>
        <FooterTemplate>
            <!--Stuff Here -->
        </FooterTemplate>
    </MC:CustomRepeater>
</form>
```