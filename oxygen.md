# Oxygen Framework

## Installation

It's **not** required to clone the repository for using the XTriples
Oxygen framework. It's installable with a few clicks by using the
following link:

```
https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/xtriples-micro/descriptor.xml
```

Paste this link into the field **Show add-ons from** of the dialog
**Install new add-ons** that is accessible from the Oxygen's main
menu's **Help** entry. The dialog looks like this:

![Dialog for adding a new add-on (Different URL
here!)](images/ox-install-new-addons.png)

After clicking **Next&gt;**, do not forget to check the **I accept all
terms of the end user license** on the next dialogue and hit
**Next&gt;** again. You will then be warned that the XTriples
framework is not signed with a signature. That's OK, we haven't
implemented the signing yet in our deployment pipeline. Just click
**Continue anyway**.

![Continue, albeit a signature is
missing](images/ox-missing-signature.png)

The installation is done now. The XTriples framework is ready to use,
after restarting the Oxygen editor.

## Editing an XTriples Configuration

### The Template

The framework provides a template for XTriples configuration
files. You can get it when creating a new file be it in Oxygen's
project view (file manager) or via the white sheet in the toolbar or
via the main menu's **File** entry. Just start typing "xtriples" in
the top file type filter – like in this screenshot. Then select the
XTriples configuration from the list of templates and fill in the file
name below.

![Create a new XTriples configuration file from a
template](images/ox-new-file2.png)

### Content Completion

The framework makes Oxygen offer you content completion when editing
the file:

![Oxygen knows which elements and attributs names are allowed in a
specfic context and offers you completion
options](ox-content-completion.png)

## Evaluating the XTriples Configuration

The framework comes with transformation scenarios for evaluating your
XTriples configuration by the XTriples processor, which is based on
XSLT. What they do is explained in the
[README](readme.md#extracting-rdf-triples)

![Transformation scenarios](images/ox-transformation-scenarios.png)

These three scenarios can be applied on XTriples configuration files.

The framework also provides XSLT stylesheets, that can be applied on
an XML source input file. However, the framework can not offer a
transformation scenario for these stylesheets, because the framework
is not active when editing other files than XTriples
configurations. If it was provided in the framework, such a scenario
would not be accessible when editing the XML source file. But we can
offer a scenario, that you can import into your project on at the user
level. These transformation scenarios are in
[`xtriples.scenarios`](xtriples.scenarios) You can [import these
scenarios](https://www.oxygenxml.com/doc/versions/27.1/ug-editor/topics/import-export-global-scenarios.html)
to your project.
