---
title:  "Empty Item Template for asp:Repeater"
categories: 
  - DotNet
tags:
  - repeater
  - empty-template
  - asp.net
---

The default repeater control does not come with a case for when the datasource is null or empty.  This presented somewhat of a problem for me, so I figured I would post my solution so that others could make this change as well. I have uploaded the dll file, you can download it at the end of this post.
	 
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