#! /bin/sh
haxe docs/docs.hxml
haxelib run dox -i docs -o pages --title "Plasma Engine Documentation" -ex .*^ -in base/* -in external/* -in funkin/* -in scripting/*