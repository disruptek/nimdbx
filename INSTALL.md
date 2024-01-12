# How To Do A Thing (on Linux x86_64)

The process depicted here looks like this:
- install git-nim, which pulls in nightly compiler distributions
- install a specific version of nimble, which kinda-sorta works
- install nimph, which delegates to that nimble
- clone nimdbx and its dependencies
- setup nimterop wrapper generator
- build the balls test runner
- generate the wrapper and save it to cache
- run the tests

## compiler
Install all the nims, plus gitnim, and put them in the $PATH.
This will take a minute.
```
$ cd /somewhere
$ git clone https://github.com/nim-works/gitnim nims
$ cd nims
$ export PATH=`pwd`/bin:$PATH
```
Build git-nim, update the distribution, select the 1.9.3 compiler.
This will take a minute.
```
$ nim c gitnim/gitnim.nim
cutelog.nim(47, 3) Warning: 'Lock levels' are deprecated, now a noop [Deprecated]
cutelog.nim(92, 5) Warning: 'Lock levels' are deprecated, now a noop [Deprecated]
gitnim.nim(55, 3) Hint: gitnim uses the following binary releases: [User]
gitnim.nim(56, 3) Hint: https://github.com/nim-lang/nightlies [User]
gitnim.nim(57, 3) Hint: via setting the $NIM_BINS, or [User]
gitnim.nim(58, 3) Hint: via passing --define:binsURL="..." [User]
gitnim.nim(59, 3) Hint: gitnim uses the following distribution url: [User]
gitnim.nim(60, 3) Hint: https://github.com/disruptek/dist [User]
gitnim.nim(61, 3) Hint: via setting the $NIM_DIST, or [User]
gitnim.nim(62, 3) Hint: via passing --define:distURL="..." [User]
Hint: mm: orc; threads: on; opt: none (DEBUG BUILD, `-d:release` generates faster code)
66233 lines; 0.626s; 109.547MiB peakmem; proj: gitnim; out: git-nim [SuccessX]
$ git nim
git-nim against https://github.com/nim-works/gitnim
refreshing available Nim releases...
refreshing the 1.9.3 distribution...
(no updates)
--------------------------------------------------------------------
specify a branch; eg. `git nim 1.2.2` or `git nim origin/1.0.7`:
* 1.9.3                   daf81105e update gitnim
  remotes/origin/1.0.11   544224108 update dist
  remotes/origin/1.2.14   b5e0bb0bf release 2021-11-08
  remotes/origin/1.4.9    0364c5513 nightly 2021-10-28
  remotes/origin/1.5.1    a514d8918 nightly 2021-10-18
  remotes/origin/1.6.11   60e3fe364 nightly 2022-12-02
  remotes/origin/1.7.3    04b5e7f08 nightly 2022-12-14
  remotes/origin/1.7.3arc fb9c0ec3f atomic rc
  remotes/origin/1.9.3    daf81105e update gitnim
  remotes/origin/2.0.3    ac79bee4f nightly 2023-01-10
  remotes/origin/2.1.1    90e9462b9 nightly 2023-01-06
  remotes/origin/HEAD     -> origin/1.9.3
  remotes/origin/gh-pages 1ebc81546 Deploy to GitHub pages
  remotes/origin/master   1834b90e8 let it work on earlier gits

or you can specify one of these tags; eg. `git nim latest`:
atomicrc        devel with atomic refs
devel           nightly development build
latest          latest release
stable          stable production release
traces          this one has working stack traces
version-1-0     1.0
version-1-2     1.2
version-1-4     1.4
version-1-6     1.6
version-2-0     2.0
$ git nim 1.9.3
git-nim against https://github.com/nim-works/gitnim

Nim Compiler Version 1.9.3 [Linux: amd64]
Compiled at 2023-05-26
Copyright (c) 2006-2023 by Andreas Rumpf

git hash: 0eb508e43405662eaddf113aba171119623d6bdb
active boot switches: -d:release
```

## package manager
Install nimble-0.12.0, which pre-dates later insanity.
```
$ cd /somewhere
$ git clone https://github.com/nim-lang/nimble.git
$ cd nimble
$ git checkout v0.12.0
$ nim c --out=nimble src/nimble.nim
$ export PATH=`pwd`:$PATH
```

Install a working package manager.
```
$ cd /somewhere/else
$ git clone https://github.com/disruptek/nimph
$ ./bootstrap-nonimble.sh
$ export PATH=`pwd`:$PATH
```

## database
Now we're ready to mess with projects.
```
$ cd /somewhere/else
$ git clone git@github.com:uncommoncorrelation/nimdbx.git
$ cd nimdbx
```

We want to use "local dependencies" so that the requirements of this
project don't taint the requirements of any other, because the compiler's
interpretation of the dependencies which satisfy any given `import` statement
don't necessarily coincide with those of Nimble.

