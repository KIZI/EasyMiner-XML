For use with Web service XML upload

This folder contains an XSD file which checks, whether an XML document is a PMML document. The check is less thorough than the PMML XML Schema to allow for "slightly" violating PMML documents to enter the system. 

Once an XML file passes the XSD check, the webservice uploader takes the XSL transform with the same name and applies it to correct minor errors. 

