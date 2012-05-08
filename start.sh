#!/bin/sh
# NOTE: mustache templates need \ because they are not awesome.
exec erl -pa  deps/*/ebin  apps/*/ebin  -boot start_sasl \
    -setcookie aaa \
    -s erlmc \
    +K true +P 10240000 \
    $*
