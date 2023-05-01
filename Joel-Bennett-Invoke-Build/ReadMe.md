---
title: "Invoke-Build: PowerShell in CI/CD"
license: "CC-BY-SA 4.0"
theme: simple
highlightTheme: nnfx-dark # nnfx-light # foundation  # school-book #
transition: convex
hashOneBasedIndex: true
controls: true
controlsLayout: edges
progress: true
showSlideNumber: speaker
fragments: true
---

# Invoke-Build
## PowerShell in CI/CD
### Building, Testing, and Deploying

Joel "Jaykul" Bennett

https://github.com/Jaykul/DevOps2023

note: Welcome to my talk on Invoke-Build and using PowerShell in CI/CD -- I am Joel Bennett, also known as Jaykul, and today I'm not here to talk about one of my side-projects, but instead to talk about what I spend too much time on **at work**: building, testing, and deploying software ... and trying to make sure our builds "just work" as often as possible.

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
---

note: In case you don't know who I am, here's a little bit about me. I'm Joel Bennett, I'm from upstate New York by way of the grasslands of Guanacaste, Costa Rica. I have been "Jaykul" (pronounced J. Cool) online since the 1990s, and I'm currently the Principal DevOps Engineer at loanDepot! Let's see, what else... I am Bilingual, I am Battle Faction, I am blessed. I use He/Him pronouns. I am a 14 time Microsoft MVP, a Christian, an open source programmer, a ... really helpful guy. You can find me on GitHub (and from there, everywhere).


