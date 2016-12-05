# xml-to-json
An XML to JSON converter intended for use in [Enonic CMS](https://enonic.com/docs/4.7/developer-guide.html)
The template is intended for filtering the XML returned from a datasource and converting it to JSON.
A probable use-case is to create an endpoint that returns the datasource as JSON for use from frontend code.

## How to use
1. [Create a new portlet:](https://enonic.com/docs/4.7/portlets.html)
 * [Use this file](xml-to-json-converter.xsl) as the portlet XSL
 * [Configure the datasource](https://enonic.com/docs/4.7/datasources.html) you want to return
 * Set filtering options in the portlet parameters([see 'inlcude-frame' and 'frame-heading' params here](https://enonic.com/docs/4.7/portlets.html#Portlets-GeneralPane)) to filter what you want to return (normally way too much data is returned in the datasource). (Defaults in paranthesis)
   - exclude-context (true) - Remove the context node that is always included in datasources
    - data-only (false) - Only return the content node
    - minified (false) - Filter away the location, binaries and relatedcontentkeys nodes in the content node
    - contentdata-only (false) - Only return the data in the contentdata, which is the data entered by an editor in the content form
2. Note that you have to use a page template which returns a JSON document, not any normal template that returns HTML. It may be possible to get just the portlet-document, though, but this has not been tested...

## Open source
This code is licenced under the MIT licence, which basically means "help yourself". The code has been tested a while in production, but there are some edge-cases that are not handled. (Though they have not been encountered in Enonic CMS 4.7 so far.)

Also, please note that this code is based upon being used in Enonic CMS. I might create a more general template later, and welcome anyone wanting to contribute to making this code better.
