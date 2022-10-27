#!/bin/bash
cd ../src
(cat core.sql && python3 filler_generation.py) > ../initialize.sql
cd ../scripts
