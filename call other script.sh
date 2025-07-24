#!/bin/bash

course="Devops from current script"

echo "Before calling other script course:$course"
echo "Process instance id of current script:$$"

./'normal calling script.sh'

echo "After calling other script course:$course"
echo "Process instance id of current script:$$"