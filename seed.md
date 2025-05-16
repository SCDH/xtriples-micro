# Deployment on a Microservice

## Passing the configuration, not a URI

When the XSLT stylesheets are deployed on a web service, it would be
inconvenient, to first put the configuration at some accessible
location, where the service can get it from. The stylesheets therefore
provide some means of passing the configuration directly.

Unfortunately, passing the configuration as a XML string to a
stylesheet parameter does not work due to escaping problems. So we
need some kind of encoding/decoding mechanism.


### base64 encoded string

The cleanest solution is passing the configuration as a base64 encoded
string using the `config-b64` stylesheet parameter. Let's test this
locally:

```shell
target/bin/xslt.sh -xsl:xsl/extract.xsl -s:$(realpath test/gods/1.xml) config-b64=$(cat test/gods/configuration.xml.b64)
```

Or without an intermediate base64 file:

```shell
target/bin/xslt.sh -xsl:xsl/extract.xsl -s:$(realpath test/gods/1.xml) config-b64=$(base64 -w 0 test/gods/configuration.xml)
```


Probably, you will get an error message `decoding of base64 encoded
strings not available`, because the because the function
[`bin:decode-string`](https://www.saxonica.com/documentation12/index.html#!functions/expath-binary/decode-string)
from the binary extension package is not available on Saxon-HE. Try it
in Oxygen, which comes with Saxon-PE, and it works.

Same on your microservice: If the function `bin:decode-string#1` is
not available, this approach will fail.


### array of codepoints

When decoding base64 encoded files using
[`bin:decode-string`](https://www.saxonica.com/documentation12/index.html#!functions/expath-binary/decode-string)
is not an option, then passing the configuration as an array of
integers representing unicode codepoints is the resort. You can pass
such an array to the `config-codepoints` stylesheet parameter. Note
the `?` in front of the parameter `?config-codepoints=...`, that makes
Saxon interpret the value as an XPath expression.

Again, let's test this locally:

```shell
target/bin/xslt.sh -xsl:xsl/extract.xsl -s:$(realpath test/gods/1.xml) ?config-codepoints=$(cat test/gods/configuration.xml.json)
```

You generate such an array of codepoints using the
`xsl/to-codepoints.xsl` stylesheet:

```
target/bin/xslt.sh -xsl:xsl/to-codepoints.xsl -it input=$(realpath test/gods/configuration.xml)
```