```
$ cat > nim.cfg
# set a local cache directory for nimterop (wrapper generator) reasons
# and locate it adjacent to this configuration file
--nimcache="$config/cache"
# zero out the compiler's idea of where dependencies might live
--clearNimblePath
# tell the compiler where to discover dependencies using its own methodology
# and locate them adjacent to this configuration file
--nimblePath="$config/deps/pkgs/"
# let tests or programs we write here import directly from this project
--path="$config/"
# put the binaries in a place where we can subsequently remove/ignore them
--outdir="$config/bin"
^D
```
Make the missing directories.
```
$ mkdir --parents deps/pkgs
```
Run the package manager.
```
$ nimph doctor
👭cloning https://github.com/genotrance/nimterop...
rolled to #v0.6.13 to meet nimterop>=0.6.13
👭cloning https://github.com/disruptek/balls.git...
rolled to #4.0.20 to meet https://github.com/disruptek/balls>=4.0.0
👍environment changed; re-examining dependencies...
👭cloning https://github.com/nitely/nim-regex...
rolled to #v0.24.1 to meet regex>=0.15.0
👭cloning https://github.com/c-blake/cligen.git...
rolled to #1.6.17 to meet cligen>=1.0.0
👭cloning https://github.com/disruptek/grok.git...
rolled to #0.6.4 to meet https://github.com/disruptek/grok>=0.5.0
👭cloning https://github.com/disruptek/ups.git...
rolled to #0.0.9 to meet https://github.com/disruptek/ups<1.0.0
👭cloning https://github.com/disruptek/insideout.git...
rolled to #582a614af257347edd3b9710da9ecfde9be1a8bf to meet https://github.com/disruptek/insideout**
👍environment changed; re-examining dependencies...
👭cloning https://github.com/nitely/nim-unicodedb...
rolled to #0.12.0 to meet unicodedb>=0.7.2
👭cloning https://github.com/zevv/npeg...
rolled to #1.2.1 to meet npeg>=0.23.2
👭cloning https://github.com/nim-works/cps.git...
rolled to #0.9.1 to meet https://github.com/nim-works/cps**
👍environment changed; re-examining dependencies...
nimdbx-#3ac02f1c8cf1ce418f9a7176fcd2c97783bdab6f repository has been modified
👌nimdbx version 0.4.1 lookin' good
```

## wrapper
Build the wrapper generator.
```
$ pushd deps/pkgs/nimterop*
$ nim c --define:release --out=nimterop/toast nimterop/toast.nim
$ nim c --define:release --out=nimterop/build/loaf nimterop/loaf.nim
$ popd
```
Check that everything looks legit.
```
$ nimph
  e97965       nimdbx   repoint deps
  adec8b     nimterop   hack something i cannot be bothered to grok
 v0.24.1        regex   bump to 0.24.1
  0.12.0    unicodedb   readme
  1.6.17       cligen   Bump versions pre-release
  4.0.20        balls   4.0.20
   0.6.4         grok   comment operator
   0.0.9          ups   0.0.9
   1.2.1         npeg   bumped 1.2.1
  582a61    insideout   try fixing valgrind install (#4)
   0.9.1          cps   support nim-2.1.1
```
Build the library using clang, so it will work, and build only the library, so
it will work.
```
$ export CC=clang
$ pushd libmdbx-dist
$ make lib
$ popd
```
Try to build a test so that the wrapper generator runs and caches its work
in the `cache` subdirectory.
```
$ nim c tests/test1_data.nim
```

## testing

Make sure you have a balls binary, in case this is your first time using it,
and put our local binaries directory in your $PATH.
```
$ pushd deps/pkgs/balls*
$ nim c balls.nim
$ popd
$ export PATH=`pwd`/bin:$PATH
```
Now you can finally run all the tests using `balls`.  If you have valgrind
installed, memcheck/helgrind/drd will run as well.  Otherwise, the C
compiler sanitizers will be substituted instead.
```
$ balls
nim-1.9.3                          refc  m&s  arc  orc  vm  js
    tests/test1_Data  c   release              🔴
    tests/test1_Data  c    danger              🔴
    tests/test1_Data  c  memcheck              ❔
    tests/test1_Data  c  helgrind              ❔
    tests/test1_Data  c       drd              ❔
tests/test2_Database  c   release              🟢
tests/test2_Database  c    danger              🔴
tests/test2_Database  c  memcheck              ❔
tests/test2_Database  c  helgrind              ❔
tests/test2_Database  c       drd              ❔
   tests/test3_Index  c   release              🔴
   tests/test3_Index  c    danger              🔴
   tests/test3_Index  c  memcheck              ❔
   tests/test3_Index  c  helgrind              ❔
   tests/test3_Index  c       drd              ❔
```
