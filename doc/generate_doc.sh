#! /bin/bash

###
# generate_doc.sh
# This script run ldoc o generate documentation.
# The script should be started from the root of the repository (.. from here)
# . doc/generate_doc.sh
###


# remove old generated documentation
rm -R build/doc

# generate doc
ldoc -c doc/config.ld .

# copy ressources to generated directly
mkdir -p build/doc/documentation/images
cp images/demo.gif build/doc/documentation/images/demo.gif
