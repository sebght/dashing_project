#!/bin/sh

# Copy query to mongo server
scp /home/sshuser/custom-scripts/dashing/products-selection_fonct.js sshuser@mongo-01b:/home/sshuser/tmp/products-selection_fonct.js

# Execute query
ssh mongo-01b "mongo s_product_prod --quiet /home/sshuser/tmp/products-selection_fonct.js" > /home/sshuser/custom-scripts/dashing/temp/products-selection_fonct.json

# Copy file to dev-02 server
scp /home/sshuser/custom-scripts/dashing/temp/products-selection_fonct.json sshuser@dev-02:/space/dashing/data/products-selection_fonct.json
