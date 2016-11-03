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

# URI format

There should be two one URI provided to access the resource this could be like the github raw urls:

```
https://raw.githubusercontent.com/owner/repo/commit/releaseNotes/ReleaseNotes_0.0.2.md
```

if thats not avaliable maybe something else but it should contain:

* repo location
* commit
* path


```
git://<host>/path/to/git/repo?commit=3a78b0ed90a77ac5aac4c7d0200d454838ec34c9&path=src/Makefile
```
this is not a standard but it contains whats needed. So if the scheme was changed to `intogit` then thats our scheme which is pretty easy to decode.

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

```bash
204d3da7075ea02dd49d22a8871b8327cdbb039d
5582df5e5c6d765cb776616f649812a0be22f116
3a78b0ed90a77ac5aac4c7d0200d454838ec34c9
925d3f1a38aa5e5892d1a900594dfe2817db502c
54cb78af0a367135a6d1ab321be52f4c8e111880
```

* `git show --pretty="format: %H" --name-status $commit` get changes in the commit per file

```bash
39ddeb02323d0d4f7f7baaedabe941db80c94d10
A       .gitignore
A       back-up-hooks.sh
A       hooks/post-commit
```

* `git rev-parse HEAD` current SHA1

```bash
204d3da7075ea02dd49d22a8871b8327cdbb039d
```

* `git config --get remote.origin.url` remote url like: `git@github.com:lausdahl/tracability-test.git`
* `git config user.name` get user name
* `git config user.email` get user email
* `git log -1 --format=%cd HEAD` get datetime of commit

```bash
Wed Nov 2 13:50:20 2016 +0100
```

* `git log -1 --pretty=%B HEAD` get commit message

```bash
udpated readme with new message types and commands

```

* `git --no-pager show -s --format='%an <%ae>' HEAD` get username and email of commit

```bash
Kenneth Lausdahl <lausdahl@some.domain>
```

* `git rev-list HEAD -- filename` show history of this file second line is last version or `git log --follow --format='%H' HEAD -- post-commit`

```bash
f46152d5f57a77c62966d8c44c23676688ba1122
acf6e19ef80a97c2f84838856c08727a9414d9a4
b03d900ee86ac6d011e94c5d4be16136c12501ab
39ddeb02323d0d4f7f7baaedabe941db80c94d10
```

* `git ls-tree -r HEAD~1` get blobs in commit

```bash
100644 blob a5a3854643e960b37178578085fac2ae4a3cc239	.gitignore
100755 blob f2a11625510192ea64b56ef407139d5874309233	back-up-hooks.sh
100644 blob 1a2de88845fe6605239dd7d7de03ac9de450a185	hooks/oslc-template.json
100755 blob 41802e4c5bb43c65c99657d33501f31b64994ce2	hooks/post-commit
100755 blob 187878d1c03010f0b7105f99ab86cff314665b19	install-hooks.sh
100755 blob eada36c92e0c6d4defff15ed586fb28013ef51c4	p.sh
100644 blob 31d8baee2a064ea35569c85fa2144169b4e6a9a6	readme.md
100644 blob d687e04848b7b78b41b08e418a76d7be85b6d024	test1.txt
```


# pandoc

```bash
cat README.md | pandoc -f markdown_github | browser
```
