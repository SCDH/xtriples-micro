#!/usr/bin/env -S sed -f

# run this on a scenario file to fix editor variables

s/\${pdu}/${framework(XTriples)}/g
