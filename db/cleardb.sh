#!/bin/bash
# Removes the database and recreates it
# Henry J Schmale
# 01-12-2017

rm database.sqlite
sqlite3 database.sqlite < db.sql
