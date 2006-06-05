# Copyright (C) 2004 - 2006 John Goerzen <jgoerzen@complete.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

.PHONY: all hugsbuild
all: setup			# GHC build
	./setup configure
	./setup build

hugsbuild: setup
	./setup configure --hugs
	./setup build

setup: Setup.lhs HSH.cabal
	ghc -package Cabal Setup.lhs -o setup

.PHONY: doc
doc: setup
	-rm -rf html
	./setup configure
	./setup haddock
	mv dist/doc/html .

.PHONY: hugsbuild


clean:
	-./setup clean
	-rm -rf html `find . -name "*.o"` `find . -name "*.hi"` \
		`find . -name "*~"` *.a setup dist testsrc/runtests \
		local-pkg doctmp
	-rm -rf testtmp/*
	-cd doc && $(MAKE) clean

.PHONY: local-pkg
local-pkg: all
	echo "[" > local-pkg
	cat .installed-pkg-config >> local-pkg
	echo "]" >> local-pkg

testsrc/runtests: all 
	cd testsrc && ../dist/build/testsrc/runtests

test-ghc6: testsrc/runtests

.PHONY: testsrc/runtests test-ghc6 test

test-hugs: hugsbuild
	runhugs -98 +o -P$(PWD)/dist/build:$(PWD)/testsrc: testsrc/runtests.hs

interact-hugs:
	hugs -98 +o -P$(PWD)/dist/build:

interact-ghci: all
	ghci -idist/build -Ldist/build $(GHCPARMS)

interact: interact-hugs

test: test-ghc6
