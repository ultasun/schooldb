#!/bin/bash
cd ../src
(cat core.sql && python filler-generation.py) | mysql -u root -p

