# Architecture As Code: Architect, Decide, Document

“[Diagrams as code](https://www.thoughtworks.com/radar/techniques/diagrams-as-code)” is an approach where you use a programming language to describe and generate diagrams. Just like how developers define and manage infrastructure using code, diagrams as code allows developers to generate, manage, and maintain visual diagrams using code.
Diagrams-as-code tools are suited for long-term documentation as they can be checked into source control with version history.

This repository contains a blueprint of the
architecture-as-code toolchain [proposed by Simon Brown](https://dev.to/simonbrown/a-minimal-approach-to-software-architecture-documentation-4k6k). It expands the “diagrams as code” concept with “software architecture documentation as code” and “architecture decision records as code” extensions. 

The blueprint toolchain blah-blah

1. Diagrams (C4, deployment, and runtime) built with [Structurizr Lite](https://github.com/structurizr/lite) 
2. Software Architecture Documentation built with pragmatic, free and open source [arc42 template](https://arc42.org/overview)
3. [Lightweight Architecture Decision Records](https://www.thoughtworks.com/en-es/radar/techniques/lightweight-architecture-decision-records) built with [ADR Tools](https://github.com/npryce/adr-tools)

![](img/structurizr.png)

### 1. Diagrams As Code
https://dev.to/simonbrown/diagrams-as-code-2-0-82k

#### [Live Demo](https://structurizr.com/share/36141/diagrams#SystemContext)

[Structurizr](https://structurizr.com/) builds upon “[diagrams as code](https://www.thoughtworks.com/radar/techniques/diagrams-as-code)”, allowing you to create *multiple software
architecture diagrams* from a *single model*.
There are a number of tools for creating Structurizr compatible workspaces, with
the [Structurizr DSL](https://github.com/structurizr/dsl)
being the recommended option for most teams.
This Structurizr DSL example creates two diagrams, based upon a single set of elements and relationships.

---

```
workspace {

    model {
        user = person "User"
        softwareSystem = softwareSystem "Software System" {
            webapp = container "Web Application" {
                user -> this "Uses"
            }
            container "Database" {
                webapp -> this "Reads from and writes to"
            }
        }
    }

    views {
        systemContext softwareSystem {
            include *
            autolayout lr
        }

        container softwareSystem {
            include *
            autolayout lr
        }

        theme default
    }
```

---

![Context](https://static.structurizr.com/img/help/multiple-diagrams-1.png)

---

![Container](https://static.structurizr.com/img/help/multiple-diagrams-2.png)

### 2. Software Architecture Documentation

#### [Live Demo](https://structurizr.com/share/31/documentation/Financial%20Risk%20System#context)


Because the code doesn't tell the whole story, Structurizr provides support for lightweight supplementary technical
documentation. The documentation is a collection of Markdown or AsciiDoc files, one per section, which are rendered in
the web browser. This blueprint uses [arc42](https://arc42.org/overview) template because it:
- is based on practical experience of many systems in various domains, from information and web systems, real-time and embedded to business intelligence and data warehouses;
- supports arbitrary technologies and tools;
- is completely process-agnostic, and especially well-suited for lean and agile development approaches;
- is open-source and can be used free of charge, in commercial and private situations.

![](https://arc42.org/images/arc42-overview-V8.png)

### 3. Lightweight Architecture Decision Records

#### [Live Demo](https://structurizr.com/share/31/decisions/Financial%20Risk%20System)

Because diagrams alone can't express the decisions that led to a solution, Structurizr allows you to supplement your
software architecture model with a decision log,
captured as a collection of lightweight Architecture Decision Records (ADRs)
[as described by Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions),
and featured on
the [ThoughtWorks Technology Radar](https://www.thoughtworks.com/radar/techniques/lightweight-architecture-decision-records).

Structurizr allows you to publish your ADRs to allow team members get an "at a glance" view of the current set of ADRs,
along with facilities to make navigating them easier.

## How to run

- `docker compose up -d`
- Open web browser and go to [`http://localhost:8081/`](http://localhost:8081/)

## How to use Structurizr Lite

- Check [`http://localhost:8081/workspace/diagrams`](http://localhost:8081/workspace/diagrams) for diagrams
- Check [`http://localhost:8081/workspace/documentation/Internet%20Banking%20System`](http://localhost:8081/workspace/documentation/Internet%20Banking%20System)
for documentation
- Check [`http://localhost:8081/workspace/decisions/Internet%20Banking%20System`](http://localhost:8081/workspace/decisions/Internet%20Banking%20System)
for [ADRs](https://github.com/npryce/adr-tools)
- Check [language reference](https://github.com/structurizr/dsl/blob/master/docs/language-reference.md) for dsl syntax
- Check [Getting started with Structurizr Lite](https://dev.to/simonbrown/getting-started-with-structurizr-lite-27d0)
  for more details
- Watch two talks at the bottom of the [C4 FAQ](https://c4model.com/#FAQ)
- [Arc42](https://arc42.org/overview) docs are in `internet-banking-system/docs`
- [ADRs](https://github.com/npryce/adr-tools) are in `internet-banking-system/adrs`

## What can I use this template for?
- Presale
- Project discovery
- Ongoing architecture documentation for your system

## Export & Integrations

### docToolChain

[docToolChain](https://github.com/docToolchain/docToolchain) is an implementation of the docs-as-code approach for
software architecture. The basis of docToolchain is the philosophy that software documentation should be treated in the
same way as code together with the arc42 template for software architecture.

![docToolChain](https://camo.githubusercontent.com/51aa243c71a36dba275cd24060ed053d882260104832c10a88279641c5c10e23/68747470733a2f2f646f63746f6f6c636861696e2e6769746875622e696f2f646f63546f6f6c636861696e2f76322e302e782f696d616765732f65612f4d616e75616c2f4f76657276696577322e706e67)

### Notes for Confluence users

- If you consider to use confluence, the [asciidoc2confluence](https://github.com/rdmueller/asciidoc2confluence) script
  might be helpful.
- https://structurizr.atlassian.net/wiki/spaces/demo/overview
- https://arc42-template.atlassian.net/wiki/spaces/ARC42/overview?homepageId=1579772
- https://github.com/structurizr/atlassian-confluence-server

#### Alternatives