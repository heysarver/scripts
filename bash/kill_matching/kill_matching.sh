#!/bin/bash

kill_matching() {
    local pattern=$1
    # Match processes that contain the pattern followed by ".py" or not.
    ps aux | grep -i "${pattern}" | grep -v grep | awk '{print $2}' | xargs -r kill -9
}
