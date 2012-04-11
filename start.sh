#!/bin/sh
# NOTE: mustache templates need \ because they are not awesome.
exec erl -pa ebin edit deps/*/ebin -boot start_sasl \
    -setcookie aaa \
    -s erlmc \
    +K true +P 10240000 \
    $*
