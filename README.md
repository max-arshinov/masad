# A minimal approach to software architecture documentation

An example of the approach [proposed by Simon Brown](https://dev.to/simonbrown/a-minimal-approach-to-software-architecture-documentation-4k6k) built with [Structurizr Lite](https://github.com/structurizr/lite).


## How to run
- `docker compose up -d`
- Open web browser and go to [`http://localhost:8081/`](http://localhost:8081/)

## How to use Structurizr Lite
- Check [`http://localhost:8081/workspace/diagrams`](http://localhost:8081/workspace/diagrams) for diagrams
- Check [`http://localhost:8081/workspace/documentation/Internet%20Banking%20System`](http://localhost:8081/workspace/documentation/Internet%20Banking%20System) for documentation
- Check [`http://localhost:8081/workspace/decisions/Internet%20Banking%20System`](http://localhost:8081/workspace/decisions/Internet%20Banking%20System) for [ADRs](https://github.com/npryce/adr-tools)

##
- [Arc42](https://arc42.org/overview) docs are in `internet-banking-system/docs`
- [ADRs](https://github.com/npryce/adr-tools) are in `internet-banking-system/adrs`

## docToolChain

[docToolChain](https://github.com/docToolchain/docToolchain) is an implementation of the docs-as-code approach for software architecture. The basis of docToolchain is the philosophy that software documentation should be treated in the same way as code together with the arc42 template for software architecture.

![docToolChain](https://camo.githubusercontent.com/51aa243c71a36dba275cd24060ed053d882260104832c10a88279641c5c10e23/68747470733a2f2f646f63746f6f6c636861696e2e6769746875622e696f2f646f63546f6f6c636861696e2f76322e302e782f696d616765732f65612f4d616e75616c2f4f76657276696577322e706e67)

## Notes for Confluence users

- If you consider to use confluence, the [asciidoc2confluence](https://github.com/rdmueller/asciidoc2confluence) script might be helpful.