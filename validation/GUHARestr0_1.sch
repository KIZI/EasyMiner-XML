<?xml version="1.0" encoding="UTF-8"?>
<!-- 
This schematron schema checks, whether the GUHA PMML document complies with LISp-Miner/SEWEBAR restrictions.
Specifically, the three tier DBA structure must be enforced.

-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron">
    <ns uri="http://keg.vse.cz/ns/GUHA0.1rev1" prefix="guha"/>
    <ns uri="http://keg.vse.cz/ns/GUHA0.1rev1" prefix="pmml"/>    
    <pattern>
        <let name="RuleLevelIDs" value="//@antecedent | //@consequent | //@condition"/>
        <let name="nonLiteralDBA" value="//DBA[@literal='false' or not(@literal)]/@id"/>
        <let name="nonLiteralDBAthatIsARulePart" value="//DBA[(@literal='false' or not(@literal)) and (@id=//@antecedent or @id=//@consequent  or @id=//@condition)]/@id"/>
        <let name="nonLiteralDBAthatIsNotARulePart" value="//DBA[(@literal='false' or not(@literal)) and not(@id=//@antecedent or @id=//@consequent  or @id=//@condition)]/@id"/>
        <let name="literalDBA" value="//DBA[@literal='true']/@id"/>
        <let name="BBAs" value="//BBA/@id"/>
        <rule context="AssociationRule">
            
            <assert test="@antecedent=../DBA/@id[@literal='false' or not(@literal)] or not(@antecedent)">
               AR must reference a non-literal DBA
            </assert>
            <assert test="@consequent=../DBA/@id[@literal='false' or not(@literal)]">
                AR must reference a non-literal DBA
            </assert>
            <assert test="@condition=../DBA/@id[@literal='false' or not(@literal)] or not(@condition)">
                AR must reference a non-literal DBA
            </assert>
        </rule>
        
        <rule context="DBA[(@literal='false' or not(@literal)) and (@id=//@antecedent or @id=//@consequent  or @id=//@condition)]">
            <assert test="BARef=$nonLiteralDBAthatIsNotARulePart">
                A rule part level DBA must reference a non-literal DBA
            </assert>            
            <assert test="@connective='Conjunction'">
                A non-rule part non-literal level DBA must have Conjunction connective
            </assert>
            
        </rule>
        <rule context="DBA[(@literal='false' or not(@literal)) and not(@id=//@antecedent or @id=//@consequent  or @id=//@condition)]">
            <assert test="BARef=$literalDBA">
                A non-rule part non-literal level DBA must reference a literal DBA
            </assert>            
            <assert test="@connective='Conjunction' or @connective='Disjunction'">
                A non-rule part non-literal level DBA must not have Negation connective
            </assert>
        </rule>
        <rule context="DBA[(@literal='true')]">
            <assert test="BARef=$BBAs">
                Literal DBA must reference a BBA
            </assert>
            <assert test="@connective='Conjunction' or @connective='Negation'">
                Literal DBA must have Conjunction od Disjunction connective (negation not allowed) 
            </assert>
        </rule>
    </pattern>
</schema>