#!/bin/sh

# Copy query to mongo server
scp /home/sshuser/custom-scripts/dashing/cashout.js sshuser@mongo-01b:/home/sshuser/tmp/cashout.js

# Execute query
ssh mongo-01b "mongo s_checkout_prod --quiet /home/sshuser/tmp/cashout.js" > /home/sshuser/custom-scripts/dashing/temp/cashout.json

# Copy file to dev-02 server
scp /home/sshuser/custom-scripts/dashing/temp/cashout.json sshuser@dev-02:/space/dashing/data/cashout.json
