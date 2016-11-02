# Tracability test

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

# Links

- http://open-services.net/bin/view/Main/OSLCCoreSpecJSONExamples
- http://open-services.net/bin/view/Main/OSLCCoreSpecTurtleExamples
- http://open-services.net/bin/view/Main/OSLCCoreSpecRDFXMLExamples
- http://open-services.net/bin/view/Main/OSLCCoreSpecAppendixRepresentations


# new JSON

* base nessage
```json
{
    "rdf:RDF": {
        "xmlns:rdf": "http:\/\/www.w3.org\/1999\/02\/22-rdf-syntax-ns#",
        "xmlns:prov": "http:\/\/www.w3.org\/ns\/prov#",
        "messageFormatVersion": "0.1"
    }
}
```

* an agent
```json
{
    "prov:Agent": [
        {
            "rdf:about": "Agent:My git user",
            "name": "My git user"
        }
    ]
}
```

* a tool
```json
{
    "prov:Entity": {
        "rdf:about": "Entity.softwareTool:Overture:2.4.0",
        "version": "2.4.0",
        "type": "softwareTool",
        "name": "Overture"
    }
}
```

* a source file
```json
{
    "prov:Entity": [
        {
            "rdf:about": "Entity.file:<git-hash>\/path\/to\/file.txt",
            "path": "path\/to\/file.txt",
            "hash": "213123435234",
            "type": "file"
        },
        {
            "rdf:about": "Entity.file:<git-hash>\/path\/to\/file.txt:classA",
            "path": "path\/to\/file.txt",
            "type": "definition"
        }
    ]
}
```

* a source file with internal members
```json
{
    "prov:Entity": [
        {
            "rdf:about": "Entity.file:<git-hash>\/path\/to\/file.txt",
            "path": "path\/to\/file.txt",
            "hash": "213123435234",
            "type": "file",
            "prov:hadMember": {
                "prov:Entity": [
                    {
                        "rdf:about": "Entity.file:<git-hash>\/path\/to\/file.txt:classA"
                    }
                ]
            }
        },
        {
            "rdf:about": "Entity.file:<git-hash>\/path\/to\/file.txt:classA",
            "path": "path\/to\/file.txt",
            "type": "definition"
        }
    ]
}
```


* new version of file `^1` means previous version
```json
{
    "prov:Entity": [
        {
            "rdf:about": "Entity.file:<git-hash>\/path\/to\/file.txt",
            "path": "path\/to\/file.txt",
            "hash": "213123435234",
            "type": "file",
            "prov:wasDerivedFrom": {
                "prov:Entity": [
                    {
                        "rdf:about": "Entity.file:<git-hash^1>\/path\/to\/file.txt"
                    }
                ]
            }
        }
    ]
}
```



# Git commands

* `git rev-list master` get list of SHA1 commit ids since the begining newest first
* `git show --pretty="format: %H" --name-status $commit` get changes in the commit per file

```bash
39ddeb02323d0d4f7f7baaedabe941db80c94d10
A       .gitignore
A       back-up-hooks.sh
A       hooks/post-commit
```

* `git rev-parse HEAD` current SHA1
* `git config --get remote.origin.url` remote url like: `git@github.com:lausdahl/tracability-test.git`
* `git config user.name` get user name
* `git config user.email` get user email
* `git log -1 --format=%cd HEAD` get datetime of commit
* `git log -1 --pretty=%B HEAD` get commit message
* `git --no-pager show -s --format='%an <%ae>' HEAD` get username and email of commit


# pandoc

```bash
cat README.md | pandoc -f markdown_github | browser
```
