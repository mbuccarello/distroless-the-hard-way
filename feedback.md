feedback.md


# new  principles and rules
we need to change the focus of the project and purpose:

The idea of this project must be a mix between "kubernetes the hard way" and "google distroless project" and all the lessons learned in the chainguard blog "this shit is hard".

Mixing the different experience allow new users in this space to learn the pain  on building everything from source without trusting anything.

Like in the "kubernetes the hard way" we need to drive step by step any new user to understand the principles and the process you should face in creating distroless images by yourself in the right way without no security compromise.

Like in "google distroless project" we need to follow the same pattern of different images:

- base image: contains the minimal libraries to allow programs like c c++ go with statically linked libraris working with a minimal attack surface
- cc image: created "FROM BASE" we are adding here all the missing dependency to run interpreter like java python

from base you can create C GO flavor, from cc image you can create JAVA PYTHONG flavor

Like in "this shit is hard " blog series we should try always to use the right approach no matter is painful and time consuming doing stuff, we need to be strict to the chainguard exprience and principles.

we need to be pragmatic and genering the GEMINI.MD should be generic and changed in AGENT.md in this way all the AI can contribute and facilitate documentation and reduce the pain.

we need to remove any reference about distroless-eu and change everything in "distroless the hard way".


# feedback about github actions
.github/workflows/assemble-base.yml

I don't like the usage of alpine to unzip files, we are breaking the principle of zero trust, we must use from scratch and build from source, the same should apply to other commmands like make gcc and so on.

# feedback about cosing

where are the key to sing the image? we are relaying the public transaction log? I don't see any publc private key as a github secret

# feedback about semgrep

what kind of rules are used for static scans? 
Can malcontento from chainguard help to improve the quality of the scans?

# feeedack about  grc registry

What kind of credential are used to push images on that regrisy I don't see any github secret containg those secret

# feedback about documentation 

Does not make any sense describe the iteration between POC and architecture vd, create two separated coumenatuon one for the poc one for the current architecture and make it separed and not related.

# the written content always sounds like AI generated, change the tone use a human tone without emoji

For example the "Zero-Trust Proof Points" makes no sense below we have just the highlevel description of each steps, beside the description of each pipeline steps in each md file isgenere and short 

# mandate and principles

Mandats and priciples should be part of the documentation not only a part of GEMINI.md file, explain principles and idea the main README.md file and other files if required.


# update the AGENT.md

after you did al modification and renamed the GEMINI.md in AGENT.md  make sure that all the new prinicple behavior are documented and written not only in the documentation but also in the AGENT.md, in this way any AI can interact with the right perimeter







