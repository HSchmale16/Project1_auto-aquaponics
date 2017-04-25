#!/bin/bash
# Performs the update for the system

git pull
npm install
sudo systemctl restart aqua-sensord.service
sudo systemctl restart aqua-webapp.service
