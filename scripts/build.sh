#!/bin/bash
cd ../src
(cat core.sql && python filler-generation.py) > ../initialize.sql
cd ../scripts
