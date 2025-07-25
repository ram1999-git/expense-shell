#!/bin/bash

course="Devops from current script"

echo "Before calling script, Course:$course"
echo "Process Instance ID of the script is:$$"

./Other-script.sh

echo "After calling script,course:$course"