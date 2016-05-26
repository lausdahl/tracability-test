

This is a small tracability test

It uses git to issue OSLC commands, that are split into:

- added
- deleted
- modified

It is somehow unclear what most of the information should be mapped to.

When a change is commited the tool issues the OSLC like:

```bash
git commit -m "added +x to install script"
```

The OSLC printet will look like:

```
---------------------------------------------------------------------

OSLC Entry

---------------------------------------------------------------------
{
    "dcterms:content": "added +x to install script",
    "dcterms:creator": {
        "foaf:name": "Kenneth Lausdahl <lausdahl@eng.au.dk>"
    },
    "dcterms:modified": "Thu May 26 23:01:25 2016 +0200",
    "dcterms:title": "Modified",
    "prefixes": {
        "dcterms": "http://purl.org/dc/terms/",
        "foaf": "http://http://xmlns.com/foaf/0.1/",
        "oslc": "http://open-services.net/ns/core#",
        "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    },
    "rdf:about": "github.com/lausdahl/tracability-test/commit/90ec8655cf2c4091a68ae65ae24d7c0b7fef5140/install-hooks.sh",
    "rdf:type": [
        {
            "rdf:resource": "http://open-services.net/ns/bogus/blogs#not-sure-what-this-is"
        }
    ]
}
```


# Setup

to install the tool checkout this repo and run

```bash
./install-hooks.sh 
```

it required *nix bash + python any version


# Submodules + subchanges

The idea is to implement a submodule expander with file lines + a diff tool for the model (Overture).

This will make it possible to detect what part of the model changed and use the commit message for OSLC so no user input will be needed. Only requirement is that the model parses. 