# About Me
note:
- Joel "Jaykul" Bennett
- Principal DevOps Engineer @ loanDepot
- [PoshCode.org](https://PoshCode.org): [/discord](https://discord.gg/PowerShell), [/slack](https://poshcode.org/slack), [/irc](https://poshcode.org/irc)
- [fosstodon.org/@jaykul](https://fosstodon.org/@jaykul) (and [Twitter](https://twitter.com/Jaykul))
- [github.com/Jaykul](https://github.com/Jaykul) (also [PoshCode](https://github.com/PoshCode))


![About Me:An Image of my Github Profile](images/github.png)

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat"
-->
--

<!-- .slide: data-background="url(images/github.png) bottom 0px left 0px/100% 100% no-repeat" -->

note:  You can find me on Discord, Mastodon, and Twitter (sometimes), as well as GitHub, and I'm always happy to talk about PowerShell, Programming, DevOps, silly origin stories, etc.<br/> But TODAY, I want to talk about CI/CD automation.

---

# The Goal:

### Always Use the Same Workflow.<br/>
### Iterate Faster.

- The Edge
- The Cloud
- Containers? {.fragment .fade-in-then-out }

note: Here's the goal: We want to always use the same workflow, so we can iterate faster.
<br/><br/>
As a developer, and now as a DevOps engineer, I've always hated doing work twice. I don't want to write build instructions or build scripts for developers to use on their laptops, and then still have to create a completely separate process for my continuous integration testing environment.
<br/><br/>
What I really want is a CI system that will let me run my build and test workflows locally -- the same way that I run them on the server or "in the cloud." The industry is {{BUMP}} starting to get here, but more on that later. For now, I am settling for a local system that works when I call it in the cloud (in my CI pipelines).
<br/><br/>
Let's clarify a couple of terms...

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
---

# The Edge

Your workstation, laptop, or cloud-hosted container.

A fast loop is critical for productivity.

Skip what's already done.

note: So let's start at the edge. In this case we're talking about the place where the code gets written. Whether that's a laptop, a beefy workstation, or a cloud-hosted dev container. The bottom line is that you need to be able to quickly rebuild and test your code **locally** on the environment where you're authoring it.

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
---

# The Cloud

Your Continuous Integration environment.

Github Workflows, Azure Pipelines, Jenkins, Gitlab, CruiseControl, TeamCity, AppVeyor, whatever.

Always from scratch, status/progress reporting is key.

note: And let's go to the cloud. In this case, maybe not so much cloud, as server. But I'm calling it cloud to emphasize the ephemeral nature. The thing that makes cloud CI/CD servers different than your local workstation is that they are always starting from scratch. No code, no package cache, maybe not even the right compiler.

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
---

# Building on the Edge {.r-fit-text }

[nightroman/invoke-build](https://github.com/nightroman/Invoke-Build) { style="font-size: 1.5em;" }

[.../wiki/Build-Scripts-in-Projects](https://github.com/nightroman/Invoke-Build/wiki/Build-Scripts-in-Projects):

- PSReadline, PSES, PSRule, etc.
- 1.8k results on github
- 1.3m downloads
- Last Update 3/2023

note: So why Invoke-Build? There are many tools for local builds, including a few PowerShell modules. But Invoke-Build is one of the oldest PowerShell modules still in active development (dating back to _at least_ 2012). It's popular, and used by a lot of companies, including Microsoft...
<br/><br/>
You can see the stats here: eighteen-hundred builds scripts on github, over a million downloads just from the PowerShell Gallery (which didn't even exist when this project started), and -- as I said -- it's still being actively developed.
<br/><br/>
One note of caution (and I'll apologize to Roman for saying this, but): please don't copy Invoke-Build's coding style. It's easily the **least** discoverable PowerShell module. The design predates modules, and it even uses my least favorite verb. It doesn't actually export commands, and Get-Help doesn't even work until you do tricks. So read the docs.
<br/><br/>
Despite all that, we're talking about Invoke-Build because ...

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" data-auto-animate -->
---

# Building on the Edge {.r-fit-text }

[nightroman/invoke-build](https://github.com/nightroman/Invoke-Build) { style="font-size: 1.5em;" }

- **Incremental**: occurring over a series of gradual steps
- **Task Tree**: recursive dependency graph
- **Checkpoint**: save state and resume later
- **File System**: Build root, inputs, and outputs

note: ... it's very good at what it does. You can specify **incremental** tasks with inputs and outputs, and chain them via dependencies, visualize your dependency graph, and more. It even supports checkpoints like the old Windows Workflow.

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" data-auto-animate  -->
---

# SEE CODE {.r-fit-text}
# SEE CODE RUN {.r-fit-text}
# RUN, CODE, RUN {.r-fit-text}

note: This is obviously a play on the kids books, but I wrote it because of the core truth: Our work pattern, as developers is "Code, Run, Code, Run." The sooner you can see the results of running your code, the sooner you begin to iterate, and the faster you can get it right. So let's look at some Invoke-Build code. Maybe we'll come back to more slides later, but I'm not promising anything.

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
--

# SEE CODE

Hopefully you'll not see this slide,
because you'll be watching the demo in person.
`Invoke-Build` will run the default task,
which runs both `restore` and `build` in this case.

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
--

# SEE CODE RUN {.r-fit-text}


```ps1 {data-line-numbers="1|2|7|11|1-11"}
# project.build.ps1
param($Configuration = 'Release')

# The default build:
task . restore, build

task restore { exec { dotnet restore } }

task build   { exec { dotnet build -c $Configuration } }

task clean   { remove bin, obj }
```

note: You can see a few features in this very simple demo:
Invoke-build scripts are just powershell scripts ending in .build.ps1
Parameters to build scripts are available (in script scope) to all tasks
Tasks are basically just functions, but Invoke-Build has additional syntax for expressing dependencies, file system inputs and outputs
There are a few helper functions, I've used two of them here:
exec -- handles checking LastExitCode for us
remove -- remove-item -recurse without failing when they don't exist

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
--


# RUN, CODE, RUN {.r-fit-text}


```ps1 {data-line-numbers="1-8,10|15-23|25-27"}
<#
.SYNOPSIS
    ./project.build.ps1
.NOTES
    0.2.0 - 2021-03-23
    Allow directly invoking the build script
    Expand aliases for maintainability (PSScriptAnalyzer)
#>
param(
    # dotnet build configuration parameter (Debug or Release)
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release'
)

if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
    if (!(Get-Command Invoke-Build -ErrorAction SilentlyContinue)) {
        Install-Module InvokeBuild -Scope CurrentUser -Force
        Import-Module InvokeBuild
    }

    Invoke-Build @PSBoundParameters -File $MyInvocation.MyCommand.Path
    return
}

Add-BuildTask restore {
    Invoke-BuildExec { dotnet restore }
}

Add-BuildTask build restore, {
    Invoke-BuildExec { dotnet build -c $Configuration }
}

Add-BuildTask clean {
    Remove-BuildItem bin, obj
}

Add-BuildTask . restore, build
```

note: We document with comments
We make our build script directly invocable
We expand aliases for maintainability (PSScriptAnalyzer)

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
--

# RUN CODE LESS {.r-fit-text}

## Incremental Builds {.r-fit-text}

note: If you run that build twice, it will restore and build twice.
Make each task incremental, so we skip steps that have already run.
Switch to the hash table syntax and provide inputs and outputs

```ps1
Add-BuildTask DotNetBuild @{
    Inputs  = {
        Get-ChildItem -Recurse -File -Filter *.cs |
            # Exclude generated files in /obj/ folders
            Where-Object FullName -NotMatch "[\\/]obj[\\/]"
    }
    Outputs = {
        Get-ChildItem bin -Recurse -File -Filter *.dll
    }
    Jobs    = {
        exec {
            dotnet build -c $configuration -o bin
        }
    }
}
```

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
---

# Continuous Integration {.r-fit-text}



<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
---

## Start with a [README](README.md)

It's where the next person will look for instructions

note: You probably didn't think documentation would be part of this talk. You wouldn't think I'd need to mention the README! Whether it's on github or in a private corporate repository, the README should be the first thing _and the last thing_ that you write.
<br/><br/>
It's the first thing the next person will look at when they are trying to figure out what this code is for. It's also the only place you can leave a note for yourself about the state of affairs the last time you touched this project.
<br/><br/>
You need to write instructions for building, testing, and installing, especially since your automation won't be foolproof (please don't invest that kind of time!).
<br/><br/>
Make sure you update it whenever you change the dependencies, update the framework, etc.

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->

--

## Have a Bootstrap Script

Help the next person install dependencies.

Each new team member updates it...<br/>
...once they get it to build 😉

note: You really should always document the tools you use and the versions that were in use at the time. Bonus points if you have a script to help people get all the tools they need. This can be a lot easier at work, where you might assume people will have the basic tools (like dotnet), but for the sake of the next person who'll join your team, or your future self when you come back to a project after months on another
<br/>- Be thorough and document the versions you're using.
<br/>- Keep it up to date by having new people use it (or by using it in CI/CD).

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
--

## Keep Your Build.ps1

Even when you write `Project.build.ps1`

Because then you can _always_ run `./build`

note: People aren't that great about actually reading the README, and anything other than "build.ps1" or "build.sh" (or, I guess .bat or .cmd) is going to get missed.
<br/>Don't rely on conventions that are specific to your language, industry, or framework. Especially not with open source projects.
<br/>So even though Invoke-Build uses a dot-build-dot-ps1 -- that file isn't necessarily directly runnable, and if you don't have a build.ps1, people will try to run it.

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
---

# The FUTURE?
## https://earthly.dev/

CI based on BuildKit

- Supports complex build graphs
- Every pipeline runs in containers
- Everything is cached and parallelized
- Builds run the same, everywhere

note: If things had turned out a little differently, I might be giving this talk about Earthly.dev. Earthly is a CI framework that's based on BuildKit. You can use it to run local builds on the edge (whether you're outputting to your working directory, or generating container images), but the builds always run in a container, so like the cloud, it's always clean, and it works the same for everyone. It caches and parallelizes aggressively, so you might actually speed up your builds using it.

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->

---

# Thanks

https://github.com/Jaykul/DevOps2023-Building

<!-- .slide: data-background="url(images/ccbysa.png) bottom 10px left 200px/auto 80px no-repeat, url(images/summit.png) bottom 10px right 10px/auto 80px no-repeat, url(images/pshsummit.svg) bottom 10px left 65%/30% 80px no-repeat, url(images/background.jpg) bottom 0px left 0px/100% 100px no-repeat" -->
