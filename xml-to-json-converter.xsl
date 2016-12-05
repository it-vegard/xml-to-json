<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" xmlns="http://www.w3.org/1999/xhtml" version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:portal="http://www.enonic.com/cms/xslt/portal"
                xmlns:stk="http://www.enonic.com/cms/xslt/stk"
                xmlns:itera="http://itera.no">

    <xsl:import href="/modules/library-stk/json.xsl"/>
    
    <xsl:output method="text"/>

    <xsl:param name="exclude-context" select="'true'"/>
    <xsl:param name="data-only" select="'false'"/>
    <xsl:param name="minified" select="'false'"/>
    <xsl:param name="contentdata-only" select="'false'"/>

    <!-- Filters -->

    <xsl:variable name="node-filter" as="xs:string">
        <xsl:variable name="strict">
            <xsl:text>
                location binaries relatedcontentkeys
            </xsl:text>
        </xsl:variable>
        <xsl:variable name="standard">
            <xsl:text>
                categoryname sectionnames <!-- Deprecated nodes are always excluded -->
                owner modifier assignee assigner assignment-due-date assignment-description name title <!-- Content metadata -->
            </xsl:text>
        </xsl:variable>
        <xsl:variable name="exclusions">
            <xsl:value-of select="if($exclude-context = 'true') then 'context ' else ''"/>
            <xsl:value-of select="if($minified = 'true') then concat($strict, ' ') else ''"/>
            <xsl:value-of select="$standard"/>
        </xsl:variable>
        <xsl:value-of select="concat('|', replace(normalize-space($exclusions), ' ', '|'), '|')"/>
    </xsl:variable>

    <xsl:variable name="attribute-filter" as="xs:string">
        <xsl:variable name="strict">
            <xsl:text>
                direct-membership <!-- Context metadata -->
                resultcount <!-- Contents metadata -->
                created <!-- Content metadata -->
            </xsl:text>
        </xsl:variable>
        <xsl:variable name="standard">
            <xsl:text>
                url qualified-name built-in <!-- Context metadata -->
                totalcount searchcount index count <!-- Contents metadata -->
                unitkey approved state status contenttypekey languagecode languagekey priority publishfrom timestamp is-assigned <!-- Content metadata -->
            </xsl:text>
        </xsl:variable>
        <xsl:variable name="exclusions">
            <xsl:value-of select="if($exclude-context = 'true') then 'context ' else ''"/>
            <xsl:value-of select="if($minified = 'true') then concat($strict, ' ') else ''"/>
            <xsl:value-of select="$standard"/>
        </xsl:variable>
        <xsl:value-of select="concat('|', replace(normalize-space($exclusions), ' ', '|'), '|')"/>
    </xsl:variable>

    <xsl:template match="node()|@*" mode="filter">
        <xsl:choose>
            <xsl:when test="$contentdata-only = 'true' and not(ancestor-or-self::*[name() = 'contentdata'])">
                <xsl:apply-templates select="node()|@*" mode="filter"/>
            </xsl:when>
            <xsl:when test="current()/@deprecated or current()/has-value='false'"/>
            <!--<xsl:when test="$data-only">
                <xsl:copy>
                    <xsl:apply-templates select="node()|@*" mode="filter"/>
                </xsl:copy>
            </xsl:when>-->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="node()|@*" mode="filter"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains($node-filter, concat('|', name(), '|'))]|@*[contains($attribute-filter, concat('|', name(), '|'))]" mode="filter"/>

    <!-- Transform XML to JSON -->

    <xsl:template match="/">
        <xsl:variable name="filtered-xml">
            <xsl:copy>
                <xsl:apply-templates select="*" mode="filter"/>
            </xsl:copy>
        </xsl:variable>
        <xsl:variable name="json">
            <xsl:copy>{
                <xsl:apply-templates select="$filtered-xml" mode="json"/>
            }</xsl:copy>
        </xsl:variable>
        <!--<xsl:value-of select="concat($node-filter, ' \n', $attribute-filter, '\n')"/>-->
        <xsl:value-of select="replace(replace(replace(replace(normalize-space(replace($json, ',,', ',')), ', \}', '}'), '&quot; &quot;', '&quot;, &quot;'), '\} &quot;', '}, &quot;'), '\}&quot;', '}, &quot;')"/>
    </xsl:template>

    <!-- Object or Element property -->
    <xsl:template match="*[count(child::*) > 0 or count(@*) > 0]" mode="json">
        <xsl:variable name="name" select="name(.)"/>
        <xsl:choose>
            <xsl:when test="following-sibling::*[name() = $name] and not(preceding-sibling::*[name() = $name])">"<xsl:value-of select='name()'/>" : [ <xsl:apply-templates select=".|following-sibling::*[name() = $name]" mode="json-object"/> ]<xsl:value-of select="if(following-sibling::* and current() != '') then ',' else ''"/></xsl:when>
            <xsl:when test="preceding-sibling::*[name() = $name]"/>
            <xsl:otherwise>"<xsl:value-of select='name()'/>" : <xsl:apply-templates select="." mode="json-object"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Object or Element properties -->
    <xsl:template match="*" mode="json-object">
        <!--{ <xsl:apply-templates select="@*" mode="json"/><xsl:value-of select="if(@* and *) then ',' else ''"/><xsl:apply-templates select="*" mode="json"/><xsl:value-of select="if((@* or *) and current() != '') then ',' else ''"/><xsl:apply-templates select="text()" mode="json"/> }<xsl:value-of select="if(position() != last()) then ',' else ''"/>-->
        { <xsl:apply-templates select="*|@*|text()" mode="json"/> }<xsl:value-of select="if(position() != last()) then ',' else ''"/>
    </xsl:template>

    <xsl:template match="*[count(child::*) = 0 and count(@*) = 0]" mode="json">
        "<xsl:value-of select="name()"/>" : "<xsl:value-of select="replace(., '&quot;', '\\&quot;')"/>",
    </xsl:template>

    <!-- Attributes -->
    <xsl:template match="@*" mode="json">"<xsl:value-of select="name()"/>" : "<xsl:value-of select="replace(., '&quot;', '\\&quot;')"/>"<xsl:value-of select="if(position() != last()) then ',' else ''"/></xsl:template>

    <!-- Text node -->
    <xsl:template match="text()" mode="json">"#text" : "<xsl:value-of select="replace(., '&quot;', '\\&quot;')"/>"</xsl:template>

    <!-- Special handling of <br/> -->
    <xsl:template match="br" mode="json">
        "br":"",
    </xsl:template>

</xsl:stylesheet>
